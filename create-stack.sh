#!/bin/bash


file="${1}"
name="${file%.*}"
name="${name%.*}"

[ "${file}" ] || exit 0

aws cloudformation create-stack \
  --stack-name ${name}  \
  --template-body file://"${file}"

