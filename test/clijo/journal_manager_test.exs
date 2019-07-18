defmodule Clijo.JournalManagerTest do
  use ExUnit.Case, async: true

  setup_all do
    current_date = Date.utc_today()
    current_year = current_date.year
    current_month = current_date.month
    current_day = current_date.day

    home_directory = Clijo.ConfigManager.get_home_directory()

    %{current_day: current_day,
     current_month: current_month,
     current_year: current_year,
     home_directory: home_directory}
  end

  test "make_monthly_log/0 returns {:ok, path_to_monthly_log}", context do
    assert Clijo.JournalManager.make_monthly_log() ==
           {:ok, "#{context[:home_directory]}/#{context[:current_year]}/#{context[:current_month]}/monthly_log.md"}
  end
end
