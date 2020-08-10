---
layout: post
title: Amazon State Language
date: 2020-08-04
categories:
  - Translation
description: 
image: /assets/images/traffic_light.jpg
image-sm: /assets/images/traffic_light.jpg

---


[Amazon States Language](https://states-language.net/)

本文描述了一种基于[JSON](https://tools.ietf.org/html/rfc7159)格式的状态机描述语言。满足此描述的状态机可以被称之为解释器(the interpreter)的软件执行。

Copyright © 2016 Amazon.com Inc. or Affiliates.

Permission is hereby granted, free of charge, to any person obtaining a copy of this specification and associated documentation files \(the “specification”\), to use, copy, publish, and/or distribute, the Specification\) subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies of the Specification.

You may not modify, merge, sublicense, and/or sell copies of the Specification.

THE SPECIFICATION IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SPECIFICATION OR THE USE OR OTHER DEALINGS IN THE SPECIFICATION.​

Any sample code included in the Specification, unless otherwise specified, is licensed under the Apache License, Version 2.0.


## 目录

* 状态机结构

  * [例子: Hello World](#example)


  * [一级字段](#toplevelfields)


* 相关概念

  * [状态(States)](#states-fields)


  * [状态转换(Transitions)](#transition)

  * [时间戳](#timestamps)

  * [数据(Data)](#data)

  * [路径(Paths)](#path)

  * [引用路径(Reference Paths)](#ref-paths)

  * [输入与输出处理](#filters)

  * [错误](#errors)

* 状态类型(State Type)

  * [状态类型和字段表](#state-type-table)

  * [Pass State](#pass-state)

  * [Task State](#task-state)


  * [Choice State](#choice-state)


  * [Wait State](#wait-state)


  * [Succeed State](#succeed-state)

  * [Fail State](#fail-state)


  * [Parallel State](#parallel-state)


  * [Map State](#map-state)

* 附录

  * [附录 A: 预定义的错误类型](#appendix-a)

## 状态机的结构

一个状态机使用[JSON 对象](https://tools.ietf.org/html/rfc7159#section-4)来表示。

### 例子: Hello World

状态机的操作是通过由JSON对象表示的状态集合(states)指定的，也就是一级字段"States"的值。在以下例子中展示了一个名为"Hello World"状态。

```json
{
    "Comment": "A simple minimal example of the States language",
    "StartAt": "Hello World",
    "States": {
        "Hello World": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:HelloWorld",
            "End": true
        }
    }
}
```

当状态机启动时，解释器就开始执行被识别为开始状态(Start State)的节点。执行完这个状态的任务之后，判断此状态是否被标记为结束状态(End State)。如果是，那么状态机将会停止执行并返回结果。如果不是，解释器将查找Next字段所指向的状态并接着执行，重复以上动作直到某个状态是[结束状态(Terminal State)](#terminal-state)：包括成功(Succeed)，失败(Fail)，结束(End)这些状态或者是出现运行时错误。


 在此示例中，状态机含名为"Hello World"的单个状态。因为"Hello World"是一个任务状态(Task State)，所以解释器会尝试执行。通过检查Resource字段可以知道其指向Lambda函数，此时解释器会尝试调用该函数。假设Lambda函数成功执行，状态机将成功结束。

状态机是通过JSON对象表示的。

### 一级字段

状态机对象必须有States字段，表示状态集合。

状态机对象必须有StartAt字段，并且这个字段的值必须是States状态集合里的某个状态名。解释器会从这个状态开始执行。

状态机对象可包含Comment字段，用来描述状态机。

状态机对象可包含Version字段，表示所用的状态机描述语言的版本号。此文档的版本是1.0，所以此字段的默认值为1.0。

状态机对象可包含有TimeoutSeconds字段，表示此状态机的最长允许执行时间。如果执行时间超过了指定时间，解释器将执行失败，[错误名](#error-names)为States.Timeout。


## 概念

### 状态集合(States)

状态集合由顶层的States字段表示。状态的名称就是key名，必须小于128个Unicode字符，并且所有的状态名称必须唯一。状态可以描述任务(工作单元)，或者是特定流程控制(例如Choice)。

这是一个执行Lambda函数的状态例子：

```
"HelloWorld": {
  "Type": "Task",
  "Resource": "arn:aws:lambda:us-east-1:123456789012:function:HelloWorld",
  "Next": "NextState",
  "Comment": "Executes the HelloWorld Lambda function"
}
```

请注意：

1. 所有状态必须有Type字段。此文档将此字段定义为状态的类型，像之前例子中的状态是一个任务类型状态(Task State)。


2.  状态可包含有Comment字段，表示对状态的描述。

3.  本文档中的大部分状态类型都有一些额外的字段，来表示特定类型状态的额外信息。

4. 除了Choice、Succeed、Fail状态外其它状态都可包含有类型为boolean的End字段。结束状态(Terminal State)指是的含有以下字段的状态：{"End": true }或{ "Type": "Succeed" }或{ "Type": "Fail" }。

### 状态流转(Transitions)

状态流转定义了状态机的控制流，将所有状态连接在一起。在执行完一个非终止状态时，解释器将继续执行下一个状态。大多数状态类型是通过状态的Next字段无条件流转的。


除了类型为Choice的状态外，其它非终止状态都必须有Next字段，而且此字段必须是状态集合里的某一个状态名，匹配时大小写敏感。

一个状态的流转来源可以是多个状态，例如多个状态的Next字段是同一个状态名。



### 时间戳(Timestamps)

Choice和Wait类型的状态需要处理包含有时间戳的字段。时间戳字段必须是满足[RFC3339](https://www.ietf.org/rfc/rfc3339.txt)), ISO 8601的一个字符串, 并加强了如下限制：大写字母T必须用来分开日期和时间，在没有时区时必须使用大写字母Z，例如”2016-03-14T01:59:00Z”。


### 数据(Data)

解释器通过在状态间传递数据来执行计算任务或者控制流程。所有这些数据必须以JSON表示。


当状态机开始时，调用者可以提供一个初始的JSON字符串做为输入，这也将传给Start State做为输入，默认为`{}`。每一个状态在执行完成后也会产生JSON格式的输出。当两个状态被流转在一起时，第一个状态的输出将成为第二个状态的输入。状态机终止状态的输出，将被视为这个状态机的输出。

举个例子，如下将两个数相加的状态机：

```json
{
  "StartAt": "Add",
  "States": {   
    "Add": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:Add",
      "End": true
    }
  }
}
```

假设Add这个函数定义如下：

```js
exports.handler = function(event, context) {
  context.succeed(event.val1 + event.val2);
};
```

如果之前的状态机以`{ "val1": 3, "val2": 4 }`做为输入，那么输出的JSON值就是数字`7`。

适用于JSON编码的约束也同样适用，特别需要注意：

1. JSON中的数字通常符合JavaScript语义，通常对应于双精度IEEE-854值。有关此问题和其他互操作性问题，请参阅[RFC 7159](https://tools.ietf.org/html/rfc7159)。


2. 独立的分隔字符串“-”、布尔值和数字都是有效的JSON文本。


### 路径(Paths)

路径是以"$"开头的字符串，使用[JsonPath](https://github.com/jayway/JsonPath)语法来标识JSON对象的某个字段。


### 引用路径(Reference Paths)


引用路径是受限制的路径访问(PATH)，只能访问JSON结构中单个节点：不支持“@”， “,”，“:” 和 “?” 。所有的引用路径必须是对单个值，数组，对象(子树)的明确引用。

例如，如果状态的输入如下：

```
{
    "foo": 123,
    "bar": ["a", "b", "c"],
    "car": {
        "cdr": true
    }
}
```

则如下显示了引用路径以及结果示例：

```
$.foo => 123
$.bar => ["a", "b", "c"]
$.car.cdr => true
```


路径和引用路径会在特定的状态中使用，包括文档后面介绍的控制状态机的流程以及配置状态机的选项。


以下是一些合法的引用路径的语法参考：

```
$.store.book
$.store\.book
$.\stor\e.boo\k
$.store.book.title
$.foo.\.bar
$.foo\@bar.baz\[\[.\?pretty
$.&Ж中.\uD800\uDF46
$.ledgers.branch[0].pending.count
$.ledgers.branch[0]
$.ledgers[0][22][315].foo
$['store']['book']
$['store'][0]['book']
```

### 输入和输出处理


如上文说述，数据是以JSON字符串的形式在状态间传递。然而，一个状态可能只会处理输入数据的子集，变换其结构。同样，也需要控制输出数据的格式和内容。

存在名为“ InputPath”，“ Parameters”，“ OutputPath”和“ ResultPath”的字段来支持此功能。除Success和Fail状态外的任何状态都可拥有“ InputPath”和“ OutputPath”字段。可能产生结果的状态可以具有“ ResultPath”和“ Parameters”字段：Pass State, Task State, Parallel State, and Map State。


在本文中，原始输入(raw input)表示作为状态输入的JSON文本。结果(Result)表示状态产生的JSON文本，它可以来自于Task State执行外部代码的结果、Parallel State各个分支结果的合并、Pass State的Result字段。 有效输入(Effective input)是指应用InputPath和Parameters后的输入，有效输出(effective output)是指使用ResultPath和OutputPath处理Result后的最终状态输出。


#### InputPath, Parameters, OutputPath, DefaultPath

1. InputPath的值必须是一个Path，应用于状态的raw input来筛选出某些或者全部的值；筛选的结果将被状态所使用，例如在Task State中将传递给Resources指定的任务，在Choice State中将传递给选择器(Choices selectors)。

2. Parameters可以包含任意值。以下讨论的场景允许从effec

2.  “Parameters” may have any value. Certain conventions described below allow values to be extracted from the effective input and embedded in the Parameters structure. If the “Parameters” field is provided, its value, after the extraction and embedding, becomes the effective input.

3. ResultPath的值必须是一个Reference Path，指定了raw input的组合或者替换状态的结果。
3.  The value of “ResultPath” MUST be a Reference Path, which specifies the raw input’s combination with or replacement by the state’s Result.

4. OutputPath的值必须是Path，应用于由ResultPath处理后的状态的结果，由此产生了effective out，并作为下一个状态的raw input。

请注意，将JsonPath应用于输入JSON文本时，可以产生多个值。 例如，给定以下文本：

```
{ "a": [1, 2, 3, 4] }
```

JsonPath`$.a[0,1]`的结果将是`1`和`2`两个值。这种情况下，解释器会将这些值合并成数组，所以以上例子在状态中将看到如下输入：

```
[ 1, 2 ]
```

同样的规则也将应用于OutPath；如果OutputPath的结果包含多个合二为一，则effective output将是这些值组成的数组。

ResultPath字段是Refrence Path，表示状态的结果相对于raw input将保存在哪个字段中。如果raw input在ResultPath指示的字段中有值，则在输出时此字段将被状态的结果替换掉。否则将在输出时创建新字段，并根据需要构造中间字段。如下例子中，给定raw input：

```
{
  "master": {
    "detail": [1, 2, 3]
  }
}
```

如果状态的结果是数字`6`，并且ResultPath是`$.master.detail`，则在输出结果时`detail`字段将被覆盖：

```
{
  "master": {
    "detail": 6
  }
}
```

如果ResultPath为`$.master.result.sum`，则结果将是在raw input的基础上链式增加两个新字段，`result`和`sum`：

```
{
  "master": {
    "detail": [1, 2, 3],
    "result": {
      "sum": 6
    }
  }
}
```
如果InputPath的值为`null`，这表示raw input将被忽略，此状态的effective input将是一个空的JSON对象`{}`。注意InputPath的值为`null`与缺少此字段所表示的意思不同。

如果ResultPath的值为`null`，这表示状态的Result将被忽略，raw input将成为Result。

如果OutputPath的值为`null`，这表示输入和Result将被忽略，effective output 将是一个空的JSON对象`{}`。

#### Defaults


InputPath、Parameters、ResultPath、OutputPath这些字段都是可选的。InputPath的默认值为`$`，所以effective input默认情况下就是raw input。ResultPath的默认值为`$`，所以状态的Result默认情况下会覆盖掉输入。OutputPath的默认值为`$`，所以状态的有效输出默认就是ResultPath。


Parameters没有默认值。在不给此字段的情况下，对effective input不产生作用。

因此，在这些字段都没有的情况下，一个状态消费raw input并将它产生的Result传给下一个状态。

#### 输入输出处理示例

回顾之前给出的两数相加的状态机例子。原来的输入是`{ "val1": 3, "val2": 4 }`，输出 为数字 `7`。

考虑以下更复杂点的输入：

```
{
  "title": "Numbers to add",
  "numbers": { "val1": 3, "val2": 4 }
}
```

另外我们将状态添加如下两个字段：

```
"InputPath": "$.numbers",
"ResultPath": "$.sum"
```

并将Lambda函数改成`return JSON.stringify(total)`；这可能是更好的一种形式，因为函数只关心数学运算，而不用关心最终结果如何标注。

在这个例子中，输出可能如下：

```
{
  "title": "Numbers to add",
  "numbers": { "val1": 3, "val2": 4 },
  "sum": 7
}
```

解释器也可能需要构建多级的JSON对象来达到想要的结果。假设某个Task状态的输入为：


```
{ "a": 1 }
```

假设Task状态的输出为"Hi!"，并且ResultPath字段为`$.b.greeting`。则这个状态的输出将是：


```
{
  "a": 1,
  "b": {
    "greeting": "Hi!"
  }
}
```

#### Context对象

解释器可以为运行中的状态机提供关于本次执行与其它实现细节的信息。这是以称之为Context Object的JSON对象来传递的。这一版本的状态机语言没有指定任何Context Object应该包含的内容。

#### Parameters

Parameters字段的值经过下面的处理成为有效输入。考虑如下的Task状态：

```
"X": {
  "Type": "Task",
  "Resource": "arn:aws:states:us-east-1:123456789012:task:X",
  "Next": "Y",
  "Parameters": {
    "first": 88,
    "second": 99
  }
}
```

在这个例子中，Resource字段函数的有效输入是一个包含有first和second字段的对象，这两个字段的值为Parameters里指定的值。

有效输入和Context Object的值可以使用一种字段约定和JsonPath相结合的语法来插入到Parameters的字段中。

如果Parameters中JSON对象的字段名以`.$`结尾(不管是第几层的字段)，那么这个字段的值必须以`$`开头。

如果某个值以`$$`开头，除掉第一个`$`符外，剩下的字符串必须是一个PATH。这种情况下，这个Path所标识的是Context Object和Extracted Value的结果值。

如果某个值单个`$`开头，则必须是一个Path。这种情况下，这个Path所标识的是有效输入和Extracted Value的结果值。

如果Path是有效的，但无法找到对应的引用值，则解释器将执行失败，并抛出名为States.ParameterPathFailure的错误。

如果一个字段名以`.$`结果，他的值可以被用作生成之前提到的Extracted Value，这个字段名将是去掉`.$`之后的字符串，值为Extracted Value。

比如下面的例子：

```
"X": {
  "Type": "Task",
  "Resource": "arn:aws:states:us-east-1:123456789012:task:X",
  "Next": "Y",
  "Parameters": {
    "flagged": true,
    "parts": {
      "first.$": "$.vals[0]",
      "last3.$": "$.vals[3:]"
    },
    "weekday.$": "$$.DayOfWeek"
  }
}
```

假设状态的输入为：

```
{
  "flagged": 7,
  "vals": [0, 10, 20, 30, 40, 50]
}
```

另外，假设Context Object如下：

```
{
  "DayOfWeek": "TUESDAY"
}
```

这种情况下，对于Resource字段所表示的函数的有效输入为：

```
{
  "flagged": true,
  "parts": {
    "first": 0,
    "last3": [30, 40, 50]
  },
  "weekday": "TUESDAY"
}
```

#### 运行时错误(Runtime Errors)

假设状态的输入值为`"foo"`，ResultPath的字段值为`$.x`，这个ResultPath无法被于输入的值(输入的值是字符串，无法再追加x字段)，所以解释器将执行失败，并抛出错“States.ResultPathMatchFailure”。

### 错误(Errors)

任何状态都可能产生运行时错误。错误的产生原因可能是状态机的定义问题(例如之前ResultPath的问题)、任务失败(例如Lambda函数执行异常)以及一些诸如网络异常等临时问题。

当某个状态报告错误时，解释器的默认操作是使得整个状态机失败。


#### 错误表示(Error representation)

错误是由大小写敏感的字符串标识，称之为错误名(Error Names)。此文档中定义了些常见错误名，这些错误名都是以States开头的字符串，参见[Appendix A](#appendix-a)。

状态也可以报告其它的错误，但这些错误名不能以States开头。

#### 出错重试(Retrying after error)


Task States、Parallel States和Map States可包含有Retry字段，此字段的值是由称之为Retriers的对象组成的数组。

任一Retrier必须饮食有ErrorEquals字段，字段的值必须是匹配[Error Names](#error-names)的非空字符串。

当错误发生时，解释器遍历Retriers寻找ErrorEquals字段值为此错误名的Retrier，并按其所描述的重试策略来实施。

每一个Retrier代表特定次数的尝试，通常时间间隔随次数增加。

Retrier可包含有IntervalSeconds字段，它的值必须是正整数，表示第一次重试之前需要等待的时间(默认为1)；也可包含MaxAttempts字段，也必须是一个正整数，表示最大重试次数；也可包含BackoffRate字段，表示重试间隔的增长率(默认为2.0)，字段值必须大于1.0。

注意MaxAttempts字段值为0时，表示指定错误出现时不需要重试。

以下是一个Retrier的例子，将在States.Timeout错误发生之后3秒之后重试，如果再失败，将在4.5秒后再重试：

```
"Retry" : [
    {
      "ErrorEquals": [ "States.Timeout" ],
      "IntervalSeconds": 3,
      "MaxAttempts": 2,
      "BackoffRate": 1.5
    }
]
```

Retrier的ErrorEquals字段中可以包含保留名States.ALL，表示匹配任意错误。含有States.ALL的ErrorEquals数组必须只有这一个值，并且这个Retrier必须是所有Retry数组中的最后一个。

以下Retry的配置例子，将会使用Retrier的默认参数重试除了States.Timeout之外的所有错误。

```
"Retry" : [
    {
      "ErrorEquals": [ "States.Timeout" ],
      "MaxAttempts": 0
    },
    {
      "ErrorEquals": [ "States.ALL" ]
    }
]
```

如果错误出现的次数超过了MaxAttempts字段所允许的次数，则将停止重试，并进入正常的错误处理。

#### 复杂的重试场景(Complex retry scenarios)


在单次状态执行的上下文中，Retrier的参数会应用于对该Retrier的所有访问。通过以下的例子更容易理解：

```
"X": {
  "Type": "Task",
  "Resource": "arn:aws:states:us-east-1:123456789012:task:X",
  "Next": "Y",
  "Retry": [
    {
      "ErrorEquals": [ "ErrorA", "ErrorB" ],
      "IntervalSeconds": 1,
      "BackoffRate": 2,
      "MaxAttempts": 2
    },
    {
      "ErrorEquals": [ "ErrorC" ],
      "IntervalSeconds": 5
    }
  ],
  "Catch": [
    {
      "ErrorEquals": [ "States.ALL" ],
      "Next": "Z"
    }
  ]
}
```

假设这个任务连续失败了4次，错误分别是ErrorA，ErrorB，ErrorC和ErrorB。前两次错误匹配到第一个Retrier，所以分别在1秒和2秒后进行重试。第三个错误匹配到第二个Retrier，并等待5秒后重试。第四个错误匹配到第一个Retrier，但是第一个Retrier已经超过了MaxAttemp的次数限制，所以Retrier失败了，将通过Catch字段的Next跳转到Z状态继续执行。


注意一旦解释器流转到其它状态执行，所有的Retrier参数将重置。

#### 回退状态(Fallback states)

Task States、Parallel States和Map States可包含有Catch字段，其值必须为对象的数组，称之为Catchers。

每个Catchr必须饱含有ErrorEquals字段，与Retrier的ErrorEquals字段含义一致，也必须包含Next字段，值必须匹配某个状态名。

当某个状态执行报错，并且此状态没有对应的Retrier或者所有的Retrier都已经不再满足条件时，解释器将按数组顺序扫描Catch字段，当按错误名搜索到与匹配的Catcher时，将状态流转到此Catcher的Next字段所指向的状态。

保留名States.ALL出现在Catcher的ErrorEquals字段时，此Catcher将与任意错误相匹配。所以States.ALL只能做为ErrorEquals的唯一元素出现，并且此Catcher必须是Catch数组的最后一个元素。

#### 错误输出(Error output)

当某个状态出现错误，并且匹配到一个Catcher将转到下一个状态执行时，这一状态的结果(JSON对象)称之为错误输出(Error Output)，这将成为Catcher的Next指向状态的输入。错误输出必须含有值为字符串的Error字段，表示错误名。也必须含有字符串类型的Cause字段，包含可阅读的错误描述。


Catcher可包含ResultPath字段，这与状态一级字段的ResultPath工作方式一样，可以将错误输出注入到原始的输入中，并将此结果做为Next字段所指向的状态的输入。ResultPath的默认值为`$`，表示错误输出将做为整个状态的输出。

下面这个例子中，当Lambda函数抛出未来捕获的Java Exception时，会将流转到RecoveryState状态，如果是其它错误时，流转到EndMachine状态。

另外，在这个例子中，如果第一个Catcher匹配成功，RecoveryState的输入将是原来状态的输入外包含有错误输出的error-info字段。如果是第二个Catcher匹配成功，则EndMachine的输入仅仅是错误输出。

```
"Catch": [
  {
    "ErrorEquals": [ "java.lang.Exception" ],
    "ResultPath": "$.error-info",
    "Next": "RecoveryState"
  },
  {
    "ErrorEquals": [ "States.ALL" ],
    "Next": "EndMachine"
  }
]
```

Catcher可以匹配多个错误。

一个状态既有Retry字段又有Catch字段时，解释器会优先匹配Retriers，只有当重试策略无法解决问题时(如超过允许重试次数)，才会匹配Catcher进行状态流转。


## 状态类型(State Types)


提醒一下，状态类型由Type字段的值给出，该值必须出现在每个状态对象中。

### 状态类型和字段表(Table of State Types and Fields)

许多字段不仅仅出现在一个状态类型中。下表汇总了哪些字段可以出现在哪些类型的状态中。表中不包含某一类型特定的字段。


<style>
center{
	font-size: 0.7em;
    margin-top: -20px;
    margin-bottom: 15px;
}
table{
	font-size:0.7em;
	margin-bottom: 29px;
	border: 2px solid #2b5fa8;
}

table th {
	background: #cef;
    padding: 5px;
}
.post ul {
    font-size: 0.75em;
    list-style-type: disc;
    padding-left: 16px;
}

td{
padding: 8px;
}
td.special-title{
color: #a30623;
}
table .field{
  background-color:#cef
}
table .allowed{
  background-color:#cfe
}
table .required{
    background-color:#cfa

}
table .empty{
  background-color:#fbb
}
</style>


<table>
  <tbody>
    <tr>
      <td></td><th align="center" colspan="8">States</th>
    </tr>
    <tr align="center">
      <td></td><th>Pass</th><th>Task</th><th>Choice</th><th>Wait</th><th>Succeed</th><th>Fail</th><th>Parallel</th><th>Map</th>
    </tr>
    <tr align="center">
      <td align="right" class="field">Type</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td>
    </tr>
    <tr align="center">
      <td align="right" class="field">Comment</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td>
    </tr>
    <tr align="center">
      <td align="right" class="field">InputPath, OutputPath</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="empty"></td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td>
    </tr>
    <tr align="center">
      <td align="right" class="field">Parameters</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td>
    </tr>
    <tr align="center">
      <td align="right" class="field">ResultPath</td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td>
    </tr>
    <tr align="center">
      <td align="right" class="field"><i>One of:</i> Next <i>or</i> "End":true</td><td align="center" class="required">Required</td><td align="center" class="required">Required</td><td align="center" class="empty"></td><td align="center" class="required">Required</td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="required">Required</td><td align="center" class="required">Required</td>
    </tr>
    <tr align="center">
      <td align="right" class="field">Retry, Catch</td><td align="center" class="empty"></td><td align="center" class="allowed">Allowed</td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="empty"></td><td align="center" class="allowed">Allowed</td><td align="center" class="allowed">Allowed</td>
    </tr>
  </tbody>
</table>

### Pass State

Pass State(`"Type":"Pass"`)简单地将状态的输入转化为输出，没有额外的功能。Pass State在
构造和调试状态机时很有用。

Pass State可包含字段Result。它的值被视为虚拟任务的输出，并由ResultPath字段来处理后将其传递给下一个状态。如果Result字段未提供，输出即为输入。因此如果Result和ResultPath都没有提供，Pass State只是拷贝输入并做为输出。

以下例子中Pass State在状态机中注入了一些固定值，可以用于调试：

```
"No-op": {
  "Type": "Pass",         
  "Result": {
    "x-datum": 0.381018,
    "y-datum": 622.2269926397355
  },
  "ResultPath": "$.coords",
  "Next": "End"
}
```

假设给这个状态的输入如下：

```
{
  "georefOf": "Home"
}
```

那么输出为：

```
{
  "georefOf": "Home",
  "coords": {
    "x-datum": 0.381018,
    "y-datum": 622.2269926397355
  }
}
```

### Task State

Task State(`"Type":"Task"`)将使得状态机执行Resource字段定义的任务。

示例如下：

```
"TaskState": {
  "Comment": "Task State example",
  "Type": "Task",
  "Resource": "arn:aws:states:us-east-1:123456789012:task:HelloWorld",
  "Next": "NextState",
  "TimeoutSeconds": 300,
  "HeartbeatSeconds": 60
}
```

Task State必须包含Resource字段，表示指向特定执行任务的唯一标识URI。本规范不规定URI scheme，也不规定URI的其它部分。

此类型状态可以指定某超时时间。TimeoutSeconds和HeartbeatSconds字段表示秒数，必须是正整数。如果如果指定了HeartbeatSeconds，则它的值必须小于TimeoutSeconds。

TimeoutSeconds的去缺省值为60。

如果状态运行时间比指定的超时时间长，或者任务的心跳间隔超过了指定的心跳超时，解释器将失败，并抛出State.Timeout错误。

### Choice State

Choice State(`"Type":"Choice"`)为状态机添加了分支逻辑。

Choice State必须包含Choices字段，值为非空数组。每一个数组元素被称之为Choice Rule，一个包含有比较操作和指向某个状态名的Next字段的对象。

解释器按数组的顺序尝试匹配Choice Rules，当输入与数组元素中的比较操作相匹配时，将流转到此Choice Rule的Next字段指定的状态中继续执行。

以下是Choice state的例子，包括会流转到的状态：

```
"ChoiceStateX": {
  "Type" : "Choice",
  "Choices": [
    {
        "Not": {
          "Variable": "$.type",
          "StringEquals": "Private"
        },
        "Next": "Public"
    },
    {
      "And": [
        {
          "Variable": "$.value",
          "NumericGreaterThanEquals": 20
        },
        {
          "Variable": "$.value",
          "NumericLessThan": 30
        }
      ],
      "Next": "ValueInTwenties"
    }
  ],
  "Default": "DefaultState"
},

"Public": {
  "Type" : "Task",
  "Resource": "arn:aws:lambda:us-east-1:123456789012:function:Foo",
  "Next": "NextState"
},

"ValueInTwenties": {
  "Type" : "Task",
  "Resource": "arn:aws:lambda:us-east-1:123456789012:function:Bar",
  "Next": "NextState"
},

"DefaultState": {
  "Type": "Fail",
  "Cause": "No Matches!"
}
```

在这个状态中，假设输入为：

```
{
  "type": "Private",
  "value": 22
}
```

解释器根据value字段在Choices中进行匹配后，将流转到ValueInTwenties状态。

任一Choice Rule必须包含以下比较操作中的某一个，而且有且仅有一个。支持的比较操作有：

1.  StringEquals

2.  StringLessThan

3.  StringGreaterThan

4.  StringLessThanEquals

5.  StringGreaterThanEquals

6.  NumericEquals

7.  NumericLessThan

8.  NumericGreaterThan

9.  NumericLessThanEquals

10.  NumericGreaterThanEquals

11.  BooleanEquals

12.  TimestampEquals

13.  TimestampLessThan

14.  TimestampGreaterThan

15.  TimestampLessThanEquals

16.  TimestampGreaterThanEquals

17.  And

18.  Or

19.  Not



For each of these operators, the field’s value MUST be a value of the appropriate type: String, number, boolean, or [Timestamp](#timestamps).

The interpreter scans through the Choice Rules in a type-sensitive way, and will not attempt to match a numeric field to a string value. However, since Timestamp fields are logically strings, it is possible that a field which is thought of as a time-stamp could be matched by a “StringEquals” comparator.

The various String comparators compare strings character-by-character with no special treatments such as case-folding, white-space collapsing, or [Unicode form normalization](https://unicode.org/reports/tr15/). Put simply, they are case-sensitive.

Note that for interoperability, numeric comparisons should not be assumed to work with values outside the magnitude or precision representable using the IEEE 754-2008 “binary64” data type. In particular, integers outside of the range \[-\(253\)+1, \(253\)-1\] might fail to compare in the expected way.

The values of the “And” and “Or” operators MUST be non-empty arrays of Choice Rules that MUST NOT contain “Next” fields; the “Next” field can only appear in a top-level Choice Rule.

The value of a “Not” operator MUST be a single Choice Rule, that MUST NOT contain “Next” fields; the “Next” field can only appear in a top-level Choice Rule.

Choice states MAY have a “Default” field, which will execute if none of the Choice Rules match. The interpreter will raise a run-time States.NoChoiceMatched error if a “Choice” state fails to match a Choice Rule and no “Default” transition was specified.

Choice states MUST NOT be End states.

### Wait State

A Wait state \(identified by `"Type":"Wait"`\) causes the interpreter to delay the machine from continuing for a specified time. The time can be specified as a wait duration, specified in seconds, or an absolute expiry time, specified as an ISO-8601 extended offset date-time format string.

For example, the following Wait state introduces a ten-second delay into a state machine:

```
"wait_ten_seconds" : {
  "Type" : "Wait",
  "Seconds" : 10,
  "Next": "NextState"
}
```

This waits until an absolute time:

```
"wait_until" : {
  "Type": "Wait",
  "Timestamp": "2016-03-14T01:59:00Z",
  "Next": "NextState"
}
```

The wait duration does not need to be hardcoded. Here is the same example, reworked to look up the timestamp time using a Reference Path to the data, which might look like `{ "expirydate": "2016-03-14T01:59:00Z" }`:

```
"wait_until" : {
    "Type": "Wait",
    "TimestampPath": "$.expirydate",
    "Next": "NextState"
}
```

A Wait state MUST contain exactly one of ”Seconds”, “SecondsPath”, “Timestamp”, or “TimestampPath”.

### Succeed State

The Succeed State \(identified by `"Type":"Succeed"`\) either terminates a state machine successfully, ends a branch of a Parallel state, or ends an iteration of a Map state. The output of a Succeed state is the same as its input, possibly modified by “InputPath” and/or “OutputPath”.

The Succeed State is a useful target for Choice-state branches that don't do anything except terminate the machine.

Here is an example:

```
"SuccessState": {
  "Type": "Succeed"
}
```

Because Succeed States are terminal states, they have no “Next” field.

### Fail State

The Fail State \(identified by `"Type":"Fail"`\) terminates the machine and marks it as a failure.

Here is an example:

```
"FailState": {
          "Type": "Fail",
          "Error": "ErrorA",
          "Cause": "Kaiju attack"
}
```

A Fail State MUST have a string field named “Error”, used to provide an error name that can be used for error handling \(Retry/Catch\), operational, or diagnostic purposes. A Fail State MUST have a string field named “Cause”, used to provide a human-readable message.

Because Fail States are terminal states, they have no “Next” field.

### Parallel State

The Parallel State \(identified by `"Type":"Parallel"`\) causes parallel execution of "branches".

Here is an example:

```
"LookupCustomerInfo": {
  "Type": "Parallel",
  "Branches": [
    {
      "StartAt": "LookupAddress",
      "States": {
        "LookupAddress": {
          "Type": "Task",
          "Resource": 
            "arn:aws:lambda:us-east-1:123456789012:function:AddressFinder",
          "End": true
        }
      }
    },
    {
      "StartAt": "LookupPhone",
      "States": {
        "LookupPhone": {
          "Type": "Task",
          "Resource": 
            "arn:aws:lambda:us-east-1:123456789012:function:PhoneFinder",
          "End": true
        }
      }
    }
  ],
  "Next": "NextState"
}
```

A Parallel state causes the interpreter to execute each branch starting with the state named in its “StartAt” field, as concurrently as possible, and wait until each branch terminates \(reaches a terminal state\) before processing the Parallel state's “Next” field. In the above example, this means the interpreter waits for “LookupAddress” and “LookupPhoneNumber” to both finish before transitioning to “NextState”.

In the example above, the LookupAddress and LookupPhoneNumber branches are executed in parallel.

A Parallel State MUST contain a field named “Branches” which is an array whose elements MUST be objects. Each object MUST contain fields named “States” and “StartAt” whose meanings are exactly like those in the top level of a State Machine.

A state in a Parallel state branch “States” field MUST NOT have a “Next” field that targets a field outside of that “States” field. A state MUST NOT have a “Next” field which matches a state name inside a Parallel state branch’s “States” field unless it is also inside the same “States” field.

Put another way, states in a branch’s “States” field can transition only to each other, and no state outside of that “States” field can transition into it.

If any branch fails, due to an unhandled error or by transitioning to a Fail state, the entire Parallel state is considered to have failed and all the branches are terminated. If the error is not handled by the Parallel State, the interpreter should terminate the machine execution with an error.

Unlike a Fail state, a Succeed state within a Parallel merely terminates its own branch. A Succeed state passes its input through as its output, possibly modified by “InputPath” and “OutputPath”.

The Parallel state passes its input \(potentially as filtered by the “InputPath” field\) as the input to each branch’s “StartAt” state. It generates a result which is an array with one element for each branch containing the output from that branch. The elements of the output array correspond to the branches in the same order that they appear in the “Branches” array. There is no requirement that all elements be of the same type.

The output array can be inserted into the input data using the state’s “ResultPath” field in the usual way.

For example, consider the following Parallel State:

```
"FunWithMath": {
  "Type": "Parallel",
  "Branches": [
    {
      "StartAt": "Add",
      "States": {
        "Add": {
          "Type": "Task",
          "Resource": "arn:aws:states:::task:Add",
          "End": true
        }
      }
    },
    {
      "StartAt": "Subtract",
      "States": {
        "Subtract": {
          "Type": "Task",
          "Resource": "arn:aws:states:::task:Subtract",
          "End": true
        }
      }
    }
  ],
  "Next": "NextState"
}
```

If the “FunWithMath” state was given the JSON array `[3, 2]` as input, then both the “Add” and “Subtract” states would receive that array as input. The output of “Add” would be `5`, that of “Subtract” would be `1`, and the output of the Parallel State would be a JSON array:

```
[ 5, 1 ]
```

### Map State

The Map State \(identified by `"Type": "Map"`\) causes the interpreter to process all the elements of an array, potentially in parallel, with the processing of each element independent of the others. This document uses the term “iteration” to describe each such nested execution.

The Parallel state applies multiple different state-machine branches to the same input, while the Map state applies a single state machine to multiple input elements.

There are several fields which may be used to control the execution. To summarize:

1.  The “Iterator” field’s value is an object that defines a state machine which will process each element of the array.

2.  The “ItemsPath” field’s value is a reference path identifying where in the effective input the array field is found.

3.  The “MaxConcurrency” field’s value is an integer that provides an upper bound on how many invocations of the Iterator may run in parallel.

Consider the following example input data:

```
{
  "ship-date": "2016-03-14T01:59:00Z",
  "detail": {
    "delivery-partner": "UQS",
    "shipped": [
      { "prod": "R31", "dest-code": 9511, "quantity": 1344 },
      { "prod": "S39", "dest-code": 9511, "quantity": 40 },
      { "prod": "R31", "dest-code": 9833, "quantity": 12 },
      { "prod": "R40", "dest-code": 9860, "quantity": 887 },
      { "prod": "R40", "dest-code": 9511, "quantity": 1220 }
    ]
  }
}
```

Suppose it is desired to apply a single Lambda function, “ship-val”, to each of the elements of the “shipped” array. Here is an example of an appropriate Map State.

```
"Validate-All": {
  "Type": "Map",
  "InputPath": "$.detail",
  "ItemsPath": "$.shipped",
  "MaxConcurrency": 0,
  "Iterator": {
    "StartAt": "Validate",
    "States": {
      "Validate": {
        "Type": "Task",
        "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ship-val",
        "End": true
      }
    }
  },
  "ResultPath": "$.detail.shipped",
  "End": true
}
```

In the example above, the “ship-val” Lambda function will be executed once for each element of the “shipped” field. The input to one iteration will be:

```
{
  "prod": "R31",
  "dest-code": 9511,
  "quantity": 1344
}
```

Suppose that the “ship-val” function also needs access to the shipment’s courier, which would be the same in each iteration. The [“Parameters”](#parameters) field may be used to construct the raw input for each iteration:

```
"Validate-All": {
  "Type": "Map",
  "InputPath": "$.detail",
  "ItemsPath": "$.shipped",
  "MaxConcurrency": 0,
  "Parameters": {
    "parcel.$": "$$.Map.Item.Value",
    "courier.$": "$.delivery-partner"
  },
  "Iterator": {
    "StartAt": "Validate",
    "States": {
      "Validate": {
        "Type": "Task",
        "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ship-val",
        "End": true
      }
    }
  },
  "ResultPath": "$.detail.shipped",
  "End": true
}
```

The “ship-val” Lambda function will be executed once for each element of the array selected by “ItemsPath”. In the example above, the raw input to one iteration, as specified by “Parameters”, will be:

```
{
  "parcel": {
    "prod": "R31",
    "dest-code": 9511,
    "quantity": 1344
   },
   "courier": "UQS"
}
```

In the examples above, the ResultPath results in the output being the same as the input, with the “detail.shipped” field being overwritten by an array in which each element is the output of the “ship-val” Lambda function as applied to the corresponding input element.

#### Map State input/output processing

The “InputPath” field operates as usual, selecting part of the raw input \- in the example, the value of the “detail” field \- to serve as the effective input.

A Map State MAY have a “ItemsPath” field, whose value MUST be a Reference Path. The Reference Path is applied to the effective input and MUST identify a field whose value is a JSON array.

The default value of “ItemsPath” is “\$”, which is to say the whole effective input. So, if a Map State has neither an “InputPath” nor a “ItemsPath” field, it is assuming that the raw input to the state will be a JSON array.

The input to each invocation, by default, is a single element of the array field identified by the “ItemsPath” value, but may be overridden using the [“Parameters”](#parameters) field.

In each iteration, within the Map state \(but not child states within an Iterator field\), the Context Object will have an object field named “Map” which contains an object field named “Item” which in turn contains an integer field named “Index” whose value is the \(zero-based\) array index being processed in the iteration and a field named “Value”, whose value is the array element being processed.

A Map state’s Result is an array containing one element for each element of the ItemsPath input array, in the same order.

#### Map State concurrency

A Map state MAY have a non-negative integer “MaxConcurrency” field. Its default value is zero, which places no limit on invocation parallelism and requests the interpreter to execute the iterations as concurrently as possible.

If “MaxConcurrency” has a non-zero value, the interpreter will not allow the number of concurrent iterations to exceed that value.

A MaxConcurrency value of 1 is special, having the effect that interpreter will invoke the Iterator once for each array element in the order of their appearance in the input, and will not start an iteration until the previous iteration has completed execution.

#### Map State Iterator definition

A Map State MUST contain an object field named “Iterator” which MUST contain fields named “States” and “StartAt”, whose meanings are exactly like those in the top level of a State Machine.

A state in the “States” field of an “Iterator” field MUST NOT have a “Next” field that targets a field outside of that “States” field. A state MUST NOT have a “Next” field which matches a state name inside an “Iterator” field’s “States” field unless it is also inside the same “States” field.

Put another way, states in an Iterator’s “States” field can transition only to each other, and no state outside of that “States” field can transition into it.

If any iteration fails, due to an unhandled error or by transitioning to a Fail state, the entire Map state is considered to have failed and all the iterations are terminated. If the error is not handled by the Map State, the interpreter should terminate the machine execution with an error.

Unlike a Fail state, a Succeed state within a Map merely terminates its own iteration. A Succeed state passes its input through as its output, possibly modified by “InputPath” and “OutputPath”.

## Appendices

### Appendix A: Predefined Error Codes

| Code | Description |
| --- | --- |
| States.ALL | 
A wild-card which matches any Error Name.

 |
| States.Timeout | 

A Task State either ran longer than the “TimeoutSeconds” value, or failed to heartbeat for a time longer than the “HeartbeatSeconds” value.

 |
| States.TaskFailed | 

A Task State failed during the execution.

 |
| States.Permissions | 

A Task State failed because it had insufficient privileges to execute the specified code.

 |
| States.ResultPathMatchFailure | 

A state’s “ResultPath” field cannot be applied to the input the state received.

 |
| States.ParameterPathFailure | 

Within a state’s “Parameters” field, the attempt to replace a field whose name ends in “.\$” using a Path failed.

 |
| States.BranchFailed | 

A branch of a Parallel state failed.

 |
| States.NoChoiceMatched | 

A Choice state failed to find a match for the condition field extracted from its input.

 |




