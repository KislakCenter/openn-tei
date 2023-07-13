#!/usr/bin/env bash

this_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

find ${this_dir}/../Data -iname \*tei.xml | while read line
do
  dir=$(dirname ${line})
  base=$(basename ${line})
  (
    cd $dir
    ruby ${this_dir}/generate_description_csv.rb ${base} > description.csv
    echo "Wrote ${dir}/description.csv"
  )
done