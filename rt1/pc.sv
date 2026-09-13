module pc (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] next_pc,
    output logic [31:0] pc_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'd0;
        else
            pc_out <= next_pc;
    end

endmodule