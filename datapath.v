module datapath(
                input         clk,
                input         reset,
                input         mem_write,
                input         reg_write,
                input         ir_write,
                input         pc_write,
                input         instruction_or_data,
                input [1:0]   result_src,
                input [1:0]   alu_src_a,
                input [1:0]   alu_src_b,
                input [3:0]   alu_control,
                output [31:0] instr_out,
                output [31:0] d_pc_out, // Added output for PC
                output [31:0] d_alu_result
                );

   reg [31:0]                 pc;
   wire [31:0]                next_pc;
   reg [31:0]                 ir;
   reg [31:0]                 reg_file [0:31];
   reg [31:0]                 mem [0:1023];
   reg [31:0]                 alu_out;
   reg [31:0]                 data;
   reg [31:0]                 alu_result;
   reg [31:0]                 adr;
   reg [31:0]                 result;

   reg [31:0]                 read_data;
   wire [31:0]                rs1_data, rs2_data;
   wire [31:0]                immediate;
   wire [4:0]                 rs1, rs2;
   reg [31:0]                 alu_a, alu_b;
   reg                        zero_flag;

   assign instr_out = ir;
   assign d_pc_out = pc; // Output the PC value
   assign d_alu_result = alu_out;
   assign data = read_data;

   assign rs1 = ir[19:15];
   assign rs2 = ir[24:20];

   assign rs1_data = reg_file[rs1];
   assign rs2_data = reg_file[rs2];

   // assign immediate = {{20{ir[31]}}, ir[31:20]};

   immediate_gen immediate_generator_unit (
                                           .instruction(ir),
                                           .opcode(ir[6:0]),
                                           .immediate_out(immediate)
                                           );

   always @(posedge clk or posedge reset) begin
      if (reset) begin
         pc <= 0;
         ir <= 0;
      end else begin
         if (pc_write) pc <= next_pc;
         if (ir_write) ir <= mem[pc >> 2]; // Fetch instruction from memory
         read_data <= mem[adr >> 2];
      end
   end

   // ALU operation
   ALU alu_unit (
                 .in_a(alu_a),
                 .in_b(alu_b),
                 .alu_control(alu_control),
                 .alu_result(alu_result),
                 .zero_flag(zero_flag)
                 );

   // ALU source muxes
   always @(*) begin
      case (alu_src_a)
        2'b00: alu_a = pc;
        2'b01: alu_a = rs1_data;
        default: alu_a = 32'b0;
      endcase

      case (alu_src_b)
        2'b00: alu_b = rs2_data;
        2'b01: alu_b = 4;
        2'b10: alu_b = immediate;
        2'b11: alu_b = 0;
        default: alu_b = 32'b0;
      endcase

      // case (alu_control)
      //   3'b000: alu_result = alu_a + alu_b; // ADD
      //   3'b001: alu_result = alu_a - alu_b; // SUB
      //   // Add more ALU operations here
      //   default: alu_result = 32'b0;
      // endcase

      // Result selection
      case (result_src)
        2'b00: result = alu_out;
        2'b01: result = data;
        2'b10: result = alu_result;
      endcase

      // Address selection
      case (instruction_or_data)
        1'b0: adr = pc;
        1'b1: adr = result;
      endcase
   end

   // ALU result register
   always @(posedge clk) begin
      if (reset) begin
         alu_out <= 32'b0;
      end else begin
         alu_out <= alu_result;
      end
   end

   // Register file write
   always @(posedge clk) begin
      if (reg_write) begin
         reg_file[ir[11:7]] <= result;
      end
   end

   // Memory write
   always @(posedge clk) begin
      if (mem_write) begin
         mem[alu_out >> 2] <= rs2_data;
      end
   end

   // pc update stuff
   assign next_pc = alu_result;

endmodule
