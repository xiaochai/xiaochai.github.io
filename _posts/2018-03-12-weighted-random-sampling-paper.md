---
layout: post
title: "加权随机抽样"
date: 2018-03-12
categories:
  - Tech
description: 
image: http://wx2.sinaimg.cn/large/6a1f6674gy1fp99we6hx9j21kw0ks7fj.jpg
image-sm: https://wx2.sinaimg.cn/mw1024/6a1f6674gy1fp99we6hx9j21kw0ks7fj.jpg
---

<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

原论文来自Efraimidis、Spiraki， 发表于2005年，以下为部分翻译

### 问题定义

不放回随机抽样（random sampling without replacement(RS)）问题要求从大小为n的集合中，随机抽取m个不同元素。如果所有的元素被抽取出来的概率一致，则称之为均匀随机抽样（uniform RS）。一次遍历解决均匀抽样问题在推荐阅读的[1,5,10]中有讨论。在数据流上使用蓄水池类型（Reservoir-type）均匀抽样算法在推荐阅读[11]给出。推荐阅读[9]给出了一种可并行计算的均匀随机抽样算法。对于加权随机抽样（weighted random smapling(WSR)），它指的是所有元素都含有权重，每一个元素被取出的概率是由元素本身的权重决定的。WSR问题可以使用以下算法D来定义:

#### 算法D，WRS定义

输入：含有n个带权重元素的集合V
输出：售有m个元素的加权抽样结果集S

1： for k = 1 to m do 
2：     元素$$v_i$$在第k回合被选出来的概率为$$p_i(k)=\frac{w_i}{\sum_{s_j\in V-S} w_j$$
3：     从$$V-S$$中选出$$v_i$$，然后插入到S中
4： End-For

加权随机抽样（WRS）中最重要的算法有Alias Method, Partial Sum Trees 和 the Acceptance/Rejection method（推荐阅读[8]包含了WRS问题的解决算法汇总）。但这些算法皆非一次遍历算法（one-pass)。这篇论文中将展示一种简单的，非常灵活的解决WRS问题的方法。该方法可以基于数据流运行，并且此方法支持并行和分布式计算。以作者所知（To the best knowledge of the entry authors），这是第一个可以解决数据流的WRS算法，也是第一个能够支持并行、分布式运算的WRS算法。

定义：所谓一次遍历WRS(One-pass WRS)是指只对元素集合进行一次遍历即可完成加权随机抽样WRS算法。如果这个集合的大小是不确定的（例如数据流），可以使用蓄水池抽样算法来解决。这种算法使用一组额外空间（蓄水池）来保存最后结果的候选元素。

符号与假设：开始时所有元素的权重是未知的正实数。总集合的大小为n，抽样m个元素。元素$$v_i$$的权重为$$w_i$$。函数random(L,H)产生（L,H）之间的随机数。X表示随机变量。假设支持无限精度计算。在无特别说明时，本文所指的抽样都是不放回抽样。WRS这个名词可以用作抽样的结果，或者抽样的操作过程，示上下文而定。

### 关键结果

WRS方法的关键工作如下，姑且称之为算法A:

#### 算法A

输入：售有n个带权重元素的集合V
输出：m个元素的加权随机抽样结果

1：对于任意的$$v_i \in V$$, $$u_i = random(0, 1)$$，$$k_i = u_i^{\frac{1}{w}}$$
2：选取m个$$k_i$$最大的元素做为WRS

定理1. 算法A可获得一个WRS结果

以下使用蓄水池类型适配的算法A，我们称之为A-Res算法（algorithm A-Res）：

使用蓄水池适配的算法A（Algorithm A With a Reservoir(A-Res)）

输入：含有n个带权重元素的集合V
输出：带有m个权重抽样结果的集合R

1：V的前m个元素直接插入R
2: 对于$$v_i\inR$$：计算关键值（key）$$k_i = U_i^{\frac{1}{w_i}$$，其中$$u_i=random(0,1)$$
3: 让i依次等于m+1, m+2, ... , n，执行4到7步骤
4:    计算R中的最小关键值做为当前的阈值T
5:    计算$$v_i$$的关键值$$k_i = u_i^{\frac{1}{w_i}$$，其中$$u_i = random(0,1)$$
6:    如果$$k_i > T$$，则将R中关键值最小的元素使用$$v_i$$代替

算法A-Res使用了算法A来计算生成了加权抽样结果。下面的命题给出此算法集合R的操作次数:

定理2. 如果A-Res做用在n个带权重的元素上，并且这些权重值大于0，且为连续分布的独立随机数，则集合R的插入操作预期为（不包括前m个元素的插入）：

$$\sum_{i=m+1}^{n}P[第i个元素被插入S] = \sum_{i=m+1}^{n}\frac{m}{i} = O(m*log(\frac{n}{m}))$$

令$$S_w$$为被A-Res算法跳过的元素（没有插入到S）的权重之和。如果$$T_w$$为当前进入S集合的阈值，则$$S_w$$为服从指数分布的连续随机变量。所以可以使用$$S_w$$随机跳过若干元素，这样就不用对所有元素生成随机数了。同样的技术 已经在均匀随机抽样中得到 应用。以下算法A-ExpJ是使用指数跳跃类型适配的算法A:

使用指数跳跃的算法A（Algorithm A with exponential jumps(A-ExpJ)

输入：含有n个带权重元素的集合V
输出：带有m个权重抽样结果的集合R

1: V的前m个元素直接插入R
2: 计算R中各个元素的关键值（即key值，$$k_i = u_i^{\frac{1}{w_i}$$，其中$$u_i = random(0, 1)
3: R中最小的关键值为阈值
4：对V中剩下的元素执行5~10步骤
5:     令r = random(0, 1)， $$X_w = log(r)/log(T_w)$$
6:     从当前的元素$$v_c$$一直跳过，直到$$v_i$$满足以下条件：
7：    $$w_c+w_{c+1}+..+w_{i-1} < X_w  <= w_c+w_{c+1}+w_






