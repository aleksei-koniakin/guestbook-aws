#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "Usage: $0 [username]"
    exit 1
fi

if [[ $1 -eq "{{ bastion_user }}" ]] ; then
    cat /var/keys/*
fi
