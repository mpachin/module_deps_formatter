defmodule AliasFormatter.ContextAliasCollector.NamePathsMapTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  describe "add_alias/2" do
    test "should update given map with alias data" do
      test_alias_data = {[:Test, :Module, :Aaa], :Aaa}

      assert {
               %{
                 Test: %{
                   Module: %{
                     Aaa: :Aaa
                   }
                 }
               },
               %{Aaa: 1}
             } = NamePathsMap.add_alias({%{}, %{}}, test_alias_data)
    end

    test "should preserve given map existing paths" do
      assert {%{
                Test: %{
                  Module: %{
                    Aaa: :Aaa
                  },
                  Module_2: %{
                    Aaa: :Aaa_2
                  }
                },
                Test_2: %{
                  Module: %{
                    Aaa: :Aaa_3
                  }
                }
              },
              %{Aaa: 3}} =
               {%{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa_3})
    end

    test "should automatically postfix as: alias with increment if leaves collision found" do
      assert {%{
                Test: %{
                  Module: %{
                    Aaa: :Aaa
                  },
                  Module_2: %{
                    Aaa: :Aaa_2
                  }
                },
                Test_2: %{
                  Module: %{
                    Aaa: :Aaa_3
                  }
                }
              },
              %{Aaa: 3}} =
               {%{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa})
    end

    test "should work correctly in border case collision" do
      assert {%{
                Test: %{
                  Module: %{
                    Aaa: :Aaa
                  },
                  Module_2: %{
                    Aaa: :Aaa_2
                  }
                },
                Test_2: %{
                  Module: %{
                    Aaa: :Aaa_3
                  }
                }
              },
              %{Aaa: 3}} =
               {%{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa})
    end

    test "should base postfix on first input" do
      assert {%{
                Test: %{
                  Module: %{
                    Aaa: :Aaa_3
                  },
                  Module_2: %{
                    Aaa: :Aaa_4
                  }
                },
                Test_2: %{
                  Module: %{
                    Aaa: :Aaa_5
                  }
                }
              },
              %{Aaa: 5}} =
               {%{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa_1})
    end

    test "should ignore duplicate paths" do
      assert {%{
                Test: %{
                  Module: %{
                    Aaa: :Aaa_3
                  },
                  Module_2: %{
                    Aaa: :Aaa_4
                  }
                }
              },
              %{Aaa: 4}} =
               {%{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
    end
  end
end
