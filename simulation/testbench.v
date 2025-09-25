
`include "../rtl/complete_nn.v"


`timescale 1ns / 1ns


//THIS IS PERFECT
module tb_top;

    // --- Parameters ---
    localparam INPUT_WIDTH  = 128;
    localparam CLK_PERIOD   = 10; // 10 ns = 100 MHz clock

    // --- Testbench Signals ---
    reg                        clk;
    reg                        rst_n;
    reg  [INPUT_WIDTH-1:0]     test_in;
    wire [3:0]                 final_out_index;
    wire [9:0]                 final_out_onehot;
    wire [17:0] max;
    reg updown;

    wire done;
    
    integer i,j;  // Declare once outside 
    // --- Instantiate the Device Under Test (DUT) ---
    mytop dut (
        .in(test_in),
        .clk(clk),
        .rst_n(rst_n),
        .updown(updown),
        //.out(final_out_index),
        .out_activehigh(final_out_onehot),
        .done(done)
        //.max(max)
    );

    // --- Clock Generation ---
    initial begin
        clk = 1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    reg [255:0] pixel_mem [0:1592];

    // Memory to hold all one-hot encoded labels
    reg [9:0] labels_mem [0:1592];

    reg [9:0] expected_label;
    reg [15:0] correct;
    reg [15:0] incorrect;

    initial begin
        $readmemb("pixel_data_256bit.mem", pixel_mem);
        $readmemb("labels.mem", labels_mem);
    end

    // --- Test Scenarios ---
    initial begin
        // For waveform debugging, uncomment these lines
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top);
        correct = 0;
        incorrect = 0;
        updown = 0;
        //$monitor ("clk:%b-->Input:%h Output Index: %d, One-Hot Output: %b , %d", clk, test_in,  final_out_index, final_out_onehot, max);

        $display("==========================================================");
        $display("Simulation Started: Applying active-low reset...");
        rst_n   = 1'b0; // Assert reset
        test_in = {INPUT_WIDTH{1'b0}};
        #(CLK_PERIOD * 5); // Hold reset for 5 clock cycles
        
        rst_n = 1'b1; // De-assert reset
        $display("Reset released. Starting test cases.");
        #(CLK_PERIOD); // Wait one cycle for reset to propagate

        // --- Test Case 1: All inputs are zero ---
        // $display("\nTest Case 1: Driving all %0d inputs to 1.", INPUT_WIDTH);
        // test_in = {INPUT_WIDTH{1'b1}};
         
       
        
         for (j = 0; j < 15; j = j + 1) begin
            i = $urandom_range(1550, 0);
            //i = j;
            $display("\nTest Case %0d: Driving test set vector.", i); 
            updown = 0;  
            test_in = pixel_mem[i][255:128];
            #(CLK_PERIOD * 1);
            updown = 1;
            test_in = pixel_mem[i][127:0];
            $display("input = %h", pixel_mem[i] );       
            expected_label = labels_mem[i];  

            //wait for done signal
            wait (done == 1);
            #(CLK_PERIOD * 1);
            $display("-->One-Hot Output: %b", 
                    final_out_onehot);
            //#(CLK_PERIOD * 4);
            if (final_out_onehot === expected_label) begin
                $display("  PASS: Output %b matches expected %b", final_out_onehot, expected_label);
                correct = correct + 1;
            end else begin
                $display("  FAIL: Output %b DOES NOT match expected %b", final_out_onehot, expected_label);
                incorrect = incorrect + 1;
            end     
        end
        
        $display ("correct: %d, incorrect: %d", correct, incorrect);
        $display("\n==========================================================");
        $display("Simulation Finished.");
        $finish;
    end

endmodule



