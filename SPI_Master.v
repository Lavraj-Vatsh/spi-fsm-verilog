module spi_master_fsm (
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output reg mosi,
    input miso,
    output reg sclk,
    output reg cs,
    output reg done
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg_tx;
    reg [7:0] shift_reg_rx;

    reg [1:0] state;
    parameter IDLE = 2'b00,
              LOAD = 2'b01,
              TRANSFER = 2'b10,
              FINISH = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg_tx <= 0;
            shift_reg_rx <= 0;
            mosi <= 0;
            sclk <= 0;
            cs <= 1;
            done <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    sclk <= 0;
                    cs <= 1;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    cs <= 0;
                    shift_reg_tx <= data_in;
                    shift_reg_rx <= 0;
                    bit_cnt <= 3'd7;
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    sclk <= 0;
                    mosi <= shift_reg_tx[bit_cnt];

                    #2 sclk <= 1; // Sample on rising edge

                    shift_reg_rx[bit_cnt] <= miso;

                    #2 sclk <= 0;

                    if (bit_cnt == 0)
                        state <= FINISH;
                    else
                        bit_cnt <= bit_cnt - 1;
                end

                FINISH: begin
                    cs <= 1;
                    data_out <= shift_reg_rx;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
