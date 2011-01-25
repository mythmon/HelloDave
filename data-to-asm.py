#!/usr/bin/python

import re

data_path = 'data.txt'
blocks = []

class OopsBlock:

    oopsId = 0

    @classmethod
    def make(cls, prevOpt, id=[]):

        oopsBlock = {
            'name': 'OOPS_{}'.format(cls.oopsId),
            'line1': 'Oops! No one has',
            'line2': 'written this yet',
            'opt1' : prevOpt,
            'opt2' : prevOpt
        }
        cls.oopsId += 1
        return oopsBlock['name'], oopsBlock

try:
    data_file = open(data_path)
    for line in data_file:
        if line.strip() == '':
            continue

        name = line.strip()

        line1 = data_file.readline()[:-1]
        line2 = data_file.readline()[:-1]

        # 0x7E and 0x7F are right/left arrows on the microcontroller.
        if line1[0] == '<':
            line1 = chr(0x7F) + line1[1:]
        if line2[0] == '>':
            line2 = chr(0x7E) + line2[1:]

        line1 = line1.ljust(16)
        line2 = line2.ljust(16)

        opt1, opt2 = [x.strip() for x in data_file.readline().split(',')]
        if opt1 == 'OOPS':
            opt1, oopsBlock = OopsBlock.make(name)
            blocks.append(oopsBlock)
        if opt2 == 'OOPS':
            opt2, oopsBlock = OopsBlock.make(name)
            blocks.append(oopsBlock)

        blocks.append({
            'name': name,
            'line1': line1,
            'line2': line2,
            'opt1': opt1,
            'opt2': opt2
        })
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
