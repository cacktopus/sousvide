#!/bin/bash

outpin () {
    PIN=$1
    echo ${PIN} > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio${PIN}/direction 
    chgrp gpio /sys/class/gpio/gpio${PIN}/value
    chmod g+w /sys/class/gpio/gpio${PIN}/value
}

outpin 25
outpin 17

chown root.gpio /dev/watchdog
chmod g+rw /dev/watchdog
