module turbo_test();
module turbo_test();

reg[1055:0] in;
reg[1055:0] out;
reg[1055:0] expected_out;

integer counter;
reg start_rec;
reg start_send;

//inputs
reg clk, reset, vld_crc, rdy_out, cbs;
reg [7:0] data_in_rev;
reg [7:0] data_in;

//outputs
wire rdy_crc, vld_out;
wire [7:0] data_out;

string correct;

initial 
begin

$display("starting simulation");
$display("counter | reset | vld_crc | where_in_block | data_in");

in <= 1056'b110001111110110110101000111110001100110000101100000001010001100001001000000111110111100111110010111100000111110010110001110010110100100110110010100110000001101111000110010100001110101100100101001100110100010110001110111100010000100011001001111010101100000010110010001001110101000001101010001011100000100000100010111001010100000011001101011111110001100110111001010101100100001110010111000010110100111001001000100010010110100010000011010100011101111101110100001001000110000010100111110111011100100011000000011000100000010001010100110101110101111001111011100100101110001000110100101010100001100100000100111001000011110001101100011010111101001000110010111111000111000100010111011011000111110011011100001000000110000110011000000011110111010001101101110000010100011110110010110010111100011000000010110011100101011101000010111111100010111110110011111100010001111010100101011110001001110000111110110101000100001111010010001100000011010001101101000110010111100101010101101100011011011111101110110011110011010101101101111111101110100000101101111000101001000110100011;
expected_out <= 1056'b000011010010110100011100010000000111010011100100100111111010001010011110000001000010001110000010001100110100000111011100011011000110110100100101110010100111100010001101000000101101001000111110000011101110001000011110011111000010011111111110010000010101011111011010111000000100100100101011010000111001000100010100000110110100101011011011110011100111001000101101100101010101101110001011110110100110010001111000110110100101010010110001010000010011010100000001111000101010011111100010010111111101010011100111011001000110000111100010101011110111001000111011110000110111101001011000000110101000100011100110110111011100011101101110101100010100101111101000001111011101100101001001110010010100000101011110100011010100011100011010010111110110010000110111111000100000110010100011000110000011100000100000011010000001101110010010100000000011101110011001011010001010111010011011110011100111010011100110110110011110100010010000111000101111010100000100010110111101010110100011110111001001110101111000110101101110011001011111010001110011110001000000010111000011010001100101;
cbs <= 1'b0;
reset <= 1'b1;
vld_crc <= 1'b0;
rdy_out <= 1'b0;
clk <= 1'b0;
start_rec <= 1'b0;
start_send <= 1'b0;

counter <= 0;

data_in <= 8'd0;


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
@(posedge clk) begin
 reset <= 1'b0;
 vld_crc <= 1'b1;
end
//send code block size
@(posedge clk) begin
 vld_crc <= 1'b0;
 cbs <= 1'b0;
end
@(posedge clk) begin
 rdy_out <= 1'b1;
 counter <= 0;
 start_rec <= 1'b1;
end
//start sending data
@(posedge clk) begin
end
//wait until we get vld_out
@(posedge vld_out) begin
 start_rec <= 1'b0;
end
//send cbs
@(posedge clk) begin
 rdy_out <= 1'b0;
 cbs <= 0;
end
@(posedge clk) begin
 start_send <= 1'b1;
 counter <= 0;
end
//wait one clock cycle
@(posedge clk) begin
end
#3000
$stop;
end

always @(negedge clk)
begin
	// if recieving
	if(start_rec) begin
		data_in_rev = in[counter +: 8];
//		#1
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
	if(start_send) begin
		out[counter +: 8] = data_out;
		if(data_out == expected_out[counter +: 8])
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
	$display("count: %0d | vld_crc: %b | start_rec: %b | start_send: %b | data_in: %b | data_out: %b | expected: %b | correct: %s", counter, vld_crc, start_rec, start_send, data_in, out[counter +: 8], expected_out[counter +: 8], correct);
	counter = counter + 8; 
end

interleaver dut(clk, reset, vld_crc, rdy_out, cbs, data_in, rdy_crc, vld_out, data_out);


endmodule
