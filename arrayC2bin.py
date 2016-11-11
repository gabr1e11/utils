#!/usr/bin/python3
import sys
from optparse import OptionParser

def main():

    parser = OptionParser()
    parser.add_option("-i", "--input",  dest="in_filename",  help="Read file with C style hex data", metavar="FILE")
    parser.add_option("-o", "--output", dest="out_filename", help="Output binary data to file", metavar="FILE")

    (options, args) = parser.parse_args()

    # Open input and output files
    in_file = open(options.in_filename, 'r') if options.in_filename != None else sys.stdin
    out_file = open(options.out_filename, 'wb') if options.out_filename != None else sys.stdout.buffer

    in_data = in_file.read()
    in_data = in_data.rstrip().split(",")
    in_data = [ int(x,16) for x in in_data ]
    in_data = bytes(in_data)
    out_file.write(in_data)

    in_file.close()
    out_file.close()

if __name__ == "__main__":
    main()
