#the name of the output file
filename = "file.mif"
#the size of the mif file (how many addresses the mif file should contain)
depth = 6144
#the width of the data (how many bits each address will hold)
width = 24


file = open(filename, "w")
file.write('DEPTH = %d;\nWIDTH = %d;\n' %(depth, width))
file.write('ADDRESS_RADIX = DEC;\nDATA_RADIX = DEC;\n')
file.write('CONTENT\nBEGIN\n')


#iterate through addresses in mif file here
for address in range (0, depth):
	#data is what you would like to put in the address
	data = 0
	file.write('%d : %d\n' %(address, data))


file.write('END;')