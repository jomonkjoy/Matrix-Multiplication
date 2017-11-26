// Fully pipelined Load-enabled MAC Unit
// acc = acc + a*b
module multiply_acc #(
  parameter DATA_WIDTH = 16
) (
  input  logic clk,
  input  logic reset,
  input  logic load,
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [2*DATA_WIDTH-1:0] acc
);
  
  localparam DATA_LSB = $clog2(DATA_WIDTH/8);
  localparam ZERO = {2*DATA_WIDTH{1'b0}};
  
  logic signed [1*DATA_WIDTH-1:0] a_reg;
  logic signed [1*DATA_WIDTH-1:0] b_reg;
  logic signed [2*DATA_WIDTH-1:0] mul_reg;
  logic signed [2*DATA_WIDTH-1:0] acc_reg;
  logic signed [2*DATA_WIDTH-1:0] acc_int;
  
  assign acc_int = load ? ZERO : acc_reg;
  
  always_ff @(posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    mul_reg <= a_reg * b_reg;
    acc_reg <= acc_int + mul_reg;
  end
  
  assign acc = acc_reg[DATA_WIDTH+DATA_LSB-1:DATA_LSB];
  
endmodule
