---
layout: post
title: "机器学习课程备忘(Week1)"
date: 2017-5-12
categories:
  - Tech
description: 
image: http://wx2.sinaimg.cn/mw1024/6a1f6674ly1ffrwr3jywej21kw0tkk56.jpg
image-sm: http://wx2.sinaimg.cn/mw1024/6a1f6674ly1ffrwr3jywej21kw0tkk56.jpg
---
<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

### Lecture1: Introduce

#### 机器学习定义

*Arthur Samuel(1959), informal definition:* 

> The field of study that gives computers the ability to learn without being explicitly programmed.

*Tom Mitchell(1998), modern definition:*

> A computer program is said to learn from experience E with respect to some class of tasks T and performance measure P, if its performance at tasks in T, as measured by P, improves with experience E.

#### 机器学习分类

##### 监督学习(Supervised Learning)

*定义：给出的机器学习样本集含有正确的答案（标签）*

*细分*

> 回归问题(Regression): 预测值是连续的 ====> 房价预测问题<br/>
> 分类问题(Classification): 预测值为离散 ====> 恶性和良性肿瘤问题

##### 无监督学习(Unsupervised Learning)

*定义：给出的样本集没有标签*

*细分*

> 聚类算法(Clustering): 谷歌新闻汇聚 <br/>
> 非聚类算法(Non-clustering): 鸡尾酒会问题（Cocktail Party Algorithm）$$[W,s,v] = svd((repmat(sum(x.*x,1),size(x,1),1).*x)*x');$$

##### 其它

> Reinforcement Learning, Recommender Systems

---

### Lecture2: Linear Regression with One Variable

#### 单变量线性回归(Linear Regression with One Variable)

##### 符号

> m: 样本数量<br/>
> x: 输入变量/特征<br/>
> y: 输出变量/目标变量<br/>
> (x,y): 一个样本<br/>
> $$(x^{(i)}, y^{(i)})$$: 第i行样本，有时写做$$(x_i, y_i)$$

##### 预测函数(Hypothesis)

$$\class{myMJSmall}{h_\theta(x)=\theta_0+\theta_1*x}$$

##### 代价函数(Cost Function/Squared Error Function/Mean Squared Error)

$$\class{myMJSmall}{J(\theta_0,\theta_1)=\frac 1{2m}\sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})^2}$$


> 目标：求出使得$$J(\theta_0, \theta_1)$$最小的$$\theta_0, \theta_1$$的值


##### 梯度下降(Gradient descent)

*流程：选定初值$$\theta_0, \theta_1$$（比如$$\theta_0=0, \theta_1=1$$）,不断改变（同时地）$$\theta_0,\theta_1$$，来减少$$J(\theta_0,\theta_1)$$的值，直到收敛（局部最小值）。*

$$\class{myMJSmall}{\theta_j := \theta_j - \alpha \frac{\partial}{\partial \theta_j} J(\theta_0, \theta_1)}$$

> 导数表示函数曲线切线的斜率。当为正数时，曲线趋势为上升，所以取函数最小值应减少$$x$$(此时为$$\theta$$)；当为负数时，应加大$$x$$的值。偏导亦如此。这就是上面公式所表达的函数。<br/>
> $$\alpha$$: learning rate。当选择过大时，可能无法收敛; 当选择太小时，需要迭代多次才能收敛。


##### 计算：$$ \class{myMJSmall}{\frac{\partial}{\partial \theta_1} J(\theta_0, \theta_1) = \frac{1}{m} \sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})x^{(i)}}$$

* 两个函数相加的导数等于两个函数的导数相加$$(f(x)+g(x))' = f'(x) + g'(x)$$

> 根据定义$$f'(x) = lim_{\Delta x\rightarrow0}\frac{f(x+\Delta x)-f(x)}{\Delta x} \\$$
> 所以 $$(f(x)+g(x))' = lim_{\Delta x\rightarrow0}\frac{f(x+\Delta x)+g(x+\Delta x)-(f(x)+g(x))}{\Delta x} \\
> f'(x)+g'(x) = lim_{\Delta x\rightarrow0}\frac{f(x+\Delta x)-f(x)}{\Delta x} + lim_{\Delta x\rightarrow0}\frac{g(x+\Delta x)-g(x)}{\Delta x} \\
>             = lim_{\Delta x\rightarrow0}\frac{f(x+\Delta x)-f(x)+g(x+\Delta x)-g(x)}{\Delta x} \\$$
> 所以 $$(f(x)+g(x))' = f'(x)+g'(x)$$

* 链式求导法则:$$(f(g(x)))' = f'(g(x))g'(x)$$ or $$\frac{dy}{dx} = \frac{dy}{dz}\frac{dz}{dx} $$

> 证明：todo

* 计算：

> 过程如下：$$\frac{\partial}{\partial \theta_1} J(\theta_0, \theta_1) = \frac{\partial}{\partial \theta_1} \frac{1}{2m} \sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})^2 \\
> = \frac{\partial}{\partial \theta_1} \frac{1}{2m} \sum_{i=1}^m(\theta_0+\theta_1 x_i-y_i)^2 \\
> = \frac{\partial}{\partial \theta_1} \frac{1}{2m} ((\theta_0+\theta_1 x^{(1)} -y^{(1)})^2+ \cdots + (\theta_0+\theta_1 x^{(m)} - y^{(m)})^2) \\
> = \frac{\partial}{\partial \theta_1} \frac{1}{2m} (\theta_0+\theta_1 x^{(1)} -y^{(1)})^2 + \cdots + \frac{\partial}{\partial \theta_1} \frac{1}{2m} (\theta_0+\theta_1 x^{(m)} -y^{(m)})^2 \\ 
> = \frac{\partial(\frac{1}{2m}(\theta_0+\theta_1 x^{(1)} -y^{(1)})^2)}{\partial(\theta_0+\theta_1 x^{(1)} -y^{(1)})} \cdot \frac{\partial(\theta_0+\theta_1 x^{(1)} -y^{(1)})}{\partial\theta_1} + \cdots + \frac{\partial(\frac{1}{2m}(\theta_0+\theta_1 x^{(m)} -y^{(m)})^2)}{\partial(\theta_0+\theta_1 x^{(m)} -y^{(m)})} \cdot \frac{\partial(\theta_0+\theta_1 x^{(m)} -y^{(m)})}{\partial\theta_1}\\
> = \frac{1}{m}(\theta_0+\theta_1 x^{(1)} - y^{(1)}) \cdot x^{(1)} + \cdots + \frac{1}{m}(\theta_0 + \theta_1 x^{(m)} - y^{(m)}) \cdot x^{(m)} \\
> = \frac{1}{m}\sum_{i=1}^m(\theta_0+\theta_1 x^{(i)}+y^{(i)})x^{(i)} \\
> = \frac{1}{m}\sum_{i=1}^m(h_\theta(x^{(i)}) - y^{(i)})x^{(i)}
> $$

* 由于每一次迭代都要对所有的样本进行计算，所以梯度下降也叫批量梯度下降(Batch Gradient Descent)

<br/>
*当j=0时*

$$\class{myMJSmall}{\frac{\partial}{\partial \theta_0} J(\theta_0, \theta_1) = \frac{1}{m} \sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})}$$

*当j=1时*

$$\class{myMJSmall}{\frac{\partial}{\partial \theta_1} J(\theta_0, \theta_1) = \frac{1}{m} \sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})x^{(i)}}$$



##### 代价函数的图像

*线性回归的代价函数($$J(\theta)$$) 总是一个碗形(bow shaped function)，这种函数叫做凸函数(convex function)。*


---

### Lecture3: Matrices and vectors

##### 矩阵(Matrix)与向量(Vector)

* 矩阵：$$m\times n$$矩阵，有$$m$$行，$$n$$列;表示为$$A$$（大写）。第$$i$$行$$j$$列的元素表示成$$A_{ij}$$。

* 向量：$$n\times 1$$矩阵，表示为$$y$$（小写）。第$$i$$行元素表示为$$y_i$$。

* 矩阵相加：必须维度相同，各对应元素相加（减法同理）。

* 矩阵标量乘法：当一个实数乘以一个矩阵时，结果为这个矩阵的每一个元素与这个实数相乘（除法同理）。

* 两矩阵相乘

> $$A\times B$$ 必须满足$$A$$的列与$$B$$的行数相等。如果$$A$$为$$m\times n$$，$$B$$为$$n \times o$$，那么结果矩阵$$C$$为$$m\times o$$，并且$$C_{ij}=A_{i1}*B_{1j}+A_{i2}*B_{2j}+\cdots+A_{in}*B_{nj}$$。<br/>
> 一般情况下：$$A\times B \not= B\times A$$<br/>
> $$A\times B \times C = A\times (B \times C)$$


* 单位矩阵($$I$$)：$$A\times I = I\times A$$。$$I$$为$$n$$维方阵，并且对角线值为1，即$$I_{ii} = 1; i \in [1,n]$$。

* 矩阵的逆：$$A$$为$$m$$维方阵，$$A^{-1}$$为矩阵的逆，那么$$A\times A^{-1} = I$$。并非所有的方阵都有逆，没有逆的方阵叫做奇异矩阵（Singular）或者退化矩阵（degenerate）。

* 矩阵转置：表示为$$A^T$$，其中$$A_{ij} = A^T_{ji}$$。


##### 学习资料

[课件和笔记](/assets/material/ml/)
