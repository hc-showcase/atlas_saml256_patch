#!/bin/sh

docker build -t atlas .

docker tag atlas:latest 10.156.0.2:9874/hashicorp-atlas:CIRC-143648-3973f7b824
