# Simple Antivirus Daemon

A lightweight bash-based antivirus monitoring daemon and interactive quarantine recovery tool designed to monitor changes in a directory and isolate malicious files based on file extensions and payload keywords.

# 1. Project Overview & Folder Hierarchy

# Overview
- `antivirusd.sh`: A long-lived monitoring daemon that periodically checks a specified source directory (`dir`) for modifications. If changes are detected, it scans the directory, prints flagged files to the terminal, quarantines them into `malicious_dir`, and deletes them from `dir`.
- `restore.sh`: An interactive command-line tool that displays quarantined files from `malicious_dir` in a numbered list, allowing the user to review each file to restore false positives back into `dir` or permanently delete genuine threats.
- `Makefile`: Automates folder creation, running the antivirus daemon, and executing the restore tool via simple `make` commands.

#Folder Hierarchy
```text
.
├── Makefile
├── README.md
├── antivirusd.sh
└── restore.sh
