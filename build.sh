#!/bin/sh

make -C data all
mirage configure $*

make build
