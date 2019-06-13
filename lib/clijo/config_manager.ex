defmodule Clijo.ConfigManager do
  @moduledoc """
  The responsibility of the Clijo.ConfigManager module is to handle
  any work that relates to the users configuration of CliJo.
  """
  @moduledoc since: "June 7th, 2019"

  @user_config_path "./config/user_config.json"

  @doc """
  Takes in a string and sets `path` as the home_directory variable in
  `user_config.json`

  Returns `{:ok, path}` if successful, returns `{:error, reason}` if unsuccessful.
  """
  @doc since: "June 6th, 2019"
  def set_home_directory(path) do
    if File.exists?(path) do
      path = Path.expand(path)
      write_to_file = &File.write!(@user_config_path, &1)
      # Update settings map and write to file
      %{get_user_config() | "home_directory" => path}
      |> Jason.encode!()
      |> write_to_file.()

      {:ok, path}
    else
      {:error, "#{path} does not exist"}
    end
  end

  @doc """
    Grabs the value of the `home_directory` variable in
    `user_config.json`.
  """
  @doc since: "June 7th, 2019"
  def get_home_directory() do
    get_user_config()
    |> Map.get("home_directory")
  end

  def define_prefixes() do
    # TODO
  end

  def get_prefix(item) do
    # TODO
  end

  # Returns a map of the settings defined in `user_config.json`
  defp get_user_config() do
    @user_config_path
    |> File.read!()
    |> Jason.decode!()
  end
end
