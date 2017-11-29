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
  output logic [DATA_WIDTH-1:0]   mem_c_read_data,
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
  
  logic [SIZE_COUNT][DATA_WIDTH-1:0] mem_a_read_data;
  logic [SIZE_COUNT][DATA_WIDTH-1:0] mem_b_read_data;
  logic [SIZE_COUNT][DATA_WIDTH-1:0] mem_c_write_data;
  logic [SIZE_COUNT][DATA_WIDTH/8-1:0] mem_c_write_strb;
  
  assign mem_c_write_strb = {SIZE_COUNT*DATA_WIDTH/8{1'b1}};
  
  genvar i;
  generate for (i=0; i<SIZE_COUNT; i++) begin
    assign mat_a_read_data [i] = mem_a_read_data [i];
    assign mat_b_read_data [i] = mem_b_read_data [i];
    assign mem_c_write_data[i] = mat_c_write_data[i];
  end endgenerate
  
  asymmertic_wr_ram #(
    .DATA_RATIO(SIZE_COUNT),
    .ADDR_DEPTH(SIZE_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) matrix_a_ram_inst (
    .clk(clk),
    .mem_if_write(mem_a_write && !busy),
    .mem_if_address(busy ? mat_a_addess : mem_a_address),
    .mem_if_write_data(mem_a_write_data),
    .mem_if_write_strb(mem_a_write_strb),
    .mem_if_read_data(mem_a_read_data)
  );
  
  asymmertic_wr_ram #(
    .DATA_RATIO(SIZE_COUNT),
    .ADDR_DEPTH(SIZE_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) matrix_b_ram_inst (
    .clk(clk),
    .mem_if_write(mem_b_write && !busy),
    .mem_if_address(busy ? mat_b_addess : mem_b_address),
    .mem_if_write_data(mem_b_write_data),
    .mem_if_write_strb(mem_b_write_strb),
    .mem_if_read_data(mem_b_read_data)
  );
  
  asymmertic_rd_ram #(
    .DATA_RATIO(SIZE_COUNT),
    .ADDR_DEPTH(SIZE_COUNT),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) matrix_c_ram_inst (
    .clk(clk),
    .mem_if_write(mat_c_write && busy),
    .mem_if_address(busy ? mat_c_addess : mem_c_address),
    .mem_if_write_data(mem_c_write_data),
    .mem_if_write_strb(mem_c_write_strb),
    .mem_if_read_data(mem_c_read_data)
  );
  
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
