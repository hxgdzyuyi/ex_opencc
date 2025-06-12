defmodule ExOpencc do
  @moduledoc """
  Simple wrapper around OpenCC using NIF.
  """

  @on_load :load_nif

  def load_nif do
    priv_dir = Application.app_dir(:ex_opencc, "priv")
    path = :filename.join(priv_dir, "ex_opencc_nif")

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      error -> raise "load_nif failed: #{inspect(error)}"
    end
  end

  @doc """
  创建一个新的 OpenCC 转换器实例
  
  ## 参数
  - `config` (可选): 配置文件名，默认为 "s2t.json"
  
  ## 返回值
  - `{:ok, converter}` - 成功创建转换器
  - `{:error, reason}` - 创建失败
  
  ## 示例
  
      iex> {:ok, converter} = ExOpencc.new()
      iex> {:ok, converter} = ExOpencc.new("s2t.json")
      iex> {:ok, converter} = ExOpencc.new("t2s.json")
  """
  def new(), do: :erlang.nif_error(:nif_not_loaded)
  def new(_config), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  同步转换文本
  
  ## 参数
  - `converter`: 转换器实例
  - `text`: 要转换的文本
  
  ## 返回值
  - `{:ok, converted_text}` - 转换成功
  - `{:error, reason}` - 转换失败
  
  ## 示例
  
      iex> {:ok, converter} = ExOpencc.new("s2t.json")
      iex> {:ok, result} = ExOpencc.convert_sync(converter, "简体中文")
      iex> result
      "簡體中文"
  """
  def convert_sync(_converter, _text), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  便捷函数：创建转换器并转换文本
  
  ## 参数
  - `text`: 要转换的文本
  - `config` (可选): 配置文件名，默认为 "s2t.json"
  
  ## 返回值
  - `{:ok, converted_text}` - 转换成功
  - `{:error, reason}` - 转换失败
  
  ## 示例
  
      iex> {:ok, result} = ExOpencc.convert("简体中文")
      iex> result
      "簡體中文"
      
      iex> {:ok, result} = ExOpencc.convert("簡體中文", "t2s.json")
      iex> result
      "简体中文"
  """
  def convert(text, config \\ "s2t.json") do
    with {:ok, converter} <- new(config),
         {:ok, result} <- convert_sync(converter, text) do
      {:ok, result}
    end
  end
end
