#!/bin/sh

REPO=$1

git clone $REPO `echo $REPO | sed -e 's/^.*github.com\///'`
