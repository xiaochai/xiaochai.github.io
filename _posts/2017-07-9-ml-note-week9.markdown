---
layout: post
title: "机器学习(Week9)-误差检测与推荐系统(Anomaly Detection & Recommender Systems)"
date: 2017-07-09
categories:
  - Tech
description: 
image: /assets/images/recom_system.jpg
image-sm: /assets/images/recom_system.jpg
---
<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

### Lecture1: Anomaly Detection

##### 问题描述

> 给出一组样本数据$${x^{(1)}, x^{(2)},\dots,x^{(m)}}$$<br/>
> 给出一个新的样本数据$$x_{test}$$，判断这个样本数据是否为异常数据（abnormal/anomalous）

##### 模型

> 定义一个模型$$p(x)$$表示这个样本为正常样本的概率，定义一个阈值$$\epsilon$$，做为正常样本和异常样本的分界线，即如果$$p(x) \lt \epsilon $$，则样本$$x$$为异常样本

##### 例子

> 诈骗检测:<br/>
> $$x^{(i)}$$表示用户i的行为采样数据<br/>
> 从已有数据中学习出模型$$p(x)$$<br/>
> 从中找出$$p(x) \lt \epsilon$$的用户即为可疑用户<br/>
> 如果我们找出太多的异常用户，那么我们要适当减少$$\epsilon$$的值

#### 高斯分布（Gaussian Distribution）

> 高斯分布为一个钟型的曲线，表示为$$\mathcal{N}(\mu,\sigma^2)$$<br/>
> 对于一个变量$$x \in \mathbb{R}$$，如果它的概率分布服务从高斯分布，则表示为

$$\class{myMJSmall}{x \sim \mathcal{N}(\mu, \sigma^2)}$$

> 其中$$\mu$$为均值，也是高斯曲线的最高点，$$\sigma^2$$为方差，$$\sigma$$为标准差，体现为高斯曲线的胖廋程度<br/>
> 高斯函数的具体表示形式为：<br/>

$$\class{myMJSmall}{
	p(x;\mu,\sigma^2) = \frac{1}{\sigma \sqrt{(2\pi)}} exp(-\frac{(x-\mu)^2}{2\sigma^2})
}$$

> 我们从样本中可以直接通过以下式子算出$$\mu，\sigma^2$$<br/>

$$\class{myMJSmall}{
	\mu = \frac{1}{m}\sum^m_{i=1}x^{(i)} \\
	\sigma^2 = \frac{1}{m}\sum^m_{i=1}(x^{(i)} - \mu)^2
}$$

##### 模型定义和算法

> 给出一个样本集合$${x^{(1)}, x^{(2)},\dots,x^{(m)}}$$，其中$$x \in \mathbb{R}^n$$，则：<br/>

$$\class{myMJSmall}{
	p(x) = p(x_1;\mu_1,\sigma_1^2)p(x_2;\mu_2,\sigma^2_2)\cdots p(x_n;\mu_n,\sigma^2_n)
}$$

> 也可以写成如下形式:<br/>

$$\class{myMJSmall}{
	p(x) = \displaystyle \prod^n_{j=1} p(x_j;\mu_j,\sigma_j^2)
}$$

> 以上式子是基于每一个样本特征都是独立互不相关的独立性假设（independence assumption），虽然实际中这样样本特征并不一定是毫不相关的，但以上算法在实际中表示不错<br/>

* 整体算法描述

> 选择觉得可以指示是否异常的特征$$x_i$$，假设选出n个特征<br/>
> 根据公式$$\mu_j = \frac{1}{m}\sum^m_{i=1}x^{(i)}_j，\sigma_j^2 = \frac{1}{m}\sum^m_{i=1}(x^{(i)}_j - \mu_j)^2$$，算出对应特征的高斯函数$$p(x_j;\mu_j,\sigma_j^2)$$<br/>
> 给出一个样本$$x$$，根据$$p(x) = \displaystyle \prod^n_{j=1} p(x_j;\mu_j,\sigma_j^2)$$，算出$$p(x)$$，如果$$p(x) \lt \epsilon$$，则样本异常

#### 开发与评估异常检测系统

> 为了评估算法，我们需要一些带标签数据，$$y=0$$的数据表示正常数据，$$y=1$$表示异常的数据<br/>
> 这些数据中，取一大部分正常的数据用来训练$$p(x)$$模型，剩下的既有正常和非正常的样本数据，分成两组成为交叉验证集合和测试集。

##### 算法评估

> 使用训练集合训练出模型$$p(x)$$<br/>
> 使用交叉验证集样本数据和训练出来的$$p(x)$$，如果$$p(x) \lt \epsilon$$，预测$$y = 1$$<br/>
> 根据交叉验证集算出来的y值和样本真实的y值，算出查准率和召回率（F1分数）（见[偏斜类](/2017/06/04/ml-note-week6/#skewed-classes)）。
> 取不同的$$\epsilon$$，取F1分数高的$$\epsilon$$值

#### 错误检测与监督学习

##### 使用错误检测的情况

> 样本中只有一小部分的正样本($$y=1$$)，大部分都是负样本($$y=0$$)<br/>
> 引发异常的原因多样，无法从正样本中学习出异常引发的特征。而且新出现的异常与之前的异常样本没有相似的地方<br/>

#### 使用监督学习的情况

> 有大量的正负样本数据<br/>
> 有足够的正样本来学习出新的异常数据特征，即新异常数据与正样本数据有相同的特征<br/>

#### 选择特征

> 选择不同的特征很大程度上影响异常检测系统的工作情况<br/>

> 画出特征的直方图来确认分布是否为高斯分布<br/>
> 如果不是高斯分布的特征，可以通过$$log(x), log(x+1), log(x+x), \sqrt{x}, x^{\frac{1}{3}}$$等转换函数使其符合高斯分布<br/>

##### 错误分析

> 错误检测的目标是对于正常的样本，p(x)应该很大，异常的样本p(x)很小<br/>
> 一个常见的问题是，不论对于正常样本和异常样本，p(x)都很大。此时应该检查样本，看是否有一些新的特征能更好的区分正常和非正常数据 <br/>

#### 多元高斯分布（Multivariate Gaussian Distribution）

> 不再对每个特征训练出一个p(x)模型，而是所有的特征都合并在一起：<br/>

$$\class{myMJSmall}{
	p(x;u, \Sigma) = \frac{1}{(2\pi)^{\frac{n}{2}}|\Sigma|^{\frac{1}{2}}}exp(-\frac{1}{2}(x-\mu)^T\Sigma^{-1}(x-\mu))
}$$

> 其中$$\mu \in \mathbb{R}^n, \Sigma \in \mathbb{R}^{n \times n}$$，$$\Sigma$$是协方差矩阵(covariance matrix)<br/>
> 多元高斯分布模型可以表示出非平等于轴线的高斯分布数据，可以更好的拟合样本数据<br/>

#### 使用多元高斯分布实现错误检测

> 参数$$\mu = \frac{1}{m}\sum^m_{i=1}x^{(i)}，\Sigma = \frac{1}{m}\sum^{m}_{i=1}(x^{(i)} - \mu)(x^{(i)} - \mu)^T$$<br/>
> 有了p(x)函数之后，就与普通的错误检测系统一样，如果$$p(x) \lt \epsilon$$则预测为异常数据<br/>

> 多元高斯分布可以自动捕获不同特征之间的关系，但计算量更大，在特征量很大并且样本数据太小时，$$\Sigma$$可能成为奇异矩阵，不可逆<br/>


### Lecture2: Recommender Systems

#### 常用表示法

> 在一个给电影打分的网站，我们以以下符号表示对应的函义：<br/>
> $$n_u$$表示用户数量<br/>
> $$n_m$$表示电影数量<br/>
> $$r(i,j)$$，如果值为1，表示用户i对电影j打过分<br/>
> $$y(i,j)$$表示用户i对电影j打的分数，只有当$$r(i,j) = 1$$时才有定义

#### 基于内容的推荐

> 引入两个特征$$x_1, x_2$$分别表示电影中爱情和动作的成分比例<br/>
> 对于某个人对电影的分数预测，可以转化为线性回归问题: 对应用户j，学习得到参数$$\theta^{(j)} \in \mathbb{R}^3$$，使用$$(\theta^{(j)})^Tx^{(i)}$$来预测用户j对电影i的评分<br/>

> $$\theta^{(j)}$$为用户j的参数向量<br/>
> $$x^{(i)}$$为电影i的特征向量<br/>
> $$m^{(j)}$$为用户j评分的电影数量<br/>

##### 求用户的参数向量

$$\class{myMJSmall}{
min_{\theta^{(j)}} = \dfrac{1}{2}\displaystyle \sum_{i:r(i,j)=1} ((\theta^{(j)})^T(x^{(i)}) - y^{(i,j)})^2 + \dfrac{\lambda}{2} \sum_{k=1}^n(\theta_k^{(j)})^2
}$$

> 以上式子即为线性回归<br/>
> 注意以上第一部分的求和，只是对用户有评分的电影进行计算$$r(i,j)=1$$。<br/>

> 对所有的用户求参数$$\theta$$: 

$$\class{myMJSmall}{
	min_{\theta^{(1)},\dots,\theta^{(n_u)}} = \dfrac{1}{2}\displaystyle \sum_{j=1}^{n_u}  \sum_{i:r(i,j)=1} ((\theta^{(j)})^T(x^{(i)}) - y^{(i,j)})^2 + \dfrac{\lambda}{2} \sum_{j=1}^{n_u} \sum_{k=1}^n(\theta_k^{(j)})^2
}$$

> 使用线性回归的求法，即可算出所有的$$\theta$$参数<br/>
> 与线性回归唯一不同的是，以上公式没有$$\frac{1}{m}$$项

#### 协同过滤（Collaborative Filtering）

> 基于内容的推荐有个缺点，就是必须对每一部电影找出他的爱情成分和动作成分。这一般比较难。<br/>
> 我们可以让用户告诉我们他们对不同题材电影的喜欢程度，这相当于知道了参数$$\theta$$<br/>
> 根据用户参数，使用以下公式可以推导出每一个电影的成分特征向量$$x^{(i)}$$<br/>

$$\class{myMJSmall}{
	min_{x^{(1)},\dots,x^{(n_m)}} \dfrac{1}{2} \displaystyle \sum_{i=1}^{n_m}  \sum_{j:r(i,j)=1} ((\theta^{(j)})^T x^{(i)} - y^{(i,j)})^2 + \dfrac{\lambda}{2}\sum_{i=1}^{n_m} \sum_{k=1}^{n} (x_k^{(i)})^2
}$$

> 如果我们使用一个随机的$$\theta$$，推导出对应的x，然后再使用推导出来的x，再推导出更好的$$\theta$$，如此反复，最终会收敛一组相当不错的用户和电影的特征向量<br/>

##### 算法描述

> 为了加快算法执行，我们可以将之前推导x和$$\theta$$两个步骤合并成一部，同时的计算用户参数和电影特征：
$$\class{myMJSmall}{
	J(x,\theta) = \dfrac{1}{2} \displaystyle \sum_{(i,j):r(i,j)=1}((\theta^{(j)})^Tx^{(i)} - y^{(i,j)})^2 + \dfrac{\lambda}{2}\sum_{i=1}^{n_m} \sum_{k=1}^{n} (x_k^{(i)})^2 + \dfrac{\lambda}{2}\sum_{j=1}^{n_u} \sum_{k=1}^{n} (\theta_k^{(j)})^2
}$$

> 以上式子中的x不包含偏置单元$$x_0 = 1$$，所以$$x \in \mathbb{R}^n, \theta \in \mathbb{R}^n$$<br/>

##### 求解步骤

> 使用小随机数初使化x和$$\theta$$ <br/>
> 使用梯度下降或者其它优化方法最小化函数J，其中：

$$\class{myMJSmall}{
	x_k^{(i)} := x_k^{(i)} - \alpha\left (\displaystyle \sum_{j:r(i,j)=1}{((\theta^{(j)})^T x^{(i)} - y^{(i,j)}) \theta_k^{(j)}} + \lambda x_k^{(i)} \right)\\
	\theta_k^{(j)} := \theta_k^{(j)} - \alpha\left (\displaystyle \sum_{i:r(i,j)=1}{((\theta^{(j)})^T x^{(i)} - y^{(i,j)}) x_k^{(i)}} + \lambda \theta_k^{(j)} \right)
}$$

> 使用算出来的x和$$\theta$$，即可预测用户对一部电影的评分

#### 低秩矩阵分解（Low Rank Matrix Factorization）

> $$X \in \mathbb{R}^{n_m \times n}$$表示所有电影的特征向量<br/>
> $$\Theta \in \mathbb{R}^{n_u \times n} $$表示所有用户的参数<br/>
> 则所有用户对所有电影的预测分矩阵为$$Y=X\Theta^T$$<br/>

> 如果一个用户喜欢电影j，则我们可以推荐与电影j相似的另外一部电影给观众。相似的程度表示为两部电影的特征向量距离：$$\|x^{(k)} - x^{(j)}\|$$


#### 其它实现细节

> 对于一个没有任何评分记录的用户，使用协同过滤算出来的$$\theta$$为0，导致预测他对所有电影的评分都为0

> 可以使用均值归一化的方法来解决此问题:<br/>
> 算出电影的平均得分$$\mu$$，将现有用户的评分减去$$\mu$$，得到一个新的评分矩阵<br/>
> 使用此新的矩阵训练出x和$$\theta$$<br/>
> 预测得分的公式变成$$(\theta^{(j)})^T x^{(i)} + \mu_i$$<br/>

> 使用均值归一化之后，对于没有任何评分记录的用户，预测出来的对一部电影的评分为这个电影的平均分<br/>

##### 学习资料

[课件和笔记](http://pan.baidu.com/s/1hsGETb2)
[Octave编程作业](https://github.com/xiaochai/ml_assignment)

