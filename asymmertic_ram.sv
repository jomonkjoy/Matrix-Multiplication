module asymmertic_wr_ram #(
  parameter DATA_RATIO = 8,
  parameter ADDR_DEPTH = 32,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic mem_if_write,
  input  logic [ADDR_WIDTH-1:0] mem_if_address,
  input  logic [DATA_WIDTH-1:0] mem_if_write_data,
  input  logic [DATA_WIDTH/8-1:0] mem_if_write_strb,
  output logic [DATA_RATIO][DATA_WIDTH-1:0] mem_if_read_data
);

endmodule

module asymmertic_rd_ram #(
  parameter DATA_RATIO = 8,
  parameter ADDR_DEPTH = 32,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic mem_if_write,
  input  logic [ADDR_WIDTH-1:0] mem_if_address,
  input  logic [DATA_RATIO][DATA_WIDTH-1:0] mem_if_write_data,
  input  logic [DATA_RATIO][DATA_WIDTH/8-1:0] mem_if_write_strb,
  output logic [DATA_WIDTH-1:0] mem_if_read_data
);

endmodule
