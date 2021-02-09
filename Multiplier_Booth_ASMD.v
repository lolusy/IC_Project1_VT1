module Multiplier_Booth_ASMD #(parameter L_word = 4)
( output [2*L_word-1: 0] product,
  output                 Ready,
  input  [L_word-1: 0]   A, x,
  input                  Start, clk, reset
);

   wire 		 Empty, w2_neg, m_is_1, m0, Flush, Load_words, Shift, Add, Sub;

   Control_Unit M0_controller(.Load_words(Load_words),
                              .Flush(Flush),
                              .Shift(Shift),
                              .Add(Add),
                              .Sub(Sub),
                              .Ready(Ready),
                              .Empty(Empty),
                              .w2_neg(w2_neg),
                              .m_is_1(m_is_1),
                              .m0(m0),
                              .Start(Start),
                              .clk(clk),
                              .reset(reset));

    Datapath_Unit M1_Datapath(.product(product),
			      .Empty(Empty),
			      .w2_neg(w2_neg),
			      .m_is_1(m_is_1),
			      .m0(m0),
			      .A(A),
			      .x(x),
			      .Load_words(Load_words),
			      .Flush(Flush),
			      .Shift(Shift),
			      .Add(Add),
			      .Sub(Sub),
			      .clk(clk),
			      .reset(reset));

endmodule // Multiplier_Booth_ASMD

module Control_Unit #(parameter L_word = 4, L_state = 3, L_BRC = 2)
( output reg   Load_words, Flush, Shift, Add, Sub,
  output       Ready,
  input        Empty, w2_neg, m_is_1, m0, Start, clk, reset
);
  parameter   S_idle = 0, S_running = 1, S_working = 2, S_shift1 = 3, S_shift2 = 4;
  reg [L_state-1:0] state, next_state;
  reg 		     m0_del;
  wire [L_BRC-1: 0] BRC = {m0,m0_del};                    //Booth recording bits
  assign Ready = (state == S_idle) || (state == S_idle);

  //Necessary to reset m0_del when Load_words is asserted, otherwise it would start with residual value

always@(posedge clk, posedge reset)
  
  if(reset)
    m0_del <= 0;
  else if(Load_words)
    m0_del <= 0;
  else if(Shift)
    m0_del <= m0;

always@(posedge clk, posedge reset)

  if(reset)
    state <= S_idle;
  else
    state <= next_state;

always@(state, Start, BRC, Empty, w2_neg, m_is_1, m0) begin      //Next state and control logic

   Load_words = 0;
   Flush = 0;
   Shift = 0;
   Add = 0;
   Sub = 0;

   case(state)

     S_idle:
     if(!Start) 
        next_state = S_idle;
     else if(Empty) begin 
        Flush = 1; 
        next_state = S_idle;
     end
     else begin
	Load_words = 1;
	Flush = 1;
	next_state = S_running;
     end

     S_running:
     if(m_is_1) begin
	if(BRC==3) begin
	   Shift = 1;
	   next_state = S_shift2;
	end
	else begin
	   Sub = 1;
	   next_state = S_shift1;
	end
     end
     else begin
	if(BRC==1) begin
	   Add = 1;
	   next_state = S_working;
	end
	else if(BRC==2) begin
	   Sub = 1;
	   next_state = S_working;
	end
     end // else: !if(m_is_1)

     S_shift1:
       begin
	  Shift = 1;
	  next_state = S_shift2;
       end

     S_shift2:
       begin
	  next_state = S_idle;
	  if((BRC==1)&&(!w2_neg))
	    Add = 1;
       end

     S_working:
       begin
	  Shift = 1;
	  next_state = S_running;
       end

     default:
       next_state = S_idle;
   endcase // case (state)
end // always@ (state, Start, BRC, Empty, w2_neg, m_is_1, m0)
endmodule // Control_Unit

module Datapath_Unit #(parameter L_word = 4)
(  output reg [2*L_word-1: 0]       product,
   output 		            Empty, w2_neg, m_is_1, m0;
   input [L_word-1: 0] 	            A, x;
   input 			    Load_words, Flush, Shift, Add, Sub, clk, reset
);

   reg [2*L_word-1: 0] 		    multiplicand;
   reg [L_word-1:0] 		    multiplier;
   reg 				    Flag;

   assign Empty=((A==0) || (x==0));
   assign w2_neg = Flag;
   assign m_is_1 = (multiplier==1);
   assign m0 = multiplier[0];
   parameter 			    All_Ones = {L_word{1'b1}};
   parameter 			    All_zeros = {L_word{1'b0}};           //Register/Datapath Operations

always@(posedge clk, posedge reset)
  if(reset) begin
     multiplier <= 0;
     multiplicand <= 0;
     product <= 0;
     Flag <= 0;
  end
  else begin
     if(Load_words) begin
	Flag = x[L_word-1: 0];
	if(A[L_word-1]==0)
	  multiplicand <= A;
	else
	  multiplicand <= {All_Ones, A[L_word-1: 0]};
	  multiplier <= x;
     end//Load_words
     if(Flush) product <= 0;
     if(Shift) begin
	multiplier <= multiplier >> 1;
	multiplicand <= multiplicand << 1;
     end
     if(Add) begin
	product <= product + multiplicand;
     end
     if(Sub) begin
	porduct <= product - multiplicand;
     end
  end // else: !if(reset)
endmodule // Datapath_Unit

