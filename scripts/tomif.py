def generate_roms(block_size):

	roms = [[] for i in range(8)]

	f = lambda x: ((17 * x + 66 * x * x) % block_size)

	print([f(i) % 8 for i in range(8)])
	print([f(i) % 8 for i in range(8, 16)])

	interleave = {}
	for i in range(block_size):
		interleave[f(i)] = i

	for i in range(block_size):
		roms[i % 8].append(interleave[i] / 8)

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
		width = 11


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
	generate_mifs(generate_roms(1056))