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
  - Allows migration of a task to a custom destination
  - Will default to the newest monthly log
- Index View
  - Show folder structure of journal
- Access entries and collections from anywhere on the cli
- View all tasks for a certain day/week/month

***

## Commands

- [x] Define Home Directory \[full_or_relative_path\]
  - Defines a location to put all files from CliJo
  - Changing home directory should move all files automatically ~~X~~
- [x] New Daily Log \[log_name (optional)\]
  - Creates a new daily log titled `log_name`
  - Defaults to month.day \<space\> day_of_week (ex: 5.25 SAT) ~~X~~
- [x] New Entry \[log_name (optional)\]
  - Appends an entry (one or more lines of text) to the file for `log_name`
  - If `log_name` is not provided, it will default to the current daily log, if a daily log does not yet exist, it will be created
  - If `log_name` *is* given, and the log does not exist, it too will be created
- [x] Edit Log \[log_name, line_num (optional)\]
  - If no `line_num` given in command: Displays full log with numbered lines, and awaits input of `line_num` to edit
  - Once line_num is given, the user will write out the text they want to replace it with
- [x] Migrate Task \[log_from, line_num (optional), log_to (optional)\]
- [ ] View Index ~~X~~
- [ ] View Future Log ~~X~~
- [x] View Monthly Log
- [x] View Daily Log \[log_name\]
- [x] View Tasks \[day | week | month\]

***

## Notes

- My current way of referencing user settings is suboptimal, every time they are referenced, I am reopening the `user_config.json` file and decoding the JSON into a map, which I then finally search through to get the setting I want.
  - As far as remedies go, having the map of settings decoded when the application first runs and have it held as a module attribute in `Clijo.ConfigManager` is not one of them, as module attributes are determined at compile-time.
  - Alternatives?

## If I Were to Rewrite This

- I would separate each piece of the journal into it's own module, giving
  each type of log its own struct.
- I started with input and output right away, this led to functions that 
  weren't as pure as they should be. In a rewrite I would employ a more 
  methodical, test-centric/test-friendly approach.
- I would try to stick more strictly to hygenic Git use, e.g. use branches
  more often, more detailed commit messages, smaller commits, etc.
- I would possibly model the project so that all contents of the journal would
  be persisted in a global struct, I don't think it would necessarily be an
  anti-pattern in my case (but then again, everyone always thinks they're the 
  special case). The only issue is it would effectively double my memory useage, 
  though on the grand scale it shouldn't matter too much, text is /reasonably/ 
  low-footprint.
