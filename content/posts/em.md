---
title: "[统计学习方法]EM算法"
date: 2021-04-23T10:51:44+08:00
draft: false
---
EM算法是对含有隐变量的概率模型进行参数估计的一种方法。在本文，我将参考《统计学习方法》一书，对EM算法的目的、原理以及收敛性进行整理。

# 一、EM算法的目的
首先，我们要理解EM算法要解决的问题。在一些参数估计的问题中，很多变量是不可以直接观测的。

比如，在一所高中，我们需要估计男女生的身高的分布，但我们只有每个人的身高信息，没有他们的性别信息。我们知道，男女生的身高应该是服从两个不同的正态分布，但由于我们无法直接获悉当前样本的性别，因此无法直接使用极大似然估计或者贝叶斯估计对正态分布的均值与方差两个参数进行估计。

在这个问题中，样本的性别就属于隐变量（Latent Variable）而样本的身高属于观测变量（Observable Variable）。我们令所有的隐变量组成集合$Z$，所有的观测变量组成集合$Y$。

参考极大似然估计的想法，我们需要使得当前出现的情形是概率最大的，即
$$
\argmax_\theta P(Y|\theta) = \sum_Z P(Z|\theta)P(Y|Z,\theta) \tag{1}
$$
但难点在于，对于公式(1)左边的式子，由于其含有隐变量，我们无法对其进行积分运算。因此，我们需要尝试一种近似的策略。

# 二、EM算法的原理
EM算法通过定义$P(Y|\theta)$的近似$Q$函数，再对$Q$函数进行极大化进而使得$P(Y|\theta)$极大（实际上，EM算法并不能实现$P(Y|\theta)$的极大，此处按下不表）。

所以，EM算法可以分为两个步骤：
- E步（Exception）：计算$Q(\theta,\theta^{(i)})$
- M步（Maximum）：极大化$Q(\theta,\theta^{(i)})$，得到参数$\theta^{(i+1)}$

具体的，$Q$函数是指 **完全数据的对数似然函数$\log P(Y,Z|\theta)$关于在给定观测数据$Y$和当前参数$\theta^{(i)}$下对未观测数据$Z$的条件概率分布$P(Z|Y,\theta(i))$的期望，即**

$$
Q(\theta,\theta^{(i)})=E_z[\log P(Y,Z|\theta)|Y,\theta^{(i)}] \tag{2}
$$

一言以蔽之，$Q$函数就是指在当前情况下$\log P(Y,Z|\theta)$的可能性，极大化$Q$函数，就是在极大化$\log P(Y,Z|\theta)$，也就是说，每一次迭代后$\theta$的取值为：

$$
\theta^{(i+1)}=\argmax_\theta Q(\theta,\theta^{(i)}) \tag{3}
$$

下面，我们严格地来证明极大化$Q$函数近似于极大化$\log P(Y|\theta)$。

我们令$L(\theta)=\log P(Y|\theta) = \log \sum_Z P(Y,Z|\theta) = \log \left( \sum_Z P(Y|Z,\theta)P(Z|\theta) \right)$（由贝叶斯公式可得）。

由于直接极大化$L(\theta)$不可行，我们可以把目标近似地替代为，使得每一次参数调整之间的差均是正值
$$
\begin{aligned}
    L(\theta) - L(\theta^{(i)}) &= \log \left( \sum_Z P(Y|Z,\theta)P(Z|\theta) \right) - \log P(Y|\theta^{(i)}) \\
    &= \log \left( \sum_Z P(Z|Y,\theta^{(i)}) \dfrac{P(Y|Z,\theta)P(Z|\theta)}{P(Z|Y,\theta^{(i)})}\right) - \log P(Y|\theta^{(i)}) \\
    &\geq \sum_Z P(Z|Y,\theta^{(i)}) \log \dfrac{P(Y|Z,\theta)P(Z|\theta)}{P(Z|Y,\theta^{(i)})P(Y|\theta^{(i)})} \tag{4}
\end{aligned}
$$
(使用Jesson不等式)

从公式(4)中可以得到$L(\theta) \geq \sum_Z P(Z|Y,\theta^{(i)}) \log \dfrac{P(Y|Z,\theta)P(Z|\theta)}{P(Z|Y,\theta^{(i)})P(Y|\theta^{(i)})} + L(\theta^{(i)})$，则令$B(\theta,\theta^{(i)})=\sum_Z P(Z|Y,\theta^{(i)}) \log \dfrac{P(Y|Z,\theta)P(Z|\theta)}{P(Z|Y,\theta^{(i)})P(Y|\theta^{(i)})}$。

则极大化$L(\theta)$的目标转换为极大化$B(\theta,\theta^{(i)})$，也就是提升$L(\theta)$的下界，即
$$
\begin{aligned}
    \theta^{(i+1)} &= \argmax_{\theta} B(\theta,\theta^{(i)}) \\
    &= \argmax_\theta \left( L(\theta^{(i)}) + \sum_Z P(Z|Y,\theta^{(i)}) \log \dfrac{P(Y|Z,\theta)P(Z|\theta)}{P(Z|Y,\theta^{(i)})P(Y|\theta^{(i)})} \right) \\
    &= \argmax_\theta \left( \sum_Z P(Z|Y,\theta^{(i)}) \log P(Y|Z,\theta)P(Z|\theta)  \right) \\
    &= \argmax_\theta \left( \sum_Z P(Z|Y,\theta^{(i)}) \log P(Y,Z|\theta) \right) \\
    &= \argmax Q(\theta,\theta^{(i)})
\end{aligned} \tag{5}
$$

也就是说，极大化$Q$函数实际上是在极大化$B$函数。

# 三、EM算法的收敛性
显然的，EM算法的每一次迭代都会使得$Q$函数更大，并且$Q$函数是有上界的。根据单调有界原理，EM算法一定是收敛的。但EM算法执行结束时，取得的参数$\theta$并不一定是最优参数。这是因为，我们实际上是在最大化某个下界，此下界与真实值之间会存在差距。