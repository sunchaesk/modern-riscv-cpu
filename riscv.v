module riscv(
                input         clk,
                input         reset,
                output [31:0] instr_out,
                output [31:0] pc_out,
                output [31:0] alu_result_out
                );

    wire mem_write, reg_write, ir_write, pc_write, instruction_or_data, zero_flag, branch_taken;
    wire [1:0] result_src, alu_src_a, alu_src_b;
    wire [2:0] branch_type;
    wire [3:0] alu_control, current_state;
    wire [31:0] d_pc_out, d_alu_result;

    datapath u_datapath(
        .clk(clk),
        .reset(reset),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .ir_write(ir_write),
        .pc_write(pc_write),
        .instruction_or_data(instruction_or_data),
        .result_src(result_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .branch_type(branch_type),
        .alu_control(alu_control),
        .zero_flag(zero_flag),
        .branch_taken(branch_taken),
        .instr_out(instr_out),
        .d_pc_out(d_pc_out),
        .d_alu_result(d_alu_result)
    );

    control u_control(
        .clk(clk),
        .reset(reset),
        .zero_flag(zero_flag),
        .branch_taken(branch_taken),
        .opcode(instr_out[6:0]),
        .funct3(instr_out[14:12]),
        .funct7(instr_out[31:25]),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .ir_write(ir_write),
        .pc_write(pc_write),
        .instruction_or_data(instruction_or_data),
        .result_src(result_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .branch_type(branch_type),
        .alu_control(alu_control),
        .current_state(current_state)
    );

    assign pc_out = d_pc_out;
    assign alu_result_out = d_alu_result;

endmodule
