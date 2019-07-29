defmodule Clijo.JournalManagerTest do
  use ExUnit.Case, async: true

  setup_all do
    current_date = Date.utc_today()
    current_year = current_date.year
    current_month = current_date.month
    current_day = current_date.day

    home_directory = Clijo.ConfigManager.get_home_directory()

    %{
      current_day: current_day,
      current_month: current_month,
      current_year: current_year,
      home_directory: home_directory
    }
  end

  test "make_monthly_log/0 returns {:ok, path_to_monthly_log}", context do
    assert Clijo.JournalManager.make_monthly_log() ==
             {:ok,
              "#{context[:home_directory]}/" <>
                "#{context[:current_year]}/" <>
                "#{context[:current_month]}/" <>
                "monthly_log.md"}
  end

  test "parse_items/2 returns a list of strings with the correct prefixes", context do
    string = """
    # My Header

    - - A note
    - [ ] A task.
      - [ ] Another, nested task.
    - * some other thing
    - [ ] A final task.

    """

    item = "task_prefix"

    {:ok, list_of_strings} = Clijo.JournalManager.parse_items(string, item)

    assert list_of_strings ==
             ["- [ ] A task.\n", "- [ ] Another, nested task.\n", "- [ ] A final task.\n"]
  end

  test "future_log_map_to_string/1 works correctly" do
    map = %{"8" => ["item1", "item2"], "9" => ["item3", "item4"]}
    {:ok, string} = Clijo.JournalManager.future_log_map_to_string(map)

    assert string ==
      "# FUTURE LOG\n\n***\n8\n\nitem1\nitem2\n\n***\n9\n\nitem3\nitem4\n\n***"
  end

  test "future_log_map_to_string/1 works correctly when map is not provided in order" do
    map = %{"9" => ["item3", "item4"], "8" => ["item1", "item2"]}
    {:ok, string} = Clijo.JournalManager.future_log_map_to_string(map)

    assert string ==
      "# FUTURE LOG\n\n***\n8\n\nitem1\nitem2\n\n***\n9\n\nitem3\nitem4\n\n***"
  end

  test "future_log_string_to_map/1 works correctly", context do
    string = "# FUTURE LOG\n\n***\n8\n\nitem1\nitem2\n\n***\n9\n\nitem3\nitem4\n\n***"
    {:ok, map} = Clijo.JournalManager.future_log_string_to_map(string)

    assert map ==
      %{"8" => ["item1", "item2"], "9" => ["item3", "item4"]}
  end
end
