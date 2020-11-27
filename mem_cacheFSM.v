/*

word size 4 bytes
cache   128 bytes 128/16    3'b <== index
block    16 bytes           2'b <== offset
memory 1024 bytes 1024/128  3'b <== tag

*/

`timescale 1ns/100ps

module mem_cache(
    pc,
    instruction
    busywait,
    mem_address,
    mem_instruction,
    mem_busywait
);

    input [31:0] pc;
    output busywait;
    output[31:0] instruction;

    output[8:0] mem_address;
    input mem_busywait;
    input [127:0] mem_instruction;

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
    assign #1 tag = pc[12:7];
    assign #1 index = pc[6:4];//extracting relevent bits from the instruction
    assign #1 offset = pc[3:2];

    assign cache_tag = cache_mem[index][130:128];
    assign valid = cache_mem[index][131];

    assign #0.9 hit = (valid && (tag==cache_tag)) ? 1 : 0;//tag comparison and checking for validity
    
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b0, MEM_READ = 3'b1;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit)//miss  
                    next_state = MEM_READ;
                else 
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = IDLE;
                else    
                    next_state = MEM_READ;
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_address = 9'bz;
                busywait = 0;                

            end
        
            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = {tag, index};
                busywait = 1;
                #1 if(!mem_busywait) begin //storing the correct data ftched from memory due to a miss
                cache_mem[index] =  {1'b1,tag,mem_readdata};//valid
                end
            end
            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end

    //reading
    always @ (*) begin 
    if(hit)
    begin
        case(offset)
        2'b00:readdata = #1 cache_mem[index][31:0];
        2'b01:readdata = #1 cache_mem[index][64:32];
        2'b10:readdata = #1 cache_mem[index][96:65];
        2'b11:readdata = #1 cache_mem[index][128:97];
        default: readdata = 8'bz;
        endcase
    end

endmodule
