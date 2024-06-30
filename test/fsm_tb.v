`timescale 1ns / 1ps

module fsm_tb;

   reg clk;
   reg reset;
   reg [31:0] instr;
   wire [3:0] state;

   // Instantiate the FSM
   control uut (
                .clk(clk),
                .reset(reset),
                .current_state(state)
                );

   // Clock generation
   initial begin
      clk = 0;
      forever #5 clk = ~clk; // 10ns period
   end

   initial begin
      $dumpfile("exe.vcd");
      $dumpvars(0, fsm_tb);
   end

   // Test sequence
   initial begin
      // Initialize inputs
      reset = 1;
      instr = 32'b0;
      #10;

      // Release reset
      reset = 0;
      #10;

      // Apply lw instruction
      instr = 32'h00023003; // Example lw instruction with opcode 0000011 (lw x6, 0(x4))
      #10;

      // Monitor states
      $monitor("Time: %0d, State: %0b", $time, state);

      // Run through a few cycles
      #10; // Expect DECODE state
      #10; // Expect EXECUTE state
      #10; // Expect MEMORY state
      #10; // Expect WRITEBACK state

      #100;

      // Finish simulation
      $finish;
   end

endmodule
