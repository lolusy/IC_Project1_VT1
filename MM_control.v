module MM_control (input  Start, clk, rst,
		   output reg result_en, control,
                   output reg [3:0] addr_x, addr_A, addr_P);
   
   parameter 		  idle = 2'b00, op_addr = 2'b01, op_wp = 2'b10;
   reg [1:0] 		  state, next_state;
   reg [3:0] 		  r, r_next, nn, nn_next;

   always@(posedge clk)
     if(rst) 
       state <= idle;
     else
       state <= next_state;

   always@(state, Start) begin
      addr_x = 4'h0;
      addr_A = 4'h0;
      addr_P = 4'h0;
      
    case(state)
      idle: 
        if(Start) begin 
          next_state = op_addr; 
          result_en = 0; 
          r = 4'h0; 
           nn = 4'h0; end
        else next_state = idle;

      op_addr:
	begin
	   addr_x = (nn[3:2] << 1) + (nn[3:2] << 2) + r;
           addr_A = (r << 2) + nn[1:0];
           addr_P = nn;
           r_next = r + 1;
	if(r==5) begin
	   r_next = 4'h0;
	   control = 0;
	end
	else begin
	   r = r_next;
	   control = 1;
	end
	end // case: op_addr

      op_wp:
	begin
	   result_en = 1;
	   nn_next = nn + 1;
	if(nn==15) begin
	   next_state = idle;
	end
	else begin
	   nn = nn_next;
	end
	end // case: op_wp

      default: begin next_state = idle;
      end

    endcase // case (state)
   end // always@ (state, Start)

endmodule // MM_control
