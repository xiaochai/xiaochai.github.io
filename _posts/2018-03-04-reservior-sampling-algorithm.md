---
layout: post
title: "蓄水水池抽样---从未知长度的序列中随机抽取m个元素"
date: 2018-03-04
categories:
  - Tech
description: 
image: /assets/images/sina/3c47988184eb6f93c5ddc211fa14bf5b.jpg
image-sm: /assets/images/sina/73ff8fe862fac07682ab608589dcd758.jpg
---

<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

在遇到问题时，突然发现了一种精妙的算法，那可真谓是美丽的邂逅。

### 场景描述

在一个链表(l)里，随机获取m个元素，这m个元素满足给定的条件，并且保证所有满足条件的元素被取出来的概率相等。假设满足条件的元素个数为n，则每一个元素被取出的概率为$$\frac{m}{n}$$

### 解法

```go
package main

import (
	"container/list"
	"math/rand"
)
// 假定目标的数据结构
type Data struct {
	Condition int
	Value     int
}

func ReservoirSample(l *list.List, m int, cond int) []*Data {
	var des []*Data
	i := 1
	for e := l.Front(); e != nil; e = e.Next() {
		data, ok := e.Value.(*Data);
		if !ok || data.Condition <= cond {
			continue;
		}
		if i <= m {
			des = append(des, data)
		} else {
			if pos := rand.Intn(i); pos < m {
				des[pos] = data
			}
		}
		i++
	}
	return des
}
```

### 算法描述

先取出前$$m$$个满足条件的元素放入$$des$$数组中，遍历剩下的链表，对于满足条件的第$$i$$个元素，则生成一个$$[0,i)$$的随机数$$pos$$，如果$$pos < m$$，使用第$$i$$个元素替换目前$$des$$中的随机一个元素，否则保持$$de$$s不变，直接跳过第$$i$$个元素

### 等概率证明（使用数学归纳法）

#### 命题

对于$$i$$（$$i$$从1开始，并且$$i > m$$），证明满足条件的$$i$$个元素，被取出的概率都为$$\frac{m}{i}$$

#### 证明

* 当$$i=m+1$$时，显然第$$i$$个元素取出的概率为$$\frac{m}{i}$$，而第0到$$m$$之间的元素被取出的概率为$$\frac{1}{i}+\frac{m}{i}*\frac{m-1}{m} = \frac{m}{i}$$

* 假设对于$$i$$，其中$$i>m+1$$时，每一个元素被取出的概率是$$\frac{m}{i}$$，则对于$$i+1$$，第$$i+1$$个元素被取出的概率是$$\frac{m}{i+1}$$，对于0到$$i$$这些元素被取出的概率为$$\frac{m}{i}*(\frac{i+1-m}{i+1} + \frac{m}{i+1}*\frac{m-1}{m})=\frac{m}{i+1}$$。至此，命题得证

### 应用

* 给出一个长度很大或者长度不确定的数据流，如果需要从此中等概率地取出m行或者m个元素，可以使用此算法，一次遍历即可完成。
