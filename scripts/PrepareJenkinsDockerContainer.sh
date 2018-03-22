#!/usr/bin/env bash

# This script starts the Jenkins container and installs the packages that the scripts require:
# - Docker Compose
# - Perl

if [[ -z "$1" ]]
then
    echo "Not all required command line arguments were set. Please run the script again with the required arguments:
        1: The path to your Jenkins home directory on your host machine
        2: The path to the Sugar Docker git repo on your host machine

        For example: ./PrepareJenkinsDockerContainer.sh /Users/lschaefer/jenkins /Users/lschaefer/git/sugardocker"
fi

jenkinsHome=$1
sugarDockerRepoPath=$2

# Start Jenkins
containerId=$(docker run -u root --rm -d -p 8080:8080 -v $jenkinsHome:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $sugarDockerRepoPath:/var/sugardocker jenkinsci/blueocean)

# Get the latest packages
docker exec $containerId bash -c "apk update"

# Install pip
docker exec $containerId bash -c "apk add py-pip"

# Install docker-compose
docker exec $containerId bash -c "pip install docker-compose"

# Create a symbolic link
docker exec $containerId bash -c "ln -s /usr/bin/docker-compose /usr/local/bin/docker-compose"

# Install perl
docker exec $containerId bash -c "pip install perl"
