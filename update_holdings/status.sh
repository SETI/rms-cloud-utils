#!/usr/bin/bash
TOTAL=`ls logs|wc -l`
SUCCESS=`grep SUCCESS logs/*|wc -l`
FAIL=`grep FAIL logs/* |wc -l`
echo "Total:  " $TOTAL
echo "Success:" $SUCCESS
echo "Fail:   " $FAIL
echo "Neither:" `expr $TOTAL - $SUCCESS - $FAIL`
grep FAIL logs/*

