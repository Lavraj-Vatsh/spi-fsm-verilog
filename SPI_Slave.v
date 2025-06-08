module spi_slave_fsm (
    input sclk,
    input cs,
    input mosi,
    output reg miso,
    input [7:0] data_in,
    output reg [7:0] data_out
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_tx;
    reg [7:0] shift_rx;

    always @(negedge cs) begin
        bit_cnt <= 3'd7;
        shift_tx <= data_in;
    end

    always @(posedge sclk) begin
        if (!cs) begin
            shift_rx[bit_cnt] <= mosi;
            miso <= shift_tx[bit_cnt];
            if (bit_cnt == 0) begin
                data_out <= shift_rx;
            end else begin
                bit_cnt <= bit_cnt - 1;
            end
        end
    end
endmodule
