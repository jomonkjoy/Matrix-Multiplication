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
  
  localparam ADDR_LSB = $clog2(DATA_WIDTH/8);
  localparam ADDR_MSB = $clog2((DATA_RATIO*DATA_WIDTH)/8);
  
  logic [DATA_RATIO][DATA_WIDTH-1:0] int_if_write_data;
  logic [DATA_RATIO][DATA_WIDTH/8-1:0] int_if_write_strb;
  
  assign int_if_write_data = {DATA_RATIO{mem_if_write_data}};
  assign int_if_write_strb = mem_if_write_strb << mem_if_address[ADDR_MSB-1:ADDR_LSB];
  
  byte_write_spram #(
    .ADDR_DEPTH(ADDR_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH*DATA_RATIO)
  ) byte_write_spram_inst (
    .clk(clk),
    .mem_if_write(mem_if_write),
    .mem_if_address(mem_if_address),
    .mem_if_write_data(int_if_write_data),
    .mem_if_write_strb(int_if_write_strb),
    .mem_if_read_data(mem_if_read_data)
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
  
  localparam ADDR_LSB = $clog2(DATA_WIDTH/8);
  localparam ADDR_MSB = $clog2((DATA_RATIO*DATA_WIDTH)/8);
  
  logic [ADDR_WIDTH-1:0] mem_if_address_r;
  logic [DATA_RATIO][DATA_WIDTH-1:0] int_if_read_data;
  
  always_ff @(posedge clk) begin
    mem_if_address_r <= mem_if_address;
  end
  
  assign mem_if_read_data = int_if_read_data[mem_if_address_r[ADDR_MSB-1:ADDR_LSB]];
  
  byte_write_spram #(
    .ADDR_DEPTH(ADDR_DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH*DATA_RATIO)
  ) byte_write_spram_inst (
    .clk(clk),
    .mem_if_write(mem_if_write),
    .mem_if_address(mem_if_address),
    .mem_if_write_data(mem_if_write_data),
    .mem_if_write_strb(mem_if_write_strb),
    .mem_if_read_data(int_if_read_data)
  );
  
endmodule
