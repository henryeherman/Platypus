#!/usr/bin/env python

import os
import signal
import sys
import argparse

parser = argparse.ArgumentParser(description='Write data to file continuously',
                                epilog='Intended for use with FT2232H RX Demo')

parser.add_argument('outfile', nargs=1, type=argparse.FileType('w'))
parser.add_argument('-n', dest = 'numrepeat', action='store', type=int, default=1024)
parser.add_argument('-N', dest = 'numpackets', action='store', type=int, default=None)
parser.add_argument('--fifo', action="store_true", default=False)

args = parser.parse_args()


f = args.outfile[0]

if args.fifo:
    print "Output to FIFO %s" % f.name
    f.close()
    os.remove(f.name)
    os.mkfifo(f.name)
    f = file(f.name)

exit_request = False

def handler(signum, frame):
    print "Signal handler called with signal:", signum
    f.close()
    sys.exit(0)
    exit_request = True

signal.signal(signal.SIGINT, handler)

total_count = 0
count = 0
while (True):
    import time
    print count
    f.write(chr(count) * args.numrepeat)
    count = count + 1
    total_count = total_count + 1
    if count > 255:
        count = 0
    if exit_request is True:
        break

    if args.numpackets is not None:
        if total_count > args.numpackets:
            break
