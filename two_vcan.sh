#!/bin/bash

sudo apt install can-utils
sudo modprobe vcan
sudo modprobe can-gw

sudo ip link add dev vcan0 type vcan
sudo ip link add dev vcan1 type vcan

sudo cangw -A -s vcan0 -d vcan1 -e
sudo cangw -A -s vcan1 -d vcan0 -e

sudo ip link set vcan0 up
sudo ip link set vcan1 up
