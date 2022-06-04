#!/bin/bash

echo -e "\n"

# schematool --initSchema -dbType derby
schematool --initSchema -dbType mysql

echo -e "\n"

hive