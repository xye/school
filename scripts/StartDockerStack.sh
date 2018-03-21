#!/usr/bin/env bash

# This script clones a copy of the Sugar Docker repo and starts the appropriate stack.


######################################################################
# Variables
######################################################################

#TODO: fix this for dockerDirectory
if [[ -z "$1" ]] || [[ -z "$2" ]]
then
    echo "Not all required command line arguments were set. Please run the script again with the required arguments:
        1: Sugar version (Example: 7.11)
        2: Path to where the Sugar Docker files should be stored relative to the current directory. WARNING: The
           data/app/sugar directory will be deleted and recreated.

        For example: ./StartDockerStack.sh 7.11 workspace/sugardocker"
    exit 1
fi

# The Sugar version to download
sugarVersion=$1

# The local directory associated with the $dockerGitRepo
dockerDirectory=$2

# The Git Repo where the Sugar Docker stacks are stored
dockerGitRepo="https://github.com/esimonetti/SugarDockerized.git"


######################################################################
# Setup
######################################################################

if [[ "$sugarVersion" == "7.10" || "$sugarVersion" == "7.11" ]]
then
    ymlPath=$dockerDirectory/stacks/sugar710/php71.yml
elif [[ "$sugarVersion" == "7.9" ]]
then
    ymlPath=$dockerDirectory/stacks/sugar79/php71.yml
else
    echo "Unable to identify Docker Stack yml for Sugar version $sugarVersion"
    exit 1
fi


######################################################################
# Start the Docker Stack
######################################################################

# Get the latest changes from the Sugar Docker repo
if [ -d "$dockerDirectory" ];
then
    cwd=$(pwd)
    cd $dockerDirectory
    git fetch $dockerGitRepo
    git pull $dockerGitRepo
    cd $cwd
else
    git clone $dockerGitRepo $dockerDirectory
fi

# Special case for when this code is being run from Jenkins running on Docker.
# We need to update the Sugar Docker stack yml file to have a hard coded path to the Sugar Docker directory on the
# host machine.
if [[ -n $PATH_TO_SUGAR_DOCKER_ON_HOST ]]
then
    # This regular expression searches for the following:
    #
    # volumes:
    #          - ../../
    #
    # The "../.." are replaced with the path to the Sugar Docker Directory

    perl -0777 -i -pe "s#(volumes\:\n *- )\.\.\/\.\.#\1$PATH_TO_SUGAR_DOCKER_ON_HOST#g" $ymlPath
fi

# Start the Sugar Docker stack
docker-compose -f $ymlPath up -d
