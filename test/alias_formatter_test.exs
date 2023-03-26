defmodule AliasFormatterTest do
  use ExUnit.Case

  alias AliasFormatter

  test "should sort aliases alphanumerically" do
    test_module_str =
      String.trim("""
      defmodule TestModuleExample do
        alias TestModuleExample.Ccc
        alias TestModuleExample.Bbb
        alias TestModuleExample.Aaa
      end
      """)

    expected_result_str =
      String.trim("""
      defmodule TestModuleExample do
        alias TestModuleExample.Aaa
        alias TestModuleExample.Bbb
        alias TestModuleExample.Ccc
      end
      """)

    assert expected_result_str == test_module_str |> AliasFormatter.format([])
  end
end
