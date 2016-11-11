#!/bin/bash

#
# Converts an input binary file containing 2048-bit modulus + 4 bytes exponent into
# a PEM file that can be used with OpenSSL
#
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "    $(basename $0) <modexp.bin>"
    echo ""

    exit 0
fi

function successOrDie()
{
    errcode=$?
    if [ "$errcode" != "0" ]; then
        echo "ERROR [$errcode] $1"
        rm -rf tmp 2>/dev/null
        exit $errcode
    fi
}

input_file=$1
output_name=$(basename $input_file)
output_file="${output_name%.*}.pem"

rm -rf tmp
mkdir tmp

dd if=$input_file of=tmp/modulus.bin bs=1 count=256 2>/dev/null
successOrDie "Creating modulus file"

dd if=$input_file of=tmp/exponent.bin bs=1 skip=257 count=3 2>/dev/null
successOrDie "Creating exponent file"

echo 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA' | base64 -d > tmp/header.bin
successOrDie "Creating PEM header file"

echo '02 03' | xxd -r -p > tmp/mid-header.bin
successOrDie "Creating PEM intermediate header file"

cat tmp/header.bin tmp/modulus.bin tmp/mid-header.bin tmp/exponent.bin > tmp/key.der
successOrDie "Creating intermediate DER file"

openssl pkey -inform der -outform pem -pubin -in tmp/key.der -out $output_file
successOrDie "Generating final PEM file"

openssl asn1parse -in $output_file -strparse 19 2>/dev/null 1>&2
successOrDie "Generated PEM file cannot be read by OpenSSL"

echo "PEM file created succesfully!"
echo ""
echo "INFO"
openssl asn1parse -in $output_file -strparse 19

rm -rf tmp 2>/dev/null
