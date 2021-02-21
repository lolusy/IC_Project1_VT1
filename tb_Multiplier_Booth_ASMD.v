`timescale 1ns/1ns
  module tb_Multiplier_Booth_ASMD #(parameter L_word = 4)();
   reg [L_word-1: 0]     A, x;
   reg 		         Start, clk, reset;
   wire [2*L_word-1: 0]  product;
   wire 		 Ready;

   Multiplier_Booth_ASMD DUT (.product(product),
                              .A(A),
			      .x(x),
			      .Ready(Ready),
			      .Start(Start),
			      .clk(clk),
			      .reset(reset)
   );

   parameter 		 clk_period = 50;

   /*iverilog*/
   initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_Multiplier_Booth_ASMD);
   end
   /*iverilog*/

   always begin
      #100 clk = 0;
      #100 clk = 1;
   end

   initial begin
      reset = 1;
      Start = 1;
      x = 4'h2;
      A = 4'h3;
     // test(4'b0001, 4'b0010, 8'h02);
      #10000
      $finish
	end // initial begin
   
  /* tasktest;
      input [L_word-1:0] in0;
      input [L_word-1:0] in1;
      input [2*L_word-1:0] out;
      begin
	 x = in0;
	 A = in1;
	 @(posedge clk);
	 @(negedge clk);
	 if (product == out) begin
	    $display ("It works");
	 end
	 else begin
	    $display ("opps %d * %d ~= %d, expect %d", in0, in1, out, product);
	 end */
	 
endmodule // tb_Multiplier_Booth_ASMD
