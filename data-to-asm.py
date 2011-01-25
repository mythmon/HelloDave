#!/usr/bin/python

import re

data_path = 'data.txt'
blocks = []

try:
    data_file = open(data_path)
    for line in data_file:
        if line.strip() == '':
            continue
        block = {}
        block['name'] = line.strip()
        line1 = data_file.readline()[:-1]
        line2 = data_file.readline()[:-1]
        
        # 0x7E and 0x7F are right/left arrows on the microcontroller.
        if line1[0] == '<':
            line1 = chr(0x7F) + line1[1:]
        if line2[0] == '>':
            line2 = chr(0x7E) + line2[1:]

        block['line1'] = line1.ljust(16)
        block['line2'] = line2.ljust(16)
        block['opt1'], block['opt2'] = [x.strip() for x in data_file.readline().split(',')]
        blocks.append(block)
finally:
    data_file.close()

try:
    output = open('storydata.asm', 'w')

    for block in blocks:
        output.write('{0[name]}:\n'.format(block))
        output.write('.DB     "{0[line1]}"\n'.format(block))
        output.write('.DB     "{0[line2]}"\n'.format(block))
        output.write('.DW     {0[opt1]} << 1\n'.format(block))
        output.write('.DW     {0[opt2]} << 1\n'.format(block))
        output.write('\n')
finally:
    output.close()
