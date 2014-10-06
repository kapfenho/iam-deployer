#!/bin/sh


rm -Rf /opt/fmw/*
mkdir -p /opt/fmw/products

ps -ef | grep fmwuser | awk '{ print $2 }' | xargs kill -9
