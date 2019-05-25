# CliJo

A Bullet-Journal application for the CLI.

***

## Main Functionalities

- Optional automation
- Daily Log
  - Automatically push dated tasks/events to monthly log
  - Allow nested entries
- Monthly Log
  - Add/Remove task from log
- Future Log
- Migration
  - Allows migration of a task to a custom destination.
  - Will default to the newest monthly log.
- Index View
  - Show folder structure of journal.
- Access entries and collections from anywhere on the cli
- View all tasks for a certain day/week/month

***

## Commands

- Define Home Directory \[full_or_relative_path\]
  - Defines a location to put all files from CliJo
  - Changing home directory should move all files automatically
- New Daily Log \[log_name (optional)\]
  - Creates a new daily log titled `log_name`
  - Defaults to month.day \<space\> day_of_week (ex: 5.25 SAT)
- New Entry \[log_name (optional)\]
  - Appends an entry (one or more lines of text) to the file for `log_name`
  - If `log_name` is not provided, it will default to the current daily log, if a daily log does not yet exist, it will be created.