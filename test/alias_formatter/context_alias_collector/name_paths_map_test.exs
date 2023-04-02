defmodule AliasFormatter.ContextAliasCollector.NamePathsMapTest do
  use ExUnit.Case

  alias AliasFormatter.ContextAliasCollector.NamePathsMap

  describe "add_alias/2" do
    test "should update given map with alias data" do
      test_alias_data = {[:Test, :Module, :Aaa], :Aaa}

      assert %{
               Test: %{
                 Module: %{
                   Aaa: :Aaa
                 }
               }
             } = NamePathsMap.add_alias(%{}, test_alias_data)
    end

    test "should preserve given map existing paths" do
      assert %{
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
             } =
               %{}
               |> NamePathsMap.add_alias({[:Test, :Module, :Aaa], :Aaa})
               |> NamePathsMap.add_alias({[:Test, :Module_2, :Aaa], :Aaa_2})
               |> NamePathsMap.add_alias({[:Test_2, :Module, :Aaa], :Aaa_3})
    end
  end
end
