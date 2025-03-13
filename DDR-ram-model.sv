module ddr_memory #(
    parameter ADDR_WIDTH = 28,
    parameter DATA_WIDTH = 64,
    parameter MASK_WIDTH = 8,
    parameter ROW_WIDTH = 16,
    parameter COL_WIDTH = 10,
    parameter BANK_WIDTH = 3
)(
    input  logic                    clk,
    input  logic                    reset_n,
    input  logic                    cs_n,
    input  logic                    ras_n,
    input  logic                    cas_n,
    input  logic                    we_n,
    input  logic [BANK_WIDTH-1:0]  ba,
    input  logic [ROW_WIDTH-1:0]   addr,
    inout  logic [DATA_WIDTH-1:0]  dq,
    inout  logic [MASK_WIDTH-1:0]  dqs,
    input  logic [MASK_WIDTH-1:0]  dm
);
    // Memory array - using associative array for sparse memory simulation
    logic [DATA_WIDTH-1:0] mem_array[int];
    
    // Internal signals
    logic [DATA_WIDTH-1:0] dq_reg;
    logic                  dq_en;
    logic [MASK_WIDTH-1:0] dqs_reg;
    logic                  dqs_en;
    
    // Active row tracking
    logic [ROW_WIDTH-1:0] active_row [2**BANK_WIDTH];
    logic                 row_active [2**BANK_WIDTH];
    
    // Timing parameters (in clock cycles)
    localparam tRCD = 4;  // RAS to CAS delay
    localparam tRP  = 4;  // Precharge period
    localparam tWR  = 4;  // Write recovery time
    localparam CL   = 3;  // CAS latency
    
    // Command decode
    typedef enum logic [3:0] {
        CMD_NOP      = 4'b0111,
        CMD_ACTIVE   = 4'b0011,
        CMD_READ     = 4'b0101,
        CMD_WRITE    = 4'b0100,
        CMD_PRECHARGE = 4'b0010,
        CMD_REFRESH  = 4'b0001
    } cmd_t;
    
    cmd_t current_cmd;
    assign current_cmd = {cs_n, ras_n, cas_n, we_n};
    
    // Timing counters
    int bank_timers[2**BANK_WIDTH];
    
    // Bidirectional bus control
    assign dq  = dq_en  ? dq_reg  : 'z;
    assign dqs = dqs_en ? dqs_reg : 'z;
    
    // Command processing
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            dq_en <= 0;
            dqs_en <= 0;
            dq_reg <= '0;
            dqs_reg <= '0;
            for (int i = 0; i < 2**BANK_WIDTH; i++) begin
                row_active[i] <= 0;
                bank_timers[i] <= 0;
            end
        end else begin
            // Update timers
            for (int i = 0; i < 2**BANK_WIDTH; i++) begin
                if (bank_timers[i] > 0) bank_timers[i]--;
            end
            
            if (!cs_n) begin
                case (current_cmd)
                    CMD_ACTIVE: begin
                        if (bank_timers[ba] == 0) begin
                            row_active[ba] <= 1;
                            active_row[ba] <= addr;
                            bank_timers[ba] <= tRCD;
                        end
                    end
                    
                    CMD_READ: begin
                        if (row_active[ba] && bank_timers[ba] == 0) begin
                            // Read after CAS latency
                            dq_en <= 1;
                            dqs_en <= 1;
                            #(CL * 10);  // Assuming 10ns clock period
                            dq_reg <= mem_array[{ba, active_row[ba], addr}];
                            dqs_reg <= '1;
                            #10 dq_en <= 0;
                            dqs_en <= 0;
                        end
                    end
                    
                    CMD_WRITE: begin
                        if (row_active[ba] && bank_timers[ba] == 0) begin
                            // Write data with mask
                            #10;  // One clock delay for write
                            for (int i = 0; i < MASK_WIDTH; i++) begin
                                if (!dm[i]) begin
                                    mem_array[{ba, active_row[ba], addr}][(i+1)*8-1:i*8] <= dq[(i+1)*8-1:i*8];
                                end
                            end
                            bank_timers[ba] <= tWR;
                        end
                    end
                    
                    CMD_PRECHARGE: begin
                        if (bank_timers[ba] == 0) begin
                            row_active[ba] <= 0;
                            bank_timers[ba] <= tRP;
                        end
                    end
                    
                    default: begin
                        dq_en <= 0;
                        dqs_en <= 0;
                    end
                endcase
            end
        end
    end
    
    // Error checking
    always @(posedge clk) begin
        if (!reset_n) return;
        
        if (!cs_n) begin
            // Check for activate to active time
            if (current_cmd == CMD_ACTIVE && bank_timers[ba] > 0)
                $error("tRCD violation on bank %0d", ba);
                
            // Check for write to precharge time
            if (current_cmd == CMD_PRECHARGE && bank_timers[ba] > 0)
                $error("tWR violation on bank %0d", ba);
                
            // Check for row active requirement
            if ((current_cmd == CMD_READ || current_cmd == CMD_WRITE) && !row_active[ba])
                $error("No row active on bank %0d for read/write", ba);
        end
    end

endmodule
