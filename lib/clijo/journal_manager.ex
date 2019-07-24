defmodule Clijo.JournalManager do
  @moduledoc """
  The responsibility of the Clijo.JournalManager module is to handle
  any work that involves creating, editing, or deleting entries in
  CliJo.
  """
  @moduledoc since: "June 7th, 2019"

  alias Clijo.ConfigManager

  # *
  # TODO: Add code for failure conditions where they may appear.
  # *

  @doc """
  Creates the template for a monthly log in the
  `home/current_year/current_month` directory if it does not already exist.

  Returns `{:ok, path_to_monthly_log}`
  """
  @doc since: "July 18th, 2019"
  def make_monthly_log() do
    {:ok, path} = generate_directory()
    path = path <> "/monthly_log.md"

    unless File.exists?(path) do
      current_date = Date.utc_today()
      current_year = current_date.year
      current_month = current_date.month

      month_length = Calendar.ISO.days_in_month(current_year, current_month)
      list_of_day_numbers = Range.new(1, month_length)

      list_of_day_letters =
        list_of_day_numbers
        |> Enum.map(&Calendar.ISO.day_of_week(current_year, current_month, &1))
        |> map_days_of_week_to_letters()

      # TODO: Might need to cut this up if I want to right-justify the day
      # letters and numbers accross the board. *Should* be as simple as adding a
      # space to the beginning of the first 9 lines.
      monthly_log_template =
        Enum.zip(list_of_day_numbers, list_of_day_letters)
        |> Enum.map(fn {num, char} -> "#{num} #{char}" end)
        |> Enum.join("\n")
        |> Kernel.<>("\n\n----------\n\nTask List:\n\n")

      File.open(path, [:write], fn file ->
        IO.write(file, "# Month #{current_month}" <> "\n\n" <> monthly_log_template)
      end)
    end

    {:ok, path}
  end

  @doc """
  Writes the monthly log in the `home/year/month` directory to the
  terminal.

  If `year` and `month` are not given, they will default to
  `current_year` and `current_month` respectively.

  Returns `:ok` if successful.
  """
  @doc since: "June 11th, 2019"
  def display_monthly_log(month \\ Date.utc_today().month,
                          year \\ Date.utc_today().year) do
    path = "#{ConfigManager.get_home_directory()}/#{year}/#{month}/monthly_log.md"
    {:ok, contents} = File.read(path)
    IO.puts(contents)
  end

  @doc """
  Same functionality of `new_entry/1`, but instead writes input beneath
  the 'Tasks' section of the current month's `monthly_log`.

  Returns `{:ok, path_to_monthly_log}` if successful.
  """
  @doc since: "June 12th, 2019"
  def add_task_to_monthly_log() do
    {:ok, path} = make_monthly_log()
    get_input(path)
    {:ok, path}
  end

  @doc """
  Lists all unfinished tasks in the given `scope` into :stdio.

  If the `scope` is `"day"`,
  then all unfinished tasks for the current day are displayed.

  If the `scope` is
  `"week"` then the unfinished tasks for the last 7 numbered daily logs will be
  shown. If there are less than 7 numbered daily logs in the current month's
  directory, only those in that month will be displayed, it will not reach back
  into the previous month.

  If the `scope` is `"month"` then the unfinished tasks for *all* logs
  under that month will be shown, including the tasks for the monthly log
  itself.

  Returns `:ok` if successful.
  """
  @doc since: "July 21st, 2019"
  @spec display_tasks(String.t) :: atom()
  def display_tasks(scope \\ "day") do
    {:ok, task_list} = get_tasks(scope)
    IO.puts(task_list)
  end

  @doc """
  Returns a list of all unfinished tasks in `scope`.

  If the `scope` is `"day"`,
  then all unfinished tasks for the current day are displayed.

  If the `scope` is
  `"week"` then the unfinished tasks for the last 7 numbered daily logs will be
  shown. If there are less than 7 numbered daily logs in the current month's
  directory, only those in that month will be displayed, it will not reach back
  into the previous month.

  If the `scope` is `"month"` then the unfinished tasks for *all* logs
  under that month will be shown, including the tasks for the monthly log
  itself.

  Returns `{:ok, list_of_unfinished_tasks}` if successful.
  """
  @doc since: "July 21st, 2019"
  @spec display_tasks(String.t) :: list()
  def get_tasks(scope \\ "day") do
    month_directory =
      "#{ConfigManager.get_home_directory()}/"
      <> "#{Date.utc_today().year}/"
      <> "#{Date.utc_today().month}"

    current_day = Date.utc_today().day

    log_files = File.ls!(month_directory)

    files_to_eval =
      case scope do
        "day" ->
          [to_string(current_day) <> ".md"]

        "week" ->
          log_files
          |> Enum.filter(fn x ->
            Integer.parse(x) != :error
            && Integer.parse(x) |> elem(0) < current_day
          end)
          |> Enum.take(-7)

        "month" ->
          log_files

        _ -> {:error, "invalid argument"}
      end
    # TODO Look into adding timestamps to all files
    # (created/last updated/last visited), this could allow more intuitive
    # reasoning about with regards to what files are "relevant" for any given
    # command.

    # Puts the tasks from each file into a list, and then appends that list
    # to a super-list with all the other files' tasks.
    aggregated_tasks =
      for file <- files_to_eval do
        {:ok, contents} = get_log(String.trim(file, ".md"))

        contents
        |> parse_items("task_prefix")
        |> elem(1)
      end
    List.flatten(aggregated_tasks)
  end

  @doc """
  Displays `log_from` and waits for the user to enter the line number of the
  task they want to migrate, after the line number entered
  migrate_task_explicit/3 is called with the derived fields.
  """
  @doc since: "July 13th, 2019"
  def migrate_task(log_from, log_to \\ elem(make_monthly_log(), 1)) do
    {:ok, path} = get_log_path(log_from)
    display_daily_log(log_from)
    {line_num, _} =
      IO.gets("\nEnter line number of task you want to migrate: ")
      |> Integer.parse()
    migrate_task_explicit(path, line_num, log_to)
  end

  @doc """
  Copies the task from `log_from` on `line_num` to `log_to`, changes the prefix
  of the copied task in `log_from` to the "migrated" prefix. The task will be
  appended to the bottom of `log_to`, whether it be a daily log or a monthly
  log.

  Returns `{:ok, path_to_log_to}` if successful. If unsuccessful, returns
  `{:error, cause_of_error}`.
  """
  @doc since: "June 28th, 2019"
  def migrate_task_explicit(log_from, line_num, log_to) do
    if File.exists?(log_from) do
      task =
        File.stream!(log_from)
        |> Enum.at(line_num-1)
        |> String.trim_leading()

      if is_task?(task) do
        File.write!(log_to, task, [:append])

        migrated_task = change_prefix(task, "task_prefix", "migrated_task_prefix")
        updated_log_from =
          File.stream!(log_from)
          |> Enum.to_list()
          |> List.replace_at(line_num-1, migrated_task)

        File.write!(log_from, updated_log_from, [:write])
      else
        {:error, "#{task} is not a task, tasks have a prefix that looks like
        #{Clijo.ConfigManager.get_prefix("task_prefix")}."}
      end

    else
      {:error, "File #{log_from} does not exist."}
    end
  end

  @doc """
  Takes in a `string` and will return a list of strings dependent on
  where the designated `item`'s prefix occurs as the first item on a
  newline.

  Returns `{:ok, list_of_strings}` if successful.
  """
  @doc since: "June 13th, 2019"
  def parse_items(string, item) do
    # TODO Make this work correctly.
    {:ok, prefix} = Clijo.ConfigManager.get_prefix(item)

    list_of_strings =
      string
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))
      |> Enum.filter(&String.starts_with?(&1, prefix))
      |> Enum.map(fn x -> x <> "\n" end)

    {:ok, list_of_strings}
  end

  @doc """
  Creates a daily log in the home/current_year/current_month
  directory if it does not already exist. If `log_name` is provided,
  then the file `'log_name'.md` will be created. If `log_name` is not
  provided, then the file `'current_day'.md` will be created.

  Returns `{:ok, filename}` with full file path if successful.
  """
  @doc since: "June 10th, 2019"
  def make_daily_log(log_name \\ nil) do
    {:ok, filename} = get_log_path(log_name)
    header = generate_daily_log_header(log_name)

    unless File.exists?(filename) do
      File.open(filename, [:write], fn file ->
        IO.write(file, header)
      end)
    end

    {:ok, filename}
  end

  @doc """
  Creates a new entry into the daily log `log_name`.

  Calling new_entry/1 will stream input from the terminal into the
  designated log until the user enters the termination phrase `:done`.
  The taken input will be appened to the end of the designated log.

  If no `log_name` is given the entry will be written to the days
  default log at `current_year/current_month/current_day`.

  Returns `{:ok, path_to_entry}` is successful.
  """
  @doc since: "June 10th, 2019"
  def new_entry(log_name \\ nil) do
    {:ok, path} = make_daily_log(log_name)
    get_input(path)
    {:ok, path}
  end

  @doc """
  Writes the given daily log `log_name` to the terminal with prepended
  line numbers.

  Returns `:ok` if successful.
  """
  @doc since: "June 11th, 2019"
  def display_daily_log(log_name \\ nil) do
    {:ok, contents} = get_log(log_name)

    append_line_numbers_to(contents)
    |> Enum.each(&IO.puts(&1))

    IO.puts("----------")
  end

  @doc """
  Replaces content on line number `line_num` in log `log_name` with the
  content of `edit`.

  Returns `{:ok, path_to_file}` if successful.
  """
  @doc since: "June 10th, 2019"
  def edit_daily_log(log_name \\ nil, line_num, edit) do
    {:ok, contents} = get_log(log_name)
    {:ok, path} = make_daily_log(log_name)

    contents
    |> String.split("\n")
    |> List.replace_at(line_num - 1, String.trim_trailing(edit))
    |> Enum.map(fn x -> x <> "\n" end)
    # HACK
    |> (&if(Enum.at(&1, -1) == "\n", do: Enum.drop(&1, -1), else: &1)).()
    |> Enum.into(File.stream!(path))

    {:ok, path}
  end

  @doc """
  Returns the contents of daily log `log_name` as a string. If `log_name` is
  nil, it will default to the current day's daily log.

  Returns `{:ok, contents_of_daily_log}` if successful.
  """
  @doc since: "July 21st, 2019"
  @spec get_log(String.t | nil) :: {:ok, String.t} | {:error, String.t}
  def get_log(log_name \\ nil) do
    {:ok, path} = make_daily_log(log_name)
    File.read(path)
  end

  # Grabs input from the terminal one line at a time and terminates
  # after the phrase `:done` is read in.
  defp get_input(file_path) do
    IO.stream(:stdio, :line)
    |> Stream.take_while(&(&1 != ":done\n"))
    |> Enum.into(File.stream!(file_path, [:append]))
  end

  # Create the month and year directories if they don't already exist
  # and return `{:ok, month_path}` if successful.
  defp generate_directory() do
    # Get today's date
    date = Date.utc_today()
    year = Integer.to_string(date.year)
    month = Integer.to_string(date.month)

    # Generate the month's full path with YYYY/MM format
    month_path =
      ConfigManager.get_home_directory()
      |> Path.join(year)
      |> Path.join(month)

    # Create month and year directories
    File.mkdir_p(month_path)

    {:ok, month_path}
  end

  # Returns the full path of the given log `log_name` in an `{:ok, log_path}`
  # tuple.
  defp get_log_path(log_name) do
    {:ok, path} = generate_directory()
    date = Date.utc_today()
    day = Integer.to_string(date.day)

    log_path =
      if is_nil(log_name) do
        Path.join(path, day) <> ".md"
      else
        Path.join(path, log_name) <> ".md"
      end

    {:ok, log_path}
  end

  # Takes in a list of numbers 1-7 -likely generated by calls to
  # Calender.ISO.day_of_week/3- and replaces each number by a character
  # representing their day of the week.
  # The characters are returned in a list.
  defp map_days_of_week_to_letters(days) do
    for n <- days do
      cond do
        n == 1 -> "M"
        n == 2 -> "T"
        n == 3 -> "W"
        n == 4 -> "T"
        n == 5 -> "F"
        n == 6 -> "S"
        n == 7 -> "S"
        true -> "error in days supplied"
      end
    end
  end

  # Takes in a string and returns `true` if the string begins with the "task"
  # prefix, otherwise it returns false.
  defp is_task?(string) do
    {:ok, task_prefix} = Clijo.ConfigManager.get_prefix("task_prefix")

    string
    |> String.trim_leading()
    |> String.starts_with?(task_prefix)
  end

  # Takes in an `item` string and returns it with its prefix switched to
  # `prefix`.
  defp change_prefix(item, from_prefix, to_prefix) do
    {:ok, from_prefix} = Clijo.ConfigManager.get_prefix(from_prefix)
    {:ok, to_prefix} = Clijo.ConfigManager.get_prefix(to_prefix)
    [whitespace, item_content] = String.split(item, from_prefix, parts: 2)
    whitespace <> to_prefix <> item_content
  end

  # Generates a string to be used as a daily log header depending on the
  # `log_name` provided.
  defp generate_daily_log_header(log_name \\ nil) do
    header_title =
    if is_nil(log_name) do
      Date.utc_today()
      |> Date.to_string()
    else
      log_name
    end

  """
  # #{header_title}

  """
  end

  # Appends line numbers to a given string, it will correctly align all content
  # up to 9999 lines.
  defp append_line_numbers_to(string) do
    string
    |> String.split("\n", trim: false)
    |> Enum.with_index(1)
    # HACK
    # All this is done to make sure the text is properly alinged.
    |> Enum.map(fn {line, line_num} ->
      "#{line_num}#{
      cond do
      line_num >= 1000 -> " "
      line_num >= 100 -> "  "
      line_num >= 10 -> "   "
      true -> "    "
      end
      }#{line}"
    end)
  end
end
