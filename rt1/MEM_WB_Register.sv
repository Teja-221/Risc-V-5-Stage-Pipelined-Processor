module MEM_WB_Register (
    input logic        clk,
    input logic        reset,

    // Control signals
    input logic        RegWrite_in,
    input logic        MemToReg_in,

    // ALU result
    input logic [31:0] alu_result_in,

    // Data loaded from memory
    input logic [31:0] memory_data_in,

    // Destination register
    input logic [4:0]  rd_in,

    // Outputs
    output logic       RegWrite_out,
    output logic       MemToReg_out,

    output logic [31:0] alu_result_out,
    output logic [31:0] memory_data_out,

    output logic [4:0]  rd_out
);

    always_ff @(posedge clk) begin

        if (reset) begin

            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;

            alu_result_out  <= 32'd0;
            memory_data_out <= 32'd0;

            rd_out <= 5'd0;

        end

        else begin

            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;

            alu_result_out  <= alu_result_in;
            memory_data_out <= memory_data_in;

            rd_out <= rd_in;

        end

    end

endmodule