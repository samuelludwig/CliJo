defmodule Clijo.CLI do
  def main(_args) do
    IO.puts("Welcome to CliJo!")
    print_help_message()
    receive_command()
  end

  @commands %{
    "quit" => "Quits CliJo"
    "def_home" => "Defines the location to put all files from CliJo"
  }

  defp receive_command() do
    IO.gets("\n>")
    |> String.trim()
    |> execute_command()
  end

  defp execute_command("quit") do
    IO.puts("Goodbye!")
    exit(:normal)
  end
end
