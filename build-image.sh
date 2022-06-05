#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop&hive image\n"
sudo docker build -t yanyun/hadoop:1.2 .

echo ""