#!/bin/sh

if [[ $# -ne 0 ]]; then
  echo "Error, wrong arguments" >&2
  exit 5
fi

retval=""

extract_body() {
  retval=$(cut -d '>' -f 2 <<< "$1" | cut -d '<' -f 1)
}

assert_catalog() {
  if [ $has_catalog = false ]; then
    echo "Error, malformed XML, catalog not found" >&2
    exit 19
  fi
}

assert_duplicate() {
  if [[ $1 != "" ]]; then
    echo "Error, malformed XML, duplicated entry line $count" >&2
    exit 19
  fi
}

assert_closing() {
  if [[ $1 != *"</$2>" ]]; then
    echo "Error, no closing tag on line $count" >&2
    exit 19
  fi
}

assert_opening() {
  if [[ $1 != "<$2>"* ]]; then
    echo "Error, no opening tag on line $count" >&2
    exit 19
  fi
}

assert_in_plant() {
  if [[ $in_plant == false ]]; then
    echo "Error, malformed XML, unexpected data not in plant line $count" >&2
    exit 19
  fi
}

assert_plant_closed() {
  if [[ $in_plant == true ]]; then
    echo "Error, you can't define a plant inside a plant (no plantception) line $count" >&2
    exit 19
  fi
}

assert_line() {
  assert_catalog
  assert_in_plant
  assert_duplicate "$3"
  assert_opening "$1" "$2"
  assert_closing "$1" "$2"
}

assert_empty() {
  if [[ $count -eq 0 ]]; then
    echo "Error, the file is empty" >&2
    exit 11
  fi
}

assert_no_preamble() {
  if [[ $has_xml_preamble == false ]]; then
    echo "Error, no xml preamble" >&2
    exit 19
  fi
}

count=0
has_catalog=false
has_common=false
in_plant=false

has_xml_preamble=false
while read line; do
  if [[ $line != "" ]]; then
    count=$((count + 1))
  fi

  if [[ $line == "<?xml"*"?>" ]]; then
    has_xml_preamble=true
    break
  fi
done

assert_empty
assert_no_preamble

while read line; do
  if [[ $line != "" ]]; then
    count=$((count + 1))
  fi

  if [[ $line == "<CATALOG>" ]]; then
    has_catalog=true
  fi

  if [[ $line == "<PLANT>" ]]; then
    assert_catalog
    assert_plant_closed

    common=""
    botanical=""
    zone=""
    light=""
    price=""
    availability=""

    in_plant=true
  fi

  if [[ $line == *"COMMON"* ]]; then
    assert_line "$line" "COMMON" "$common"

    extract_body "$line"
    has_common=true
    common=$retval
  fi

  if [[ $line == *"BOTANICAL"* ]]; then
    assert_line "$line" "BOTANICAL" "$botanical"

    extract_body "$line"
    botanical=$retval
  fi

  if [[ $line == *"ZONE"* ]]; then
    assert_line "$line" "ZONE" "$zone"

    extract_body "$line"
    zone=$retval
  fi

  if [[ $line == *"LIGHT"* ]]; then
    assert_line "$line" "LIGHT" "$light"

    extract_body "$line"
    light=$retval
  fi

  if [[ $line == *"PRICE"* ]]; then
    assert_line "$line" "PRICE" "$price"

    extract_body "$line"
    price=$retval
  fi

  if [[ $line == *"AVAILABILITY"* ]]; then
    assert_line "$line" "AVAILABILITY" "$availability"

    extract_body "$line"
    availability=$retval
  fi

  if [[ $line == "</PLANT>" ]]; then
    if [ $has_common = false ]; then
      echo "Error, malformed XML, COMMON field not found" >&2
      exit 19
    fi
    
    has_common=false
    in_plant=false
    echo "$common;$botanical;$zone;$light;$price;$availability"
  fi
done

assert_empty

echo "No error" >&2
exit 0