defmodule AliasFormatter.DefmoduleSubstituteTest do
  use ExUnit.Case

  alias AliasFormatter.DefmoduleSubstitute

  @test_do_block_ast_list [
    {:def, [line: 2],
     [
       {:first, [line: 2], nil},
       [
         {{:__block__, [line: 2], [:do]}, {:__block__, [line: 3], ["first"]}}
       ]
     ]},
    {:alias, [line: 5],
     [
       {:__aliases__, [line: 5], [:C_TestModuleExample, :Aaa, :Ccc]}
     ]}
  ]

  @ast_before_substitution {:defmodule, [line: 1],
                            [
                              {:__aliases__, [line: 1], [:TestModuleExample]},
                              [
                                {
                                  {:__block__, [line: 1], [:do]},
                                  {:__block__, [], @test_do_block_ast_list}
                                }
                              ]
                            ]}

  @expected_result_ast {:defmodule, [line: 1],
                        [
                          {:__aliases__, [line: 1], [:TestModuleExample]},
                          [do: {:__block__, [], @test_do_block_ast_list}]
                        ]}

  describe "substitute/1" do
    test "should change defmodule ast to use block do...end" do
      assert @expected_result_ast = DefmoduleSubstitute.substitute(@ast_before_substitution)
    end

    test "should keep defmodule ast untouched if it has correct structure" do
      assert @expected_result_ast = DefmoduleSubstitute.substitute(@expected_result_ast)
    end
  end
end
