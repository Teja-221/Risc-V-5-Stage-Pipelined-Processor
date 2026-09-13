module register_file (
    input  logic        clk,
    input  logic        reset,
    input  logic        reg_write,

    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,

    input  logic [31:0] write_data,

    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    // 32 registers, 32 bits each
    logic [31:0] regs [0:31];

    integer i;

    // =========================================================
    // REGISTER WRITE
    // =========================================================
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;

        end
        else begin

            // x0 is always zero
            if (reg_write && (rd != 5'd0))
                regs[rd] <= write_data;

        end

    end

    // =========================================================
    // REGISTER READ
    // WITH WRITE-BACK BYPASS
    // =========================================================
    always_comb begin

        // -------------------------
        // RS1
        // -------------------------
        if (rs1 == 5'd0) begin

            read_data1 = 32'd0;

        end
        else if (reg_write && (rd != 5'd0) && (rd == rs1)) begin

            // Use value being written this cycle
            read_data1 = write_data;

        end
        else begin

            read_data1 = regs[rs1];

        end


        // -------------------------
        // RS2
        // -------------------------
        if (rs2 == 5'd0) begin

            read_data2 = 32'd0;

        end
        else if (reg_write && (rd != 5'd0) && (rd == rs2)) begin

            // Use value being written this cycle
            read_data2 = write_data;

        end
        else begin

            read_data2 = regs[rs2];

        end

    end

endmodule