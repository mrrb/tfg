// module test1(input clk, wen, input [10:0] addr, input [1:0] wdata, output reg [1:0] rdata);
//   reg [1:0] mem [0:2047];
//   initial mem[0] = 2;
//   always @(posedge clk) begin
//         if (wen) mem[addr] <= wdata;
//         rdata <= mem[addr];
//   end
// endmodule

// module test2(input clk, wen, input [9:0] addr, input [3:0] wdata, output reg [3:0] rdata);
//   reg [3:0] mem [0:1023];
//   initial mem[0] = 7;
//   always @(posedge clk) begin
//         if (wen) mem[addr] <= wdata;
//         rdata <= mem[addr];
//   end
// endmodule

// module test3(input clk, wen, input [8:0] addr, input [7:0] wdata, output reg [7:0] rdata);
//   reg [7:0] mem [0:1023];
//   initial mem[0] = 7;
//   always @(posedge clk) begin
//         if (wen) mem[addr] <= wdata;
//         rdata <= mem[addr];
//   end
// endmodule

module test4(input clk, wen, input [7:0] addr, input [15:0] wdata, output reg [15:0] rdata);
  reg [15:0] mem [0:1023];
  initial mem[0] = 7;
  always @(posedge clk) begin
        if (wen) mem[addr] <= wdata;
        rdata <= mem[addr];
  end
endmodule