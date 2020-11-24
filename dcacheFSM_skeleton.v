/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns/100ps

module dcache (
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
    mem_busywait
    );

    //cpu port
    input				clock;
    input           	reset;
    input           	read;
    input           	write;
    input[7:0]      	address;
    input[7:0]     	    writedata;
    output reg [7:0]	readdata;
    output reg      	busywait;

    //memory port
    input [31:0]	    mem_readdata;
    input       	    mem_busywait;
    output reg         	mem_read;
    output reg         	mem_write;
    output reg[5:0]     mem_address;
    output reg[31:0]    mem_writedata;

    wire[2:0] tag;
    wire[2:0] index;
    wire[1:0] offset;

    wire dirty;
    wire hit;
    wire valid;
    wire[2:0] cache_tag;//relevent tag value in the cache
    
    integer i;
    
    reg[36:0] cache_mem[7:0];//valid,   dirty,  tag,    data              8-blocks
    //                         1bit     1bit    3bit    32bit(4 bytes)    ==> 37bit

    //Combinational part for indexing, tag comparison for hit deciding, etc.
    assign #1 tag = address[7:5];
    assign #1 index = address[4:2];//extracting relevent bits from the instruction
    assign #1 offset = address[1:0];

    assign cache_tag = cache_mem[index][34:32];
    assign valid = cache_mem[index][36];
    assign dirty = cache_mem[index][35];

    assign #0.9 hit = (valid && (tag==cache_tag)) ? 1 : 0;//tag comparison and checking for validity

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;
                else 
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = IDLE;
                else    
                    next_state = MEM_READ;

            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 8'dx;
                busywait = 0;                

            end
        
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                busywait = 1;
                #1 if(!mem_busywait) begin //storing the correct data ftched from memory due to a miss
                cache_mem[index] =  {1'b1,1'b0,tag,mem_readdata};
                end
            end

            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {cache_tag, index};
                mem_writedata = cache_mem[index][31:0];//4 bytes of data in the corresponding index
                busywait = 1;
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

    /* Cache Controller FSM End */ 

    //writing 
    always @(posedge clock, reset)
    begin
        if(reset) begin
            for(i=0;i<8;i++) begin
                cache_mem[i] = 0;
            end
        end else if(write && hit) begin
            cache_mem[index][36:32] = {1'b1,1'b1,tag};//valid dirty
            case (offset)
                0: cache_mem[index][7:0] = #1 {writedata};
                1: cache_mem[index][15:8] = #1 {writedata};
                2: cache_mem[index][23:16] = #1 {writedata};
                3: cache_mem[index][31:24] = #1 {writedata};
            endcase
        end
    end

    //reading
    always @ (*) begin 
    if(read)
    begin
        case(offset)
        2'b00:readdata = #1 cache_mem[index][7:0];
        2'b01:readdata = #1 cache_mem[index][15:8];
        2'b10:readdata = #1 cache_mem[index][23:16];
        2'b11:readdata = #1 cache_mem[index][31:24];
        default: readdata = 8'bz;
        endcase
    end
    end
    //   /* START DEBUGGING CODE (Not required in the usual implementation */
    // initial
    // begin
    // // monitor changes in reg file content and print (used to check whether the CPU is running properly)
    // $display("\n\t\t\t=================================================");
    // $display("\t\t\t Change of Cache Content Starting from Time #5");
    // $display("\t\t\t==================================================\n");
    // $display("\t\ttime\treg0\treg1\treg2\treg3\treg4\t");
    // $display("\t\t-----------------------------------------------------");
    // $monitor($time, "\t%d\t%d\t%d\t%d",cache_mem[0][0],cache_mem[0][1],cache_mem[0][2],cache_mem[0][3]);
    // end
    // /* END DEBUGGING CODE */
endmodule
