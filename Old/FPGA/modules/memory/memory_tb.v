// Modulo de memoria. Test Bench.
// Mario Rubio.

`include "memory.v"

module memory_tb ();

  parameter Addr_width = 3;
  parameter Data_width = 8;

  reg CS, PW, PR, PS, SD, SV;
  wire ERR;
  wire DEBUG;

  reg [Addr_width-1:0]ADDR;
  wire [Data_width-1:0]DATA;

  memory #(.Addr_width(Addr_width),
           .Data_width(Data_width))
          mem
          (.CS(CS),
           .PW(PW),
           .PR(PR),
           .PS(PS),
           .SD(SD),
           .SV(SV),
           .ADDR(ADDR),
           .ERR(ERR),
           .DATA(DATA));

  // initial begin
  //   $monitor("CS=%0d PR=%0d OUT=%0d", CS, PR, DEBUG);
  //   CS = 0;
  //   PR = 0;
  //   PS = 0;
  //   PW = 0;
  //   #1 CS = 1;
  //   #1 PR = 1;
  //   #1 PR = 0;
  //   #1 PR = 1;
  //   #1 CS = 0;
  //   #1 $finish;
  // end
  reg [Data_width-1:0]ctrl = 8'bzzzzzzzz;
  assign DATA = ctrl;
  initial begin
    $display("%b", {8{1'bz}} );
    CS = 0; PW = 0; PR = 0; PS = 0; SD = 0; SV = 0;
    $monitor("CS=%b, PR=%b, PW=%b, PS=%b, SD=%b, SV=%b, DATA=%b, ADDR=%b", CS, PR, PW, PS, SD, SV, DATA, ADDR);
    #1 CS = 0; PW = 0; PR = 0; PS = 0; SD = 0; SV = 0;
    $display("Memory Write!");
    #1 CS = 1; ADDR = 3'b001; ctrl = 8'b00001111;
    #1 PW = 1;
    #1 ctrl = 8'bzzzzzzzz;
    #1 PW = 0;

    $display("Memory Read!");
    #1 PR = 1;

    #1 CS = 0; PW = 0; PR = 0; PS = 0; SD = 0; SV = 0;
    $display("Memory Shift!");
    #1 CS = 1; ADDR = 3'b001; PS = 1;
    #1 PS = 0;
    #1 PR = 1;
    #1 PR = 0; SD = 1; SV = 1;
    #1 PS = 1;
    #1 PS = 0;
    #1 PR = 1;


  end

endmodule
