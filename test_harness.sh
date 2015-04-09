#!/bin/bash

PARAM_LIST="1"

for PARAM in ${PARAM_LIST}; do
  ./$1 $PARAM
done 
