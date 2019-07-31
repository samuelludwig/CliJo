# CliJo

A Bullet-Journal application for the CLI.

***

## Main Functionalities

- Optional automation ~~X~~
- Daily Log
  - Automatically push dated tasks/events to monthly log ~~X~~
  - Allow nested entries
- Monthly Log
  - Add/Remove task from log
- Future Log ~~X~~
- Migration
  - Allows migration of a task to a custom destination
  - Will default to the newest monthly log
- Index View ~~X~~
  - Show folder structure of journal ~~X~~
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
- [x] View Daily Log \[log_name (optional)\]
- [x] View Tasks \[day | week | month\]

***

## Notes

- My current way of referencing user settings is suboptimal, every time they are referenced, I am reopening the `user_config.json` file and decoding the JSON into a map, which I then finally search through to get the setting I want.
  - As far as remedies go, having the map of settings decoded when the application first runs and have it held as a module attribute in `Clijo.ConfigManager` is not one of them, as module attributes are determined at compile-time.
  - Alternatives?
- Bugs remain to be squashed, I believe that they will be someday, but for now other
  projects exist.

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
  though on the grand scale it shouldn't matter too much, text is _reasonably_ 
  low-footprint.

## Why I Might Come Back to this Project in the Future

- To try approaching it in a different manner via Elixir or via another language
  a la the ideas discussed in the "If I Were to Rewrite This" section. 
- For a chance to come back to this from a different angle, the code is not too
  high in spaghetti content, but it could be better. In my current state-of-mind
  regarding this project I'm much more liable to create spaghetti.
- To provide proper testing to all functions and functionalities.
- To give all the code a good SOLID scrubbing and DRYing.

## Why I Might Not Come Back to this Project in the Future

- When I initially embarked on this project, my motivation was partly
  exploration, to see if I could sucessfully make something in Elixir. I did
  have a secondary component to my motivation, which was that I was trying to
  solve a problem I had; I had just started experimenting with Bullet Journaling
  and realized that there really wasn't any way (that I knew of) of recording
  "Bullet-Journal-friendly" notes easily on my desktop, where I spend most of my
  time working. I operated with this motivation for about a month or so- and
  then I came upon Org-Mode... and suddenly my "problem" was solved. So as a 
  result I no longer had the "need" motivation; this was ok, I still had my
  exploratory motivation, so I could survive- but my sails were a little less
  wind-ful. 
- It is because of these reasons that trying to make this project more
  "feature-complete" feels like a bit of an exercise in futility, when something
  like org-mode (it really is wonderful) can do anything I need and more. This
  is not to say I am not happy with this project, I really am, it really is one
  of the first things that I've made that _works_ beyond just being a PoC. And 
  yet other shores beckon at this moment, there are other things I'd like to 
  learn/try, the motivation of exploring calls me elsewhere.
