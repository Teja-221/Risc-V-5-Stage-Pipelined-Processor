module forwarding_unit (
    // Source registers of instruction in EX stage
    input logic [4:0] rs1_ex,
    input logic [4:0] rs2_ex,

    // Destination register of instruction in MEM stage
    input logic [4:0] rd_mem,
    input logic       regwrite_mem,

    // Destination register of instruction in WB stage
    input logic [4:0] rd_wb,
    input logic       regwrite_wb,

    // Forwarding controls
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin

        // Default:
        // 00 = use normal ID/EX register value
        forward_a = 2'b00;
        forward_b = 2'b00;


        // ========================================================
        // Forward ALU A input
        // ========================================================

        // EX/MEM has the newest value
        if (regwrite_mem &&
            (rd_mem != 5'd0) &&
            (rd_mem == rs1_ex)) begin

            forward_a = 2'b10;

        end

        // Otherwise check MEM/WB
        else if (regwrite_wb &&
                 (rd_wb != 5'd0) &&
                 (rd_wb == rs1_ex)) begin

            forward_a = 2'b01;

        end


        // ========================================================
        // Forward ALU B input
        // ========================================================

        if (regwrite_mem &&
            (rd_mem != 5'd0) &&
            (rd_mem == rs2_ex)) begin

            forward_b = 2'b10;

        end

        else if (regwrite_wb &&
                 (rd_wb != 5'd0) &&
                 (rd_wb == rs2_ex)) begin

            forward_b = 2'b01;

        end

    end

endmodule