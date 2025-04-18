`include "defines.v"

module dpsm_cv
  #(parameter DATA_WIDTH = 16,
    parameter L = 6)
  (
    input rstn,
    input en,
    input clk,
    input [DATA_WIDTH - 1 : 0] vqx,
    input [DATA_WIDTH - 1 : 0] vqy,
    input signed [(L + 1) * (L + 1) * DATA_WIDTH - 1 : 0] rpsm,
    input qrs,
    input cv1_flag,
    output [DATA_WIDTH - 1 : 0] y
  );

  localparam TOTAL_ELEMENTS = (L + 1) * (L + 1);
  localparam INDEX_BIT_WIDTH = $clog2(TOTAL_ELEMENTS);

  wire [DATA_WIDTH - 1 : 0] xin_array [1 : 0];
  wire [DATA_WIDTH - 1 : 0] rpsm_array [((L + 1) * (L + 1) - 1) : 0];

  reg signed [DATA_WIDTH - 1 : 0] epsm [((L + 1) * (L + 1) - 1) : 0];
  reg signed [DATA_WIDTH - 1 : 0] diff [((L + 1) * (L + 1) - 1) : 0];
  integer i;
  reg [INDEX_BIT_WIDTH - 1 : 0] index;
  reg [DATA_WIDTH - 1 : 0] counter;

  reg [DATA_WIDTH - 1 : 0] cv1;

  assign {xin_array[1], xin_array[0]} = {vqx, vqy};
  `UNPACK_ARRAY(DATA_WIDTH, TOTAL_ELEMENTS, rpsm_array, rpsm)

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      index <= 0;
    end
    else if (rstn && en)
    begin
      index <= xin_array[0] * (L + 1) + xin_array[1];
    end
  end

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < TOTAL_ELEMENTS; i++)
        epsm[i] <= 0;
    end
    else if (en && qrs)
    begin
      for (i = 0; i < TOTAL_ELEMENTS; i++)
        epsm[i] <= 0;
    end
    else if (rstn && en)
    begin
      epsm[xin_array[0] * (L + 1) + xin_array[1]] <= epsm[xin_array[0] * (L + 1) + xin_array[1]] + 1;
    end
  end

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < TOTAL_ELEMENTS; i++)
        diff[i] <= 0;
    end
    else if (en && qrs)
    begin
      for (i = 0; i < TOTAL_ELEMENTS; i++)
        diff[i] <= 0;
    end
    else if (rstn && en)
    begin
      diff[xin_array[0] * (L + 1) + xin_array[1]] <= epsm[xin_array[0] * (L + 1) + xin_array[1]] - rpsm_array[xin_array[0] * (L + 1) + xin_array[1]];
    end
  end


  // always @(posedge clk or negedge rstn)
  // begin
  //   if (!rstn)
  //     counter <= 1;
  //   else if (rstn && en)
  //   begin
  //     if (qrs == 1)
  //       counter <= 1;
  //     else 
  //       if (diff[index] != 0)
  //         counter <= counter + 1;
  //   end
  // end


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      counter = 1;
      cv1 <= 1;
    end
    else if (rstn && en)
    begin
      if (qrs == 1)
      begin
        counter = 1;
        for (i = 0; i < TOTAL_ELEMENTS; i++)
          if (diff[i] != 0)
            counter = counter + 1;
        
        if (cv1_flag)
          cv1 <= counter;
      end
    end
  end


  // always @(posedge clk or negedge rstn)
  // begin
  //   if (!rstn)
  //   begin
  //     cv1 <= 1;
  //   end
  //   else if (rstn && en)
  //   begin
  //     if (cv1_flag)
  //       cv1 <= counter;
  //   end
  // end

  assign y = (rstn && en && !cv1_flag) ? (counter / cv1) : {DATA_WIDTH{1'b0}};

endmodule