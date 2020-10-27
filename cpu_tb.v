// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage
`include "CPU.v"

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    //wire [31:0] CPU_INSTRUCTION;
    reg [7:0] instr_mem[0:1023];

/*//this works too but need a wire to be passed to the cpu and a reg to be assigned
    always @ (PC,INSTRUCTION) begin
        INSTRUCTION[31:24] <= #2 instr_mem[PC];
        INSTRUCTION[23:16] <= #2 instr_mem[PC+32'b0001];
        INSTRUCTION[15:8] <= #2 instr_mem[PC+32'b0010];
        INSTRUCTION[7:0] <= #2 instr_mem[PC+32'b0011];
    end
*/

    assign #2 INSTRUCTION[7:0] = instr_mem[PC];//is it okay to do continuous assignment with a variable index??
    assign #2 INSTRUCTION[15:8] = instr_mem[PC+32'b0001];//works fine but practically makes no sense to me  
    assign #2 INSTRUCTION[23:16] = instr_mem[PC+32'b0010];
    assign #2 INSTRUCTION[31:24] = instr_mem[PC+32'b0011];
    //assign CPU_INSTRUCTION = INSTRUCTION;

    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
/*
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        */
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
       // $monitor($time,"cmplmt_falg = %b immdte_flag=%b",COMPLEMENT_FLAG,IMMEDIATE_FLAG);
        
        CLK = 1'b0;
        RESET = 1'b1;
        #5
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule