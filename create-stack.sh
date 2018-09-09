#!/bin/bash
#
# Test:
#    ./create-stack.sh  file.cloudformation.json  [file.param.json]
#

file="${1}"
name="${file%.*}"
name="${name%.*}"

[ "${file}" ] || exit 0
[ "${2}"    ] && param="--parameters file://${2}"

aws cloudformation create-stack \
  --stack-name ${name}  \
  --template-body file://"${file}" \
  ${param}

