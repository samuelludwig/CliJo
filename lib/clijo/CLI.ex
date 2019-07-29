defmodule Clijo.CLI do
  alias Clijo.{JournalManager, ConfigManager}

  def main(_args) do
    IO.puts("Welcome to CliJo!")
    print_help_message()
    receive_command()
  end

  @commands %{
    "quit" => "Quits CliJo.",
    "def_home" =>
      "format: \"def_home C:/path/to/home/directory\"." <>
        "Defines the location to put all files from CliJo.",
    "new_daily" =>
      "format: \"new_daily log_name(optional)\"." <>
      "Creates a new daily log under `log_name` if one does not already exist.",
    "new_entry" => "format: \"new_entry log_name(optional)\"." <>
      "Appends an entry (one or more lines of text) to the file for `log_name`.",
    "edit_log" => "format: \"edit_log log_name line_num(optional)\"." <>
      "If no `line_num` is given, will display the full log with numbered lines" <>
      "and awaits the input of `line_num` to edit.",
    "migrate_task" => "format:" <>
      "\"migrate log_from line_num(optional) log_to(optional)\".",
    "view_monthly" => "Displays the current months monthly log.",
    "view_daily" => "format: \"view_daily log_name\"." <>
      "Display daily log `log_name`.",
    "view_tasks" => "format: \"view_tasks day|week|month\"."
  }

  defp receive_command() do
    IO.gets("\n>")
    |> String.trim()
    |> String.split(" ")
    |> execute_command()
  end

  defp execute_command(["quit"]) do
    IO.puts("Goodbye!")
    exit(:normal)
  end

  defp execute_command(["def_home" | path]) do
    {status, _} = ConfigManager.define_home_directory(path)
    message = "\nCommand returned with status '#{status}'."
    IO.puts(message)
    receive_command()
  end

  defp execute_command(["new_daily" | log_name]) do
    case {status, path} = JournalManager.make_daily_log(log_name) do
      {:ok, path} ->
        message =
          "\nCommand returned with status '#{status}' - " <>
            "Daily Log was created at location #{path}."

        IO.puts(message)

      _ ->
        message = "\nAn error has occured."
        IO.puts(message)
        print_help_message()
    end

    receive_command()
  end

  defp execute_command(["new_daily"]) do
  end

  defp execute_command(["new_entry" | log_name]) do
  end

  defp execute_command(["new_entry" | log_name, line_num]) do
  end

  defp execute_command(["edit_log" | log_name]) do
  end

  defp execute_command(["edit_log" | log_name, line_num]) do
  end

  defp execute_command(["migrate_task" | log_from]) do
  end

  defp execute_command(["view_monthly"]) do
  end

  defp execute_command(["view_daily"]) do
  end

  defp execute_command(["view_daily" | log_name]) do
  end

  defp execute_command(["view_tasks" | span]) do
  end

  defp execute_command(_unknown) do
    IO.puts("\nInvalid command, please pick from the list of valid commands-\n")
    print_help_message()

    receive_command()
  end

  defp print_help_message() do
    IO.puts("\nThe following commands are supported:\n")

    @commands
    |> Enum.map(fn {command, description} ->
      IO.puts("    #{command} - #{description}")
    end)
  end
end
