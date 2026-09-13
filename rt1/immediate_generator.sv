module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [2:0]  imm_type,
    output logic [31:0] immediate
);

    localparam I_TYPE = 3'b000;
    localparam S_TYPE = 3'b001;
    localparam B_TYPE = 3'b010;
    localparam U_TYPE = 3'b011;
    localparam J_TYPE = 3'b100;

    always_comb begin

        case (imm_type)

            // I-Type
            I_TYPE: begin
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};
            end

            // S-Type
            S_TYPE: begin
                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};
            end

            // B-Type
            B_TYPE: begin
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            end

            // U-Type
            U_TYPE: begin
                immediate = {instruction[31:12], 12'b0};
            end

            // J-Type
            J_TYPE: begin
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};
            end

            default: begin
                immediate = 32'b0;
            end

        endcase

    end

endmodule