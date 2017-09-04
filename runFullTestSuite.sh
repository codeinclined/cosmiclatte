#!/bin/sh

date -u > LAST_TEST
git describe --always >> LAST_TEST
lua tests/fullsuite.lua | tee -a LAST_TEST
sed -i'' -r 's/'$(echo -e "\033")'\[[0-9]{1,2}(;([0-9]{1,2})?)?[mK]//g' LAST_TEST
