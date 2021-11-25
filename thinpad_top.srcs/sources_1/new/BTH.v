`timescale 1ns / 1ps

module BTH(
        input wire clk,
        input wire rst,
        input wire[1:0] branch_predict_success,
        output wire[1:0] state_out
    );

reg[1:0] prediction_history_state;
assign state_out = prediction_history_state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        prediction_history_state <= 2'b0;
    end
    else begin
        if (branch_predict_success[1]) begin //branch prediction in if
            if(branch_predict_success[0]) begin //correct predicton
                case (prediction_history_state)
                    2'b00: begin
                        prediction_history_state <= 2'b00;
                    end
                    2'b01: begin
                        prediction_history_state <= 2'b00;
                    end
                    2'b10: begin
                        prediction_history_state <= 2'b11;
                    end
                    2'b11: begin
                        prediction_history_state <= 2'b11;
                    end
                endcase
            end
            else begin
                case (prediction_history_state)
                    2'b00: begin
                        prediction_history_state <= 2'b01;
                    end
                    2'b01: begin
                        prediction_history_state <= 2'b10;
                    end
                    2'b10: begin
                        prediction_history_state <= 2'b01;
                    end
                    2'b11: begin
                        prediction_history_state <= 2'b10;
                    end
                endcase
            end
        end
        else begin //no prediction
            prediction_history_state <= prediction_history_state;
        end
    end
end
endmodule
