module datapath(
                input         clk,
                input         reset,
                input [31:0]  instr,
                input         mem_write,
                input         reg_write,
                input         ir_write,
                input         pc_write,
                input         instruction_or_data,
                input [1:0]   result_src,
                input [1:0]   alu_src_a,
                input [1:0]   alu_src_b,
                input [2:0]   alu_control,
                output [31:0] instr_out,
                // output [31:0] read_data,
                output [31:0] d_pc_out, // Added output for PC
                output [31:0] d_alu_result
                );

   reg [31:0]                 pc;
   reg [31:0]                 ir;
   reg [31:0]                 reg_file [0:31];
   reg [31:0]                 mem [0:1023];
   // reg [31:0]                 instr_mem [0:1023];
   // reg [31:0]                 data_mem [0:1023];
   reg [31:0]                 alu_out;
   reg [31:0]                 data;
   reg [31:0]                 alu_result;
   reg [31:0]                 adr;
   reg [31:0]                 result;

   wire [31:0]                read_data;
   wire [31:0]                rs1_data, rs2_data;
   wire [31:0]                immediate;
   wire [4:0]                 rs1, rs2;
   reg [31:0]                 alu_a, alu_b;

   assign instr_out = ir;
   assign d_pc_out = pc; // Output the PC value
   assign d_alu_result = alu_out;
   assign data = read_data;

   assign rs1 = instr[19:15];
   assign rs2 = instr[24:20];

   assign rs1_data = reg_file[rs1];
   assign rs2_data = reg_file[rs2];
   assign immediate = {{20{instr[31]}}, instr[31:20]};

   always @(posedge clk or posedge reset) begin
      if (reset) begin
         pc <= 0;
         ir <= 0;
      end else begin
         if (pc_write) pc <= alu_out;
         if (ir_write) ir <= (instruction_or_data ? 32'bz : mem[pc >> 2]);
      end
   end

   // essentially muxes in the multicycle processor
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

      case (alu_control)
        3'b000: alu_result = alu_a + alu_b; // ADD
        3'b001: alu_result = alu_a - alu_b; // SUB
        // Add more ALU operations here
        default: alu_result = 32'b0;
      endcase

      case (result_src)
        2'b00: result = alu_out;
        2'b01: result = data;
        2'b10: result = alu_result;
      endcase

      case (instruction_or_data)
        2'b0: adr = pc;
        2'b1: adr = result;
      endcase
   end

   // alu_out ff logic
   always @(posedge clk) begin
      if (reset) begin
         alu_out <= 32'b0;
      end else begin
         alu_out <= alu_result;
      end
   end

   assign read_data = mem[adr >> 2]; // word aligned read of the memory

   // always @(posedge clk) begin
   //    if (mem_write)
   //      data_mem[alu_out >> 2] <= rs2_data;
   // end


   // assign read_data = (result_src == 2'b01) ? data_mem[alu_out >> 2] : 32'b0;

   // always @(posedge clk) begin
   //    if (reg_write)
   //      reg_file[instr[11:7]] <= (result_src == 2'b01) ? read_data : alu_out;
   // end

endmodule
