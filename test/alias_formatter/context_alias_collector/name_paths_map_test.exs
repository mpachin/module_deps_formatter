defmodule AliasFormatter.ContextAliasCollector.NamePathsMapTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  describe "add_alias/2" do
    test "should update given map with alias data" do
      {alias_path, alias_as} = test_alias_data = {[:Test, :Module, :Aaa], :Aaa}

      assert {
               %{
                 [:Test, :Module, :Aaa] => ^alias_as
               },
               %{Aaa: ^alias_path},
               %{Aaa: 1}
             } = NamePathsMap.add_alias({%{}, %{}, %{}}, test_alias_data)
    end

    test "should preserve given map existing paths" do
      assert {
               %{
                 [:Test, :Module, :Aaa] => :Aaa,
                 [:Test, :Module_2, :Aaa] => :Aaa_2,
                 [:Test_2, :Module, :Aaa] => :Aaa_3
               },
               %{
                 Aaa: [:Test, :Module, :Aaa],
                 Aaa_2: [:Test, :Module_2, :Aaa],
                 Aaa_3: [:Test_2, :Module, :Aaa]
               },
               %{Aaa: 3}
             } =
               {%{}, %{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa_3})
    end

    test "should automatically postfix as: alias with increment if leaves collision found" do
      assert {
               %{
                 [:Test, :Module, :Aaa] => :Aaa,
                 [:Test, :Module_2, :Aaa] => :Aaa_2,
                 [:Test_2, :Module, :Aaa] => :Aaa_3
               },
               %{
                 Aaa: [:Test, :Module, :Aaa],
                 Aaa_2: [:Test, :Module_2, :Aaa],
                 Aaa_3: [:Test_2, :Module, :Aaa]
               },
               %{Aaa: 3}
             } =
               {%{}, %{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa})
    end

    test "should work correctly in border case collision" do
      assert {
               %{
                 [:Test, :Module, :Aaa] => :Aaa,
                 [:Test, :Module_2, :Aaa] => :Aaa_2,
                 [:Test_2, :Module, :Aaa] => :Aaa_3
               },
               %{
                 Aaa: [:Test, :Module, :Aaa],
                 Aaa_2: [:Test, :Module_2, :Aaa],
                 Aaa_3: [:Test_2, :Module, :Aaa]
               },
               %{Aaa: 3}
             } =
               {%{}, %{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa})
    end

    test "should base postfix on first input" do
      assert {
               %{
                 [:Test, :Module, :Aaa] => :Aaa_3,
                 [:Test, :Module_2, :Aaa] => :Aaa_4,
                 [:Test_2, :Module, :Aaa] => :Aaa_5
               },
               %{
                 Aaa_3: [:Test, :Module, :Aaa],
                 Aaa_4: [:Test, :Module_2, :Aaa],
                 Aaa_5: [:Test_2, :Module, :Aaa]
               },
               %{Aaa: 5}
             } =
               {%{}, %{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa_1})
    end

    test "should ignore duplicate paths" do
      assert {
               %{
                 [:Test, :Module, :Aaa] => :Aaa_3,
                 [:Test, :Module_2, :Aaa] => :Aaa_4
               },
               %{
                 Aaa_3: [:Test, :Module, :Aaa],
                 Aaa_4: [:Test, :Module_2, :Aaa]
               },
               %{Aaa: 4}
             } =
               {%{}, %{}, %{}}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa_3})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
    end

    test "should keep first found alias_as and update only leaf_to_path" do
      test_name_path = [:Test, :Module, :Aaa]

      test_paths_to_leaf = %{
        test_name_path => :FirstAliasAs
      }

      test_leaf_to_count = %{FirstAliasAs: 1}

      test_leaf_to_path = %{FirstAliasAs: test_name_path}
      expected_leaf_to_path = Map.put(test_leaf_to_path, :SecondAliasAs, test_name_path)

      assert {
               ^test_paths_to_leaf,
               ^expected_leaf_to_path,
               ^test_leaf_to_count
             } =
               {test_paths_to_leaf, test_leaf_to_path, test_leaf_to_count}
               |> NamePathsMap.add_alias({test_name_path, :SecondAliasAs})
    end
  end

  describe "get_alias_short_form/2" do
    test "should not update state and should return same short name on direct name_path match" do
      test_path = [:Test, :Module, :Aaa]

      paths_to_leaf = %{
        test_path => :Aaa
      }

      leaf_to_path = %{Aaa: test_path}

      test_state = {
        paths_to_leaf,
        leaf_to_path,
        %{Aaa: 1}
      }

      assert {:Aaa, {^paths_to_leaf, ^leaf_to_path, %{Aaa: 1}}} =
               test_state
               |> NamePathsMap.get_alias_short_form(test_path)
    end

    test "should not update state and should return same short name on composed name_patch match" do
      last_name = :Aaa
      test_path = [:Test, :Module, last_name]

      paths_to_leaf = %{test_path => last_name}

      leaf_to_path = %{last_name => test_path}

      test_state = {
        paths_to_leaf,
        leaf_to_path,
        %{last_name => 1}
      }

      assert {^last_name, {^paths_to_leaf, ^leaf_to_path, %{^last_name => 1}}} =
               test_state
               |> NamePathsMap.get_alias_short_form([last_name])
    end

    test "should update state and return short name" do
      test_case_1 = {
        {
          %{
            [:Test, :Module, :Aaa] => :Aaa
          },
          %{Aaa: [:Test, :Module, :Aaa]},
          %{Aaa: 1}
        },
        [:Test, :Module, :Aaa, :Bbb],
        {
          :Bbb,
          {
            %{
              [:Test, :Module, :Aaa] => :Aaa,
              [:Test, :Module, :Aaa, :Bbb] => :Bbb
            },
            %{
              Aaa: [:Test, :Module, :Aaa],
              Bbb: [:Test, :Module, :Aaa, :Bbb]
            },
            %{
              Aaa: 1,
              Bbb: 1
            }
          }
        }
      }

      test_case_2 = {
        {
          %{
            [:Test, :Module, :Aaa] => :Aaa,
            [:Test, :Module, :Aaa, :Bbb] => :Bbb
          },
          %{
            Aaa: [:Test, :Module, :Aaa],
            Bbb: [:Test, :Module, :Aaa, :Bbb]
          },
          %{
            Aaa: 1,
            Bbb: 1
          }
        },
        [:Test, :Module, :Aaa, :Bbb],
        {
          :Bbb,
          {
            %{
              [:Test, :Module, :Aaa] => :Aaa,
              [:Test, :Module, :Aaa, :Bbb] => :Bbb
            },
            %{
              Aaa: [:Test, :Module, :Aaa],
              Bbb: [:Test, :Module, :Aaa, :Bbb]
            },
            %{
              Aaa: 1,
              Bbb: 1
            }
          }
        }
      }

      test_case_3 = {
        {
          %{
            [:Test, :Module, :Aaa] => :Aaa,
            [:Test, :Module, :Aaa, :Bbb] => :Bbb
          },
          %{
            Aaa: [:Test, :Module, :Aaa],
            Bbb: [:Test, :Module, :Aaa, :Bbb]
          },
          %{
            Aaa: 1,
            Bbb: 1
          }
        },
        [:Test, :Module, :Aaa, :Ccc, :Bbb],
        {
          :Bbb_2,
          {
            %{
              [:Test, :Module, :Aaa] => :Aaa,
              [:Test, :Module, :Aaa, :Bbb] => :Bbb,
              [:Test, :Module, :Aaa, :Ccc, :Bbb] => :Bbb_2
            },
            %{
              Aaa: [:Test, :Module, :Aaa],
              Bbb: [:Test, :Module, :Aaa, :Bbb],
              Bbb_2: [:Test, :Module, :Aaa, :Ccc, :Bbb]
            },
            %{
              Aaa: 1,
              Bbb: 2
            }
          }
        }
      }

      test_case_4 = {
        {
          %{[:Test, :Module, :Aaa] => :AliasAs},
          %{AliasAs: [:Test, :Module, :Aaa]},
          %{AliasAs: 1}
        },
        [:Test, :Module, :Aaa],
        {
          :AliasAs,
          {
            %{[:Test, :Module, :Aaa] => :AliasAs},
            %{AliasAs: [:Test, :Module, :Aaa]},
            %{AliasAs: 1}
          }
        }
      }

      [
        test_case_1,
        test_case_2,
        test_case_3,
        test_case_4
      ]
      |> Enum.each(fn {original_state, test_path, expected_result} ->
        assert ^expected_result =
                 original_state
                 |> NamePathsMap.get_alias_short_form(test_path)
      end)
    end
  end
end
