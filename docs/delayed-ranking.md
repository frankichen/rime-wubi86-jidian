# 延后排序

`五笔拼音·延后排序版`把候选计算与学习完全分离：

1. 打字时只读取静态词典，不开启 `enable_user_dict`、自动造词或提交历史编码。
2. 候选上屏时，Lua 仅向用户目录中的 `wubi86_jidian_delayed_learning.tsv` 追加一行。
3. 在空闲时批量运行脚本，生成 `wubi86_jidian_delayed.dict.yaml`。
4. 重新部署 Rime 后，新顺序才生效。

这样不会出现候选边打边跳，也不会在每次按键时访问动态用户数据库。

## 生成排序词库

在 Rime 用户目录中运行：

```bash
python3 tools/build_delayed_ranking.py \
  --log wubi86_jidian_delayed_learning.tsv \
  --output wubi86_jidian_delayed.dict.yaml
```

默认一个“文字 + 编码”组合至少使用 3 次才进入延后排序词库，避免偶然选择立刻改变顺序。

完成后执行一次“重新部署”。建议每天、每周或累计较多输入后再运行，不需要频繁执行。

## 调节学习强度

更保守，至少使用 8 次才调整：

```bash
python3 tools/build_delayed_ranking.py \
  --log wubi86_jidian_delayed_learning.tsv \
  --output wubi86_jidian_delayed.dict.yaml \
  --min-count 8
```

限制最多生成 2000 条：

```bash
python3 tools/build_delayed_ranking.py \
  --log wubi86_jidian_delayed_learning.tsv \
  --output wubi86_jidian_delayed.dict.yaml \
  --max-entries 2000
```

## 回退

随时切回原来的 `极点五笔86` 或 `五笔拼音` 方案即可；原方案没有被修改。
