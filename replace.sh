#!/bin/bash
sed "s/tagVersion/$1/g" pod.yml > pod.yml
