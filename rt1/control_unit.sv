module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7,

    output logic       RegWrite,
    output logic       ALUSrc,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       MemToReg,
    output logic       Branch,

    output logic [3:0] ALUControl
);

    always_comb begin

        // Default values
        RegWrite   = 1'b0;
        ALUSrc     = 1'b0;
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        MemToReg   = 1'b0;
        Branch     = 1'b0;
        ALUControl = 4'b0000;


        case (opcode)

            // --------------------------------
            // R-Type instructions
            // ADD, SUB, AND, OR, XOR, SLT
            // --------------------------------

            7'b0110011: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemToReg = 1'b0;

                case (funct3)

                    3'b000: begin
                        if (funct7 == 1'b1)
                            ALUControl = 4'b0001; // SUB
                        else
                            ALUControl = 4'b0000; // ADD
                    end

                    3'b111:
                        ALUControl = 4'b0010; // AND

                    3'b110:
                        ALUControl = 4'b0011; // OR

                    3'b100:
                        ALUControl = 4'b0100; // XOR

                    3'b010:
                        ALUControl = 4'b0101; // SLT

                    default:
                        ALUControl = 4'b0000;

                endcase

            end


            // --------------------------------
            // I-Type Arithmetic
            // ADDI, ANDI, ORI, XORI
            // --------------------------------

            7'b0010011: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemToReg = 1'b0;

                case (funct3)

                    3'b000:
                        ALUControl = 4'b0000; // ADDI

                    3'b111:
                        ALUControl = 4'b0010; // ANDI

                    3'b110:
                        ALUControl = 4'b0011; // ORI

                    3'b100:
                        ALUControl = 4'b0100; // XORI

                    default:
                        ALUControl = 4'b0000;

                endcase

            end


            // --------------------------------
            // LOAD
            // LW
            // --------------------------------

            7'b0000011: begin

                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                MemRead    = 1'b1;
                MemToReg   = 1'b1;
                ALUControl = 4'b0000;

            end


            // --------------------------------
            // STORE
            // SW
            // --------------------------------

            7'b0100011: begin

                RegWrite   = 1'b0;
                ALUSrc     = 1'b1;
                MemWrite   = 1'b1;
                ALUControl = 4'b0000;

            end


            // --------------------------------
            // BRANCH
            // BEQ / BNE
            // --------------------------------

            7'b1100011: begin

                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                Branch   = 1'b1;
                ALUControl = 4'b0001;

            end


            // --------------------------------
            // LUI
            // --------------------------------

            7'b0110111: begin

                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                MemToReg   = 1'b0;
                ALUControl = 4'b0000;

            end


            // --------------------------------
            // AUIPC
            // --------------------------------

            7'b0010111: begin

                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                MemToReg   = 1'b0;
                ALUControl = 4'b0000;

            end


            // --------------------------------
            // JAL
            // --------------------------------

            7'b1101111: begin

                RegWrite = 1'b1;
                ALUSrc   = 1'b1;

            end


            default: begin

                RegWrite   = 1'b0;
                ALUSrc     = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                MemToReg   = 1'b0;
                Branch     = 1'b0;
                ALUControl = 4'b0000;

            end

        endcase

    end

endmodule