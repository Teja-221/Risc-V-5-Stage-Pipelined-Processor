module instruction_memory (
    input logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];

    initial begin

    // Initialize entire instruction memory to NOP
    integer i;

    for (i = 0; i < 256; i = i + 1)
        memory[i] = 32'h00000013;

    // ADDI x1, x0, 10
    memory[0] = 32'h00A00093;

    // ADDI x2, x0, 20
    memory[1] = 32'h01400113;

    // ADD x3, x1, x2
    memory[2] = 32'h002081B3;

    // ADD x4, x3, x1
    memory[3] = 32'h00118233;

    end

    assign instruction = memory[address[9:2]];

endmodule