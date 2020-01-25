#!/usr/bin/env bash
set -e

echo "Deleting all generated judge data .."
rm -rf judge_data/contests
rm -rf judge_data/users
echo "[+] Done\n"

echo "Flushing all redis keys "
redis-cli flushall
echo "[+] Done\n"

echo "Deleting databases"
rake db:mongoid:drop
