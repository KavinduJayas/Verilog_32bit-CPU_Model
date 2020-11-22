module cache(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
	mem_clock,
    mem_reset,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
    mem_busywait
);

input				clock;
input           	reset;
input           	read;
input           	write;
input[7:0]      	address;
input[31:0]     	writedata;
output reg [31:0]	readdata;
output reg      	busywait;

input				mem_clock;
input           	mem_reset;
input           	mem_read;
input           	mem_write;
input[7:0]      	mem_address;
input[31:0]     	mem_writedata;
output reg [31:0]	mem_readdata;
output reg      	mem_busywait;

wire tag;
wire index;
wire offset;

assign tag = address[7:5];
assign index = address[4:2];
assign offset = address[1:0];

endmodule