---
layout: post
title: "机器学习(Week4)-神经网络"
date: 2017-5-24
categories:
  - Tech
description: 
image: http://wx3.sinaimg.cn/large/6a1f6674ly1ffuf6qvvc8j21kw0u5n0z.jpg
image-sm: http://wx3.sinaimg.cn/mw1024/6a1f6674ly1ffuf6qvvc8j21kw0u5n0z.jpg
---
<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

### Lecture1: Neural Networks

#### 为什么我们需要神经网络

* 当特征特别多（计算机视觉问题）时，如果计算多次多项式，得出来的最终特征会特别多，多到计算机无法处理。

#### 产生的原因

> Algorithms that try to mimic the brain. Was very widely used in 80s and early 90s; popularity diminished in late 90s<br/>
> Recent resurgence: State-of-the-art technique for many applications

* One learning algorithm

> 大脑的某一块区域（听觉皮层）能处理听觉，视觉，触觉等相关的信息（神经重接实验），所以是否有一各机器学习算法，可以处理各种的事务？

##### 模型表示（Model Representation）

* 最简单的表示（只有一个神经元的情况下）

$$\class{myMJSmall}{
\begin{bmatrix}
x_0 \\
x_1 \\
x_2 \\
x_3 \\
  \end{bmatrix} \rightarrow
\begin{bmatrix}  
\end{bmatrix} \rightarrow
 h_\theta(x)
}$$

> 模拟神经元：输入特征$$x_1\cdots x_n$$像是神经元树突(dendrites)；输出结果$$h_\theta(x)$$好比神经轴突(axons)<br/>
> $$x_0$$的值总是为1，称之为偏置单元（bias unit），有时候会不画出来，计算维度时也不计入<br/>
> 神经网络中也使用$$\frac{1}{1+e^{\theta^Tx}}$$，称之为S型激活函数（sigmoid/logistic activation function）<br/>
> $$\theta$$参数有时候也称之为权重(weight)

* 添加层数

$$\class{myMJSmall}{
\begin{bmatrix}
x_0 \\
x_1 \\
x_2 \\
x_3 \\
  \end{bmatrix} \rightarrow
\begin{bmatrix}  
a_1^{(2)} \\
a_2^{(2)} \\
a_3^{(2)} \\
\end{bmatrix} \rightarrow
\begin{bmatrix}  
a_1^{(3)} \\
\end{bmatrix} \rightarrow
 h_\theta(x)
}$$

> $$x_0,x_1\cdots$$所在的层称为第一层（layer 1)，也称之为输入层（input layer）<br/>
> $$h_\theta(x)$$的前一层（layer 3）输出称之类输出层（output layer)<br/>
> 在输入层与输出层之间的层（layer 2）称为隐藏层（hidden layer）<br/>
> 隐藏层中的$$a_0^{(2)},a_1^{(2)}\cdots$$称为激活单元（activation units）<br/>

* 激活单元的表示


$$\class{myMJSmall}{
 \begin{align*} 
   a_1^{(2)} = g(\Theta_{10}^{(1)}x_0 + \Theta_{11}^{(1)}x_1 + \Theta_{12}^{(1)}x_2 + \Theta_{13}^{(1)}x_3) \\
   a_2^{(2)} = g(\Theta_{20}^{(1)}x_0 + \Theta_{21}^{(1)}x_1 + \Theta_{22}^{(1)}x_2 + \Theta_{23}^{(1)}x_3) \\ 
   a_3^{(2)} = g(\Theta_{30}^{(1)}x_0 + \Theta_{31}^{(1)}x_1 + \Theta_{32}^{(1)}x_2 + \Theta_{33}^{(1)}x_3) \\
   h_\Theta(x) = a_1^{(3)} = g(\Theta_{10}^{(2)}a_0^{(2)} + \Theta_{11}^{(2)}a_1^{(2)} + \Theta_{12}^{(2)}a_2^{(2)} + \Theta_{13}^{(2)}a_3^{(2)}) \\ 
 \end{align*}
}$$

> $$a_i^{(j)}$$表示第$$j$$层的第$$i$$个激活单元<br/>
> $$\Theta^{(j)}$$表示从第$$j$$层到$$j+1$$层的函数参数矩阵<br/>
> $$\Theta^{(j)}$$的维度计算方法为：$$s_{j+1}\times (s_j+1)$$，其中$$s_j$$为第j层的激活单元个数（不包括为0的单元）<br/>
> 之前的$$\Theta^{(1)}$$的维度为$$3\times4$$，$$\Theta^{(2)}$$的维度为$$1\times 4$$<br/>
> 函数$$g$$为S型函数(sigmoid function)







##### 学习资料

[课件和笔记](http://pan.baidu.com/s/1hsGETb2)
[Octave编程作业](https://github.com/xiaochai/ml_assignment)
