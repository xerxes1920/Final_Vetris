//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,
    input rst,
    //input iocs,
    //input iorw,
    output rda,
    //output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    //output txd,
    input rxd
    );
	
wire rate_en;
wire [7:0] rx2bus, bus_control_data;

/*tx tx0(   .clk(clk),
		  .rst(rst),
		  .iocs(iocs),
		  .iorw(iorw),
		  .ioaddr(ioaddr),
		  .txd(txd),
		  .tbr(tbr),
		  .rate_en(rate_en),
		  .tx_ack(bus_control_data),
		  .bus2tx(bus2tx));
*/
		  
rx rx0(   .clk(clk),
		  .rst(rst),
		  .ioaddr(ioaddr),
		  .rxd(rxd),
		  .rda(rda),
		  .rate_en(rate_en),
		  .rx_ack(bus_control_data),
		  .rx2bus(rx2bus));
		  
bus_intrf bus_intrf0(	.databus(databus),
						.ioaddr(ioaddr),
						.rda(rda),
						.bus_control_data(bus_control_data),
						.rx2bus(rx2bus));
						
baud_rate_gen brg0(   .clk(clk),
					  .rst(rst),
					  .ioaddr(ioaddr),
					  .divisor_part(bus_control_data),
					  .rate_en(rate_en));

endmodule