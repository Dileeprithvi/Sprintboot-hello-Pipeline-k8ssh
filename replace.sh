#!/bin/bash
sed "s/tagVersion/$1/g" pods.yml > pod.yml
