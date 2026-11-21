# 🏷 bash-07-backup-tool

> `backup.sh` creates compressed, timestamped backups of a folder and automatically deletes old ones.

---

## 📌 Problem Statement

Laptops get stolen, hard drives die, and files get deleted by mistake. Manual copying is slow and easy to forget, and backups pile up until the disk is full. This tool makes a backup with one command and keeps only the newest ones.

---

## 🎯 Project Goals

- Create a compressed `.tar.gz` backup of any folder
- Name each archive `<foldername>-YYYYMMDD-HHMMSS.tar.gz` with a clean internal path
- Keep only the newest `KEEP` backups of that folder (default 5)
- Validate input and report errors clearly on stderr
- Use meaningful exit codes so other scripts can rely on it

---

## 🛠 Tech Stack

**Language:**
-Bash

**Tools used:**
-`getopts` (option parsing)
-`tar` and `gzip` (archiving)
-`date`, `sort`, `mkdir`, `rm`

**Workflow:**

- Git & GitHub (feature branch + pull request)

---

## 🖥 Features

- Options `-d DEST`, `-k KEEP` and `-h`
- `DEST` defaults to `~/backups` and is created if missing
- Automatic rotation of old backups (only this folder's backups are touched)
- Validation: missing source, source not a folder, bad `KEEP`, unknown option
- Organised into functions: `usage`, `die`, `create_backup`, `rotate_backups`, `main`
- One-line success message with the archive path

---

## 📷 Screenshots

 ![alt text](<assets/images/Screenshot From 2026-10-29 13-50-32.png>)
 ![alt text](<assets/images/Screenshot From 2026-10-29 13-50-54.png>)
 ![alt text](<assets/images/Screenshot From 2026-10-29 15-20-57.png>)

---

## ⚙ Installation & Setup

```bash
git clone https://github.com/Mecaly-kjr/bash-07-backup-tool.git
cd bash-07-backup-tool
chmod +x backup.sh
```

Usage:

```bash
./backup.sh [-d DEST] [-k KEEP] SOURCE
```

| Option | Description |
| `-d DEST` | Destination folder (default `~/backups`, created if missing) |
| `-k KEEP` | Number of newest backups to keep (default `5`, positive whole number) |
| `-h` | Show help and exit with 0 |

Exit codes:

| Code | Meaning |
| 0 | Success (or `-h`) |
| 1 | Backup failed (source missing or not a folder, cannot create DEST, tar error) |
| 2 | Wrong usage (no SOURCE, extra arguments, unknown option, bad KEEP) |

Quick rotation test:

```bash
for i in 1 2 3 4 5 6 7; do ./backup.sh -k 3 ~/rebase; sleep 1; done
ls ~/backups | grep -c '^rebase-'   # 3
```

---

## 🧠 Challenges Faced

- Making rotation safe: a loose pattern like `rebase-*` would also match backups of a folder named `rebase-old`, so the pattern only matches `<folder>-YYYYMMDD-HHMMSS.tar.gz`
- Getting a clean path inside the archive with `tar -C`
- Using the correct exit code in each failure case
- Testing rotation quickly (`sleep 1` so every timestamp is unique)

---

## 📚 What I Learned

- Structuring a Bash script with functions and local variables
- Parsing options with `getopts`
- Validating input with regular expressions
- Writing errors to stderr and returning meaningful exit codes
- Working with a feature branch and pull request

---

## 🚀 Future Improvements

- Exclude patterns (e.g. `node_modules`)
- Restore command
- Dry-run mode
- Automated tests and a cron example

---

## 👨🏽‍💻 Author

Mecaly Luther Bobbilla

[mecalyluther64@gmail.com](mailto:mecalyluther64@gmail.com)

Junior Developer | Software Engineering

Based in Cameroon.
