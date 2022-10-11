#!/bin/bash

# Set up Coder extensions in Singularity
if [ -n "$SINGULARITY_NAME" ]; then
    if [ ! -e "$HOME/.vscode" ]; then
        ln -s -f $HOME/.config/vscode $HOME/.vscode
    elif [ ! -e "$HOME/.vscode/extensions" ]; then
        ln -s -f $HOME/.config/vscode/extensions $HOME/.vscode
    fi
fi
