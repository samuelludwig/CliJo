defmodule Clijo.JournalManager do
  @moduledoc """
  The responsibility of the Clijo.JournalManager module is to handle
  any work that involves creating, editing, or deleting entries in
  CliJo.
  """
  @moduledoc since: "June 7th, 2019"

  alias Clijo.ConfigManager

  # *
  # TODO: Add code for failure conditions in appropriate functions.
  # *

  def make_monthly_log() do
    # TODO
  end

  def display_monthly_log() do
    # TODO
  end

  @doc """
  Creates a daily log in the home/current_year/current_month
  directory if it does not already exist. If `log_name` is provided,
  then the file `'log_name'.md` will be created. If `log_name` is not
  provided, then the file `'current_day'.md` will be created.

  Returns {:ok, filename} with full file path if successful.
  """
  @doc since: "June 8th, 2019"
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

  Returns {:ok, path_to_entry} is successful.
  """
  @doc since: "June 8th, 2019"
  def new_entry(log_name \\ nil) do
    {:ok, path} = make_daily_log(log_name)
    get_input(path)
    {:ok, path}
  end

  @doc """
  Writes the given daily log `log_name` to the terminal with prepended
  line numbers.
  """
  @doc since: "June 9th, 2019"
  def display_daily_log(log_name \\ nil) do
    {:ok, path} = make_daily_log(log_name)
    {:ok, contents} = File.read(path)

    contents
    |> String.split("\n", trim: false)
    |> Enum.with_index(1)
    |> Enum.map(fn {line, line_num} -> # HACK
                   "#{line_num}#{cond do
                                   line_num >= 1000 -> " " # All this
                                   line_num >= 100 -> "  " # is done to
                                   line_num >= 10 -> "   " # make sure the
                                   true -> "    "          # text is properly
                                 end}#{line}" end)         # alinged.
    |> Enum.each(&IO.puts(&1))

    IO.puts("----------")
  end

  @doc """
  Replaces content on line number `line_num` in log `log_name` with the
  content of `edit`.

  Returns {:ok, path_to_file} if successful.
  """
  @doc since: "June 9th, 2019"
  def edit_daily_log(log_name \\ nil, line_num, edit) do
    {:ok, path} = make_daily_log(log_name)
    {:ok, contents} = File.read(path)

    contents
    |> String.split("\n")
    |> List.replace_at((line_num-1), String.trim_trailing(edit))
    |> Enum.map(fn x -> x <> "\n" end)
    |> (&(if Enum.at(&1, -1) == "\n", do: Enum.drop(&1, -1), else: &1)).() # HACK
    |> Enum.into(File.stream!(path))

    {:ok, path}
  end

  # Grabs input from the terminal one line at a time and terminates
  # after the phrase `:done` is read in.
  defp get_input(file_path) do
    IO.stream(:stdio, :line)
    |> Stream.take_while(& &1 != ":done\n")
    |> Enum.into(File.stream!(file_path, [:append]))
  end

  # Create the month and year directories if they don't already exist
  # and return {:ok, month_path} if successful.
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
end
