// `include "defines.v"
`include "shiftable_memory.v"
`include "memory.v"
`include "adder.v"
`include "sub.v"


module psm
  #(parameter DATA_WIDTH = 16,
    parameter L = 6
  )
  (
    input rstn,
    input en,
    input clk,
    input [DATA_WIDTH - 1 : 0] vqx,
    input [DATA_WIDTH - 1 : 0] vqy,
    input [DATA_WIDTH - 1 : 0] thrh,
    input qrs,
    input cv1_flag,
    input test_phase,
    output reg [DATA_WIDTH - 1 : 0] CPSD
  );


  localparam TOTAL_ELEMENTS = (L + 1) * (L + 1);
  localparam INDEX_BIT_WIDTH = $clog2(TOTAL_ELEMENTS);


  wire [DATA_WIDTH - 1 : 0] A;
  wire shiftA;
  wire [DATA_WIDTH - 1 : 0] RPSM;
  wire [DATA_WIDTH - 1 : 0] EPSM;
  wire [DATA_WIDTH - 1 : 0] DPSM;

  wire [DATA_WIDTH - 1 : 0] EPSM_Next;
  wire [DATA_WIDTH - 1 : 0] DPSM_Next;

  reg signed [DATA_WIDTH - 1 : 0] thr_counter;
  reg signed [DATA_WIDTH - 1 : 0] non_zero_counter;
  reg [DATA_WIDTH - 1 : 0] CV1;
  reg [DATA_WIDTH - 1 : 0] CVn;


  assign A = vqx * L + vqy;


  shiftable_memory
  #(.DATA_WIDTH(DATA_WIDTH),
    .MEM_CAPACITY(TOTAL_ELEMENTS)
  )
  MEM_REPSM
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .A(A),
    .shiftA(shiftA),
    .WDB(EPSM_Next),
    .WEB(1'b1),
    .clrB(qrs),
    .RDA(RPSM),
    .RDB(EPSM)
  );


  adder
  #(.DATA_WIDTH(DATA_WIDTH))
  ADDER_EPSM
  (
    .rstn(rstn),
    .en(en),
    .a(EPSM),
    .b({{(DATA_WIDTH - 1){1'b0}} , 1'b1}),
    .y(EPSM_Next)
  );


  sub
  #(.DATA_WIDTH(DATA_WIDTH))
  SUB_DPSM
  (
    .rstn(rstn),
    .en(en),
    .a(RPSM),
    .b(EPSM_Next),
    .y(DPSM_Next)
  );

  
  memory
  #(.DATA_WIDTH(DATA_WIDTH))
  MEM_DPSM
  (
    .rstn(rstn),
    .en(en),
    .clk(clk),
    .clr(qrs),
    .A(A),
    .WE(1'b1),
    .WD(DPSM_Next),
    .RD(DPSM)
  );


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      thr_counter <= 0;
    end
    else if (rstn && en)
    begin
      if (!test_phase)
      begin
        if (qrs)
          thr_counter <= 0;
        else if (DPSM >= thrh && DPSM_Next < thrh)
          thr_counter <= thr_counter + 1;
        else if (DPSM < thrh && DPSM_Next >= thrh && thr_counter != 0)
          thr_counter <= thr_counter - 1;
      end
    end
  end


  assign shiftA = (rstn && en && !test_phase && qrs && thr_counter == 0) ? 1 : 0;


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      non_zero_counter <= 0;
    end
    else if (rstn && en)
    begin
      if (test_phase)
      begin
        if (qrs)
          non_zero_counter <= 0;
        else if (DPSM == 0 && DPSM_Next != 0)
          non_zero_counter <= non_zero_counter + 1;
        else if (DPSM != 0 && DPSM_Next == 0)
          non_zero_counter <= non_zero_counter - 1;
      end
    end
  end


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      CV1 <= 1;
      CVn <= 0;
    end
    else if (rstn && en)
    begin
      if (test_phase)
        if (qrs)
          if (cv1_flag)
            CV1 <= (non_zero_counter == 0) ? (non_zero_counter + 1) : non_zero_counter;
          else
            CVn <= non_zero_counter;
    end
  end


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      CPSD <= {DATA_WIDTH{1'b0}};
    end
    else if (rstn && en)
    begin
      if (!cv1_flag)
        if (qrs)
          CPSD <= CVn / CV1;
    end
  end


endmodule
