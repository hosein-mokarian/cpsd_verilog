module thresholding
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input [DATA_WIDTH - 1 : 0] xin,
    input [DATA_WIDTH - 1 : 0] thr1,
    input [DATA_WIDTH - 1 : 0] thr2,
    output normal,
    output AF,
    output VF
  );

  assign normal = (rstn && en) ? ((xin <= thr1 ? 1'b1 : 1'b0)) : 1'b0;
  assign AF = (rstn && en) ? (((xin > thr1 && xin <= thr2) ? 1'b1 : 1'b0)) : 1'b0;
  assign VF = (rstn && en) ? ((xin > thr2 ? 1'b1 : 1'b0)) : 1'b0;

endmodule