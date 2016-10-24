#!/usr/bin/python3
import sys

PEM_FORMAT = [ [ "modulus",         256 ],
               [ "publicexponent",  4 ],
               [ "privateexponent", 128 ],
               [ "prime1",          128 ],
               [ "prime2",          128 ],
               [ "exponent1",       128 ],
               [ "exponent2",       128 ],
               [ "coefficient",     128] ]
PAD_SIZE = 16
line = ''

def readPEMLine():
    try:
        return input().lower().split(':')
    except EOFError:
        return None

def parseField(field):

    global line
    while True:
        if (line != None) and (len(line) > 0) and (line[0] == field):
            break
        line = readPEMLine()
        if (line == None):
            return None

    if (field == "publicexponent"):
        return [ line[1].split()[0] ]

    data = []
    while True:
        line = readPEMLine()
        if '' in line:
            line.remove('')

        if line == None or not line:
            continue
        # Check if we've finished with current field
        if line[0][0] != ' ':
            break

        data += [ ("0x" + x.strip()) for x in line ]

    return data

def printData(data, addComma):

    if (addComma):
        print(", ")

    lastIdx = len(data)-1

    for idx,elem in enumerate(data):
        print(elem, end="")
        if (idx != lastIdx):
            print(", ", end="")

            if ((idx % PAD_SIZE) == PAD_SIZE-1):
                print("\n", end="")

if __name__ == '__main__':
    firstTime = True
    publicExponent = None

    for idx,entry in enumerate(PEM_FORMAT):
        data = parseField(entry[0])
        if (data == None):
            break

        # Don't ouput the public exponent
        if (entry[0] == "publicexponent"):
            publicExponent = data[0];
            continue

        printData(data[-entry[1]:], not firstTime)
        firstTime = False

    print("\n")
    print("Public Exponent: " + publicExponent);
