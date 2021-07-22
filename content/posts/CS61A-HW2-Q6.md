---
title: "题解：CS61A-HW2-Q6：make_anonymous_factorial"
date: 2021-07-21T21:10:29+08:00
---

### 题目要求
不使用def语句实现递归的阶乘函数make_anonymous_factorial，实现效果如下：
```bash
>>> make_anonymous_factorial()(5)    
>>> 120
```

### 分析
这个题目是很有意思的，也是HW2里最难的一道题。一下子很难入手，所以我们先实现使用def的版本：
```python
def make_anonymous_factorial():
  def fact(f, k):
    if k == 0:
      return 1
    else:
      return f(f, k-1) * k
  return lambda x: fact(fact ,x)
```
其中
```python
def fact(f, k):
    if k == 0:
        return 1
    else:
        return f(f, k-1) * k
```
可以写作匿名函数如下：
```python
lambda f,k: 1 k==0 else f(f ,k-1) * k
```
由于fact函数是一个纯函数（pure function），即函数的输出只与输入有关，因此可以直接把make_anonymous_factorial函数return语句中的fact函数替换为匿名函数：
```python
def make_anonymous_factorial2():
  return lambda x: (lambda f,k: 1 if k==0 else f(f ,k-1) * k)((lambda f,k: 1 if k==0 else f(f ,k-1) * k),x)
```
不过这个代码里实现了两次fact函数，我们希望只实现一次，于是再观察一下return部分的语句：
```python
return lambda x: fact(fact ,x)
```
可以想到，将fact函数作为参数传入某个匿名函数，让其返回函数 lambda x: fact(fact ,x) 即可实现等价的功能。这里使用匿名函数的立即执行功能：
```python
return (lambda f:
    lambda x: f(f ,x)
)(
  lambda f,k: 1 if k==0 else f(f ,k-1) * k
)
```
由此，就很好地解决了这个问题，并且改变最外层匿名函数的传入值，我们还能实现各种功能（所有可以用纯函数的自我组合表示的功能都可以实现，如自增等）。
Q6引导我们一步一步对形式（x: f(f ,x)）和逻辑（具体的阶乘实现）进行解耦，一道非常有意思的题目。