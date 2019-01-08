import sys
import re
import os
# YOU WILL NEED TO RUN 'pip install bitstring' if you don't have the module installed already
from bitstring import Bits

registers32b = {
	'R0': '{0:05b}'.format(0),
	'R1': '{0:05b}'.format(1),
	'R2': '{0:05b}'.format(2),
	'R3': '{0:05b}'.format(3),
	'R4': '{0:05b}'.format(4),
	'R5': '{0:05b}'.format(5),
	'R6': '{0:05b}'.format(6),
	'R7': '{0:05b}'.format(7),
	'R8': '{0:05b}'.format(8),
	'R9': '{0:05b}'.format(9),
	'R10': '{0:05b}'.format(10),
	'R11': '{0:05b}'.format(11),
	'R12': '{0:05b}'.format(12),
	'R13': '{0:05b}'.format(13),
	'R14': '{0:05b}'.format(14),
	'R15': '{0:05b}'.format(15),
	'R16': '{0:05b}'.format(16),
	'R17': '{0:05b}'.format(17),
	'R18': '{0:05b}'.format(18),
	'R19': '{0:05b}'.format(19),
	'R20': '{0:05b}'.format(20),
	'R21': '{0:05b}'.format(21),
	'R22': '{0:05b}'.format(22),
	'R23': '{0:05b}'.format(23),
	'R24': '{0:05b}'.format(24),
	'R25': '{0:05b}'.format(25),
	'R26': '{0:05b}'.format(26),
	'R27': '{0:05b}'.format(27),
	'R28': '{0:05b}'.format(28),
	'R29': '{0:05b}'.format(29),
	'R30': '{0:05b}'.format(30),
	'R31': '{0:05b}'.format(31)
}

registers128b = {
	'E0': '{0:05b}'.format(0),
	'E1': '{0:05b}'.format(1),
	'E2': '{0:05b}'.format(2),
	'E3': '{0:05b}'.format(3),
	'E4': '{0:05b}'.format(4),
	'E5': '{0:05b}'.format(5),
	'E6': '{0:05b}'.format(6),
	'E7': '{0:05b}'.format(7),
	'E8': '{0:05b}'.format(8),
	'E9': '{0:05b}'.format(9),
	'E10': '{0:05b}'.format(10),
	'E11': '{0:05b}'.format(11),
	'E12': '{0:05b}'.format(12),
	'E13': '{0:05b}'.format(13),
	'E14': '{0:05b}'.format(14),
	'E15': '{0:05b}'.format(15),
	'E16': '{0:05b}'.format(16),
	'E17': '{0:05b}'.format(17),
	'E18': '{0:05b}'.format(18),
	'E19': '{0:05b}'.format(19),
	'E20': '{0:05b}'.format(20),
	'E21': '{0:05b}'.format(21),
	'E22': '{0:05b}'.format(22),
	'E23': '{0:05b}'.format(23),
	'E24': '{0:05b}'.format(24),
	'E25': '{0:05b}'.format(25),
	'E26': '{0:05b}'.format(26),
	'E27': '{0:05b}'.format(27),
	'E28': '{0:05b}'.format(28),
	'E29': '{0:05b}'.format(29),
	'E30': '{0:05b}'.format(30),
	'E31': '{0:05b}'.format(31)
}

opcodes = {
	'ADD': '{0:06b}'.format(1),
	'SUB': '{0:06b}'.format(2),
	'NOT': '{0:06b}'.format(3),
	'AND': '{0:06b}'.format(4),
	'OR':  '{0:06b}'.format(5),
	'XOR': '{0:06b}'.format(6),
	'SLL': '{0:06b}'.format(7),
	'SRA': '{0:06b}'.format(8),
	'SRL': '{0:06b}'.format(9),
	'LI':  '{0:06b}'.format(10),
	'LD':  '{0:06b}'.format(11),
	'ST':  '{0:06b}'.format(12),
	'JI':  '{0:06b}'.format(13),
	'JR':  '{0:06b}'.format(14),
	'BEQ': '{0:06b}'.format(15),
	'BNE': '{0:06b}'.format(16),
	'FTO': '{0:06b}'.format(17),
	'OTF': '{0:06b}'.format(18),
	'DEC': '{0:06b}'.format(19),
	'DECF': '{0:06b}'.format(20),
	'XORE': '{0:06b}'.format(21),
	'FLC': '{0:06b}'.format(22),
	'FLS': '{0:06b}'.format(23),
	'HLT': '111111',
	'NOP': '000000'
}

num_arguments = {
	'ADD': 3,
	'SUB': 3,
	'NOT': 2,
	'AND': 3,
	'OR':  3,
	'XOR': 3,
	'SLL': 3,
	'SRA': 3,
	'SRL': 3,
	'LI':  3,
	'LD':  3,
	'ST':  3,
	'JI':  1,
	'JR':  1,
	'BEQ': 1,
	'BNE': 1,
	'FTO': 5,
	'OTF': 5,
	'DEC': 3,
	'DECF': 3, 
	'XORE': 3,
	'FLC': 2,
	'FLS': 1,
	'HLT': 0,
	'NOP': 0,
}

def assemble(instruction_line, target):
	# target file of machine code
	f = open(target, "a+")

	instruction = instruction_line.strip()
	tokens = instruction.split()
	for token in tokens:
		token = token.replace(',', '')
	print tokens
	bits = ''
	opcode = opcodes[tokens[0]]
	if(num_arguments[tokens[0]] == 0):
		if(tokens[0] == 'HLT'):
			bits = str(Bits(int=-1, length=32).bin) 
		if(tokens[0] == 'NOP'):
			bits = str(Bits(int=0, length=32).bin)		
	elif(num_arguments[tokens[0]] == 1):
		if(tokens[0] == 'JR'):
			bits = registers32b[tokens[1]] + '{0:021b}'.format(0)
		elif(tokens[0] == 'FLS'):
			bits = '{0:02b}'.format(int(tokens[1])) + '{0:024b}'.format(0)
		else:
			bits = '{0:026b}'.format(int(tokens[1]))
			
		bits = opcode + bits
	elif (num_arguments[tokens[0]] == 2):
		#nothing
		if(tokens[0] == 'NOT'):
			bits = opcode + registers32b[tokens[1]] + registers32b[tokens[2]] + '{0:016b}'.format(int(0))
		else:
			bits = opcode + registers32b[tokens[1]] + '{0:02b}'.format(int(tokens[2])) + '{0:019b}'.format(0)
	elif (num_arguments[tokens[0]] == 3):
		opcode = opcodes[tokens[0]]
		if(tokens[0] == 'LI'):
			bits = opcode + registers32b[tokens[1]] + tokens[2] + str(Bits(int=int(tokens[3]), length=16).bin) + '{0:04b}'.format(0)
		elif(tokens[0] == 'LD' or tokens[0] == 'ST'):
			bits = opcode + registers32b[tokens[1]] + registers32b[tokens[2]] + str(Bits(int=int(tokens[3]), length=16).bin)#'{0:016b}'.format(int(tokens[3]))# + '{0:011b}'.format(0)
		elif(tokens[0] == 'SLL' or tokens[0] == 'SRA' or tokens[0] == 'SRL'):
			bits = opcode + registers32b[tokens[1]] + registers32b[tokens[2]] + '{0:05b}'.format(int(tokens[3])) + '{0:011b}'.format(0)
		elif(tokens[0] == 'DEC' or tokens[0] == 'DECF' or tokens[0] == 'XORE'):
			bits = opcode + registers128b[tokens[1]] + registers128b[tokens[2]] + registers128b[tokens[2]] + '{0:011b}'.format(0)
		else:
			bits = opcode + registers32b[tokens[1]] + registers32b[tokens[2]] + registers32b[tokens[3]] + '{0:011b}'.format(0)
	else :
		bits = opcode + registers128b[tokens[1]] + registers32b[tokens[2]] + registers32b[tokens[3]] + registers32b[tokens[4]] + registers32b[tokens[5]] + '0'

	print bits
	f.write(bits + '\n')
	f.close()
#	for i in xrange(num_arguments[token[0]]):
		
#	print instruction


#Begin reading the file
if os.path.exists(sys.argv[2]):
	os.remove(sys.argv[2])
empty = 0
comments = 1
with open(sys.argv[1]) as fp:
	for line in fp:
		if(line == '\n'):
			empty = empty + 1
		elif('#' in line):
			comments = comments + 1
		else:		
			assemble(line, sys.argv[2])

print "comments: " + str(comments)
print "empty lines: " + str(empty)		
