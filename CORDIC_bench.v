//Author : Ishaan Sethi
//Testbench for the CORDIC module.
module tbench;
  
  //Creating I/O
  reg clk;
  reg [31:0] angle;
  wire [15:0] sine;
  wire [15:0] cosine;
  
  //Creating an instance of the module
  cordic tr(clk, angle, sine, cosine);
  
  //Clock with period = 1 unit
  initial clk = 1'b0;
  always #1 clk = ~clk;
  
  initial angle = 'h35555555; //75deg

  //5 Tests for different angles
  initial begin
    //Dumpfile for EPWave.
	$dumpfile("dump.vcd");
    $dumpvars;
    
    #100 angle = 'h20000000; //Test 1, 45deg
    #100 angle = 'h40000000; //Test 2, 90deg
    #100 angle = 'h2AAAAAAA; //Test 3, 60deg
    #100 angle = 'hA38E38E3; //Test 4, 230deg
    #100 angle = 'hEAAAAAAA; //Test 5, 330deg

  end
  
  //Strobe
  always #50 $strobe("Angle : ", angle," Sine : ",sine," Cosine : ", cosine);
  
  //Stop after 700 units
  initial #700 $finish;


endmodule