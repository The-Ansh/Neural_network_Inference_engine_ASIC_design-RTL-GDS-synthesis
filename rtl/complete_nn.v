`timescale 1ns / 1ns

module adder_5to6 (
    input  signed [4:0] a,
    input  signed [4:0] b,
    output signed [5:0] sum
);
    assign sum = a + b;
endmodule

module adder_6to7 (
    input signed [5:0] a,
    input signed [5:0] b,
    output signed [6:0] sum
);
    assign sum = a + b;
endmodule

module adder_7to8 (
    input signed [6:0] a,
    input signed [6:0] b,
    output signed [7:0] sum
);
    assign sum = a + b;
endmodule

module adder_8to9 (
    input  signed [7:0] a,
    input  signed [7:0] b,
    output signed [8:0] sum
);
    assign sum = a + b;
endmodule

module adder_9to10 (
    input signed [8:0] a,
    input signed [8:0] b,
    output signed [9:0] sum
);
    assign sum = a + b;
endmodule

module adder_10to10 (
    input signed [9:0] a,
    input signed [9:0] b,
    output signed [9:0] sum
);
    wire signed [10:0] result;
    assign result = a + b;
    assign sum = result[9:0];
endmodule

module compare_n_out(
    input  [17:0] a,
    input  [17:0] b,
    output wire  max // 1 if a > b, else 0 (explicitly declared as wire)
);
    // The result of a comparison is already a 1-bit value (1 for true, 0 for false).
    assign max = (a > b);
endmodule

module find_max_index #(
    parameter NUM_INPUTS = 10,
    parameter DATA_WIDTH = 18
)(
    input [179:0] data_in,
    input clk,
    input rst_n,
    output reg [3:0] max_index,
    output wire [17:0] max_value
);
    // Intermediate signals for each stage of the comparator tree
    wire [17:0] stage1_winners [0:4];
    wire [17:0] stage2_winners [0:2];
    wire [17:0] stage3_winners [0:1];
    wire [17:0] final_winner;

    wire [3:0] stage1_indices [0:4];
    wire [3:0] stage2_indices [0:2];
    wire [3:0] stage3_indices [0:1];
    wire [3:0] final_index;

    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : stage1
            wire gt;
            compare_n_out cmp (
                .a(data_in[(2*i+2)*DATA_WIDTH - 1 : (2*i+1)*DATA_WIDTH]),
                .b(data_in[(2*i+1)*DATA_WIDTH - 1 : (2*i)*DATA_WIDTH]),
                .max(gt)
            );
            assign stage1_winners[i] = gt ? data_in[(2*i+2)*DATA_WIDTH - 1 : (2*i+1)*DATA_WIDTH] : data_in[(2*i+1)*DATA_WIDTH - 1 : (2*i)*DATA_WIDTH];
            assign stage1_indices[i] = gt ? (2*i+1) : (2*i);
        end

        for (i = 0; i < 2; i = i + 1) begin : stage2
            wire gt;
            compare_n_out cmp (
                .a(stage1_winners[2*i+1]),
                .b(stage1_winners[2*i]),
                .max(gt)
            );
            assign stage2_winners[i] = gt ? stage1_winners[2*i+1] : stage1_winners[2*i];
            assign stage2_indices[i] = gt ? stage1_indices[2*i+1] : stage1_indices[2*i];
        end
        assign stage2_winners[2] = stage1_winners[4]; // Carry forward the unpaired winner
        assign stage2_indices[2] = stage1_indices[4];

        for (i = 0; i < 1; i = i + 1) begin : stage3
            wire gt;
            compare_n_out cmp (
                .a(stage2_winners[2*i+1]),
                .b(stage2_winners[2*i]),
                .max(gt)
            );
            assign stage3_winners [i] = gt ? stage2_winners[2*i+1] : stage2_winners[2*i];
            assign stage3_indices[i] = gt ? stage2_indices[2*i+1] : stage2_indices[2*i];
        end
        assign stage3_winners [1] = stage2_winners[2]; // Carry forward the unpaired winner
        assign stage3_indices[1] = stage2_indices[2];
        
        wire gt_final;
        compare_n_out cmp_final (
            .a(stage3_winners[0]),
            .b(stage3_winners[1]),
            .max(gt_final)
        );
        assign final_winner = gt_final ? stage3_winners[0] : stage3_winners[1];
        assign final_index = gt_final ? stage3_indices[0] : stage3_indices[1];
    endgenerate

    assign max_value = final_winner;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            max_index <= 4'b0000;
        else
        max_index <= final_index;
    end
endmodule

module decoder_4_to_10 (
    input  wire [3:0]  in_val,
    output reg  [0:9]  out_activehigh
);

    // This combinational block updates whenever 'in_val' changes.
    always @(*) begin
        // Default to all zeros to avoid latches for unspecified cases
        out_activehigh = 10'b0; 

        case (in_val)
            4'd0: out_activehigh[0] = 1'b1;
            4'd1: out_activehigh[1] = 1'b1;
            4'd2: out_activehigh[2] = 1'b1;
            4'd3: out_activehigh[3] = 1'b1; 
            4'd4: out_activehigh[4] = 1'b1;
            4'd5: out_activehigh[5] = 1'b1;
            4'd6: out_activehigh[6] = 1'b1;
            4'd7: out_activehigh[7] = 1'b1;
            4'd8: out_activehigh[8] = 1'b1;
            4'd9: out_activehigh[9] = 1'b1;
            // A default case is good practice, though not strictly
            // necessary here since we defaulted to zero above.
            default: out_activehigh = 10'b0; 
        endcase
    end

endmodule

module multiplier9514(
    output wire signed [13:0] prod,   // signed output (14 bits)
    input  wire        [8:0] num1,   // unsigned 9-bit input (multiplicand)
    input  wire signed [4:0] num2    // signed 5-bit input (multiplier)
);
    wire [8:0] partial_prods [0:4];
    wire signed [13:0] shifted_pps [0:4];
    wire signed [13:0] intermediate_sums [0:2];
    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : partial_product_generation
            assign partial_prods[i] = num2[i] ? num1 : 9'b0;
            assign shifted_pps[i] = partial_prods[i] << i;
        end
    endgenerate
    assign intermediate_sums[0] = shifted_pps[0] + shifted_pps[1];
    assign intermediate_sums[1] = intermediate_sums[0] + shifted_pps[2];
    assign intermediate_sums[2] = intermediate_sums[1] + shifted_pps[3];
    assign prod = intermediate_sums[2] - shifted_pps[4];
endmodule

module ReLU_10bit (
    input  wire [9:0] in_data,
    output wire [8:0] out_data
);
    assign out_data = (in_data[9] == 1'b0) ? in_data[8:0] : 9'd0;
endmodule

module ReLU_19bit(
    input  wire [18:0] in_data,
    output wire  [17:0] out_data
);
    assign out_data = (in_data[18] == 1'b0) ? in_data[17:0] : 18'd0;
endmodule

module layer1 #(
    parameter ROWS      = 20,
    parameter COLS      = 256,
    parameter A_WIDTH   = 5
)(
    input clk,
    input rst_n,
    input updown,
    // Input vector 'B' (256x1, 1-bit elements) flattened to a single vector
    input [0:127] in, 
    output [179:0] out
);

    reg [0:255] B;
    // reg [4:0] A [0:19][0:255];
    // initial begin
    //     $readmemb("w1.mem", A);
    // end
    // reg [6:0] biases_l1 [0:19];
    // initial begin
    //     $readmemb("b1.mem", biases_l1);
    // end
//The following 3 lines do exactly what above commented code does
wire [4:0] A [0:19][0:255];
wire [6:0] biases_l1 [0:19];
`include "assign_l1.vh"


    wire [9:0] biases_l1_ext [0:19];
    wire [5:0] level_1_sums [0:19][0:127]; // 128 outputs, each 6 bits wide
    wire [6:0] level_2_sums [0:19][0:63];  // 64 outputs, each 7 bits wide
    wire [7:0] level_3_sums [0:19][0:31];  // 32 outputs, each 8 bits wide
    wire [8:0] level_4_sums [0:19][0:15];  // 16 outputs, each 9 bits wide
    wire [9:0] level_5_sums [0:19][0:7];   // 8 outputs, each 10 bits wide
    wire [9:0] level_6_sums [0:19][0:3];   // 4 outputs, each 10 bits wide
    wire [9:0] level_7_sums [0:19][0:1];   // 2 outputs, each 10 bits wide
    wire [9:0] level_8_sums [0:19];        // 1 output, 10 bits wide
    wire [9:0] final_sums [0:19];          // Final output, 10 bits wide

    reg [8:0] out_reg [0:19];
    wire [8:0] out_sig [0:19];
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            B <= 256'd0;
        end

        else begin
            if(!updown) begin
                B <= {in, B[128:255]};
            end
            else begin
                B <= {B[0:127], in};
            end
        end
    end


    // --- Generate 20 Parallel Dot-Product Units ---
    genvar i, j;
    generate
        for (i = 0; i < 20; i = i + 1) begin : dot_product_and_ReLU
            assign biases_l1_ext[i] = { {3{biases_l1[i][6]}}, biases_l1[i] }; // Sign-extend 7-bit bias to 9 bits
            wire [4:0] product_terms [0:255]; // 256 products, each 5 bits wide            
            for (j = 0; j < 256; j = j + 1) begin : product_terms_gen
                assign product_terms[j] = B[j] ? A[i][j] : {5{1'b0}};
                if (j%2 == 1) begin : adder_pairs
                    // assign level_1_sums[i][j/2] = product_terms[j] + product_terms[j-1];
                    adder_5to6 adder_inst (
                        .a(product_terms[j-1]),
                        .b(product_terms[j]),
                        .sum(level_1_sums[i][j/2])
                    );
                end
                if (j%4 == 3) begin : adder_quads
                    adder_6to7 adder_inst (
                        .a(level_1_sums[i][(j-1)/2]),
                        .b(level_1_sums[i][(j-3)/2]),
                        .sum(level_2_sums[i][j/4])
                    );
                end
                if (j%8 == 7) begin : adder_octets
                    adder_7to8 adder_inst (
                        .a(level_2_sums[i][(j-1)/4]),
                        .b(level_2_sums[i][(j-7)/4]),
                        .sum(level_3_sums[i][j/8])
                    );
                end
                if (j%16 == 15) begin : adder_16s
                    adder_8to9 adder_inst (
                        .a(level_3_sums[i][(j-1)/8]),
                        .b(level_3_sums[i][(j-15)/8]),
                        .sum(level_4_sums[i][j/16])
                    );
                end
                if (j%32 == 31) begin : adder_32s
                    adder_9to10 adder_inst (
                        .a(level_4_sums[i][(j-1)/16]),
                        .b(level_4_sums[i][(j-31)/16]),
                        .sum(level_5_sums[i][j/32])
                    );
                end
                if (j%64 == 63) begin : adder_64s
                    adder_10to10 adder_inst (
                        .a(level_5_sums[i][(j-1)/32]),
                        .b(level_5_sums[i][(j-63)/32]),
                        .sum(level_6_sums[i][j/64])
                    );
                end
                if (j%128 == 127) begin : adder_128s
                    adder_10to10 adder_inst (
                        .a(level_6_sums[i][(j-1)/64]),
                        .b(level_6_sums[i][(j-127)/64]),
                        .sum(level_7_sums[i][j/128])
                    );
                end
                if (j == 255) begin : final_adder
                    adder_10to10 adder_inst (
                        .a(level_7_sums[i][0]),
                        .b(level_7_sums[i][1]),
                        .sum(level_8_sums[i])
                    );
                end    
            end 
            assign final_sums[i] = level_8_sums[i] + biases_l1_ext[i];
            // Apply ReLU activation
            ReLU_10bit relu_inst (
                //.clk(clk),
                //.rst_n(rst_n),
                .in_data(final_sums[i]),
                .out_data(out_sig[i])
            );  
        end        
    endgenerate
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
    out_reg[0]  <= 9'd0;
    out_reg[1]  <= 9'd0;
    out_reg[2]  <= 9'd0;
    out_reg[3]  <= 9'd0;
    out_reg[4]  <= 9'd0;
    out_reg[5]  <= 9'd0;
    out_reg[6]  <= 9'd0;
    out_reg[7]  <= 9'd0;
    out_reg[8]  <= 9'd0;
    out_reg[9]  <= 9'd0;
    out_reg[10] <= 9'd0;
    out_reg[11] <= 9'd0;
    out_reg[12] <= 9'd0;
    out_reg[13] <= 9'd0;
    out_reg[14] <= 9'd0;
    out_reg[15] <= 9'd0;
    out_reg[16] <= 9'd0;
    out_reg[17] <= 9'd0;
    out_reg[18] <= 9'd0;
    out_reg[19] <= 9'd0;

        end else begin
            // for (integer i = 0; i < 20; i++) begin
            //     out_reg[i] <= out_sig[i];
            // end
    out_reg[0]  <= out_sig[0];
    out_reg[1]  <= out_sig[1];
    out_reg[2]  <= out_sig[2];
    out_reg[3]  <= out_sig[3];
    out_reg[4]  <= out_sig[4];
    out_reg[5]  <= out_sig[5];
    out_reg[6]  <= out_sig[6];
    out_reg[7]  <= out_sig[7];
    out_reg[8]  <= out_sig[8];
    out_reg[9]  <= out_sig[9];
    out_reg[10] <= out_sig[10];
    out_reg[11] <= out_sig[11];
    out_reg[12] <= out_sig[12];
    out_reg[13] <= out_sig[13];
    out_reg[14] <= out_sig[14];
    out_reg[15] <= out_sig[15];
    out_reg[16] <= out_sig[16];
    out_reg[17] <= out_sig[17];
    out_reg[18] <= out_sig[18];
    out_reg[19] <= out_sig[19];

        end
    end

    genvar m;
    generate
        for (m = 0; m < 20; m = m + 1) begin : output_assign
            assign out[(m+1)*9-1:m*9] = out_reg[m];
        end
    endgenerate
endmodule

module layer2(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [179:0] in, // 180-bit input
    output wire  [179:0]  out // 180-bit final output
);

    // reg signed [4:0] w2 [0:9][0:19];
    // initial begin
    //     $readmemb("w2.mem", w2);
    // end
    // reg [5:0] biases_l2 [0:9];
    // initial begin
    //     $readmemb("b2.mem", biases_l2);
    // end
//The following 3 lines do exactly what above commented code does
wire signed [4:0] w2 [0:9][0:19];
wire [5:0] biases_l2 [0:9];
`include "assign_l2.vh"

    
    wire signed [13:0] prod_terms[0:9][0:19];
    wire signed [13:0] b2_extended [0:9];
    
    wire signed [18:0] row_sums [0:9];

    wire [17:0] row_output [0:9]; 
    reg [17:0] out_reg [0:9];

    
    genvar i,j;
    generate
        for (i = 0; i < 10; i = i + 1) begin : row_iteration

            assign b2_extended[i] = { {4{biases_l2[i][5]}}, biases_l2[i], 4'd0 };

            for (j = 0; j < 20; j = j + 1) begin : prod_calc
                //assign prod_terms[i][j] = $signed(in[(j+1)*9-1:j*9]) * w2[i][j]; 
                multiplier9514 mult_inst (.prod(prod_terms[i][j]), .num1($signed(in[(j+1)*9-1:j*9])), .num2(w2[i][j]));
            end
            
            assign row_sums[i] = prod_terms[i][0]  + prod_terms[i][1] + prod_terms[i][2]  +
                             prod_terms[i][3]  + prod_terms[i][4]  + prod_terms[i][5]  +
                             prod_terms[i][6]  + prod_terms[i][7]  + prod_terms[i][8]  +
                             prod_terms[i][9]  + prod_terms[i][10] + prod_terms[i][11] +
                             prod_terms[i][12] + prod_terms[i][13] + prod_terms[i][14] +
                             prod_terms[i][15] + prod_terms[i][16] + prod_terms[i][17] +
                             prod_terms[i][18] + prod_terms[i][19] + b2_extended[i];        
            //apply ReLU
            ReLU_19bit relu_inst (
                //.clk(clk),
                //.rst_n(rst_n),
                .in_data(row_sums[i]),
                .out_data(row_output[i])
            );  
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
out_reg[0] <= 18'd0;
out_reg[1] <= 18'd0;
out_reg[2] <= 18'd0;
out_reg[3] <= 18'd0;
out_reg[4] <= 18'd0;
out_reg[5] <= 18'd0;
out_reg[6] <= 18'd0;
out_reg[7] <= 18'd0;
out_reg[8] <= 18'd0;
out_reg[9] <= 18'd0;

        end else begin
out_reg[0] <= row_output[0];
out_reg[1] <= row_output[1];
out_reg[2] <= row_output[2];
out_reg[3] <= row_output[3];
out_reg[4] <= row_output[4];
out_reg[5] <= row_output[5];
out_reg[6] <= row_output[6];
out_reg[7] <= row_output[7];
out_reg[8] <= row_output[8];
out_reg[9] <= row_output[9];

        end
    end

    genvar m;
    generate
        for (m = 0; m < 10; m = m + 1) begin : output_assign
            assign out[(m+1)*18-1:m*18] = out_reg[m];
        end
    endgenerate

endmodule

module mytop (
input wire [127:0] in,
input wire clk, 
input wire rst_n,
input wire updown,
output wire [0:9] out_activehigh,
output reg done
);

wire [179:0] layer1_out;

reg [1:0] counter;

always @ (posedge clk or negedge updown) begin
if(!updown)begin
    counter <= 0;
    done <= 0;
end

else begin
    
    if (counter < 3) begin
        counter <= counter + 1;
    end    
    else begin
        done <=1;
    end

end
end


layer1 instanceL1 (
        .clk(clk),
        .rst_n(rst_n),
        .updown(updown),
        .in(in),
        .out(layer1_out)
    );

wire [179:0] layer2_out;

layer2 instanceL2 (
        .clk(clk),
        .rst_n(rst_n),
        .in(layer1_out),
        .out(layer2_out)
    );

wire [3:0] out;
wire [17:0] max;

find_max_index uut (
        .data_in(layer2_out),
        .clk(clk),
        .rst_n(rst_n),
        .max_index(out),
        .max_value(max)
    );

decoder_4_to_10 dut (
        .in_val(out),
        .out_activehigh(out_activehigh)
    );
endmodule

