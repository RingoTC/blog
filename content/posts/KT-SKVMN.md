---
title: "[Paper I read] Knowledge Tracing with Sequential Key-Value Memory Networks"
date: 2021-10-20T16:41:00+08:00
draft: false
---

## motivation
这篇文章主要解决 DKT 和 DKVMN 两个模型的问题：
- DKT 无法给出特定概念上的掌握程度
- 无法捕获长期的信息
- DKVMN 的 write process 不够好

## contribution
- 在所有数据集上都超越了 DKVMN 和 DKT

## methodology
- 使用 LSTM 建模长期的信息
- 使用 Hop-LSTM 建模依赖性 [?]
- 修改了 DKVMN 的 write process

## experiment
- 对比实验
- ROC 曲线图