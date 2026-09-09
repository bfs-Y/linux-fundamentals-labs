#!/bin/bash
# Triggers OOM killer by exhausting memory
# Run in a VM with a snapshot first
echo "WARNING: This will exhaust memory and trigger OOM killer"
echo "Ensure you have a VM snapshot before running"
echo "Press Ctrl+C within 5 seconds to abort"
sleep 5

echo "Allocating memory..."
python3 -c "
chunks = []
i = 0
while True:
    chunks.append(' ' * 10**6)
    i += 1
    if i % 100 == 0:
        print(f'Allocated {i}MB')
"
