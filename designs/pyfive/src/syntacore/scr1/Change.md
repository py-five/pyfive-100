Following changes are done for pyfive to support yosys based synthesis

cp.1 - parameter with "int unsigned" changed "bit [31:0]"
cp.2 - enum with "int" changed to "bit [31:0]"
cp.3 - new parameter defined to match the type cast of enum
cp.4 - for loop change to match basic verilog format
       old:  for (int unsigned i=0; i<16; ++i) begin
       new:  for (int i=0; i<16; i=i+1) begin
cp.5 - enum typecast change to parameter value
cp.6 - change the struct with unpacked to packed
