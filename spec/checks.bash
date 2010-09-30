#!/bin/bash

# LeadTune API Ruby Gem
#
# http://github.com/leadtune/leadtune-ruby
# Eric Wollesen (mailto:devs@leadtune.com)
# Copyright 2010 LeadTune LLC

# this is just a quick script to check a few prerequisites

which curl > /dev/null
if [ $? -ne 0 ]; then
    echo "curl binary not found"
    exit 1
fi

curl -V | grep -qi '\bssl\b'
if [ $? -ne 0 ]; then
    echo "curl does not support ssl"
    exit 1
fi

host appraiser.leadtune.com > /dev/null
if [ $? -ne 0 ]; then
    echo "could not resolve appraiser.leadtune.com"
    exit 1
fi

host sandbox-appraiser.leadtune.com > /dev/null
if [ $? -ne 0 ]; then
    echo "could not resolve sandbox-appraiser.leadtune.com"
    exit 1
fi


echo Everything looks good.
exit 0