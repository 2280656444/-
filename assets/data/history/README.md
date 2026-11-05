# 历史上的今天 · 本地兜底数据（可选）

把离线兜底 JSON 放在本目录，文件名 `history_M_D.json`（M、D 不补零），格式：

```json
[
  { "y": 1881, "t": "鲁迅出生于浙江绍兴", "c": "出生", "u": "https://zh.wikipedia.org/..." }
]
```

- `y` 年份 · `t` 事件 · `c` 大事件/出生/逝世 · `u` 来源链接（可选）
- 没有对应文件的日期不会报错，运行时自动走维基中文在线接口
- 想批量生成：`python3 tools/gen_history.py`（需能访问 zh.wikipedia.org）
