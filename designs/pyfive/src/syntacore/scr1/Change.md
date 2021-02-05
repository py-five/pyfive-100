Following changes are done for pyfive to support yosys based synthesis

cp.1 - parameter with "int unsigned" changed "bit [31:0]"
cp.2 - enum with "int" changed to "bit [31:0]"
cp.3 - new parameter defined to match the type cast of enum
cp.4 - for loop change to match basic verilog format
       old:  for (int unsigned i=0; i<16; ++i) begin
       new:  for (i=0; i<16; i=i+1) begin
cp.5 - enum typecast change to parameter value or constant value
cp.6 - change the struct with unpacked to packed
cp.7 - enum with input and output defination are not working, change to bit format and variable are changed to local param
cp.8 - struct define in inter port are expanded
cp.9 - yosys is not propgating parameter define in previous file to next file
         ERROR: Identifier `...' is implicitly declared outside of a module.
         to fix this, we have reset the define in yosys run by adding below command
         verilog_defines -USCR1_ARCH_TYPES_SVH -USCR1_ARCH_DESCRIPTION_SVH -USCR1_CSR_SVH
cp.10 - function with structure as return function is not working
cp.11 - return in function is not working, change to std verilog format
cp.12 - type define structure defination are not propgating from one file to others
cp.13 - Two dimensional Array initialization is not allowed 
cp.14 - yoysy not able to handle two dimensional function with structure and giving below error
       ERROR: Index in generate block prefix syntax is not constant!
       example; req_fifo[req_proc_ptr].axi_addr
       Fix: Remove the struture defination and logic to req_fifo_axi_addr[req_proc_ptr]
cp.15 - for loop inside the function is not working  - fix tool not allowing variable declartion after 'begin statement'
       ERROR: Left hand side of 1st expression of procedural for-loop is not a register!

cp.16 - yosys variable declartion after befine statement in function is not allowed
        ERROR: Local declaration in unnamed block is an unsupported SystemVerilog feature!
     
       
