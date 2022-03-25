#!/bin/bash

ssh-keygen -f "/home/nbt/.ssh/known_hosts" -R "192.168.10.10"
ssh-keygen -f "/home/nbt/.ssh/known_hosts" -R "192.168.10.20"
