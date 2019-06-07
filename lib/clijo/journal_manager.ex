defmodule Clijo.JournalManager do
  @moduledoc """
  The responsibility of the Clijo.JournalManager module is to handle
  any work that involves creating, editing, or deleting entries in
  CliJo.
  """
  @doc since: "June 7th, 2019"

  def new_monthly_log() do

  end

  @doc """
  Creates a new daily log in the home/current_year/current_month
  directory. If `log_name` is provided, then the file `'log_name'.md`
  will be created. If `log_name` is not provided, then the file
  `'current_day'.md` will be created.

  Returns {:ok, filename} with full file path if successful.
  """
  @doc since: "June 7th, 2019"
  def new_daily_log(log_name \\ "") do
    {:ok, path} = generate_directory()
    date = Date.utc_today()
    day = Integer.to_string(date.day)

    filename =
      if log_name == "" do
        Path.join(path, day) <> ".md"
      else
        Path.join(path, log_name) <> ".md"
      end

    header_title =
      if log_name == "" do
        Date.to_string(date)
      else
        log_name
      end

    # Could extract this out to a separate function if we want to allow
    # custom headers
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

  def new_entry() do

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
      Clijo.ConfigManager.get_home_directory()
      |> Path.join(year)
      |> Path.join(month)

    # Create month and year directories
    File.mkdir_p(month_path)

    {:ok, month_path}
  end
end
