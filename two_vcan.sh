#!/bin/bash

sudo apt install can-utils
sudo modprobe vcan
sudo modprobe can-gw

sudo ip link add vcan0 type vcan
sudo ip link add vcan1 type vcan

sudo cangw -A -s vcan0 -d vcan1 -e
sudo cangw -A -s vcan1 -d vcan0 -e


