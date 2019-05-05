# MHXMLP

My Horrible XML Parser

Exercise for UNIX classes at ISEN school.

## Usage

```bash
cat plant_catalog.xml | ./mhxmlp.sh
```

## Tests

`tester.sh` allows testing a few conditions with different files :

* `plant_catalog.xml`: 0: No error
* `empty.xml`: 11: Error, the file is empty
* `no_catalog.xml`: 19: Error, malformed XML, catalog not found
* `no_plant.xml`: 19: Error, malformed XML, unexpected data not in plant line 123
* `no_opening.xml`: 19: Error, no opening tag on line 284
* `no_closing.xml`: 19: Error, no closing tag on line 166
* `double_plant.xml`: 19: Error, you can't define a plant inside a plant (no plantception) line 90
* `duplicated.xml`: 19: Error, malformed XML, duplicated entry line 62
* `no_preamble.xml`: 19: Error, no xml preamble
* `no_common.xml`: 19: Error, malformed XML, COMMON field not found
* `./mhxmlp.sh [arg]`: 5: Error, wrong arguments
