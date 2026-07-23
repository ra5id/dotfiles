#!/bin/bash
if pgrep -fi "vesktop" > /dev/null
then
    # The -fi here ensures we kill the same thing we found
    pkill -fi "vesktop"
else
    # Launch in background and detach so the script can finish
    vesktop &
fi
