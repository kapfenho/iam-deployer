#!/bin/sh

# ----------------------------------------------------------------------------------------------------
# Start Script for the Java Connector Server
#
# Environment Variable Prequisites
#
#   JAVA_HOME                 Must point at your Java Development Kit installation.
#                             The script will try to guess the right value if not set.
#
#   JRE_HOME                  (Optional) Must point at your Java Runtime Enviroment installation.
#                             Defaults to JAVA_HOME if empty.
#
#   SEP                       Platform separator, typically, ":" on Unix platforms, 
#                             ";" on Windows.
#                             The script will try to guess the right value if not set.
#
#   CONNECTOR_SERVER_HOME     (Optional) Path to the Connector Server home directory.
#                             Defaults to the parent directory of directory where this script resides.
#
#   CONNECTOR_SERVER_OUT      (Optional) Full path to a file where stdout and stderr
#                             will be redirected. 
#                             Default is $CONNECTOR_SERVER_HOME/logs/connectorserver.out
#
#   CONNECTOR_SERVER_TMPDIR   (Optional) Directory path location of temporary directory
#                             the JVM should use (java.io.tmpdir).  Defaults to
#                             $CONNECTOR_SERVER_HOME/temp.
#
#   CONNECTOR_SERVER_PID      (Optional) Path of the file which should contains the pid
#                             of connector server startup java process, when start (fork) is used
#
# -----------------------------------------------------------------------------------------------------

# Resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set CONNECTOR_SERVER_HOME if not already set
[ -z "$CONNECTOR_SERVER_HOME" ] && CONNECTOR_SERVER_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

# When no TTY is available, don't output to console
have_tty=0
if [ "`tty`" != "not a tty" ]; then
    have_tty=1
fi

# Make sure we have either JAVA_HOME or JRE_HOME
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  # Try to find JDK on Darwin  
  if [ -d "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home" ]; then
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
  fi
  if [ -z "$JAVA_HOME" ]; then
    JAVA_PATH=`which java 2>/dev/null`
    if [ "x$JAVA_PATH" != "x" ]; then
      JAVA_PATH=`dirname $JAVA_PATH 2>/dev/null`
      JRE_HOME=`dirname $JAVA_PATH 2>/dev/null`
    fi
    if [ "x$JRE_HOME" = "x" ]; then
      # XXX: Should we try other locations?
      if [ -x /usr/bin/java ]; then
        JRE_HOME=/usr
      fi
    fi
  fi
  if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
    echo "Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
    echo "At least one of these environment variable is needed to run this program"
    exit 1
  fi
fi
if [ -z "$JRE_HOME" ]; then
  JRE_HOME="$JAVA_HOME"
fi

# Set standard commands for invoking Java.
_RUNJAVA="$JRE_HOME"/bin/java

# Platform separator, allow setting variable from outside the script
if [ -z "$SEP" ]; then
  SEP=":"
  if [ "`uname -s | grep -i "windows"`" = "`uname -s`" -o "`uname -s | grep -i "cygwin"`" = "`uname -s`" ]; then
    SEP=";"
  fi
fi

# ----- Execute The Requested Command -----------------------------------------

# Only output this if we have a TTY
if [ $have_tty -eq 1 ]; then
  echo "CONNECTOR_SERVER_HOME: $CONNECTOR_SERVER_HOME"
  echo "Using Java Path:       $JAVA_HOME"
  echo "Using JRE Path:        $JAVA_HOME"
  echo
fi

# Misc variables
if [ -z "$CONNECTOR_SERVER_OUT" ] ; then
  CONNECTOR_SERVER_OUT="${CONNECTOR_SERVER_HOME}/logs/connectorserver.out"
fi
if [ -z "$CONNECTOR_SERVER_TMPDIR" ] ; then
  CONNECTOR_SERVER_TMPDIR="${CONNECTOR_SERVER_HOME}/temp"
fi
if [ -z "$CONNECTOR_SERVER_PID" ] ; then
  CONNECTOR_SERVER_PID="${CONNECTOR_SERVER_HOME}/.pid"
fi
CP="${CONNECTOR_SERVER_HOME}/lib/framework/connector-framework.jar${SEP}${CONNECTOR_SERVER_HOME}/lib/framework/connector-framework-internal.jar${SEP}${CONNECTOR_SERVER_HOME}/lib/framework/groovy-all.jar"
MAIN_CLASS="org.identityconnectors.framework.server.Main"
SERVER_PROPERTIES="${CONNECTOR_SERVER_HOME}/conf/ConnectorServer.properties"
JVM_OPTION_IDENTIFIER="-J"

if [ "$1" = "/run" -o "$1" = "/start" ]; then
  COMMAND=$1
  shift
  JAVA_OPTS_PARAMS=""
  JAVA_OPTS_DELIM=""
  # Now process the rest of arguments
  while [ ! -z "$1" ]; do
    # Process only those arguments starting with -J
    if [ `expr substr "$1" 1 2` = "$JVM_OPTION_IDENTIFIER" ]; then
      LENGTH=`expr length "$1"`
      LENGTH=`expr $LENGTH - 2`
      PARAM=`expr substr "$1" 3 $LENGTH`
      JAVA_OPTS_PARAMS="${JAVA_OPTS_PARAMS}${JAVA_OPTS_DELIM}${PARAM}"
      JAVA_OPTS_DELIM=" "
    fi
    shift
  done

  # Need to start the server from CONNECTOR_SERVER_HOME directory since the bundles and lib directory are defined relative to it
  cd "$CONNECTOR_SERVER_HOME"

  if [ "$COMMAND" = "/run" ]; then
    # Run the process in the current console  
    exec "$_RUNJAVA" -Xmx500m -D"java.util.logging.config.file=${CONNECTOR_SERVER_HOME}/conf/logging.properties" -D"java.io.tmpdir=${CONNECTOR_SERVER_TMPDIR}" $JAVA_OPTS_PARAMS \
      -server -cp "$CP" "$MAIN_CLASS" \
      -run -properties "$SERVER_PROPERTIES"
  else    
    if [ -f "$CONNECTOR_SERVER_PID" ]; then
      echo "PID file ($CONNECTOR_SERVER_PID) found. Is Connector Server still running? Start aborted."
      exit 1
    fi
    touch "$CONNECTOR_SERVER_OUT"

    # Run the process in the background
    "$_RUNJAVA" -Xmx500m -D"java.util.logging.config.file=${CONNECTOR_SERVER_HOME}/conf/logging.properties" -D"java.io.tmpdir=${CONNECTOR_SERVER_TMPDIR}" $JAVA_OPTS_PARAMS \
      -server -cp "$CP" "$MAIN_CLASS" \
      -run -properties "$SERVER_PROPERTIES" \
      >> "$CONNECTOR_SERVER_OUT" 2>&1 &
    # Store PID
    echo $! > "$CONNECTOR_SERVER_PID"
    echo "Connector server started in the background" 
  fi

  # Go back to the original directory
  cd "$PRGDIR"

elif [ "$1" = "/stop" ] ; then
  shift
  # Determine sleep time, 5 is default
  SLEEP=5  
  if [ ! -z "$1" ]; then
    echo $1 | grep "[^0-9]" > /dev/null 2>&1
    if [ $? -gt 0 ]; then
      SLEEP=$1
      shift
    fi
  fi

  # Use force option?, no is default
  FORCE=0
  if [ "$1" = "-force" ]; then
    shift
    FORCE=1
  fi

  if [ -f "$CONNECTOR_SERVER_PID" ]; then
    # Is the process running?
    kill -0 `cat "$CONNECTOR_SERVER_PID"` >/dev/null 2>&1
    if [ $? -gt 0 ]; then
      echo "PID file ($CONNECTOR_SERVER_PID) found but no matching process was found. Stop aborted."
      exit 1
    fi
  else
    echo "\$CONNECTOR_SERVER_PID was set ($CONNECTOR_SERVER_PID) but the specified file does not exist. Is Connector Server running? Stop aborted."
    exit 1
  fi
  
  # send TERM signal to the process
  kill -TERM `cat "$CONNECTOR_SERVER_PID"` >/dev/null 2>&1 

  # Check if the process exited
  if [ -f "$CONNECTOR_SERVER_PID" ]; then
    while [ $SLEEP -ge 0 ]; do 
      kill -0 `cat "$CONNECTOR_SERVER_PID"` >/dev/null 2>&1
      if [ $? -gt 0 ]; then
        rm "$CONNECTOR_SERVER_PID"
        echo "Connector server stopped"
        break
      fi
      if [ $SLEEP -gt 0 ]; then
        sleep 1
      fi
      if [ $SLEEP -eq 0 ]; then
        if [ $FORCE -eq 0 ]; then
          echo "Connector Server did not stop in time. PID file was not removed."
        fi
      fi
      SLEEP=`expr $SLEEP - 1 `
    done
  fi

  # If -force option used, kill it
  if [ $FORCE -eq 1 ]; then
    if [ -f "$CONNECTOR_SERVER_PID" ]; then
      PID=`cat "$CONNECTOR_SERVER_PID"`
      echo "Killing Connector Server process: $PID"
      kill -9 $PID
      rm "$CONNECTOR_SERVER_PID"
    fi
  fi

elif [ "$1" = "/setKey" ] ; then
  shift
  if [ -z "$1" ]; then
    echo "Please provide key you want to set."
  fi
  KEY=$1
  "$_RUNJAVA" -cp "$CP" "$MAIN_CLASS" -setkey -key "$KEY" -properties "$SERVER_PROPERTIES"

else
  echo "Usage: connectorserver.sh ( commands ... )"
  echo "commands:"
  echo "  /run   [-J<java option>]     Runs Connector Server in the console"
  echo "  /start [-J<java option>]     Runs Connector Server in the background"  
  echo "  /stop                        Stop Connector Server, waiting up to 5 seconds for the process to end"
  echo "  /stop <n>                    Stop Connector Server, waiting up to n seconds for the process to end"
  echo "  /stop -force                 Stop Connector Server, wait up to 5 seconds and then use kill -KILL if still running"
  echo "  /stop <n> -force             Stop Connector Server, wait up to n seconds and then use kill -KILL if still running"
  echo "  /setKey <key>                Sets Connector Server key"
  echo
  echo "example:"
  echo " ./connectorserver.sh /run \"-J-Djavax.net.ssl.keyStore=mykeystore.jks\" \"-J-Djavax.net.ssl.keyStorePassword=changeit\""
  echo "       - this will run connector server with SSL"
  exit 1

fi
