//Author : Ishaan Sethi
//Module that implements the CORDIC algorithm to obtain the sine and cosine of a given angle. 
module cordic(clk, angle, sine, cosine);
  input clk;
  input signed [31:0] angle; //Decimal value mapped to 2^32 for integer operations.
  output signed [15:0] sine; //16bit outputs.
  output signed [15:0] cosine;
  
  //13 Iterations
  //x = Real Part, y = Imaginary Part
  //z = Phase remaining to be rotated 
  //scaling_factor = Rotations introduce a scaling factor that is mapped onto 2^15 and will be multiplied with the vector. 
  //sector = Current quadrant, given by last two bits of the phase - sign of an and > or < 90degrees.
  reg signed [15:0] x [0:12];
  reg signed [15:0] y [0:12];
  reg signed [31:0] z [0:12];
  parameter scaling_factor = 32768*0.6071645;
  wire [1:0] sector;
  assign sector = angle[31:30];
  
  //Assign outputs.
  assign sine = y[12];
  assign cosine = x[12];
  
  //Table of angle values for use with z. Angles obtained as arctan(2^(-i)), then mapped to 2^32. 
  wire signed [31:0] theta [0:12];
  assign theta [ 0] = 'h20000000;  //45 degrees
  assign theta [ 1] = 'h12E4051D;  //26.565051177078 degrees
  assign theta [ 2] = 'h9FB385B;   //14.0362434679265 degrees
  assign theta [ 3] = 'h51111D4;   //7.1250163489018 degrees
  assign theta [ 4] = 'h28B0D43;   //3.57633437499735 degrees
  assign theta [ 5] = 'h145D7E1;   //1.78991060824607 degrees
  assign theta [ 6] = 'hA2F61E;    //0.895173710211074 degrees
  assign theta [ 7] = 'h517C55;    //0.447614170860553 degrees
  assign theta [ 8] = 'h28BE53;    //0.223810500368538 degrees
  assign theta [ 9] = 'h145F2E;    //0.111905677066207 degrees
  assign theta [10] = 'hA2F98;     //0.0559528918938037 degrees
  assign theta [11] = 'h517CC;     //0.0279764526170037 degrees
  assign theta [12] = 'h28BE6;     //0.013988227142265 degrees
  
  //Pre-rotating vector based on quadrant - in order to bring it between 90 and -90
  always @(posedge clk)
  begin 
	//Nothing to be done for Q1, Q4.
    if (sector == 2'b00) begin
	  x[0] <= scaling_factor;
      y[0] <= 0;
      z[0] <= angle;      
    end
	
    else if  (sector == 2'b11) begin
	  x[0] <= scaling_factor;
      y[0] <= 0;
      z[0] <= angle;      
    end      
    
	//Reduce by 90deg for Q2. 
    else if (sector == 2'b01) begin
      x[0] <= -0;
      y[0] <= scaling_factor;
      z[0] <= {2'b00,angle[29:0]};      
    end
	
	//Increase by 90deg for Q3.
    else if (sector == 2'b10) begin
      x[0] <= 0;
      y[0] <= -scaling_factor;
      z[0] <= {2'b11,angle[29:0]};
    end
  end

  //Loop that performs the rotation operation every rising clock edge. 
  genvar i;
  generate
    for (i=0; i<13; i=i+1)
      begin
		//sgn decides whether to go clockwise or anti-clockwise.
        wire sgn; 
	assign sgn = z[i][31]; //sign bit of z.
		
        //Rotation acheived by shifting and adding.
	wire signed [15:0] xnew, ynew;
        assign xnew = x[i] >>> i; //Sign-preserving right shift.
        assign ynew = y[i] >>> i;
		
        always @(posedge clk)
          begin
            if (sgn==1)
              begin
                x[i+1] <= x[i]+ynew;
                y[i+1] <= y[i]-xnew;
                z[i+1] <= z[i]+theta[i];
              end
            else
              begin
                x[i+1] <= x[i]-ynew;
                y[i+1] <= y[i]+xnew;
                z[i+1] <= z[i]-theta[i];
              end
          end
      end
  endgenerate
  

endmodule
