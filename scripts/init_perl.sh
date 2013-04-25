#!/bin/bash

###############################################################################
### The purpose of this file is install needed perl module locally.
###
###############################################################################

# First let's get the location of the current script.
MY_OLDPWD=$(pwd)
MY_WD=${0%/init_perl.sh}
MY_OS=$(uname)
CPANM_CMD=cpanm
CPANM="./$CPANM_CMD -L perlLib"

pushd $MY_WD 1>/dev/null
# Install cpanm if it does not already exists.
if [ ! -x $CPANM_CMD ] ; then
  # Assume DARWIN for now. 
  curl -LO http://xrl.us/cpanm 1>/dev/null
  chmod +x cpanm
fi

#Install Needed module to local dir 

$CPANM File::Slurp JSON JSON::Path Git::Repository 2>/tmp/run_cmd.log 1>/dev/null
# Git::PurePerl

popd 1>/dev/null
