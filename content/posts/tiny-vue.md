---
title: "实现Vue的核心功能：Virtual DOM 和 数据双向绑定"
date: 2021-04-07T15:05:29+08:00
draft: false
---

> 最近我在重学前端，对Vue的实现方式比较感兴趣。在网络上，有很多实现Vue核心功能的文章，在本文，我也将对Vue的Virtual DOM和数据双向绑定进行实现。

## 一、vue的运行基础
相信学过Vue的同学都看过这张图片：
![vue示意图](http://localhost:1313/images/tiny-vue/vue.jpg)

在Vue中，最重要的三个组件是：Reactivity Module、Compiler Module、Renderer Module，这三个Module的功能如下：
- Reactivity Module：使得JavaScript对象的值的更改能够立即被渲染在HTML上。也就是数据的双向绑定。
- Compiler Module：将template编译为render函数。
- Renderer Module：将render函数转换为HTML元素。
在本文，我将重点关注Reactivity Module和Renderer Module。

在我看来，Vue的核心功能在于维护Virtual DOM（下简称VDOM）和DOM的关系。
VDOM有三个不同类型的信息构成：
- 标签名
- 属性，包括方法如onclick等
- 子节点
这构成了一个JavaScript对象：
```
let vdom = {
    tag: 'p',
    props: {
        id: 'text'
    },
    children:'it is a text'
}
```