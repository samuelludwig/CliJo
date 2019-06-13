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
  `home/current_year/current_month` directory.

  Returns `{:ok, path_to_monthly_log}`
  """
  @doc since: "June 10th, 2019"
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

      # TODO: Might need to cut this up if I want to right-justify the day letters and numbers accross the board. *Should* be as simple as adding a space to the beginning of the first 9 lines.
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
  def display_monthly_log(year \\ Date.utc_today().year, month \\ Date.utc_today().month) do
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

  def migrate_task() do
    # TODO
  end

  @doc """
  Takes in a `string` and will return a list of strings dependent on
  where the designated `item`'s prefix occurs as the first item on a
  newline.

  Returns `{:ok, list_of_strings}` if successful.
  """
  @doc since: "June 13th, 2019"
  def parse_items(string, item) do
    # TODO implement Clijo.ConfigManager.define_prefixes/0 and .get_prefix/1
    prefix = "\n#{Clijo.ConfigManager.get_prefix(item)}"
    {:ok, String.split(string, prefix)}
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

    header_title =
      if is_nil(log_name) do
        Date.utc_today()
        |> Date.to_string()
      else
        log_name
      end

    # TODO Could extract this out to a separate function if we want to allow custom headers.
    header = """
    # #{header_title}

    """

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
    {:ok, path} = make_daily_log(log_name)
    {:ok, contents} = File.read(path)

    contents
    |> String.split("\n", trim: false)
    |> Enum.with_index(1)
    # HACK
    |> Enum.map(fn {line, line_num} ->
      "#{line_num}#{
        cond do
          # All this is done to make sure the text is properly alinged.
          line_num >= 1000 -> " "
          line_num >= 100 -> "  "
          line_num >= 10 -> "   "
          true -> "    "
        end
      }#{line}"
    end)
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
    {:ok, path} = make_daily_log(log_name)
    {:ok, contents} = File.read(path)

    contents
    |> String.split("\n")
    |> List.replace_at(line_num - 1, String.trim_trailing(edit))
    |> Enum.map(fn x -> x <> "\n" end)
    # HACK
    |> (&if(Enum.at(&1, -1) == "\n", do: Enum.drop(&1, -1), else: &1)).()
    |> Enum.into(File.stream!(path))

    {:ok, path}
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

  # Returns the full path of the given log `log_name`.
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
end
