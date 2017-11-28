module matrix_multiply_top #(
  parameter SIZE_COUNT = 8,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic                    clk,
  input  logic                    reset,
  input  logic                    start,
  input  logic [SIZE_WIDTH-1:0]   mat_a_size[2],
  input  logic [SIZE_WIDTH-1:0]   mat_b_size[2],
  input  logic                    mem_a_write,
  input  logic [ADDR_WIDTH-1:0]   mem_a_address,
  input  logic [DATA_WIDTH-1:0]   mem_a_write_data,
  input  logic [DATA_WIDTH/8-1:0] mem_a_write_strb,
  input  logic                    mem_b_write,
  input  logic [ADDR_WIDTH-1:0]   mem_b_address,
  input  logic [DATA_WIDTH-1:0]   mem_b_write_data,
  input  logic [DATA_WIDTH/8-1:0] mem_b_write_strb,
  input  logic [ADDR_WIDTH-1:0]   mem_c_address,
  output logic [DATA_WIDTH-1:0]   mem_c_read_data
  output                          busy
);

localparam SIZE_WIDTH = $clog2(SIZE_COUNT);

logic [ADDR_WIDTH-1:0] mat_a_addess;
logic [DATA_WIDTH-1:0] mat_a_read_data[SIZE_COUNT];
logic [ADDR_WIDTH-1:0] mat_b_addess;
logic [DATA_WIDTH-1:0] mat_b_read_data[SIZE_COUNT];
logic                  mat_c_write;
logic [ADDR_WIDTH-1:0] mat_c_addess;
logic [DATA_WIDTH-1:0] mat_c_write_data[SIZE_COUNT];

matrix_multiply #(
  .SIZE_COUNT (SIZE_COUNT),
  .SIZE_WIDTH (SIZE_WIDTH)
  .ADDR_WIDTH (ADDR_WIDTH),
  .DATA_WIDTH (DATA_WIDTH)
) matrix_multiply_inst (
  .clk(clk),
  .reset(reset),
  .start(start),
  .mat_a_size(mat_a_size),
  .mat_b_size(mat_b_size),
  .mat_a_addess(mat_a_addess),
  .mat_a_read_data(mat_a_read_data),
  .mat_b_addess(mat_b_addess),
  .mat_b_read_data(mat_b_read_data),
  .mat_c_write(mat_c_write),
  .mat_c_addess(mat_c_addess),
  .mat_c_write_data(mat_c_write_data),
  .busy(busy)
);

endmodule
