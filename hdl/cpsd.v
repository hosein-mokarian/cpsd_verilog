`include "shift_register.v"
`include "space_vector.v"
`include "quantization.v"
`include "psm.v"
`include "thresholding.v"
`include "timer.v"
`include "control_unit.v"


module cpsd_top
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input start,
    input [DATA_WIDTH - 1 : 0] xin,
    input [DATA_WIDTH - 1 : 0] max,
    input qrs,
    output normal,
    output AF,
    output VF
  );


  parameter ALIGNED_SHIFT = 30;
  parameter D = 6;
  parameter L = 6;
  parameter NB_DEMUX_OUPUTS = 2;
  parameter PERIOD_8000MS = 1600;


  wire [DATA_WIDTH - 1 : 0] sr_out;

  wire [DATA_WIDTH - 1 : 0] vector_x;
  wire [DATA_WIDTH - 1 : 0] vector_y;
  wire [DATA_WIDTH - 1 : 0] vector_norm_x;
  wire [DATA_WIDTH - 1 : 0] vector_norm_y;

  wire [NB_DEMUX_OUPUTS - 1 : 0] which_phase;

  wire cv1_flag;
  wire [DATA_WIDTH - 1 : 0] cpsd_n;

  reg [DATA_WIDTH - 1 : 0] thr1 = 5;
  reg [DATA_WIDTH - 1 : 0] thr2 = 10;
  reg [DATA_WIDTH - 1 : 0] thrh = 3;

  wire timer_trigger;
  wire timer_update_flag;

  
  shift_register
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .NB_OF_REGS(ALIGNED_SHIFT)
  )
  SR1
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .xin(xin),
    .y(sr_out)
  );


  space_vector
  #(.DATA_WIDTH(DATA_WIDTH),
    .d(D)
  )
  SV
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .xin(sr_out),
    .qrs(qrs),
    .vx(vector_x),
    .vy(vector_y)
  );

  
  quantization
  #(.DATA_WIDTH(DATA_WIDTH),
    .d(D),
    .L(L)
  )
  NORM
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .M(max),
    .vx(vector_x),
    .vy(vector_y),
    .vqx(vector_norm_x),
    .vqy(vector_norm_y)
  );


  psm
  #(.DATA_WIDTH(DATA_WIDTH),
    .L(L)
  )
  PSM
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .vqx(vector_norm_x),
    .vqy(vector_norm_y),
    .thrh(thrh),
    .qrs(qrs),
    .cv1_flag(cv1_flag),
    .test_phase(which_phase[0]),
    .CPSD(cpsd_n)
  );


  thresholding
  #(.DATA_WIDTH(DATA_WIDTH))
  THR
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .xin(cpsd_n),
    .thr1(thr1),
    .thr2(thr2),
    .normal(normal),
    .AF(AF),
    .VF(VF)
  );


  timer
  #(.PERIOD(PERIOD_8000MS))
  TIMER_8S
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .start(timer_trigger),
    .update_flag(timer_update_flag)
  );


  control_unit
  #(.DATA_WIDTH(DATA_WIDTH))
  CU
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .qrs(qrs),
    .start(start),
    .timer_update_flag(timer_update_flag),
    .timer_trigger(timer_trigger),
    .which_phase(which_phase),
    .cv1_flag(cv1_flag)
  );

endmodule
