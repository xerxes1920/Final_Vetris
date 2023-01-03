module bus_intrf(
	//input	iorw,
	//input	iocs,
	input	rda,
	//input	tbr,
	input	[1:0] ioaddr,
	input	[7:0] rx2bus,

	output	[7:0] bus_control_data,
	//output	[7:0] bus2tx,

	inout	[7:0] databus
);	
	parameter IO_XFER=2'b00, REG_RD=2'b01, LD_DIV_LO=2'b10, LD_DIV_HI=2'b11;

	//always@(*) begin
	//	if(iocs) begin
    //    	case(ioaddr)
    //        	IO_XFER: begin //***We may need to investage the correct method of implementing a tri-state driver here.
	//				if(iorw) begin
	//					databus = rx2bus;	
	//				end else begin
	//					bus2tx = databus; //should replace bus2tx with bus_control_data according to the graph...But don't know if we need to do according to the graph...
	//				end
	//			end
	//			REG_RD: begin			
	//				if(iorw)
	//					databus = {6'b0,rda,tbr};
	//			end
	//			default: begin //load dividor
	//				bus_control_data = databus; //may need to change based on synth
	//			end
    //   endcase
	//	end                          
    //end

	assign databus =  (ioaddr[1] == 1'b0) ? ((ioaddr == IO_XFER) ? rx2bus : {6'b0,rda,1'b0}) : 8'bz;
	//assign bus2tx = (ioaddr == IO_XFER) & !iorw ? databus : 8'b0;
	assign bus_control_data = (ioaddr[1] == 1'b1) ? databus : 8'b0;

endmodule