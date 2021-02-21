`timescale 1ns/1ns
  module tb_MM_control();
   reg Start;
   reg clk, rst;

   wire result_en, control;
   wire [3:0] addr_x, addr_A, addr_P;

   MM_control DUT (.Start(Start),
		   .clk(clk),
		   .rst(rst),
		   .result_en(result_en),
		   .control(control),
		   .addr_x(addr_x),
		   .addr_A(addr_A),
		   .addr_P(addr_P)
   );

   /*iverilog*/
   initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_MM_control);
   end
   /*iverilog*/
   
   always begin
      #100 clk = 0;
      #100 clk = 1;
   end

   initial begin
      rst = 1;
      Start = 1;
      #10000
      $finish;
   end

endmodule // tb_MM_control
