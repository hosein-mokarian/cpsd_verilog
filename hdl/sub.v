module sub
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input [DATA_WIDTH - 1 : 0] a,
    input [DATA_WIDTH - 1 : 0] b,
    output [DATA_WIDTH - 1 : 0] y
  );

  wire signed [DATA_WIDTH - 1 : 0] c;

  assign c = (rstn && en) ? (a - b) : {DATA_WIDTH{1'b0}};

  assign y = (rstn && en) ? ((c < 0) ? -c : c) : {DATA_WIDTH{1'b0}};

endmodule