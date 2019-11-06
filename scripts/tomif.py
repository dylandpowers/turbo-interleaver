def generate_roms():

	roms = [[] for i in range(8)]
	block_size0 = 1056
	block_size1 = 6144
	f0 = lambda x: ((17 * x + 66 * x * x) % block_size0)
	f1 = lambda x: ((263 * x + 480 * x * x) % block_size1)
	print([f0(i) % 8 for i in range(8)])
	print([f0(i) % 8 for i in range(8, 16)])
	print([f1(i) % 8 for i in range(8)])
	print([f1(i) % 8 for i in range(8, 16)])

	map0 = [0, 7, 2, 1, 4, 3, 6, 5]
	map1 = [0, 7, 6, 5, 4, 3, 2, 1]

	interleave0 = {}
	interleave1 = {}
	for i in range(block_size0):
		interleave0[f0(i)] = i
	
	for i in range(block_size1):
		interleave1[f1(i)] = i

	for i in range(block_size0):
		roms[map0[i % 8]].append(interleave0[i] / 8)

	for i in range(block_size1):
		roms[map1[i % 8]].append(interleave1[i] / 8)

	return roms

def generate_rom(block_size):
	f = lambda x: ((17 * x + 66 * x * x) % block_size)

	rom = [0] * 1056
	for i in range(block_size):
		rom[f(i)] = i

	return rom

def generate_mifs(roms):
	#the name of the output file
	for i in range(len(roms)):
		filename = "rom{}.mif".format(i)
		#the size of the mif file (how many addresses the mif file should contain)
		rom = roms[i]
		depth = len(rom)
		#the width of the data (how many bits each address will hold)
		width = 10


		file = open(filename, "w")
		file.write('DEPTH = %d;\nWIDTH = %d;\n' %(depth, width))
		file.write('ADDRESS_RADIX = DEC;\nDATA_RADIX = DEC;\n')
		file.write('CONTENT\nBEGIN\n')


		#iterate through addresses in mif file here
		for address in range(depth):
			#data is what you would like to put in the address
			data = rom[address]
			file.write('%d : %d;\n' %(address, data))


		file.write('END;')
		file.close()

if __name__ == "__main__":
	generate_mifs(generate_roms())