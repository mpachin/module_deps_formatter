defmodule AliasFormatterTest do
  use ExUnit.Case

  alias AliasFormatter

  test "should sort aliases alphanumerically" do
    test_cases = [
      {
        """
        defmodule TestModuleExample do
          alias TestModuleExample.Ccc
          alias TestModuleExample.Bbb
          alias TestModuleExample.Aaa
        end
        """,
        """
        defmodule TestModuleExample do
          alias TestModuleExample.Aaa
          alias TestModuleExample.Bbb
          alias TestModuleExample.Ccc
        end
        """
      },
      {
        """
        defmodule TestModuleExample do
          alias C_TestModuleExample.Aaa.Ccc
          alias B_TestModuleExample.Bbb.Bbb
          alias A_TestModuleExample.Ccc.Aaa
        end
        """,
        """
        defmodule TestModuleExample do
          alias A_TestModuleExample.Ccc.Aaa
          alias B_TestModuleExample.Bbb.Bbb
          alias C_TestModuleExample.Aaa.Ccc
        end
        """
      }
    ]

    for {test_input, expected_result} <- test_cases do
      assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
    end
  end
end
