defmodule Clijo.FileManagement do
  @moduledoc """
  The responsibility of the Clijo.FileManagement module is to handle
  any work that relates to navigating the file system, creating files,
  moving files, finding files, and deleting files.
  """
  @moduledoc since: "June 6th, 2019"

  @user_config_path "./config/user_config.json"

  @doc """
  Takes in a string and sets `path` as the home_directory variable in
  `user_config.json`

  Returns `{:ok, path}` if successful, returns `{:error, reason}` if unsuccessful.
  """
  @doc since: "June 6th, 2019"
  def set_home_directory(path) do
    if File.exists?(path) do
      # Grab user settings and put them into a map
      settings_map =
      @user_config_path
      |> File.read!()
      |> to_string()
      |> Jason.decode!()

      # Update map and write to file
      %{settings_map | "home_directory" => path}
      |> Jason.encode!()
      |> (&(File.write!(@user_config_path, &1))).()

      {:ok, path}
    else
      {:error, "#{path} does not exist"}
    end
  end

  def get_home_directory() do

  end
end
