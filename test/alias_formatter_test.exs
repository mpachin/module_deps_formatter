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

  test "should hoist aliases to the beginning of the module" do
    test_input = """
    defmodule TestModuleExample do
      def first do
        "first"
      end
      alias C_TestModuleExample.Aaa.Ccc
      def second, do: "second"
      alias B_TestModuleExample.Bbb.Bbb
      def third, do: "third"
      alias A_TestModuleExample.Ccc.Aaa
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias A_TestModuleExample.Ccc.Aaa
      alias B_TestModuleExample.Bbb.Bbb
      alias C_TestModuleExample.Aaa.Ccc

      def first do
        "first"
      end

      def second, do: "second"
      def third, do: "third"
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end
end
