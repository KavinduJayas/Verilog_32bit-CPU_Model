// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage
//Group : 12

`include "CPU.v"
`include "dcacheFSM_skeleton.v"
`include "icacheFSM.v"
`include "dmem_for_dcache.v"
`include "imem_for_icache.v"

`timescale 1ns/100ps

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    wire READ;
    wire WRITE;
    wire [7:0]ADDRESS;
    wire [7:0]WRITE_DATA;
    wire[7:0]READ_DATA;
    wire DBUSYWAIT;
    wire IBUSYWAIT;

    wire dmem_read;
    wire dmem_write;
    wire[5:0] dmem_address;
    wire[31:0] mem_writedata;
    wire[31:0] mem_readdata;
	wire dmem_busywait;
    
    wire imem_read;
    wire [5:0] imem_address;
    wire[127:0] mem_instruction;
	wire imem_busywait;

    reg [7:0] instr_mem[0:1023];//instruction memory array

    cpu mycpu(PC, INSTRUCTION, CLK, RESET,READ,WRITE,ADDRESS,WRITE_DATA,READ_DATA,DBUSYWAIT);
    
    dcache data_cache(CLK,RESET,READ,WRITE,ADDRESS,WRITE_DATA,READ_DATA,DBUSYWAIT,dmem_read,dmem_write,dmem_address,mem_writedata,mem_readdata,dmem_busywait);
    data_memory dmem(CLK,RESET,dmem_read,dmem_write,dmem_address,mem_writedata,mem_readdata,dmem_busywait);
    
    icache inst_cache(CLK,RESET,PC,IBUSYWAIT,INSTRUCTION,imem_read,imem_busywait,imem_address,mem_instruction);
    instruction_memory imem(CLK,imem_read,imem_address,mem_instruction,imem_busywait);


    /* 
    -----
     CPU
    -----
    */

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;

        //creating a reset pulse of 5 time units
        RESET = 1'b1;
        #5
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        // finish simulation after some time
        #3000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule