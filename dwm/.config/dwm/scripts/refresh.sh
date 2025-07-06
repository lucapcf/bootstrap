#!/bin/bash

#pkill -f status.sh

kill "$(pstree -lp | grep -- -status.sh\([0-9] | sed "s/.*sleep(\([0-9]\+\)).*/\1/")"

