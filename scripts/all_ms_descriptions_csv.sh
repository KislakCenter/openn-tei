#!/usr/bin/env bash

this_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

output=all_ms_descriptions.csv
find ${this_dir}/../Data -iname \*tei.xml | ruby ${this_dir}/generate_description_csv.rb > all_ms_descriptions.csv > ${output}

echo "Wrote: ${output}"