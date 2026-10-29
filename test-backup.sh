#!/usr/bin/env bash

echo "===== TEST 1: Missing source (expect 2) ====="
./backup.sh
echo "Exit code: $?"

echo "===== TEST 2: Help (expect 0) ====="
./backup.sh -h
echo "Exit code: $?"

echo "===== TEST 3: Invalid KEEP (expect 2) ====="
./backup.sh -k abc "$HOME/rebase"
echo "Exit code: $?"

echo "===== TEST 4: Missing folder (expect 1) ====="
./backup.sh /no/such/folder
echo "Exit code: $?"

echo "===== TEST 5: Create backup ====="
./backup.sh "$HOME/rebase"
echo "Exit code: $?"

echo "===== TEST 6: Check archive contents ====="
latest=$(
    find "$HOME/backups" -maxdepth 1 -type f \
        -name 'rebase-*.tar.gz' \
        -printf '%f\n' 2>/dev/null |
        sort -r |
        head -n 1
)

if [[ -n "$latest" ]]; then
    tar -tzf "$HOME/backups/$latest" | head -n 1
else
    echo "ERROR: No backup archive found"
fi

echo "===== TEST 7: Create seven backups, keep three ====="
for _ in 1 2 3 4 5 6 7; do
    ./backup.sh -k 3 "$HOME/rebase" || break
    sleep 1
done

echo "===== TEST 8: Count backups (expect 3) ====="
find "$HOME/backups" -maxdepth 1 -type f \
    -name 'rebase-*.tar.gz' \
    -printf '.' 2>/dev/null |
    wc -c
