loadi 0 0x09 // 0 <-- 9 
loadi 1 0x01 // 1 <-- 1  
swd 0 1 //write miss 000 000 [01]  <-- 9
swi 1 0x00 //write hit 000 000 [00] <-- 1 
lwd 2 1 // read hit 000 000 [01] <-- 9
lwd 3 1 // read hit 000 000 [01] <-- 9    
sub 4 0 1 //reg 4 <-- 8     
swi 4 0x02 //write hit 000 000 [10] <-- 8
lwi 5 0x02 //read hit reg 5 <-- 8   
swi 4 0x20 //write miss 001 000 [00] <-- 8       
lwi 6 0x20 //read hit <--- 8

// 000 - [0] [8] [9] [1] -------> [0] [8] [9] [1]
// 000 - [0] [0] [0] [8] <-------