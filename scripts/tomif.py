def generate_roms(block_size):

	roms = [[] for i in range(8)]
	f1, f2 = 0, 0
	if block_size == 1056:
		f1, f2 = 17, 66
	else:
		f1, f2 = 263, 480

	f = lambda x: ((f1 * x + f2 * x * x) % block_size)

	interleave = {}
	for i in range(block_size):
		interleave[f(i)] = i

	for i in range(block_size):
		roms[i % 8].append(interleave[i] / 8)

	return roms

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
	roms_1056 = generate_roms(1056)
	roms_6144 = generate_roms(6144)
	for i in range(len(roms_1056)):
		roms_1056[i].extend(roms_6144[i])
	generate_mifs(roms_1056)