module adder
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input [DATA_WIDTH - 1 : 0] a,
    input [DATA_WIDTH - 1 : 0] b,
    output [DATA_WIDTH - 1 : 0] y
  );

  assign y = (rstn && en) ? (a + b) : {DATA_WIDTH{1'b0}};

endmodule