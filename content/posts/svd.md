---
title: "[统计学习方法]奇异值分解"
date: 2021-04-20T16:25:31+08:00
draft: false
---
# 一、奇异值分解的含义
奇异值分解是指，对于任意的一个$m\times n$阶矩阵$A$，都存在分解
$$A=U\Sigma V^T \tag{1}$$
其中$U$是$m$阶的正交矩阵、$V$是$n$阶的正交矩阵、$\Sigma$是$m\times n$的对角矩阵，$\Sigma=[\sigma_1,\sigma_2,...,\sigma_n]$。

# 二、证明对于每一个矩阵均存在奇异值分解
这里使用构造性的证明方法。
首先，不妨假设$m>n$，然后我们分别构造$U$、$\Sigma$和$V$。
## 第一步：构造$V$和$\Sigma$
注意到，$A^TA$是一个实对称矩阵，因此$A^TA$一定可以被相似对角化，即：$V^T(A^TA)V=\Lambda$。定义奇异值$\sigma_j=\sqrt{\lambda_j}$，这里定义奇异值为$A^TA$的特征值的根号，可以直观地理解为$A^TA$相当于$A^2$，则$A$的"特征值"应当是根号下的$\lambda_j$。

对于矩阵$A$，它的秩为$r<n$，有$\sigma_j > 0,(1\leq j\leq r)$，$\sigma_j = 0, r+1 \leq j \leq n$。
则令$V_1=[v_1,v_2,...,v_r]$和$V_2=[V_{r+1},v_{r+2},...,v_n]$，其中$v_k$指$A^TA$的特征向量，则有
$$V = [V_1,V_2] \tag{2}$$

再令
$$\Sigma_1=\text{diag}(\sigma_1,\sigma_2,...,\sigma_r) \tag{3}$$

则

$$
\Sigma = \text{diag}(\Sigma_1,0)
$$

至此，我们就构造出来了$V$和$\Sigma$矩阵，类比于相似对角化$A=Q\Lambda Q^T$，这里的$\Sigma$即$\Lambda$，而$V$和$U$即$Q$。但是对于一个一般的矩阵，并不存在$U=V$，因此，下一步就是去构造$U$。

## 第二步：构造矩阵$U$
首先，令
$$
u_j = \frac{1}{\sigma_j}Av_j \tag{4}
$$
$$
U_1 = [u_1,u_2,...,u_r] \tag{5}
$$
则$AV_1=U_1\Sigma_1$，可证明$U_1$是一个正交矩阵。
再令$U_2$的列向量为$N(A^T)$的标准正交基，以及$U=[U_1,U_2]$，则

$$
\begin{aligned}
    U\Sigma V^T &= [U_1 \quad U_2] \begin{bmatrix}
        \Sigma_1 & 0 \\
        0 & 0
    \end{bmatrix}\begin{bmatrix}
        V_1^T \\
        V_2^T
    \end{bmatrix} \\
    &= U_1\Sigma_1 V_1 \\
    &= AV_1V_1^T \\
    &= A
\end{aligned}
\tag{6}
$$
至此，我们就证明了对$m>n$的任意矩阵存在奇异值分解，对$n>m$的矩阵同理。

# 三、矩阵近似
奇异值分解可以看作在Frobenius范数下的矩阵近似，所谓Frobenius范数是指；
$$
||A||_F= \left( \sum_{i=1}^m \sum_{j=1}^n (a_{ij})^2 \right)
\tag{7}
$$
容易证明
$$||A||_F=(\sigma_1^2+\sigma_2^2+...+\sigma_n^2)^{1/2} \tag{8}$$

矩阵近似是指，使用一个低秩的矩阵去近似一个高秩的矩阵。学习过线性代数我们都知道，一个低秩的矩阵所能张成的线性空间的维度是低于高秩矩阵的。矩阵最优近似可以定义为
$$
||A-X||_F = \min_{s \in M} ||A -S||_F \tag{9}
$$
其中,$r(A)=r$,$M$为所有秩不超过$r$的矩阵的集合。
可以证明，对任意矩阵$A=U\Sigma V^T$有
$$
\begin{aligned}
    ||A-X||_F &= \min_{S\in M} ||A-S||
    &= \left( \sigma_{k+1}^2 + \sigma_{k+2}^2 + ... + \sigma_n^2 \right) \tag{10}
\end{aligned}
$$
由公式(8)可知，$||A||_F=(\sigma_1^2+\sigma_2^2+...+\sigma_n^2)^{1/2}$，也就是说，使用一个低秩矩阵$X$其秩为$k$去近似一个高秩的$n$阶矩阵$A$，其误差的下界是$\mathcal{O}\left( \sigma_{k+1}^2 + \sigma_{k+2}^2 + ... + \sigma_n^2 \right)$。从这里可以看出，越大的奇异值对应越丰富的信息，越小的奇异值对应越少的信息。

公式(10)的具体证明过程如下：
假设秩为n的矩阵$A$，其在秩为$k$下最优近似为$A'$。
$A'=Q\Omega P^T$，其中$\Omega=\text{diag}(\omega_1,...,\omega_k,0,...,0)$。令$B=Q^TAP$则有：
$$
\begin{aligned}
    ||A-A'||_F &= ||Q(B-\Omega)P^T|| \\
    &= ||B_{11} - \Omega_k||_F^2 + ||B_{12}||_F^2 + ||B_{21}||_F^2 + ||B_{22}||_F^2 \tag{11}
\end{aligned}
$$
由于$A'$是$A$的最优近似，令
$$
Y = Q \begin{bmatrix}
    B_{11} & B_{12} \\
    0 & 0
\end{bmatrix} P^T \tag{11}
$$
则
$$
||A-Y||_F^2 = ||B_{21}||_F^2 + ||B_{22}||_F^2 < ||A-A'||_F^2 \tag{12}
$$
则公式(12)必定不能成立，因此，$B_{12}=0$，同理可得$B_{21}=0$。
再证$B_{11}=\Omega_k$，令
$$
Z = Q \begin{bmatrix}
    B_{11} & 0 \\
    0 & 0
\end{bmatrix} P^T \tag{13}
$$
则
$$
||A-Z||_F^2 = ||B_{22}||_F^2 \leq ||B_11 - \Omega_k||_F^2 +||B_{22}||_F^2 = ||A-X||_F^2 \tag{14}
$$
则$||B_{11}-\Omega_k||_F^2=0$，即$B_{11}=\Omega_k$。对$B_{22}$有奇异值分解$B_{22}=U_1\Lambda V_1^T$，则：
$$
||A-X||_F = ||B_{22}||_F = ||\Lambda||_F \geq  \left( \sigma_{k+1}^2 + \sigma_{k+2}^2 + ... + \sigma_n^2 \right) \tag{15}
$$
公式(10)得证。

# 四、奇异值分解的计算
在第二节，已经介绍了奇异值分解的构造，这一节我将使用具体的矩阵来介绍奇异值分解的计算。
给定矩阵
$$
A = \begin{bmatrix}
    1 & 2 \\
    2 & 2 \\
    0 & 0 
\end{bmatrix} \tag{16}
$$
## 第一步：求矩阵$A^TA$的特征值与特征向量
$$
A^TA = \begin{bmatrix}
    5 & 5 \\
    5 & 5
\end{bmatrix} \tag{17}
$$
其特征值和特征向量为
$$\lambda_1=10 \quad v_1=\begin{bmatrix}
    \frac{1}{\sqrt{2}} \\ \frac{1}{\sqrt{2}}
\end{bmatrix}$$
$$\lambda_1=0 \quad v_2=\begin{bmatrix}
    \frac{1}{\sqrt{2}} \\ -\frac{1}{\sqrt{2}}
\end{bmatrix}$$

## 第二步：求正交矩阵$V$
由第一步得到的特征向量可得$V$
$$
V = \begin{bmatrix}
    \frac{1}{\sqrt{2}} & \frac{1}{\sqrt{2}} \\
    \frac{1}{\sqrt{2}} & -\frac{1}{\sqrt{2}}
\end{bmatrix}
$$

## 第三步：求对角矩阵$\Sigma$
由第一步求得的特征值可得，奇异值为$\sigma_1=\sqrt{\lambda_1}=\sqrt{10}$和$\sigma_2 = \sqrt{\lambda_2} = 0$，需要注意的是，这里对特征值由大到小进行排列。
根据奇异值可得对角矩阵
$$
\Sigma = \begin{bmatrix}
    \sqrt{10} & 0 \\
    0 & 0 \\
    0 & 0
\end{bmatrix}
$$
可以看到，这里的对角矩阵并非方阵，这是因为最后一行加入了零行向量，以保证$\Sigma$可以和$U$、$V$进行矩阵乘法。

## 第四步：求正交矩阵$U$
由第三步得到的奇异值，可以计算
$u_1=\dfrac{1}{\sigma_1}A_{v_1}=\begin{bmatrix}
    \dfrac{1}{\sqrt{5}} & \dfrac{2}{\sqrt{5}} & 0
\end{bmatrix}^T$
而$u_2,u_3$是$N(A^T)$的标准正交基，即$A^Tx=0$的基础解系。
计算得到
$$
U = \begin{bmatrix}
    \dfrac{1}{\sqrt{5}} & -\dfrac{2}{\sqrt{5}} & 0 \\
    \dfrac{2}{\sqrt{5}} & \dfrac{1}{\sqrt{5}} & 0 \\
    0 & 0 & 1
\end{bmatrix}
$$
由以上四步，我们可以得到矩阵$A$的奇异值分解为
$$
A = U\Sigma V^T = \begin{bmatrix}
    \dfrac{1}{\sqrt{5}} & -\dfrac{2}{\sqrt{5}} & 0 \\
    \dfrac{2}{\sqrt{5}} & \dfrac{1}{\sqrt{5}} & 0 \\
    0 & 0 & 1
\end{bmatrix}\begin{bmatrix}
    \sqrt{10} & 0 \\
    0 & 0 \\
    0 & 0
\end{bmatrix}\begin{bmatrix}
    \frac{1}{\sqrt{2}} & \frac{1}{\sqrt{2}} \\
    \frac{1}{\sqrt{2}} & -\frac{1}{\sqrt{2}}
\end{bmatrix}
$$

# 五、奇异值分解的几何理解
我们现在已经知道$A=U\Sigma V^T$对于任意矩阵均成立，实际上，$U、V^T$作为正交矩阵，在线性变换的意义上即旋转变换，而$\Sigma$作为对角矩阵即伸缩变换。这提示我们，所有的线性变换均可以分解为旋转、伸缩、旋转。