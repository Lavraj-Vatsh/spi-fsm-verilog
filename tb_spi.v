module spi_fsm_tb;

    reg clk = 0, rst = 1;
    reg start = 0;
    reg [7:0] master_in = 8'hA5;
    wire [7:0] master_out;
    wire mosi, miso, sclk, cs, done;

    reg [7:0] slave_data = 8'h3C;
    wire [7:0] slave_out;

    // Clock
    always #5 clk = ~clk;

    spi_master_fsm master (
        .clk(clk), .rst(rst), .start(start),
        .data_in(master_in),
        .data_out(master_out),
        .mosi(mosi), .miso(miso),
        .sclk(sclk), .cs(cs), .done(done)
    );

    spi_slave_fsm slave (
        .sclk(sclk), .cs(cs),
        .mosi(mosi), .miso(miso),
        .data_in(slave_data), .data_out(slave_out)
    );

    initial begin
        $dumpfile("spi_fsm.vcd");
        $dumpvars(0, spi_fsm_tb);

        #10 rst = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10 $display("Master received: %b", master_out);
        $display("Slave received: %b", slave_out);
        #20 $finish;
    end
endmodule
