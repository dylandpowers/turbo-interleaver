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
wire rdy_crc, vld_out, last_byte;
wire [7:0] data_out;

string correct;

initial 
begin

$display("starting simulation");
$display("counter | reset | vld_crc | where_in_block | data_in");

in <= 1056'b011111001100000011010100011101010011110000100101010110110101101010000000001011101010000100101111100001001010110001111011010110110110011111100101011011011111001000111100011101011111110011010101100111110011000110111100011100010100011111101110110001111001000010110111100010101000110100001000001011110111001110001100011011010111011010010100000001100001110110111011010011000000111100011100100011010111111001001101010111100110101001111010100101100010101010111010010101110111111010010001011000111100110110110111010000110000101100110011010001110111110001110001000110001001001011111100101010000101010101111000001001010110110100001000010000111111101110100110101000110100101101011010101101101011010000001111101111111000111010010101110000001010111011001000011011000110011101010101000010100100110110100100011110111110000010001000100100111110001111001001110110101001110100101100000101111011001000011001000000000110011100100100011001110101110001011010000011100010100001001110000100100010011010100111100101000110101110110001101010100100111110000001111001101011101010110010;
expected_out <= 1056'd0;
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
@(negedge clk) begin
 reset <= 1'b0;
 vld_crc <= 1'b1;
end
//send code block size
@(negedge clk) begin
 
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
 vld_crc <= 1'b0;
end
@(posedge clk) begin
	start_send <= 1'b1;
	counter <= 0;
end
@(posedge clk)
@(posedge clk)
@(posedge clk)
@(posedge clk)
@(negedge clk) begin
	rdy_out <= 1'b0;
end
@(negedge clk)
@(negedge clk) begin
	rdy_out <= 1'b1;
end
#3000
$stop;
end

always @(negedge clk)
begin
	// if recieving
	if(start_rec) begin
		data_in = in[counter +: 8];
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
	$display("count: %0d | vld_crc: %b | start_rec: %b | start_send: %b | last_byte: %b | data_in: %b | data_out: %b | expected: %b | correct: %s", counter, vld_crc, start_rec, start_send, last_byte, data_in, out[counter +: 8], expected_out[counter +: 8], correct);
	if(start_rec) begin
		counter = counter + 8; 
	end
	if(start_send && rdy_out) begin
		counter = counter + 8;
	end
end

interleaver dut(clk, reset, vld_crc, rdy_out, cbs, data_in, rdy_crc, vld_out, last_byte, data_out);


endmodule
