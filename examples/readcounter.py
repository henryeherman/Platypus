#!/usr/bin/env python
import os
import sys
import argparse

parser = argparse.ArgumentParser(description='Read data from counter file and print to screen',
                                epilog='Intended for use with FT2232H TX Demo')

parser.add_argument('infile', nargs=1, type=argparse.FileType('r'))

args = parser.parse_args()

f = args.infile[0]

while True:
    val = f.read(1)
    if val:
        #pass

        print ord(val)
    else:
        break

print "Reached end of file"
