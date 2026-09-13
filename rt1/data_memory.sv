module data_memory (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,

    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

    logic [31:0] memory [0:255];

    always_ff @(posedge clk) begin

        if (mem_write)
            memory[address[9:2]] <= write_data;

    end

    always_comb begin

        if (mem_read)
            read_data = memory[address[9:2]];
        else
            read_data = 32'd0;

    end

endmodule