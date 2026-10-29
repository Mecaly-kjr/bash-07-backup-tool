#!/usr/bin/env bash

echo "===== TEST 1: Missing source (expect 2) ====="
./backup.sh
echo "Exit code: $?"

echo "===== TEST 2: Help (expect 0) ====="
./backup.sh -h
echo "Exit code: $?"

echo "===== TEST 3: Invalid KEEP (expect 2) ====="
./backup.sh -k abc ~/rebase
echo "Exit code: $?"

echo "===== TEST 4: Missing folder (expect 1) ====="
./backup.sh /no/such/folder
echo "Exit code: $?"

echo "===== TEST 5: Create backup ====="
./backup.sh ~/rebase
echo "Exit code: $?"

echo "===== TEST 6: Check archive contents ====="
latest=$(ls -t "$HOME"/backups/rebase-*.tar.gz 2>/dev/null | head -1)
if [[ -n "$latest" ]]; then
    tar -tzf "$latest" | head -1
else
    echo "ERROR: No backup archive found"
fi

echo "===== TEST 7: Create seven backups, keep three ====="
for i in 1 2 3 4 5 6 7; do
    ./backup.sh -k 3 ~/rebase || break
    sleep 1
done

echo "===== TEST 8: Count backups (expect 3) ====="
ls "$HOME"/backups/rebase-*.tar.gz 2>/dev/null | wc -l
