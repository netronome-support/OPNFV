#!/bin/bash

SESSIONNAME="mario-vr4"
tmux has-session -t $SESSIONNAME &> /dev/null

if [ $? != 0 ]
    then
        # create session, window 0, and detach
        tmux new-session -s $SESSIONNAME -d
        tmux rename-window -t $SESSIONNAME:0 vr4
        # configure window
        tmux select-window -t $SESSIONNAME:0
tmux select-window -t mario-vr4:0
        tmux split-window -h
                tmux split-window -v
        tmux split-window -v -t 0

fi

tmux attach -t $SESSIONNAME

