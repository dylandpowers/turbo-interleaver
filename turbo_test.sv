module turbo_test();

reg[1055:0] in;
reg[1055:0] out;
reg[1055:0] expected_out;

integer counter, counter_rev;
reg start_rec;
reg start_send;

//inputs
reg clk, reset, vld_crc, rdy_out, cbs;
reg [7:0] data_in_rev;
reg [7:0] data_in;

//outputs
wire rdy_crc, vld_out, last_byte;
wire [7:0] data_out;

string correct;

initial 
begin

$display("starting simulation");
$display("counter | reset | vld_crc | where_in_block | data_in");

in <= 1056'b111000111001101101000011001011101111011001100001011110101001110010110000000000110111001100000100101101000110011001000101111000000101000001110000001011111001110001011100111101110000100111010100010001100001000000101111101011111011110100011001001101010010010000110000001011011001010100100100101111111111110001010100001000000111110110011000110001111100111010101011000111000111011110011001110011010001100101100100001110101101010111000110011001110100011010100110011111000110010110011011101100111011101001001000110111010101010010101010010001011010100100011010111010000010110100110010100010011100100110001001100100111111001110111101011000011001110101100001000101100011101111011100110001111110000010000011101110111101011011010001000110110100111011000001001101000100001110000010101010011000011011010010010000111101000011010101101100100011011101100100000011000111110110101100111111011111001111111001011101111111010111100011110110100100110101110111010110001100000101100110001001111101010101100001101001010001001101101111011101110010110100001000001011011000001100001001;
expected_out <= 1056'b111001010011010110100101010010000000001110110011110111010000100110010000101110000000010000011001111100001011001101011100111011111001011000011101110001101011100010110101010000111011000000101100100011000000110100010111100100000101001010011110110001110011101000000010001010000110011111100000100001001110000010010100001101000110101111001110010010100111101111111111001100100011010111100000011101001111111101000110101111111111010110011001011001010101101011111100001101100000110111111010110001111010001111101111110001110011110101011110011111111111100111111110000010000110010011101101110111101100111100110100100100110101000010101100010001101011001100111101000011111010111001000011101101100010110101001110110101011000000011001001010101011011010110100000010100110010101101010111101001001111100100111100011010010111000010010011010010000101100110000010111011111011000100100001000011000000010001000100011111111011000011110000011101111111110000000101011000100101011010111111100010011100010100010101010001110110010001110000011000111101010000011010000001111111100100010101;
reset <= 1'b1;
vld_crc <= 1'b0;
rdy_out <= 1'b0;
clk <= 1'b0;
start_rec <= 1'b0;
start_send <= 1'b0;
cbs <= 1'b0;

counter <= 0;

data_in <= 8'd0;
data_in_rev <= 8'd0;


end

always
begin
#10 clk <= ~clk;
end

//inital reset and setup
always
begin
//reset
@(posedge clk)
@(posedge clk)
@(posedge clk)
//end reset and assert vld_crc
@(negedge clk) begin
 reset <= 1'b0;
 vld_crc <= 1'b1;
end
@(posedge rdy_crc) begin
 rdy_out <= 1'b1;
 counter <= 0;
end

//wait until we get vld_out
@(posedge vld_out) begin
 vld_crc <= 1'b0;
end

@(posedge clk) begin
	counter <= 0;
end

#3000
$stop;
end

always @(negedge clk)
begin
	if(rdy_crc) begin
		counter_rev = (1056 - counter) - 8;
		counter = counter + 8;	
	end
	if(vld_out) begin
		counter_rev = (1056 - counter) - 8;
		counter = counter + 8;
	end
	// if recieving
	if(rdy_crc) begin
		data_in = in[counter_rev +: 8];
//		data_in[0] <= data_in_rev[7];
//		data_in[1] <= data_in_rev[6];
//		data_in[2] <= data_in_rev[5];
//		data_in[3] <= data_in_rev[4];
//		data_in[4] <= data_in_rev[3];
//		data_in[5] <= data_in_rev[2];
//		data_in[6] <= data_in_rev[1];
//		data_in[7] <= data_in_rev[0];
	end
	//if sending
	if(vld_out) begin
		out[counter_rev +: 8] = data_out;
		if(data_out == expected_out[counter_rev +: 8])
		begin
			correct = "TRUE";
		end
		else 
		begin
			correct = "FALSE";
		end
	end
	
	
end

always @(posedge clk) begin
	$display("count: %0d | vld_crc: %b | rdy_crc: %b | vld_out: %b | last_byte: %b | data_in: %b | data_out: %b | expected: %b | correct: %s", counter_rev, vld_crc, rdy_crc, vld_out, last_byte, data_in, data_out, expected_out[counter_rev +: 8], correct);
end

interleaver dut(clk, reset, vld_crc, rdy_out, cbs, data_in, rdy_crc, vld_out, last_byte, data_out);


endmodule
