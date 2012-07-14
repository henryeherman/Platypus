#!/usr/bin/env python

import sys
import os
import argparse
import random
import itertools

parser = argparse.ArgumentParser(description='Generate Random Data for ADC Input')

parser.add_argument('-o','--outfile',dest="outfile",
        metavar="out-file",action="store",type=argparse.FileType("wt")) 

parser.add_argument('-N','--numadc',action="store",dest='numadc',type=int,default=8)

parser.add_argument('-L','--length',action="store",dest='length',type=int,default=1000)

args = parser.parse_args()

print "NUM ADC: %d" % args.numadc, "\t LENGTH: %d" % args.length


if args.outfile is None:
    args.outfile = file("adcval.tv", 'w' )

vals = ("%04X\n" % random.randint(0,2**16) for i in xrange(0,args.numadc * args.length))
args.outfile.writelines(vals)
args.outfile.flush()
args.outfile.close()
