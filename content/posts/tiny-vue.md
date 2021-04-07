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
function setProps(ele, props) {
    for (const [key, value] of Object.entries(props)) {
        ele.setAttribute(key, value);
    }
}
当然，我们也同样需要unmount函数：
```
function unmount(VNode){
    if(VNode.el){
        document.removeChild(VNode.el)
    }
}
```
另一个很重要的功能是patch，即比较两个不同VDOM对象的差异，仅对元素进行最小化修改。
```
function patch(VNode1,VNode2){
    // 比较两个不同的VNode，并替换
    // VNode1 old
    // VNode2 new
    // VNode由一个三元组唯一标识 VNode = {tag,props,children}
    const el = VNode1.el // el指向可能被替换的元素
    VNode2.el = el

    if(VNode1.tag != VNode2.tag){
        // 比较tag
        mount(VNode2,el.parentNode)
        unmount(VNode1,el.parentNode)
    }else{
        // 比较 children
        if(typeof VNode2.children == 'string'){
            el.textContent = VNode2.children
            setProps(el,VNode2.props)
        }else{
            patchChildren(VNode1,VNode2) // 父节点相同 递归判断子节点的不同
        }
    }
}

function patchChildren(VNode1,VNode2){
    const c1 = VNode1.children
    const c2 = VNode2.children
    // child1 和 child2 要么是数组 要么 是字符串
    let commonLen = Math.min(
        typeof c1 == 'string' ? 0 : c1.length,
        c2.length,
    )
    // child1 child2 都是数组
        // child1 == child2
        // child1 < child2 
        // child1 > child2
    for(let i=0;i<commonLen;i++){
        patch(c1[i],c2[i])
        // 逐个比对
    }
    if(c1.length > commonLen){
        // unmount 多余部分
        for(let i=commonLen;i<c1.length;i++){
            unmount(c1[i])
        }
    }
    if(c2.length > commonLen){
        // mount 多余部分 到 n2.el
        for(let i=commonLen;i<c2.length;i++){
            mount(c2[i],n2.el)
        }
    }
}
```
此时，我们已经实现了VDOM到DOM的转换。
现在我们可以理解VDOM为何是有意义的，在直接对DOM进行操作时，很容易产生冗余操作使得DOM重排效率降低。此处我们虽然只实现了最简单的patch函数，但已经可以发现，通过VDOM的比对，再对必要处进行修改，这将使得很多冗余操作被优化。
数据双向绑定
现在，我们开始实现数据的双向绑定。正如本文开头的示意图所示，Vue使用了观察者模式。这里我们不对观察者设计模式作过多介绍，仅放出代码：
```
function observe(obj){
    Object.keys(obj).forEach(key => {
        let internalValue = obj[key]
        const dep = new Dep()
        Object.defineProperty(obj,key,{
            // 对get和set方法进行修饰
            get(){
                dep.depend()
                return internalValue
            },
            set(newVal){
                internalValue = newVal
                dep.notify()
            }
        })
    })
}

class Dep{
    constructor(value){
        this.subscribers = new Set()
    }
    depend(){
        activeUpdate && this.subscribers.add(activeUpdate)
    }
    notify(){
        this.subscribers.forEach(func => func())
    }
}

let activeUpdate = null

function autorun(update){
    function wrappedUpdate(){
        activeUpdate = update
        update()
        activeUpdate = null
    }
    wrappedUpdate()
}
```
如果你对观察者设计模式还不是很熟悉，那么在本文，你仅仅需要知道：观察者模式提供了一种服务，这种服务可以使得变量值的更替触发某些关联函数的执行。

## 三、tiny Vue 例子
上述两节，我们已经实现了数据双向绑定和VDOM到DOM的转换。这里，我们利用已经实现的功能做一个计时器例子：
```
<div id="counter"></div>
<button id="inc">inc</button>

<script>
const $ = document.querySelector.bind(document);
const container = $('#app');
const incBtn = $('#inc');
const counterContainer = $('#counter');

incBtn.addEventListener('click', () => {
  counter.count++;
});

const counter = {
  count: 1,
};

const counterComponent = {
  render(state) {
      return h('h1', {}, String(state.count));
  },
};

observe(counter); // 数据双向绑定

let oldNode = null;
autorun(function () {
  if (oldNode) {
      const newNode = counterComponent.render(counter);
      patch(oldNode, newNode);
      oldNode = newNode;
  } else {
      oldNode = counterComponent.render(counter);
      mount(oldNode, counterContainer);
  }
});

setInterval(()=>{
	counter.count++
},500)
</script>
```
在线演示：[JSFiddle](https://jsfiddle.net/e2qvfy63/5/)