#!/bin/bash

test_file() {
  output=$(cat $1 | ./mhxmlp.sh 2>&1 > /dev/null)
  echo "$1: $?: $output"
}

test_file plant_catalog.xml
test_file empty.xml
test_file no_catalog.xml
test_file no_plant.xml
test_file no_opening.xml
test_file no_closing.xml
test_file double_plant.xml
test_file duplicated.xml
test_file no_preamble.xml
test_file no_common.xml

output=$(cat plant_catalog.xml | ./mhxmlp.sh argument 2>&1 > /dev/null)
echo "./mhxmlp.sh [arg]: $?: $output"