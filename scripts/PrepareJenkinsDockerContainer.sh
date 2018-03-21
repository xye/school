#!/usr/bin/env bash

if [[ -z "$1" ]]
then
    echo "Not all required command line arguments were set. Please run the script again with the required arguments:
        1: The path to your Jenkins home directory

        For example: ./PrepareJenkinsDockerContainer.sh /Users/lschaefer/jenkins"
fi

jenkinsHome=$1

# Start Jenkins
containerId=$(docker run -u root --rm -d -p 8080:8080 -v $jenkinsHome:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v /Users/lschaefer/git/sugardocker:/var/sugardocker jenkinsci/blueocean)

docker exec $containerId bash -c "apk update"

# Install pip
docker exec $containerId bash -c "apk add py-pip"

# Install docker-compose
docker exec $containerId bash -c "pip install docker-compose"

# Create a symbolic link
docker exec $containerId bash -c "ln -s /usr/bin/docker-compose /usr/local/bin/docker-compose"

# Install perl
docker exec $containerId bash -c "pip install perl"
