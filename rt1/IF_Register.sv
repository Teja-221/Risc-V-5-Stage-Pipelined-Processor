module IF_ID_Register (
    input logic        clk,
    input logic        reset,
    input logic        stall,
    input logic        flush,

    input logic [31:0] pc_in,
    input logic [31:0] pc_plus_4_in,
    input logic [31:0] instruction_in,

    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] instruction_out
);

    always_ff @(posedge clk) begin

        if (reset) begin

            pc_out           <= 32'd0;
            pc_plus_4_out    <= 32'd0;
            instruction_out <= 32'h00000013;

        end

        else if (flush) begin

            // Insert NOP
            pc_out           <= 32'd0;
            pc_plus_4_out    <= 32'd0;
            instruction_out <= 32'h00000013;

        end

        else if (stall) begin

            // Hold current values
            pc_out           <= pc_out;
            pc_plus_4_out    <= pc_plus_4_out;
            instruction_out <= instruction_out;

        end

        else begin

            pc_out           <= pc_in;
            pc_plus_4_out    <= pc_plus_4_in;
            instruction_out <= instruction_in;

        end

    end

endmodule