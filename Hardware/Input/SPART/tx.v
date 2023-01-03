module tx (
	input clk,
	input rst,
	input iocs,
	input iorw,
	input [1:0] ioaddr,
	input rate_en,
	input [7:0] tx_ack,
	input [7:0] bus2tx,

	output reg txd,
	//output reg tbr
	output reg tbr
);

	parameter IO_XFER=2'b00, REG_RD=2'b01, LD_DIV_LO=2'b10, LD_DIV_HI=2'b11;
	parameter WAIT=3'b000, LD_TX=3'b001, START_H=3'b010, START_L=3'b011, DATA=3'b100, STOP=3'b101;
	reg [2:0] state;
	reg [2:0] nxt_state;


	reg [7:0] tx_reg;		//data to transmit
	reg [2:0] bit_cnt;		//count the bits
	
    //SM output

	reg shift; 				//if need to shift data
	reg clr_bit_cnt;		//clear bit counter
	reg inc_bit_cnt;		//inc bit counter
	reg set_TX,clr_TX;		//set transmit bit to 1 or clear it
	reg set_done;			//if set, we are done
	reg trmt;				//transmit initialization

	//state register
	always @ (posedge clk or posedge rst) begin
		if(rst)
			state = WAIT;
		else
			state = nxt_state;
	end

	//TX shift register
	always @ (posedge clk)
	  if (rst)
	    tx_reg <= 8'hFF;
	  else if (trmt)
	    tx_reg <= bus2tx; 
	  else if (shift)
	    tx_reg <= {1'b1,tx_reg[7:1]};
		
	//bit counter 
	always @ (posedge clk)
	  if (clr_bit_cnt)
	    bit_cnt <= 3'b000;
	  else if (inc_bit_cnt)
	    bit_cnt <= bit_cnt + 3'b001;

	//Output flop //
	always @ (posedge clk)
	  if (rst)
	    txd <= 1'b1;
	  else if (set_TX)
	    txd <= 1'b1;
	  else if (clr_TX)
	    txd <= 1'b0;

	//Done flop 
	always @ (posedge clk)
	  if (rst)
	    tbr <= 1'b0;
	  else if (set_done)
	    tbr <= 1'b1;
	  else if (trmt)
	    tbr <= 1'b0;


	//TX SM
	always@(*) begin
		//Set defaults
		trmt = 1'b0;
		shift = 1'b0;
		clr_bit_cnt = 1'b0;
		inc_bit_cnt = 1'b0;
		set_TX = 1'b0;
		clr_TX = 1'b0;
		set_done = 1'b0;
		//tbr = 1'b0;
		nxt_state = state;
		
		case (state)
		  WAIT: begin
			//wait at high
			set_TX = 1'b1;
		    if ((!iorw) & (ioaddr == IO_XFER)) begin
			  nxt_state = LD_TX;
		    end
		  end
		  LD_TX : begin
			trmt = 1'b1;
			nxt_state = START_H;
		  end
		  START_H : begin //Start waiting for one period trmt
		    if (rate_en) begin
			  clr_TX = 1'b1;
			  nxt_state = START_L;
			/*end else if(!trmt) begin
				nxt_state = IDLE;*/
			end else
				set_TX = 1'b1;
		  end
		  START_L : begin //Start bit
		    if (rate_en) begin
			  clr_TX = 1'b1;
			  clr_bit_cnt = 1'b1;
			  nxt_state = DATA;
			end else begin
			  clr_TX = 1'b1;
			end
		  end
		  DATA : begin //same as data, transmitting data bit by bit
		    if (bit_cnt == 3'b111 && rate_en) begin //if done
				nxt_state = STOP;
			end else if (rate_en) begin
				inc_bit_cnt = 1'b1;
				shift = 1'b1;
			end	else begin
				set_TX = tx_reg[0];
				clr_TX = ~tx_reg[0];
			 end
		  end
		  default : begin //same as stop
		  	  if (rate_en) begin
				clr_TX = 1'b0; //we are done
				set_done = 1'b1;
				nxt_state = WAIT;
				//tbr = 1'b1;
			  end else begin
				set_TX = 1'b1;
                //nxt_state = WAIT;  
			  end
		  end
		endcase
	end		

endmodule
