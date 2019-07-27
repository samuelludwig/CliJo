defmodule Clijo.ConfigManager do
  @moduledoc """
  The responsibility of the Clijo.ConfigManager module is to handle
  any work that relates to the users configuration of CliJo.
  """
  @moduledoc since: "June 7th, 2019"

  # TODO Need to clean up this module, there is a lot of repetition that
  # can be cut down, and a lot of unnecessary instructions being
  # performed.

  @user_config_path "./config/user_config.json"

  @doc """
  Takes in a string and sets `path` as the home_directory variable in
  `user_config.json`

  Returns `{:ok, path}` if successful, returns `{:error, reason}` if unsuccessful.
  """
  @doc since: "June 6th, 2019"
  def define_home_directory(path) do
    if File.exists?(path) do
      {:ok, user_config} = get_user_config()
      path = Path.expand(path)
      write_to_file = &File.write!(@user_config_path, &1)
      # Update settings map and write to file
      %{user_config | "home_directory" => path}
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
    {:ok, user_config} = get_user_config()

    user_config
    |> Map.get("home_directory")
  end

  @doc """
  Adds and/or edits existing defined prefixes in `user_config.json`

  Returns `{:ok, map_of_prefixes}` if successful.
  """
  @doc since: "June 16th, 2019"
  def define_prefixes(item_prefix_map \\ %{}) do
    {:ok, user_config} = get_user_config()
    {:ok, original_prefixes} = get_prefixes()

    new_prefixes = Map.merge(original_prefixes, item_prefix_map)
    write_to_file = &File.write!(@user_config_path, &1)
    # Update settings map and write to file
    %{user_config | "prefixes" => new_prefixes}
    |> Jason.encode!()
    |> write_to_file.()

    {:ok, new_prefixes}
  end

  @doc """
  Deletes the specified prefix of `item` in `user_config.json`.

  Returns `{:ok, map_of_prefixes}` if successful.
  Will return `{:error, "prefix: 'item' does not exist."}` if the item
  can't be found in the prefixes map.
  """
  @doc since: "June 16th, 2019"
  def delete_prefix(item) do
    {:ok, user_config} = get_user_config()
    {:ok, original_prefixes} = get_prefixes()

    if Map.has_key?(original_prefixes, item) do
      new_prefixes = Map.delete(original_prefixes, item)
      write_to_file = &File.write!(@user_config_path, &1)
      # Update settings map and write to file
      %{user_config | "prefixes" => new_prefixes}
      |> Jason.encode!()
      |> write_to_file.()

      {:ok, new_prefixes}
    else
      {:error, "prefix: #{item} does not exist."}
    end
  end

  @doc """
  Gets the `"prefixes"` map in the decoded `user_config.json` file.

  Returns `{:ok, map_of_prefixes}` if successful.
  """
  @doc since: "June 16th, 2019"
  def get_prefixes() do
    {:ok, user_config} = get_user_config()

    user_config
    |> Map.fetch("prefixes")
  end

  @doc """
  Gets the specific prefix of `item` found in `user_config.json`.

  Returns `{:ok, item_prefix}` is successful.
  """
  @doc since: "June 16th, 2019"
  def get_prefix(item) do
    {:ok, prefixes} = get_prefixes()

    prefixes
    |> Map.fetch(item)
  end

  @doc """
  Sets the value of `future_log_span` in `user_config.json` to `span`.

  Returns `{:ok, new_value_of_future_log_span}` if successful.
  """
  @doc since: "July 26th, 2019"
  def define_future_log_span(span) do
    {:ok, user_config} = get_user_config()

    write_to_file = &File.write!(@user_config_path, &1)

    %{user_config | "future_log_span" => span}
    |> Jason.encode!()
    |> write_to_file.()

    {:ok, span}
  end

  @doc """
  Gets the value of `future_log_span` from `user_config.json`.

  Returns `{:ok, number_of_months_in_future_log}` if successful.
  """
  @doc since: "July 26th, 2019"
  def get_future_log_span() do
    {:ok, user_config} = get_user_config()

    user_config
    |> Map.fetch("future_log_span")
  end

  @doc """
  Gets  a map of the settings defined in `user_config.json`.

  Returns `{:ok, user_config_map}` if successful.
  """
  @doc since: "June 16th, 2019"
  def get_user_config() do
    {:ok,
     @user_config_path
     |> File.read!()
     |> Jason.decode!()}
  end
end
