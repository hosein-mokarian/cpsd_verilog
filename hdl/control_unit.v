module control_unit
  #(parameter DATA_WIDTH = 16)
  (
    input rstn,
    input en,
    input clk,
    input qrs,
    input start,
    input timer_update_flag,
    output reg timer_trigger,
    output reg [1 : 0] which_phase,
    output reg cv1_flag
  );


  localparam STATE_START = 2'b00;
  localparam STATE_TRAINING = 2'b01;
  localparam STATE_TEST = 2'b10;

  localparam STATE_BIT_WIDTH = 2;

  reg [STATE_BIT_WIDTH - 1 : 0] state;

  reg [1 : 0] qrs_counter;


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      state <= STATE_START;
    end
    else if (rstn && en)
    begin
      case (state)
        STATE_START:
        begin
          if (start == 1)
          begin
            state <= STATE_TRAINING;
          end
        end
        STATE_TRAINING:
        begin
          if (timer_update_flag == 1)
            state <= STATE_TEST;
        end
        STATE_TEST:
        begin
        end
      endcase
    end
  end

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      timer_trigger <= 0;
    end
    else if (rstn && en)
    begin
      case (state)
        STATE_START:
        begin
          if (start == 1)
          begin
            timer_trigger <= 1;
          end
        end
        default:
          timer_trigger <= 0;
      endcase
    end
  end

  always @(*)
  begin
    if (!rstn)
    begin
      which_phase = 2'b00;
    end
    else if (rstn && en)
    begin
      case (state)
        STATE_TRAINING: which_phase = 2'b10;
        STATE_TEST:     which_phase = 2'b01;
      endcase
    end
  end

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      cv1_flag <= 1;
    end
    else if (rstn && en)
    begin
      case (state)
      STATE_TEST:
      begin
        if (qrs)
          cv1_flag <= 0;
      end
      endcase
    end
  end

endmodule