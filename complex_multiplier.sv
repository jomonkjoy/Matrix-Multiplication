// Fully pipelined Complex multiplier Unit
// p = (a + ib) * (c + id)
module complex_multiplier #(
  parameter DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic reset,
  input  logic [DATA_WIDTH-1:0] a,
  input  logic [DATA_WIDTH-1:0] b,
  output logic [2*DATA_WIDTH-1:0] p
);
  
  typedef struct packed {
    logic signed [DATA_WIDTH/2-1:0] r;
    logic signed [DATA_WIDTH/2-1:0] i;
  } complex_type;
  
  complex_type a_reg[5];
  complex_type b_reg[5];
  logic signed [DATA_WIDTH-1:0] comon_factor_add;
  logic signed [DATA_WIDTH-1:0] comon_factor_mul;
  logic signed [DATA_WIDTH-1:0] comon_factor_reg;
  logic signed [DATA_WIDTH-1:0] prod_r_add;
  logic signed [DATA_WIDTH-1:0] prod_r_mul;
  logic signed [DATA_WIDTH-1:0] prod_r_cfr;
  logic signed [DATA_WIDTH-1:0] prod_r_reg;
  logic signed [DATA_WIDTH-1:0] prod_i_add;
  logic signed [DATA_WIDTH-1:0] prod_i_mul;
  logic signed [DATA_WIDTH-1:0] prod_i_cfr;
  logic signed [DATA_WIDTH-1:0] prod_i_reg;
  
  always_ff @(posedge clk) begin
    a_reg[0] <= a;
    a_reg[1] <= a_reg[0];
    a_reg[2] <= a_reg[1];
    a_reg[3] <= a_reg[2];
    a_reg[4] <= a_reg[3];
  end
  
  always_ff @(posedge clk) begin
    b_reg[0] <= b;
    b_reg[1] <= b_reg[0];
    b_reg[2] <= b_reg[1];
    b_reg[3] <= b_reg[2];
    b_reg[4] <= b_reg[3];
  end
  // commonn factor = (a-bi) * di
  always_ff @(posedge clk) begin
    comon_factor_add <= a_reg[0].r - a_reg[0].i;
    comon_factor_mul <= comon_factor_add * b_reg[1].i;
    comon_factor_reg <= comon_factor_mul;
  end
  
  always_ff @(posedge clk) begin
    prod_r_add <= b_reg[3].r - b_reg[3].i;
    prod_r_mul <= prod_r_add * a_reg[4].r;
    prod_r_cfr <= comon_factor_reg;
    prod_r_reg <= prod_r_mul + prod_r_cfr;
  end
  
  always_ff @(posedge clk) begin
    prod_i_add <= b_reg[3].r + b_reg[3].i;
    prod_i_mul <= prod_i_add * a_reg[4].i;
    prod_i_cfr <= comon_factor_reg;
    prod_i_reg <= prod_i_mul + prod_i_cfr;
  end
  
  assign p = {prod_r_reg,prod_i_reg};
  
endmodule
