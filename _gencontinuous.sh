#!/bin/bash
publisher_jar=input-cache/publisher.jar
input_cache_path=$PWD/input-cache/
set -e

if test -f "$publisher_jar"; then
	java -jar $publisher_jar -ig ig.ini -watch "$@"
else
	publisher_jar=../publisher.jar
	if test -f "$publisher_jar"; then
		java -jar $publisher_jar -ig ig.ini -watch "$@"
	else
		echo IG Publisher NOT FOUND in input-cache or parent folder.
		echo Please run _updatePublisher.sh
		exit 1
	fi
fi
