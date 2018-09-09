#!/bin/bash


file="${1}"
name="${file%.*}"
name="${name%.*}"

[ "${file}" ] || exit 0

aws cloudformation validate-template \
  --template-body file://"${file}"

