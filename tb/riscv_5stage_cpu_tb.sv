`timescale 1ns/1ps

module riscv_5stage_cpu_tb;

    // =========================================================
    // DUT signals
    // =========================================================
    reg clk;
    reg reset;

    integer errors;
    reg forwarding_seen;

    // =========================================================
    // Instantiate CPU
    // =========================================================
    riscv_5stage_cpu uut (
        .clk   (clk),
        .reset (reset)
    );

    // =========================================================
    // Clock generation
    // 10 ns clock period
    // =========================================================
    initial begin
        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end
    end

    // =========================================================
    // Detect forwarding
    // =========================================================
    always @(posedge clk) begin
        if ((uut.forward_a != 2'b00) ||
            (uut.forward_b != 2'b00)) begin
            forwarding_seen = 1'b1;
        end
    end

    // =========================================================
    // Register checking task
    // =========================================================
    task check_register;
        input integer reg_number;
        input [31:0] expected;
        begin

            if (uut.register_file_id.regs[reg_number] == expected) begin

                $display("PASS: x%0d = %0d",
                         reg_number,
                         uut.register_file_id.regs[reg_number]);

            end
            else begin

                $display("FAIL: x%0d = %0d, Expected = %0d",
                         reg_number,
                         uut.register_file_id.regs[reg_number],
                         expected);

                errors = errors + 1;

            end

        end
    endtask

    // =========================================================
    // TEST
    // =========================================================
    initial begin

        errors = 0;
        forwarding_seen = 1'b0;

        $display("");
        $display("==============================================");
        $display("     RISC-V 5-STAGE PIPELINE VERIFICATION");
        $display("==============================================");
        $display("");

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------
        reset = 1'b1;

        #20;

        reset = 1'b0;

        $display("Reset released.");
        $display("");

        // -----------------------------------------------------
        // Allow pipeline to execute
        // -----------------------------------------------------
        $display("Executing instructions...");
        $display("");

        #200;

        // =====================================================
        // CHECK FINAL PC
        // =====================================================
        $display("----------------------------------------------");
        $display("Checking Program Counter");
        $display("----------------------------------------------");

        $display("PC = %h", uut.pc_current);

        // =====================================================
        // CHECK REGISTERS
        // =====================================================
        $display("");
        $display("----------------------------------------------");
        $display("Checking Register Results");
        $display("----------------------------------------------");

        // ADDI x1, x0, 10
        check_register(1, 32'd10);

        // ADDI x2, x0, 20
        check_register(2, 32'd20);

        // ADD x3, x1, x2
        check_register(3, 32'd30);

        // ADD x4, x3, x1
        check_register(4, 32'd40);

        // =====================================================
        // CHECK FORWARDING
        // =====================================================
        $display("");
        $display("----------------------------------------------");
        $display("Checking Pipeline Forwarding");
        $display("----------------------------------------------");

        if (forwarding_seen) begin

            $display("PASS: Forwarding activity detected.");

        end
        else begin

            $display("FAIL: No forwarding activity detected.");
            errors = errors + 1;

        end

        // =====================================================
        // FINAL RESULT
        // =====================================================
        $display("");
        $display("==============================================");

        if (errors == 0) begin

            $display("       ALL TESTS PASSED");
            $display("==============================================");

        end
        else begin

            $display("       TESTS FAILED");
            $display("       Errors = %0d", errors);
            $display("==============================================");

        end

        $display("");

        #10;
        $finish;

    end

endmodule