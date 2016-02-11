#!/bin/bash
#
# Author: Oleg Gincul <oleg.gincul@gmail.com>
#
# Script to recursively search inside Java archives.
# Usage: listArchContents.sh [-p <file-regex>] [-l <location-to-search>]

# Recursive search. Arguments:
#   - file regex
#   - location to search in
#   - [prefix for results]
listArchContents()
{
  # Iterate over [ewj]ar archives
  find $2 -type f -name '*[ewj]ar' ! -path .listArchContents | while read file; do
    # If [ew]ar, unpack and list recursively
    if [[ $file == *[ew]ar ]]; then
      mkdir -p .listArchContents
      cd .listArchContents
      jar xf ../$file
      listArchContents $1 . ${3:+$3:}${file#./}
      cd ..
      rm -fR .listArchContents
    fi
    # List archive contents
    jar tf $file | grep $1 | while read finding; do
      echo ${3:+$3:}${file#./}:$finding
    done
  done
}

# Regex and location init
paramInit()
{
  while getopts p:l: optname; do
    case $optname in
      p)
        regex=$OPTARG;;
      l)
        location=$OPTARG;;
    esac
  done
}

# Cleanup cache on CTRL+C
ctrlC()
{
  rm -fR .listArchContents
}

# Main
paramInit "$@"
trap ctrlC INT
listArchContents ${regex:-.} ${location:-.}
