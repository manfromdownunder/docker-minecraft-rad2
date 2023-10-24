#!/bin/bash

# Send initial 5-minute warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 5 minutes. Please log off.$(printf \\r)"
sleep 60  # Wait for 1 minute

# Send 4-minute warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 4 minutes. Please log off.$(printf \\r)"
sleep 60  # Wait for 1 minute

# Send 3-minute warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 3 minutes. Please log off.$(printf \\r)"
sleep 60  # Wait for 1 minute

# Send 2-minute warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 2 minutes. Please log off.$(printf \\r)"
sleep 60  # Wait for 1 minute

# Send 1-minute warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 1 minute. Please log off.$(printf \\r)"
sleep 30  # Wait for 30 seconds

# Send 30-second warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 30 seconds. Please log off.$(printf \\r)"
sleep 20  # Wait for 20 seconds

# Send 10-second warning
screen -S minecraft -p 0 -X stuff "say Server will restart in 10 seconds. Please log off.$(printf \\r)"
sleep 10  # Wait for 10 seconds

# Send server restarting message
screen -S minecraft -p 0 -X stuff "say Server is restarting now.$(printf \\r)"

# Perform server restart
screen -S minecraft -p 0 -X stuff "restart$(printf \\r)"
