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
这个VDOM与这样的一个标签对应：
```
<p id="text">it is a text</p>
```
Vue首先要关注的就是如何把一个VDOM对象转换成一个DOM对象。

## 二、VDOM -> DOM
浏览器为我们提供了操作Document的API，例如，我们可以用如下的代码创建一个HTML元素：
```
let p = document.createElementByTagName('p')
```
然后将其添加到某个元素（假设为container）下：
```
container.appendChild(p)
```
要实现VDOM到DOM的转换，其实就是把这个过程封装起来。
首先，我们要引入render函数，这个函数接收三个参数（标签名，属性，子节点），并返回一个VDOM对象。
```
function h(tag,props,children){
    return {
        tag,
        props, // object
        children // array
    }
}
```
例如：
```
let p = h(
    tag = 'p',
    props = {
        id: 'text'
    },
    children = 'it is a text'
)
```
这里的p就是一个VDOM对象。得到VDOM对象后，我们需要将其转换为DOM对象。于是定义mount函数：
```
function mount(VNode,container){
    const {tag,props,children} = VNode
    // 创建DOM对象
    VNode.el = document.createElement(tag) // VNode新增一个属性 指向 Node
    // 设置DOM属性
    setProps(VNode.el,VNode.props)
    // DOM下挂载子DOM对象
    if(typeof children == 'string'){
        VNode.el.textContent = children
    }else{
        for(child in children){
            mount(child,VNode.el)
        }
    }
    container.appendChild(VNode.el)
}
```
可以看到，children可以是数组或者字符串。数组即表示当前VDOM的所有直接子节点。
此处将setProps单独实现是为了复用：
