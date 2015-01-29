pid=$(cat pid.txt)
kill $pid
./startconnectorserver.sh
