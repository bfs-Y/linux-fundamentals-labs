#!/bin/bash
# Recall drill: usermod -aG vs -G
# Answer each question yourself before running, then verify.
echo "Q1: A user is in groups audio,video. You want to ADD them to sudo"
echo "    WITHOUT losing audio/video. What's the exact command?"
read -p "Your answer: " ans1
echo "Reference: usermod -aG sudo <username>"
echo ""
echo "Q2: What happens if you run 'usermod -G sudo <username>' instead?"
read -p "Your answer: " ans2
echo "Reference: ALL existing group memberships are silently REPLACED —"
echo "the user ends up in ONLY sudo, losing audio/video entirely."
echo ""
echo "Q3: What command verifies a user's current group memberships?"
read -p "Your answer: " ans3
echo "Reference: id <username>"
