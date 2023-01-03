module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write, line_status_in, input_right, input_left, input_down
           );
   input clk, rst;
   input [4:0] read1regsel;
   input [4:0] read2regsel;
   input [4:0] writeregsel;
   input [31:0] writedata;
   input        write;
   input [31:0] line_status_in;
   // From Input.sv
   input        input_right;
   input        input_left;
   input        input_down;


   output [31:0] read1data;
   output [31:0] read2data;
   output        err;

   reg     [31:0]       gen_reg [0:8];
	reg     [31:0]       reg_31;
   reg     [11:0]       input_reg;

    always @(posedge clk) begin
       if (write & (writeregsel < 5'h9)) begin
	            gen_reg[writeregsel] = writedata;       // The actual write
       end else if (write & (writeregsel == 5'h08)) begin
                input_reg = writedata[14:3];
       end else if (write & (writeregsel == 5'h1F)) begin
               reg_31 = writedata[14:0];
       end
    end

    assign read1data = (read1regsel < 5'h9) ? gen_reg[read1regsel] : (read1regsel == 5'h09) ? line_status_in : (read1regsel == 5'h0A) ? {17'b0,input_reg,{input_right, input_left, input_down}} : (read1regsel == 5'h1F) ? reg_31 : 32'hx;
	 assign read2data = (read2regsel < 5'h9) ? gen_reg[read2regsel] : (read2regsel == 5'h09) ? line_status_in : (read2regsel == 5'h0A) ? {17'b0,input_reg,{input_right, input_left, input_down}} : (read2regsel == 5'h1F) ? reg_31 : 32'hx;	
endmodule

