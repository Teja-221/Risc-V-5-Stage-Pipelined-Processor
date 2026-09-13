module riscv_5stage_cpu (
    input logic clk,
    input logic reset
);

    // ============================================================
    // IF STAGE
    // ============================================================

    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] instruction;

    // ============================================================
    // IF / ID
    // ============================================================

    logic [31:0] if_id_pc;
    logic [31:0] if_id_pc_plus_4;
    logic [31:0] if_id_instruction;

    // ============================================================
    // ID STAGE
    // ============================================================

    logic [6:0] id_opcode;
    logic [4:0] id_rd;
    logic [4:0] id_rs1;
    logic [4:0] id_rs2;
    logic [2:0] id_funct3;
    logic       id_funct7_bit;

    logic       id_RegWrite;
    logic       id_ALUSrc;
    logic       id_MemRead;
    logic       id_MemWrite;
    logic       id_MemToReg;
    logic       id_Branch;
    logic [3:0] id_ALUControl;

    logic [2:0]  id_imm_type;
    logic [31:0] id_immediate;

    logic [31:0] id_read_data1;
    logic [31:0] id_read_data2;

    // ============================================================
    // HAZARD DETECTION
    // ============================================================

    logic hazard_stall;

    // ============================================================
    // ID / EX
    // ============================================================

    logic       ex_RegWrite;
    logic       ex_MemRead;
    logic       ex_MemWrite;
    logic       ex_MemToReg;
    logic       ex_ALUSrc;
    logic       ex_Branch;

    logic [3:0] ex_ALUControl;

    logic [31:0] ex_pc;
    logic [31:0] ex_pc_plus_4;

    logic [31:0] ex_read_data1;
    logic [31:0] ex_read_data2;
    logic [31:0] ex_immediate;

    logic [4:0] ex_rs1;
    logic [4:0] ex_rs2;
    logic [4:0] ex_rd;

    // ============================================================
    // EX STAGE
    // ============================================================

    logic [1:0] forward_a;
    logic [1:0] forward_b;

    logic [31:0] forwarded_alu_a;
    logic [31:0] forwarded_alu_b;

    logic [31:0] ex_alu_input1;
    logic [31:0] ex_alu_input2;

    logic [31:0] ex_alu_result;
    logic        ex_zero;

    logic [31:0] branch_target;
    logic        branch_taken;

    // ============================================================
    // EX / MEM
    // ============================================================

    logic       mem_RegWrite;
    logic       mem_MemRead;
    logic       mem_MemWrite;
    logic       mem_MemToReg;

    logic [31:0] mem_alu_result;
    logic [31:0] mem_write_data;

    logic [4:0] mem_rd;

    // ============================================================
    // MEM STAGE
    // ============================================================

    logic [31:0] mem_read_data;

    // ============================================================
    // MEM / WB
    // ============================================================

    logic       wb_RegWrite;
    logic       wb_MemToReg;

    logic [31:0] wb_alu_result;
    logic [31:0] wb_memory_data;

    logic [4:0] wb_rd;

    // ============================================================
    // WRITE BACK
    // ============================================================

    logic [31:0] wb_write_data;


    // ============================================================
    // IF STAGE
    // ============================================================

    assign pc_plus_4 = pc_current + 32'd4;

    // Branch has priority over hazard stall
    assign pc_next =
        branch_taken ? branch_target :
        hazard_stall ? pc_current :
        pc_plus_4;


    // ============================================================
    // PROGRAM COUNTER
    // ============================================================

    pc pc_unit (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc_out(pc_current)
    );


    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    instruction_memory imem (
        .address(pc_current),
        .instruction(instruction)
    );


    // ============================================================
    // IF / ID REGISTER
    // ============================================================

    IF_ID_Register if_id_reg (
        .clk(clk),
        .reset(reset),

        .stall(hazard_stall),
        .flush(branch_taken),

        .pc_in(pc_current),
        .pc_plus_4_in(pc_plus_4),
        .instruction_in(instruction),

        .pc_out(if_id_pc),
        .pc_plus_4_out(if_id_pc_plus_4),
        .instruction_out(if_id_instruction)
    );


    // ============================================================
    // INSTRUCTION DECODING
    // ============================================================

    assign id_opcode     = if_id_instruction[6:0];
    assign id_rd         = if_id_instruction[11:7];
    assign id_funct3     = if_id_instruction[14:12];
    assign id_rs1        = if_id_instruction[19:15];
    assign id_rs2        = if_id_instruction[24:20];
    assign id_funct7_bit = if_id_instruction[30];


    // ============================================================
    // CONTROL UNIT
    // ============================================================

    control_unit control_unit_id (
        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7_bit),

        .RegWrite(id_RegWrite),
        .ALUSrc(id_ALUSrc),

        .MemRead(id_MemRead),
        .MemWrite(id_MemWrite),
        .MemToReg(id_MemToReg),

        .Branch(id_Branch),

        .ALUControl(id_ALUControl)
    );


    // ============================================================
    // IMMEDIATE TYPE
    // ============================================================

    always_comb begin

        case (id_opcode)

            // I-type
            7'b0010011:
                id_imm_type = 3'b000;

            // LW
            7'b0000011:
                id_imm_type = 3'b000;

            // SW
            7'b0100011:
                id_imm_type = 3'b001;

            // Branch
            7'b1100011:
                id_imm_type = 3'b010;

            // LUI / AUIPC
            7'b0110111,
            7'b0010111:
                id_imm_type = 3'b011;

            // JAL
            7'b1101111:
                id_imm_type = 3'b100;

            default:
                id_imm_type = 3'b000;

        endcase

    end


    // ============================================================
    // IMMEDIATE GENERATOR
    // ============================================================

    immediate_generator imm_gen_id (
        .instruction(if_id_instruction),
        .imm_type(id_imm_type),
        .immediate(id_immediate)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    // IMPORTANT:
    // Correct module type:
    //     register_file
    //
    // Correct instance name:
    //     register_file_id
    //
    // Correct write port:
    //     reg_write

    register_file register_file_id (
        .clk(clk),
        .reset(reset),

        .reg_write(wb_RegWrite),

        .rs1(id_rs1),
        .rs2(id_rs2),

        .rd(wb_rd),

        .write_data(wb_write_data),

        .read_data1(id_read_data1),
        .read_data2(id_read_data2)
    );


    // ============================================================
    // HAZARD DETECTION
    // ============================================================

    hazard_detection_unit hazard_unit (
        .id_ex_mem_read(ex_MemRead),
        .id_ex_rd(ex_rd),

        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),

        .stall(hazard_stall)
    );


    // ============================================================
    // ID / EX REGISTER
    // ============================================================

    ID_EX_Register id_ex_reg (
        .clk(clk),
        .reset(reset),

        .flush(branch_taken),

        .RegWrite_in(
            hazard_stall ? 1'b0 : id_RegWrite
        ),

        .MemRead_in(
            hazard_stall ? 1'b0 : id_MemRead
        ),

        .MemWrite_in(
            hazard_stall ? 1'b0 : id_MemWrite
        ),

        .MemToReg_in(
            hazard_stall ? 1'b0 : id_MemToReg
        ),

        .ALUSrc_in(
            hazard_stall ? 1'b0 : id_ALUSrc
        ),

        .Branch_in(
            hazard_stall ? 1'b0 : id_Branch
        ),

        .ALUControl_in(
            hazard_stall ? 4'b0000 : id_ALUControl
        ),

        .pc_in(if_id_pc),
        .pc_plus_4_in(if_id_pc_plus_4),

        .read_data1_in(id_read_data1),
        .read_data2_in(id_read_data2),

        .immediate_in(id_immediate),

        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(id_rd),

        .RegWrite_out(ex_RegWrite),
        .MemRead_out(ex_MemRead),
        .MemWrite_out(ex_MemWrite),
        .MemToReg_out(ex_MemToReg),

        .ALUSrc_out(ex_ALUSrc),
        .Branch_out(ex_Branch),

        .ALUControl_out(ex_ALUControl),

        .pc_out(ex_pc),
        .pc_plus_4_out(ex_pc_plus_4),

        .read_data1_out(ex_read_data1),
        .read_data2_out(ex_read_data2),

        .immediate_out(ex_immediate),

        .rs1_out(ex_rs1),
        .rs2_out(ex_rs2),
        .rd_out(ex_rd)
    );


    // ============================================================
    // FORWARDING UNIT
    // ============================================================

    forwarding_unit forwarding_unit_ex (
        .rs1_ex(ex_rs1),
        .rs2_ex(ex_rs2),

        .rd_mem(mem_rd),
        .regwrite_mem(mem_RegWrite),

        .rd_wb(wb_rd),
        .regwrite_wb(wb_RegWrite),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );


    // ============================================================
    // FORWARDING MUX - A
    // ============================================================

    always_comb begin

        case (forward_a)

            2'b00:
                forwarded_alu_a = ex_read_data1;

            2'b10:
                forwarded_alu_a = mem_alu_result;

            2'b01:
                forwarded_alu_a = wb_write_data;

            default:
                forwarded_alu_a = ex_read_data1;

        endcase

    end


    // ============================================================
    // FORWARDING MUX - B
    // ============================================================

    always_comb begin

        case (forward_b)

            2'b00:
                forwarded_alu_b = ex_read_data2;

            2'b10:
                forwarded_alu_b = mem_alu_result;

            2'b01:
                forwarded_alu_b = wb_write_data;

            default:
                forwarded_alu_b = ex_read_data2;

        endcase

    end


    // ============================================================
    // ALU INPUTS
    // ============================================================

    assign ex_alu_input1 = forwarded_alu_a;

    assign ex_alu_input2 =
        ex_ALUSrc ? ex_immediate : forwarded_alu_b;


    // ============================================================
    // ALU
    // ============================================================

    alu alu_ex (
        .A(ex_alu_input1),
        .B(ex_alu_input2),

        .ALUControl(ex_ALUControl),

        .Result(ex_alu_result),
        .Zero(ex_zero)
    );


    // ============================================================
    // BRANCH
    // ============================================================

    assign branch_target = ex_pc + ex_immediate;

    assign branch_taken = ex_Branch && ex_zero;


    // ============================================================
    // EX / MEM REGISTER
    // ============================================================

    EX_MEM_Register ex_mem_reg (
        .clk(clk),
        .reset(reset),

        .RegWrite_in(ex_RegWrite),
        .MemRead_in(ex_MemRead),
        .MemWrite_in(ex_MemWrite),
        .MemToReg_in(ex_MemToReg),

        .alu_result_in(ex_alu_result),

        .write_data_in(forwarded_alu_b),

        .rd_in(ex_rd),

        .RegWrite_out(mem_RegWrite),
        .MemRead_out(mem_MemRead),
        .MemWrite_out(mem_MemWrite),
        .MemToReg_out(mem_MemToReg),

        .alu_result_out(mem_alu_result),
        .write_data_out(mem_write_data),

        .rd_out(mem_rd)
    );


    // ============================================================
    // DATA MEMORY
    // ============================================================

    data_memory data_memory_mem (
        .clk(clk),

        .mem_read(mem_MemRead),
        .mem_write(mem_MemWrite),

        .address(mem_alu_result),

        .write_data(mem_write_data),

        .read_data(mem_read_data)
    );


    // ============================================================
    // MEM / WB REGISTER
    // ============================================================

    MEM_WB_Register mem_wb_reg (
        .clk(clk),
        .reset(reset),

        .RegWrite_in(mem_RegWrite),
        .MemToReg_in(mem_MemToReg),

        .alu_result_in(mem_alu_result),

        .memory_data_in(mem_read_data),

        .rd_in(mem_rd),

        .RegWrite_out(wb_RegWrite),
        .MemToReg_out(wb_MemToReg),

        .alu_result_out(wb_alu_result),
        .memory_data_out(wb_memory_data),

        .rd_out(wb_rd)
    );


    // ============================================================
    // WRITE BACK
    // ============================================================

    assign wb_write_data =
        wb_MemToReg ? wb_memory_data : wb_alu_result;


endmodule