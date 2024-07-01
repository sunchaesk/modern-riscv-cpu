`timescale 1ns / 1ps

module control_tb;

   reg clk;
   reg reset;
   reg [31:0] instr;
   wire [31:0] instr_out;
   wire [31:0] read_data;
   wire [31:0] alu_out;
   wire        mem_write;
   wire        reg_write;
   wire        ir_write;
   wire        pc_write;
   wire        instruction_or_data;
   wire [1:0]  result_src;
   wire [1:0]  alu_src_a;
   wire [1:0]  alu_src_b;
   wire [2:0]  alu_control;
   wire [3:0]  current_state;
   wire [31:0] pc_out; // PC output

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
                .read_data(read_data),
                .d_pc_out(pc_out), // Connect PC output
                .d_alu_result(alu_out)
                );

   // Clock generation
   initial begin
      clk = 0;
      forever #5 clk = ~clk; // 10ns period
   end

   initial begin
      $dumpfile("exe.vcd");
      $dumpvars(0, control_tb);
   end

   // Test sequence
   initial begin
      // Initialize inputs
      reset = 1;
      #10;

      // Release reset
      reset = 0;

      // load register values
      dp.reg_file[2] = 32'h00000000;

      // load data_mem
      dp.data_mem[0] = 32'h00000008;
      dp.data_mem[1] = 32'h00000008;

      // Load word instruction (lw x1, 0(x2))
      // instr = 32'b00000000000000010010000010000011; // lw x1, 0(x2)
      instr= 32'b00000000010000010010000010000011; // lw x1, 4(x2)
      #50;

      // Monitor signals
      $monitor("Time: %0d, State: %0b, PC: %0h, Read Data: %0h, ALU out: %h", $time, current_state, pc_out,  read_data, alu_out);

      // Run through a few cycles
      #100;

      // Check state and signals at each cycle


      // Finish simulation
      $finish;
   end

   // Task to check data paths at each state

endmodule
