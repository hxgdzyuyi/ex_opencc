defmodule ExOpenccTest do
  use ExUnit.Case
  doctest ExOpencc

  setup_all do
    # 确保 NIF 已加载
    :ok
  end

  test "create converter with default config" do
    assert {:ok, _converter} = ExOpencc.new()
  end

  test "create converter with specific config" do
    assert {:ok, _converter} = ExOpencc.new("s2t.json")
  end

  test "convert simplified to traditional Chinese" do
    {:ok, converter} = ExOpencc.new("s2t.json")
    {:ok, result} = ExOpencc.convert_sync(converter, "简体中文")
    assert result == "簡體中文"
  end

  test "convert traditional to simplified Chinese" do
    {:ok, converter} = ExOpencc.new("t2s.json")
    {:ok, result} = ExOpencc.convert_sync(converter, "簡體中文")
    assert result == "简体中文"
  end

  test "convert empty string" do
    {:ok, converter} = ExOpencc.new()
    {:ok, result} = ExOpencc.convert_sync(converter, "")
    assert result == ""
  end

  test "convert convenience function" do
    {:ok, result} = ExOpencc.convert("简体中文")
    assert result == "簡體中文"
    
    {:ok, result} = ExOpencc.convert("簡體中文", "t2s.json")
    assert result == "简体中文"
  end

  test "handle invalid converter resource" do
    # 这个测试可能需要根据实际的错误处理进行调整
    result = ExOpencc.convert_sync(:invalid_resource, "测试")
    assert {:error, _reason} = result
  end

  test "convert with various Chinese texts" do
    test_cases = [
      {"简体中文", "簡體中文"},
      {"中华人民共和国", "中華人民共和國"},
      {"北京大学", "北京大學"},
      {"软件工程", "軟件工程"}
    ]
    
    {:ok, converter} = ExOpencc.new("s2t.json")
    
    for {input, expected} <- test_cases do
      {:ok, result} = ExOpencc.convert_sync(converter, input)
      assert result == expected, "Failed to convert #{input}, got #{result}, expected #{expected}"
    end
  end
end
