#!/bin/bash

packages=(packages.{both,i686,x86_64})

sed '/^#/d' "${packages[@]}" |
sed '/^\s*$/d' | sort | uniq -d |
while read p ; do
	printf "$p in: "
	grep -l "^\s*$p\s*$" "${packages[@]}" | tr '\n' ' '
	echo
done
