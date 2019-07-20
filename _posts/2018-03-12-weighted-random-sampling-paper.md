---
layout: post
title: "加权随机抽样"
date: 2018-03-12
categories:
  - Tech
description: 
image: https://wx1.sinaimg.cn/large/6a1f6674gy1fpp4if4yrvj20xc0kitd1.jpg
image-sm: https://wx1.sinaimg.cn/large/6a1f6674gy1fpp4if4yrvj20xc0kitd1.jpg
---

<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

原论文《Weighted Random Sampling》来自Efraimidis、Spiraki， 发表于2005年，以下为部分翻译

### 问题定义

不放回随机抽样（random sampling without replacement(RS)）问题要求从大小为$$n$$的集合中，随机抽取$$m$$个不同元素。如果所有的元素被抽取出来的概率一致，则称之为均匀随机抽样（uniform RS）。一次遍历解决均匀随机抽样问题在推荐阅读的[1,5,10]中有讨论。在数据流上使用蓄水池类型（Reservoir-type）均匀随机抽样算法在推荐阅读[11]给出。推荐阅读[9]给出了一种可并行计算的均匀随机抽样算法。对于加权随机抽样（weighted random smapling(WSR)），它指的是所有元素都含有权重，每一个元素被取出的概率是由元素本身的权重决定的。WSR问题可以使用以下算法D来定义:

#### 算法D，WRS定义

<strong>输入：含有$$n$$个带权重元素的集合$$V$$</strong>

<strong>输出：含有$$m$$个元素的加权随机抽样结果集$$S$$</strong>

&nbsp;&nbsp;&nbsp;&nbsp;1： for $$k = 1$$ to $$m$$ do <br/>
&nbsp;&nbsp;&nbsp;&nbsp;2： &nbsp;&nbsp;&nbsp;&nbsp;元素$$v_i$$在第$$k$$回合被选出来的概率为$$p_i(k)=\frac{w_i}{\sum_{s_j\in V-S} w_j}$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;3： &nbsp;&nbsp;&nbsp;&nbsp;从$$V-S$$中选出$$v_i$$，然后插入到S中<br/>
&nbsp;&nbsp;&nbsp;&nbsp;4： End-For

<br/>


加权随机抽样（WRS）中最重要的算法有Alias Method, Partial Sum Trees 和 the Acceptance/Rejection method（推荐阅读[8]包含了WRS问题的解决算法汇总）。但这些算法皆非一次遍历算法（one-pass)。这篇论文中将展示一种简单的，非常灵活的解决WRS问题的方法。该方法可以基于数据流运行，并且此方法支持并行和分布式计算。以作者所知（To the best knowledge of the entry authors），这是第一个可以解决数据流的WRS算法，也是第一个能够支持并行、分布式运算的WRS算法。

<strong>定义：</strong>所谓一次遍历WRS(One-pass WRS)是指只对元素集合进行一次遍历即可完成加权随机抽样的WRS算法。如果这个集合的大小是不确定的（例如数据流），可以使用蓄水池类型抽样算法来解决。这种算法使用一组额外空间（蓄水池）来保存最后结果的候选元素。

<strong>符号与假设：</strong>开始时所有元素的权重是未知的正实数。总集合的大小为$$n$$，抽样$$m$$个元素。元素$$v_i$$的权重为$$w_i$$。函数$$random(L,H)$$产生$$(L,H)$$之间的随机数。$$X$$表示随机变量。假设支持无限精度计算。在无特别说明时，本文所指的抽样都是不放回抽样。WRS这个名词可以用作抽样的结果，或者抽样的操作过程，视上下文而定。

### 关键结果

WRS方法的关键工作如下，姑且称之为算法A:

##### 算法A

<strong>输入：含有$$n$$个带权重元素的集合$$V$$</strong>

<strong>输出：$$m$$个元素的加权随机抽样结果</strong>

&nbsp;&nbsp;&nbsp;&nbsp;1：对于任意的$$v_i \in V$$, $$u_i = random(0, 1)$$，$$k_i = u_i^{\frac{1}{w}}$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;2：选取$$m$$个$$k_i$$最大的元素做为WRS

##### 定理1. 算法A可获得一个WRS结果

以下使用蓄水池类型适配的算法A，我们称之为A-Res算法（algorithm A-Res）：

#### 使用蓄水池适配的算法A（Algorithm A With a Reservoir(A-Res)）

<strong>输入：含有$$n$$个带权重元素的集合$$V$$</strong>

<strong>输出：存储有$$m$$个元素的加权随机抽样结果的蓄水池空间$$R$$</strong>

&nbsp;&nbsp;&nbsp;&nbsp;1: 将$$V$$的前m个元素直接插入$$R$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;2: 对于$$v_i\in R$$：计算关键值（key）$$k_i = u_i^{\frac{1}{w_i}}$$，其中$$u_i=random(0,1)$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;3: 让$$i$$依次等于$$m+1, m+2, ... , n$$，执行4到7步骤<br/>
&nbsp;&nbsp;&nbsp;&nbsp;4: &nbsp;&nbsp;&nbsp;&nbsp;计算$$R$$中的最小关键值做为当前的阈值$$T$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;5: &nbsp;&nbsp;&nbsp;&nbsp;计算$$v_i$$的关键值$$k_i = u_i^{\frac{1}{w_i}}$$，其中$$u_i = random(0,1)$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;6: &nbsp;&nbsp;&nbsp;&nbsp;如果$$k_i > T$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;7: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;则将R中关键值最小的元素使用$$v_i$$代替


算法A-Res使用了算法A来计算生成了加权抽样结果。下面的命题给出此算法集合$$R$$的操作次数:

##### 定理2. 如果A-Res作用在$$n$$个权重($$w_i$$)大于0的元素上，且$$w_i$$为一般连续分布(common continuous distribution)的独立随机数，则集合$$R$$的插入操作次数预期为（不包括前m个元素的插入）：

$$\class{myMJSmall}{
\sum_{i=m+1}^{n}P[第i个元素被插入S] = \sum_{i=m+1}^{n}\frac{m}{i} = O(m \times log(\frac{n}{m}))
}$$

令$$S_w$$为被A-Res算法连续跳过的元素（没有插入到S）的权重之和，如果$$T_w$$为当前进入S集合的阈值，则$$S_w$$为服从指数分布的连续随机变量。所以可以使用$$S_w$$随机跳过若干元素，这样就不用对所有元素生成随机数了。同样的方法已经在均匀随机抽样中得到 应用(推荐阅读[3]中有对应的例子)。以下算法A-ExpJ是使用指数跳跃类型适配的算法A:

##### 使用指数跳跃的算法A（Algorithm A with exponential jumps(A-ExpJ)

<strong>输入：含有$$n$$个带权重元素的集合$$V$$</strong>

<strong>输出：存储有$$m$$个元素的加权随机抽样结果的蓄水池空间$$R$$</strong>

&nbsp;&nbsp;&nbsp;&nbsp;1: $$V$$的前$$m$$个元素直接插入$$R$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;2: 计算$$R$$中各个元素的关键值（即key值，$$k_i = u_i^{\frac{1}{w_i}}$$，其中$$u_i = random(0, 1)$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;3: $$R$$中最小的关键值为阈值$$T_w$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;4: 对$$V$$中剩下的元素执行5~10步骤<br/>
&nbsp;&nbsp;&nbsp;&nbsp;5:&nbsp;&nbsp;&nbsp;&nbsp;令$$r = random(0, 1)$$, $$X_w = \frac{log(r)}{log(T_w)}$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;6:&nbsp;&nbsp;&nbsp;&nbsp;从当前的元素$$v_c$$一直跳过，直到$$v_i$$满足以下条件：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;7:&nbsp;&nbsp;&nbsp;&nbsp;$$w_c+w_{c+1}+...+w_{i-1} < X_w  <= w_c+w_{c+1}+...+w_{i-1}+w_i$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;8:&nbsp;&nbsp;&nbsp;&nbsp;使用$$v_i$$替换掉$$R$$中关键值最小的元素<br/>
&nbsp;&nbsp;&nbsp;&nbsp;9:&nbsp;&nbsp;&nbsp;&nbsp;令$$t_w = T_w^{w_i}$$, $$r_2 = random(t_w, 1)$$ , $$v_i$$的关值为: $$k_i = r_2^{\frac{1}{w_i}}$$<br/>
&nbsp;&nbsp;&nbsp;&nbsp;10:&nbsp;&nbsp;&nbsp;&nbsp;算出新的阈值$$T_w$$为当前$$R$$中最小的关键值

##### 定理3. 算法A-ExpJ可获得一个WRS结果

定理2给出了使用A-ExpJ跳过的元素数量。所以使用A-ExpJ可使得随机数的生成量从原来的$$O(n)$$减少到$$O(mlog(\frac{n}{m}))$$。生成高质量的随机数有可能会有较大的性能开销，所以这个算法优化在复杂的随机抽样场景中可带来可观的性能改善

### 应用

随机抽样在计算机科学的许多应用领域都是一个基础的问题，如数据库领域（推荐阅读[4],[8]），数据挖掘，近似算法和随机算法([6])。通用工具算法A在随机算法设计中可以找到其对应的应用。如在k-Median算法的近似算法中使用了算法A(推荐阅读[6])。

基于蓄水池方式的算法A，A-Res和A-ExpJ只需要很少的额外存储（m个元素的堆），就可以使得抽样处理期间始终存储着对于已经处理过的元素的加权随机抽样，所以在数据流处理这一领域中这些算法都可以得到应用(推荐阅读[2],[7])。

算法A-Res和A-ExpJ也可以应用于对数据流的放回加权随机抽样（weighted random sampling with replacement)中。开k个A-Res和A-ExpJ进程，并行计算目标数据流的结果为1不放回随机抽样，最终的k个结果合并，即为k个放回加权随机抽样的结果。

### 推荐阅读

[1] J. H. Ahrens and U. Dieter, Sequential random sampling, ACM Trans. Math. Softw., 11 (1985), pp. 157–169.

[2] B. Babcock, S. Babu, M. Datar, R. Motwani, and J. Widom, Models and issues in data stream systems, in Proceedings of the twenty-first ACM SIGMOD-SIGACT-SIGART symposium on Principles of database systems, ACM Press, 2002, pp. 1–16.

[3] L. Devroye, Non-uniform Random Variate Generation, Springer Verlag, New York, 1986.

[4] C. Jermaine, A. Pol, and S. Arumugam, Online maintenance of very large random samples, in SIGMOD ’04: Proceedings of the 2004 ACM SIGMOD international conference on Management of data, New York, NY, USA, 2004, ACM Press, pp. 299–310.

[5] D. Knuth, The Art of Computer Programming, vol. 2 : Seminumerical Algorithms, Addison- Wesley Publishing Company, second ed., 1981.

[6] J.-H. Lin and J. Vitter, ǫ-approximations with minimum packing constraint violation, in 24th ACM STOC, 1992, pp. 771–782.

[7] S. Muthukrishnan, Data streams: Algorithms and applications, Foundations & Trends in Theoretical Computer Science, 1 (2005).

[8] F. Olken, Random Sampling from Databases, PhD thesis, Department of Computer Science, University of California at Berkeley, 1993.

[9] V. Rajan, R. Ghosh, and P. Gupta, An efficient parallel algorithm for random sampling, Information Processing Letters, 30 (1989), pp. 265–268.

[10] J. Vitter, Faster methods for random sampling, Communications of the ACM, 27 (1984), pp. 703–718.

[11] ---, Random sampling with a reservoir, ACM Trans. Math. Softw., 11 (1985), pp. 37–57.

<br/>
<hr/>

以上为简化版[论文](http://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf)，文中省略了算法的证明和详细说明。只是把实现思路陈述了下。

更详细的[论文](http://sci-hub.la/10.1016/j.ipl.2005.11.003#)里解释了概率计算与各个定理的完整计算和证明，我对其中的推倒有许多不明白的地方，所以就不给予列举，只是给出对应算法的代码实现。


##### 定义数据结构和最小堆

```go
// 元素数组结构
type Data struct {
	Condition int
	Value     int
	Weight float64 // 原生的权重
	Key    float64 // 关键值
}

// 最小堆的实现
type PHeap []*Data

func (h PHeap) Len() int{
	return len(h)
}

func (h PHeap) Less(i, j int)bool {
	return h[i].Key < h[j].Key
}

func (h PHeap)Swap(i, j int){
	h[i], h[j] = h[j], h[i]
}

func (h *PHeap)Push(x interface{}){
	d := x.(*Data)
	*h = append(*h, d)
}
func (h *PHeap)Pop()interface{}{
	item := (*h)[h.Len()-1]
	*h = (*h)[0:h.Len()-1]
	return item
}
```

#### A-Res

```go
// 加权随机抽样
func WSRARes(l *list.List, m int, cond int) []*Data{
	h := PHeap{}
	heap.Init(&h)

	for e := l.Front(); e != nil; e = e.Next() {
		data, ok := e.Value.(*Data);
		if !ok || data.Condition <= cond {
			continue;
		}
		data.Key = math.Pow(rand.Float64(), 1/data.Weight)
		if h.Len() < m {
			heap.Push(&h, data)
		} else if h[0].Key < data.Key {
			heap.Pop(&h)
			heap.Push(&h, data)
		}
	}
	return h
}
```

#### A-ExpJ

```go
func WSRExpJ(l *list.List, m int, cond int ) []*Data {
	h := PHeap{}
	heap.Init(&h)

	var XW float64
	var flightSum float64
	for e := l.Front(); e != nil; e = e.Next() {
		data, ok := e.Value.(*Data);
		if !ok || data.Condition <= cond {
			continue;
		}
		data.Key = math.Pow(rand.Float64(), 1/data.Weight)
		if h.Len() < m {
			heap.Push(&h, data)
			if h.Len() == m { // 当插入完所有元素之后，算出xw值
				XW = math.Log(rand.Float64())/ math.Log(h[0].Key)
			}
		} else if flightSum += data.Weight; flightSum >= XW {
			tw := math.Pow(h[0].Key, data.Weight)
			r2 := rand.Float64()*(1- tw) + tw
			data.Key = math.Pow(r2, 1/data.Weight)
			heap.Pop(&h)
			heap.Push(&h, data)
			flightSum = 0;
			XW = math.Log(rand.Float64())/ math.Log(h[0].Key)
		}
	}
	return h
}
```


