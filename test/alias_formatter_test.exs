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

  test "should preserve as: keyword in aliases" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.Ccc
      alias TestModuleExample.Bbb, as: Aaa
      alias TestModuleExample.Aaa, as: Bbb
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Aaa, as: Bbb
      alias TestModuleExample.Bbb, as: Aaa
      alias TestModuleExample.Ccc
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end

  test "should automatically add as: keyword with postfixed alias name if name collision found" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.Ccc
      alias TestModuleExample.Bbb.Ccc
      alias TestModuleExample.Aaa.{Ccc}
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Aaa.Ccc, as: Ccc_3
      alias TestModuleExample.Bbb.Ccc, as: Ccc_2
      alias TestModuleExample.Ccc
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end

  test "should substitute short form aliases with full form aliases" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.{Ccc, Aaa, Bbb}
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Aaa
      alias TestModuleExample.Bbb
      alias TestModuleExample.Ccc
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end

  test "should substitute short form aliases with full form aliases in complex nestings" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.Nested.{Ccc.Ccc, Aaa.Aaa, Bbb.Bbb}
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Nested.Aaa.Aaa
      alias TestModuleExample.Nested.Bbb.Bbb
      alias TestModuleExample.Nested.Ccc.Ccc
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end

  test "should remove alias duplicates" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.Aaa
      alias TestModuleExample.Aaa
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Aaa
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end

  test "should remove alias duplicates in complex nestings" do
    test_input = """
    defmodule TestModuleExample do
      alias TestModuleExample.Nested.Bbb
      alias TestModuleExample.Nested.Bbb.Bbb
      alias TestModuleExample.Nested.{Ccc.Ccc, Aaa.Aaa}
      alias TestModuleExample.Nested.{Ccc.Ccc, Aaa.Aaa, Bbb.Bbb}
    end
    """

    expected_result = """
    defmodule TestModuleExample do
      alias TestModuleExample.Nested.Aaa.Aaa
      alias TestModuleExample.Nested.Bbb
      alias TestModuleExample.Nested.Bbb.Bbb, as: Bbb_2
      alias TestModuleExample.Nested.Ccc.Ccc
    end
    """

    assert String.trim(expected_result) == AliasFormatter.format(test_input, [])
  end
end
