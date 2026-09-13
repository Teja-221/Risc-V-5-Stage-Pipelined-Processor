module ID_EX_Register (
    input logic        clk,
    input logic        reset,
    input logic        flush,

    // Control signals
    input logic        RegWrite_in,
    input logic        MemRead_in,
    input logic        MemWrite_in,
    input logic        MemToReg_in,
    input logic        ALUSrc_in,
    input logic        Branch_in,

    input logic [3:0]  ALUControl_in,

    // Data
    input logic [31:0] pc_in,
    input logic [31:0] pc_plus_4_in,

    input logic [31:0] read_data1_in,
    input logic [31:0] read_data2_in,

    input logic [31:0] immediate_in,

    // Register numbers
    input logic [4:0]  rs1_in,
    input logic [4:0]  rs2_in,
    input logic [4:0]  rd_in,

    // Outputs
    output logic       RegWrite_out,
    output logic       MemRead_out,
    output logic       MemWrite_out,
    output logic       MemToReg_out,
    output logic       ALUSrc_out,
    output logic       Branch_out,

    output logic [3:0] ALUControl_out,

    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out,

    output logic [31:0] read_data1_out,
    output logic [31:0] read_data2_out,

    output logic [31:0] immediate_out,

    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out
);

    always_ff @(posedge clk) begin

        if (reset) begin

            RegWrite_out <= 1'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            ALUSrc_out   <= 1'b0;
            Branch_out   <= 1'b0;

            ALUControl_out <= 4'b0000;

            pc_out        <= 32'd0;
            pc_plus_4_out <= 32'd0;

            read_data1_out <= 32'd0;
            read_data2_out <= 32'd0;

            immediate_out <= 32'd0;

            rs1_out <= 5'd0;
            rs2_out <= 5'd0;
            rd_out  <= 5'd0;

        end

        else if (flush) begin

            // Convert pipeline entry into NOP

            RegWrite_out <= 1'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            ALUSrc_out   <= 1'b0;
            Branch_out   <= 1'b0;

            ALUControl_out <= 4'b0000;

            pc_out        <= 32'd0;
            pc_plus_4_out <= 32'd0;

            read_data1_out <= 32'd0;
            read_data2_out <= 32'd0;

            immediate_out <= 32'd0;

            rs1_out <= 5'd0;
            rs2_out <= 5'd0;
            rd_out  <= 5'd0;

        end

        else begin

            RegWrite_out <= RegWrite_in;
            MemRead_out  <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            ALUSrc_out   <= ALUSrc_in;
            Branch_out   <= Branch_in;

            ALUControl_out <= ALUControl_in;

            pc_out        <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;

            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;

            immediate_out <= immediate_in;

            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out  <= rd_in;

        end

    end

endmodule