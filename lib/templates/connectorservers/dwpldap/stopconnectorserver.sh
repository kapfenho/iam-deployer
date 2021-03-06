#!/bin/sh


pid=$(pgrep -f '\/dwpldap\/conf\/ConnectorServer\.properties')

if [ -n ${pid} ]
then
  echo "Stopping process with PID ${pid}..."
  kill ${pid}
  echo "Process stopped."
else
  echo "No running instance found."
  exit 70
fi

exit 0


