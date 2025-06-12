# ExOpencc

ExOpencc 是基于 OpenCC 的 Elixir NIF 封装，提供简繁中文互转功能。

## 安装

在 `mix.exs` 中添加依赖：

```elixir
def deps do
  [
    {:ex_opencc, "~> 0.1.0"}
  ]
end
```

## 编译

首先获取 OpenCC 源代码：

```bash
git submodule update --init --recursive
```

然后编译：

```bash
make ex_opencc
# 或者
mix compile
```

## 基本用法

### 创建转换器

```elixir
# 默认使用 "s2t.json"
{:ok, converter} = ExOpencc.new()

# 指定配置文件
{:ok, converter} = ExOpencc.new("s2t.json")
```

### 同步转换文本

```elixir
{:ok, converter} = ExOpencc.new("s2t.json")
{:ok, result} = ExOpencc.convert_sync(converter, "简体中文")
IO.puts(result) # => "簡體中文"

# 处理空字符串
{:ok, result} = ExOpencc.convert_sync(converter, "")
IO.puts(result) # => ""
```

### 简繁互转

```elixir
# 简体转繁体
{:ok, converter} = ExOpencc.new("s2t.json")
{:ok, result} = ExOpencc.convert_sync(converter, "简体中文")
IO.puts(result) # => "簡體中文"

# 繁体转简体
{:ok, converter} = ExOpencc.new("t2s.json")
{:ok, result} = ExOpencc.convert_sync(converter, "簡體中文")
IO.puts(result) # => "简体中文"
```

### 错误处理

```elixir
result = ExOpencc.convert_sync(:invalid_resource, "测试")
# result => {:error, reason}
```

### 批量转换示例

```elixir
test_cases = [
  {"简体中文", "簡體中文"},
  {"中华人民共和国", "中華人民共和國"},
  {"北京大学", "北京大學"},
  {"软件工程", "軟件工程"}
]

{:ok, converter} = ExOpencc.new("s2t.json")

for {input, expected} <- test_cases do
  {:ok, result} = ExOpencc.convert_sync(converter, input)
  IO.puts("#{input} -> #{result}")
end
```

## 支持的配置

| 配置文件 | 转换方向 | 说明 |
|---------|---------|------|
| `s2t.json` | 简体 → 繁体 | 简体中文转换为繁体中文 |
| `t2s.json` | 繁体 → 简体 | 繁体中文转换为简体中文 |
| `s2tw.json` | 简体 → 台湾繁体 | 简体中文转换为台湾地区的繁体中文 |
| `tw2s.json` | 台湾繁体 → 简体 | 台湾地区的繁体中文转换为简体中文 |
| `s2hk.json` | 简体 → 香港繁体 | 简体中文转换为香港地区的繁体中文 |
| `hk2s.json` | 香港繁体 → 简体 | 香港地区的繁体中文转换为简体中文 |
| `s2twp.json` | 简体 → 台湾繁体（短语） | 简体中文转换为台湾地区的繁体中文，包含短语转换 |
| `tw2sp.json` | 台湾繁体（短语） → 简体 | 台湾地区的繁体中文转换为简体中文，包含短语转换 |

## API 文档

### ExOpencc.new/0, ExOpencc.new/1

创建新的 OpenCC 转换器。

**参数**
- `config` (可选) 配置文件名，默认 `"s2t.json"`

**返回值**
- `{:ok, converter}` 创建成功
- `{:error, reason}` 创建失败

### ExOpencc.convert_sync/2

使用给定的转换器同步转换文本。

**参数**
- `converter` 转换器实例
- `text` 要转换的文本

**返回值**
- `{:ok, converted}` 转换成功
- `{:error, reason}` 转换失败

## 许可证

项目基于 OpenCC
