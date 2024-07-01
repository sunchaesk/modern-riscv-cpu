module riscv (
    input         clk,
    input         reset,
    output [3:0]  current_state
);

    // Wires for interconnecting datapath and control unit
    wire [31:0] instr;
    wire mem_write, reg_write, ir_write, pc_write, instruction_or_data;
    wire [1:0] result_src, alu_src_a, alu_src_b;
    wire [2:0] alu_control;
    wire [31:0] instr_out, pc_out, alu_result;

    // Instantiate the control unit
    control cu (
        .clk(clk),
        .reset(reset),
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .ir_write(ir_write),
        .pc_write(pc_write),
        .instruction_or_data(instruction_or_data),
        .result_src(result_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_control(alu_control),
        .current_state(current_state)
    );

    // Instantiate the datapath
    datapath dp (
        .clk(clk),
        .reset(reset),
        .instr(instr),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .ir_write(ir_write),
        .pc_write(pc_write),
        .instruction_or_data(instruction_or_data),
        .result_src(result_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_control(alu_control),
        .instr_out(instr_out),
        .d_pc_out(pc_out),
        .d_alu_result(alu_result)
    );

    // Connect the instruction output of the datapath to the control unit
    assign instr = instr_out;

endmodule
