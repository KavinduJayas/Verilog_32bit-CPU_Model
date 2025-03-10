/*

word size 4 bytes
cache   128 bytes 128/16    3'b <== index
block    16 bytes           2'b <== offset
memory 1024 bytes 1024/128  3'b <== tag

*/

`timescale 1ns/100ps

module icache(
	clock,
    reset,
    pc,
    busywait,
    instruction,
    mem_read,
    mem_busywait,
    mem_address,
    mem_instruction
);
    input clock;
    input reset;
    input [31:0] pc;
    output reg busywait;
    output reg [31:0] instruction;

    output reg mem_read;
    input mem_busywait;
    output reg [5:0] mem_address;
    input [127:0] mem_instruction;//read data from memory

    wire[2:0] tag;
    wire[2:0] index;
    wire[1:0] offset;

    wire[2:0] cache_tag;//relevent tag value in the cache

    integer i;

    //                8-blocks
    //                   ||
    reg[131:0] cache_mem[7:0];//valid,  tag,    data                         
    //                          1bit    3bit    128bit(16 bytes/4 words)     ==> 132bit

    //Combinational part for indexing, tag comparison for hit deciding, etc.
    assign #1 tag = pc[9:7];
    assign #1 index = pc[6:4];//extracting relevent bits from the pc
    assign #1 offset = pc[3:2];

    assign cache_tag = cache_mem[index][130:128];
    assign valid = cache_mem[index][131];

    assign #0.9 hit = (valid && (tag==cache_tag)) ? 1 : 0;//tag comparison and checking for validity

    parameter IDLE = 3'b0, MEM_READ = 3'b1;
    reg [2:0] state, next_state;

    always @(posedge clock)begin
        if(reset) begin
            for(i=0;i<8;i++) begin
                cache_mem[i] = 0;
            end
        end 
        else if (hit) busywait = 0;
        else begin
            busywait = 1;
            mem_read = 1;
            mem_address = {tag, index};
            #1 if(!mem_busywait)begin //storing the correct data ftched from memory due to a miss
            cache_mem[index] =  {1'b1,tag,mem_instruction};//valid
            mem_read = 0;
        end
    end
    end

    //reading
    always @ (*) begin 
    if(hit)
    begin
        case(offset)
        2'b00:instruction = #1 cache_mem[index][31:0];
        2'b01:instruction = #1 cache_mem[index][63:32];
        2'b10:instruction = #1 cache_mem[index][95:64];
        2'b11:instruction = #1 cache_mem[index][127:96];
        default: instruction = 8'bz;
        endcase
    end
    end
endmodule
