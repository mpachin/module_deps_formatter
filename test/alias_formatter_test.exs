defmodule AliasFormatterTest do
  use ExUnit.Case

  alias AliasFormatter

  test "should sort aliases alphanumerically" do
    [
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
    |> assert_multiple_results_after_format()
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
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

    assert_result_after_format(test_input, expected_result)
  end

  test "should retreive and process aliases from def level to defmodule level" do
    [
      {
        """
        defmodule TestModuleExample do
          def fun do
            alias TestModuleExample.Nested.{Ccc.Ccc, Aaa.Aaa, Bbb.Bbb}
          end
        end
        """,
        """
        defmodule TestModuleExample do
          alias TestModuleExample.Nested.Aaa.Aaa
          alias TestModuleExample.Nested.Bbb.Bbb
          alias TestModuleExample.Nested.Ccc.Ccc

          def fun do
            nil
          end
        end
        """
      },
      {
        """
        defmodule TestModuleExample do
          def fun do
            alias TestModuleExample.Nested.{Ccc.Ccc, Aaa.Aaa, Bbb.Bbb}
            "first"
          end
        end
        """,
        """
        defmodule TestModuleExample do
          alias TestModuleExample.Nested.Aaa.Aaa
          alias TestModuleExample.Nested.Bbb.Bbb
          alias TestModuleExample.Nested.Ccc.Ccc

          def fun do
            "first"
          end
        end
        """
      }
    ]
    |> assert_multiple_results_after_format()
  end

  test "should consider aliases defined in previous context" do
    [
      {
        """
        alias TestModuleExample.Nested.Aaa

        defmodule TestModuleExample do
          alias TestModuleExample.Nested.Aaa
        end
        """,
        """
        alias TestModuleExample.Nested.Aaa

        defmodule TestModuleExample do
        end
        """
      },
      {
        """
        alias TestModuleExample.Nested.Aaa

        defmodule TestModuleExample do
          alias TestModuleExample.Nested.Aaa

          def test_fun do
            alias TestModuleExample.Nested.Aaa

            Aaa.test_call()
          end
        end
        """,
        """
        alias TestModuleExample.Nested.Aaa

        defmodule TestModuleExample do
          def test_fun do
            Aaa.test_call()
          end
        end
        """
      },
      {
        """
        defmodule TestModuleExample do
          defmodule NestedModule do
            def test_fun do
              alias Aaa

              Aaa.test_call()
            end

            def test_fun_2 do
              alias Bbb

              Bbb.test_call()
            end
          end

          def test_fun do
            alias Aaa

            Aaa.test_call()
          end
        end
        """,
        """
        defmodule TestModuleExample do
          alias Aaa

          defmodule NestedModule do
            alias Bbb

            def test_fun do
              Aaa.test_call()
            end

            def test_fun_2 do
              Bbb.test_call()
            end
          end

          def test_fun do
            Aaa.test_call()
          end
        end
        """
      }
    ]
    |> assert_multiple_results_after_format()
  end

  defp assert_multiple_results_after_format(assertions_list) do
    for {test_input, expected_result} <- assertions_list do
      assert_result_after_format(test_input, expected_result)
    end
  end

  defp assert_result_after_format(test_input, expected_result) do
    assert AliasFormatter.format(test_input, []) == String.trim(expected_result)
  end
end
