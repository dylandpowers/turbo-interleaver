<<<<<<< Updated upstream
import numpy as np

def generate_random_sequence(block_size):
	return np.random.randint(2, size=block_size)

def generate_output_sequence(input_sequence):
	block_size = len(input_sequence)
	f1, f2 = 0, 0
	if block_size == 1056:
		f1, f2 = 17, 66
	else:
		f1, f2 = 263, 480

	f = lambda x: ((f1 * x + f2 * x * x) % block_size)

	return [input_sequence[f(i)] for i in range(block_size)]

def print_sequence(sequence):
	print(''.join([str(i) for i in sequence]))

if __name__ == "__main__":
	sequence = generate_random_sequence(1056)
	print('Input')
	print_sequence(sequence)
	output = generate_output_sequence(sequence)
	print('Output')
	print_sequence(output)


=======
import numpy as np

def generate_random_sequence(block_size):
	return np.random.randint(2, size=block_size)

def generate_output_sequence(input_sequence):
	block_size = len(input_sequence)
	f1, f2 = 0, 0
	if block_size == 1056:
		f1, f2 = 17, 66
	else:
		f1, f2 = 263, 480

	f = lambda x: ((f1 * x + f2 * x * x) % block_size)

	return [input_sequence[f(i)] for i in range(block_size)]

def print_sequence(sequence):
	print(''.join([str(i) for i in sequence]))

if __name__ == "__main__":
	sequence = generate_random_sequence(1056)
	print('Input')
	print_sequence(sequence)
	output = generate_output_sequence(sequence)
	print('Output')
	print_sequence(output)


>>>>>>> Stashed changes
