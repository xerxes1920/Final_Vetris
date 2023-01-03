import re

# Debug flag for output
debug = False

# Open input/output files
inFile = open('test_app.asm', 'r')
outFile = open('test_app.mif', 'w')

# Read lines into list
inLines = inFile.readlines()


def resolve_reg(reg):
    temp = bin(int(reg[1:]))[2:]
    if len(temp) < 5:
        return (5 - len(temp)) * "0" + temp
    elif len(temp) > 5:
        print("Error: Reg overflow detected!")
    else:
        return temp


def resolve_shamt(sh):
    temp = bin(int(sh))[2:]
    if len(temp) < 5:
        return (5 - len(temp)) * "0" + temp
    elif len(temp) > 5:
        print("Error: Shamt overflow detected!")
    else:
        return temp


def resolve_imm(immediate):
    temp = bin(int(immediate))[2:]
    if len(temp) < 16:
        return (16 - len(temp)) * "0" + temp
    elif len(temp) > 16:
        print("Error: Immediate overflow detected!")
    else:
        return temp


def resolve_addr(address):
    temp = bin(int(address))[2:]
    if len(temp) < 26:
        return (26 - len(temp)) * "0" + temp
    elif len(temp) > 26:
        print("Error: Address overflow detected!")
    else:
        return temp


def build_r_type():
    if debug:
        return "{}-{}-{}-{}-{}-{}\n\tR-Type: {}" \
            .format(opCode, resolve_reg(rs), resolve_reg(rt), resolve_reg(rd), resolve_shamt(shamt), funct, instr[0])
    else:
        return "{}{}{}{}{}{}" \
            .format(opCode, resolve_reg(rs), resolve_reg(rt), resolve_reg(rd), resolve_shamt(shamt), funct)


def build_i_type():
    if debug:
        return "{}-{}-{}-{}\n\tI-Type: {}" \
            .format(opCode, resolve_reg(rs), resolve_reg(rt), resolve_imm(imm), instr[0])
    else:
        return "{}{}{}{}" \
            .format(opCode, resolve_reg(rs), resolve_reg(rt), resolve_imm(imm))


def build_j_type():
    if debug:
        return "{}-{}\n\tJ-Type: {}" \
            .format(opCode, addr, instr[0])
    else:
        return "{}{}" \
            .format(opCode, addr)

outLines = []
outLines.append("DEPTH = 2048;                 -- The size of memory in words\n")
outLines.append("WIDTH = 32;                   -- The size of data in bits\n")
outLines.append("ADDRESS_RADIX = HEX;          -- The radix for address values\n")
outLines.append("DATA_RADIX = BIN;             -- The radix for data values\n")
outLines.append("CONTENT                       -- start of (address : data pairs)\n")
outLines.append("BEGIN\n\n")

# Do work on lines
labels = {}
count = 0
for fullLine in inLines:
    instr = fullLine.strip()
    if instr == "" or instr[0:2] == "//":
        continue
    if ":" in instr:
        labels[instr.split(":")[0]] = resolve_addr(count)
    else:
        count += 1

lineNum = 1
hexLineNum = 0
for fullLine in inLines:
    instr = fullLine.strip()
    if instr == "" or instr[0:2] == "//":
        continue

    # Split into list
    instr = re.split(' |, |,', instr)

    # Defaults
    binary = ""
    rs = rt = rd = shamt = "00000"
    opCode = funct = "000000"
    imm = "0000000000000000"
    addr = "00000000000000000000000000"

    # Start large case statement to determine instruction type
    if ":" in instr[0]:  # Labels
        continue
    elif instr[0] == "sll":
        rd = instr[1]
        rt = instr[2]
        shamt = instr[3]
        binary = build_r_type()
    elif instr[0] == "sra":
        opCode = "000001"
        rd = instr[1]
        rt = instr[2]
        shamt = instr[3]
        binary = build_r_type()
    elif instr[0] == "sllv":
        opCode = "000010"
        rd = instr[1]
        rt = instr[2]
        rs = instr[3]
        binary = build_r_type()
    elif instr[0] == "srav":
        opCode = "000011"
        rd = instr[1]
        rt = instr[2]
        rs = instr[3]
        binary = build_r_type()
    elif instr[0] == "jr":
        opCode = "000100"
        rs = instr[1]
        binary = build_i_type()
    elif instr[0] == "add":
        opCode = "000101"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "sub":
        opCode = "000110"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "and":
        opCode = "000111"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "or":
        opCode = "001000"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "xor":
        opCode = "001001"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "nor":
        opCode = "001010"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "slt":
        opCode = "001011"
        rd = instr[1]
        rs = instr[2]
        rt = instr[3]
        binary = build_r_type()
    elif instr[0] == "j":
        opCode = "001100"
        addr = labels[instr[1]]
        binary = build_j_type()
    elif instr[0] == "jal":
        opCode = "001101"
        addr = labels[instr[1]]
        binary = build_j_type()
    elif instr[0] == "beq":
        opCode = "001110"
        rs = instr[1]
        rt = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "bne":
        opCode = "001111"
        rs = instr[1]
        rt = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "blez":
        opCode = "010000"
        rs = instr[1]
        imm = instr[2]
        binary = build_i_type()
    elif instr[0] == "bgtz":
        opCode = "010001"
        rs = instr[1]
        imm = instr[2]
        binary = build_i_type()
    elif instr[0] == "addi":
        opCode = "010010"
        rt = instr[1]
        rs = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "subi":
        opCode = "010011"
        rt = instr[1]
        rs = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "return":
        opCode = "010111"
        binary = build_r_type()
    elif instr[0] == "andi":
        opCode = "010100"
        rt = instr[1]
        rs = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "ori":
        opCode = "010101"
        rt = instr[1]
        rs = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "xori":
        opCode = "010110"
        rt = instr[1]
        rs = instr[2]
        imm = instr[3]
        binary = build_i_type()
    elif instr[0] == "wshp":
        opCode = "011001"
        rt = instr[1]
        binary = build_r_type()
    elif instr[0] == "movshpl":
        opCode = "011010"
        binary = build_r_type()
    elif instr[0] == "movshpr":
        opCode = "011011"
        binary = build_r_type()
    elif instr[0] == "movshpd":
        opCode = "011100"
        binary = build_r_type()
    elif instr[0] == "clrl":
        opCode = "011101"
        rt = instr[1]
        binary = build_r_type()
    elif instr[0] == "sndrow":
        opCode = "011110"
        rt = instr[1]
        binary = build_r_type()
    elif instr[0] == "getrow":
        opCode = "011111"
        rd = instr[1]
        rt = instr[2]
        binary = build_r_type()
    elif instr[0] == "exp":
        opCode = "100000"
        rd = instr[1]
        rt = instr[2]
        binary = build_r_type()
    else:
        if debug:
            print("ERROR: unknown instruction \n\tline #{}: '{}' in application.asm\n".format(lineNum, instr[0]))
        else:
            print("ERROR: unknown instruction \n\t'{}'\n".format(instr[0]))
        exit(69)

    if debug:
        lineNum += 1
    hexVal = (hex(hexLineNum)[2:]).upper() if (len(hex(hexLineNum)[2:]) >= 2) else ("0" + hex(hexLineNum)[2:]).upper()
    outLines.append("{} : {};\n".format(hexVal, binary))
    hexLineNum += 1

outLines.append("\nEND\n")

# Write lines to output file
outFile.writelines(outLines)

# Close files
inFile.close()
outFile.close()
