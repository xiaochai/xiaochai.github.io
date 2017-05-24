---
layout: post
title: "机器学习课程备忘(Week4)"
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
> $$x_0$$的值总是为0，称之为偏置单元（bias unit），有时候会不画出来<br/>
> 神经网络中也使用$$\frac{1}{1+e^{\theta^Tx}}$$，称之为S型激活函数（sigmoid/logistic activation function）<br/>
> $$\tehta$$参数有时候也称之为权重(weight)






$$\class{myMJSmall}{y \in \{0,1\}}$$

> $$y$$只有两个值（即分成两类）<br/>
> 标记为0的分类：也叫负类（Negative Class），例如0代表良性肿瘤<br/>
> 标记为1的分类：也叫正类（Positive Class），例如1代表恶性肿瘤

##### 预测函数/逻辑回归(Logistic Regression)

$$\class{myMJSmall}{h_\theta(x) = g(\theta^Tx) \\
	g(z) = \frac{1}{1-e^{-z}} \\ 
	即 h_\theta(x) = \frac{1}{1-e^{-\theta^Tx}}}$$

> $$ 0 \le h_\theta(x) \le 1 $$<br/>
> $$g(z)$$称为S型函数（Sigmoid function）或逻辑函数（Logistic function）<br/>
> $$h_\theta(x)$$值表示$$y=1$$的概率值，即$$h_\theta(x) = P(y=1\mid x;\theta) = 1-P(y=0\mid x;\theta)$$

![逻辑函数图像](/assets/images/sigmoid.png)

```matlab
x=-10:0.01:10;
y=1./(1+e.^(-x));
plot(x,y);
```

##### 决策边界（Decision Boundary）

* $$h_\theta(x)\ge0.5$$我们预测$$y=1$$； $$h_\theta(x)\lt0.5$$我们预测$$y=0$$
* 根据$$g(z)$$函数的特性，如果$$g(z)\ge0.5$$，则$$z\ge 0$$，即$$\theta^Tx\ge 0$$
* 决策边界即为$$y=1$$和$$y=0$$分割线

> 例如：$$\theta^Tx=-3+x_1+x_2$$，令$$y=1$$，则$$-3+x_1+x_2\ge0$$，由此函数可以得到$$x1, x2$$平面内的一条直线为决策边界<br/>
> 若函数$$z$$为非线性，比如$$z=-1+x_1^2+x_2^2$$，则决策边界为一个圆

##### 代价函数

* 如果使用线性回归中的代价函数，则$$J(\theta)$$呈现为波浪型，即有许多的局部最小值；此函数称为非凸函数（Non-convex function）

* 所以使用以下代价函数

$$\class{myMJSmall}{J(\theta)=\frac{1}{m}\sum_{i=1}^{m}Cost(h_\theta(x^{(i)}),y^{(i)})\\
Cost(h_\theta(x),y) = 
 \begin{cases} 
 −log(h_\theta(x)),  & y=1 \\ 
 -log(1-h_\theta(x)), & y=0  \\ 
\end{cases}}
$$

> 样本中$$y=1$$，如果$$h_\theta(x)$$求得结果也为1，则结果与预测吻合，代价函数值为0；如果$$h_\theta(x)$$求得结果为0，表示结果与预测相违背，代价函数值为无穷大。<br/>
> $$y=0$$同理

* 简化代价函数

$$\class{myMJSmall}{J(\theta)=-\frac{1}{m}\sum_{i=1}^{m}\left[y^{(i)}log(h_\theta(x^{(i)})) + (1-y^{(i)})log(1-h_\theta(x^{(i)}))\right]}$$

* 梯度下降

$$\class{myMJSmall}{\theta_j = \theta_j-\alpha\frac{\partial}{\partial\theta_j}J(\theta) \\ 
\text{其中} \frac{\partial}{\partial\theta_j}J(\theta) = \frac{1}{m} \sum_{i=1}^m (h_\theta(x^{(i)}) - y^{(i)}) x_j^{(i)} \\
\text{矩阵表示}\theta := \theta - \frac{\alpha}{m} X^{T} (g(X \theta ) - \vec{y})
}
$$

> 形式与线性回归一致，证明 todo

##### 高级优化

* 其它优化算法

> Conjugate gradient（共轭梯度法）<br/>
> BFGS（变尺度法）<br/>
> L_BFGS（限制变尺度法）

* 特点

> 不用手动选择$$\alpha$$<br/>
> 一般来说比梯度下降法快<br/>
> 但是更加复杂

* 使用Octave提供的这些算法

> fminunc @todo



##### 多分类分类问题（Multiclass Classification/One Vs All）

$$\class{myMJSmall}{y \in \{0,1\cdots,n\}}$$

* 将此分类问题转化成n+1个二元分类问题，即多个$$h_\theta(x)$$函数，每一个计算属于当前分类的概率，取概率最大的$$y$$值为预测值


$$\class{myMJSmall}{
	h_\theta^{(0)}(x) = P(y=0\mid x; \theta) \\
	h_\theta^{(1)}(x) = P(y=1\mid x; \theta) \\
	\vdots \\
	h_\theta^{(n)}(x) = P(y=n\mid x; \theta) \\
	precdition = \max_i(h_\theta^{(i)}(x))
}$$




---


### Lecture2: Solving the Problem of Overfitting

#### 过拟合问题（Overfitting）

* 如果特征太多，那么假设函数的曲线会通过每一样本（每一个样本按假设函数算出来的y值都与样本的y值一致），即$$J(\theta)=\frac{1}{2m}\sum_{i=1}^{m}(h_\theta(x^{(i)})-y^{(i)})^2\approx 0$$，但是不能泛化(generalize)到新样本。

![fitting](/assets/images/overfitting.png)

> 上图1，欠拟合（Underfitting），或者高偏差（High bias）<br/>
> 上图2，拟合效果很好（Just right）<br/>
> 上图3，过拟合（Overfitting），或者高方差（High variance）

#### 解决过拟合问题

* 减少特征的数量

> 人工选择更重要的特征<br/>
> 模型选择算法，自动选择使用哪些特征(后续会学到)<br/>
> 缺点：舍弃特征相当于舍弃了一些信息

* 正规化(Regularization)

> 保留所有的特征，但减小$$\theta_j$$的量级<br/>
> 当有很多特征，并且每一个特征都对结果有点贡献时，正规化可以很好的工作


#### 正规化

##### 正规化线性回归
* 修改代价函数

$$\class{myMJSmall}{J(\theta)=\frac 1{2m}\left[\sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})^2 + \lambda\sum_{j=1}^n\theta_j^2\right]}$$

> $$\lambda$$称为正规化参数（regularization parameter），如果$$\lambda$$很小，则求出来的$$\theta$$会很好的拟合样本数据（过拟合），如果$$\lambda$$很大，则$$\theta$$会变得很小，求出来的结果会是较光滑的曲线。


* 梯度下降

$$\class{myMJSmall}{
 \begin{cases} 
	\theta_0 = \theta_0 - \frac{\alpha}{m}\sum_{i=1}^{m}(h_\theta(x^{(i)})-y^{(i)})x_0^{(i)} & j=0 \\
	\theta_j = \theta_j - \frac{\alpha}{m} \left[ \left( \sum_{i=1}^{m}(h_\theta(x^{(i)})-y^{(i)})x_j^{(i)} \right) +\lambda\theta_j \right] & j \in \{1,2\cdots,n\} \\
 \end{cases}
}$$

> 当$$j\ge1$$时，式子可以写成$$\theta_j = \theta_j(1-\alpha\frac{\lambda}{m}) - \frac{\alpha}{m}\sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})x_j^{(i)}$$，可以看出来正规化后，每一次迭代$$\theta_j$$都会比无正规化前小一点。


* 正规方程

$$\class{myMJSmall}{
	\theta = (X^TX+\lambda\cdot L)^{-1}X^Ty \\
L = \begin{bmatrix}
 0 & & & & \\
 & 1 & & & \\
 & & 1 & &\\
 & & & \ddots & \\
 & & &  & & 1 \\
  \end{bmatrix} \in \mathbb{R^{(n+1)x(n+1)}}
	
}$$

> 正规化之后由于添加了$$\lambda\cdot L$$使得原来可能不可逆的$$X^TX$$变得可逆了

##### 正规化逻辑回归

* 代价函数

$$\class{myMJSmall}{
	J(\theta) = -\frac{1}{m}\sum_{i=1}^{m} \left[ 
			y^{(i)}log(h_\theta(x^{(i)})) + (1-y^{(i)})log(1-h_\theta(x^{(i)}))
		\right] 
		+ \frac{\lambda}{2m}\sum_{j=1}^{n}\theta_j^2
}$$

* 梯度下降的方程与线性梯度下降方程一致

$$\class{myMJSmall}{
 \begin{cases} 
	\theta_0 = \theta_0 - \frac{\alpha}{m}\sum_{i=1}^{m}(h_\theta(x^{(i)})-y^{(i)})x_0^{(i)} & j=0 \\
	\theta_j = \theta_j - \frac{\alpha}{m} \left[ \left( \sum_{i=1}^{m}(h_\theta(x^{(i)})-y^{(i)})x_j^{(i)} \right) +\lambda\theta_j \right] & j \in \{1,2\cdots,n\} \\
 \end{cases}
}$$


##### 学习资料

[课件和笔记](http://pan.baidu.com/s/1hsGETb2)
[Octave编程作业](https://github.com/xiaochai/ml_assignment)
