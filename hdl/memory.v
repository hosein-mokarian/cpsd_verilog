module memory
  #(parameter DATA_WIDTH = 16,
    parameter L = 6)
  (
    input rstn,
    input en,
    input clk,
    input clr,
    input [DATA_WIDTH - 1 : 0] A,
    input WE,
    input [DATA_WIDTH - 1 : 0] WD,
    output [DATA_WIDTH - 1 : 0] RD
  );

  localparam TOTAL_ELEMENTS = (L + 1) * (L + 1);

  reg [DATA_WIDTH - 1 : 0] mem [TOTAL_ELEMENTS - 1 : 0];
  integer i;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < TOTAL_ELEMENTS; i++)
        mem[i] <= 0;
    end
    else if (rstn && en)
    begin
      if (clr)
      begin
        for (i = 0; i < TOTAL_ELEMENTS; i++)
          mem[i] <= 0;
      end
      else if (WE)
        mem[A] <= WD;
    end
  end

  assign RD = (rstn && en) ? mem[A] : {DATA_WIDTH{1'b0}};

endmodule