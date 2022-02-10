---
layout: post_n
title: 《Rust权威指南》笔记
date: 2021-11-20
categories:
  - Reading
description: 陆陆续续将《Rust权威指南》看完了，文中的例子全部按自己的理解重新实现了一遍。回望来途，可谓困难坎坷，步履艰辛；即是如此，也收获满满。Rust语言的学习给我耳目一新的感觉，上一次对学习语言有这种感觉还是在Haskell的学习中。他完全颠覆我理解的语言设计，在除了垃圾回收语言和内存自主控制语言，竟然还有如此方式来保证内存安全。震撼的同时，也感觉整体学习非常吃力，学习曲线异常陡峭。虽然把整本书都看完了，但还有非常多的细节似懂非懂，也无法完全不参照例子自行写出相对复杂的程序；一些语言中很容易实现的代码在Rust中也无法自行实现出来。所以目前只是第一阶段，即入门，以此为记。后面需要通过开源项目学习练手，通过了解常用的写法去深刻体验Rust的设计精髓。
image: /assets/images/rust_programer_cover.jpeg
image-sm: /assets/images/rust_programer_cover.jpeg

---
* ignore but need
{:toc}

## 前言

陆陆续续将《Rust权威指南》(即英文版的[《The Rust Programming Language》](https://doc.rust-lang.org/book/))看完了，文中的例子全部按自己的理解重新实现了一遍(代码在[github](https://github.com/xiaochai/batman/tree/master/RustProject)上)。回望来途，可谓困难坎坷，步履艰辛；即是如此，也收获满满。

Rust语言的学习给我耳目一新的感觉，上一次对学习语言有这种感觉还是在Haskell的学习中。他完全颠覆我理解的语言设计，在除了垃圾回收语言和内存自主控制语言，竟然还有如此方式来保证内存安全。震撼的同时，也感觉整体学习非常吃力，学习曲线异常陡峭。虽然把整本书都看完了，但还有非常多的细节似懂非懂，也无法完全不参照例子自行写出相对复杂的程序；一些语言中很容易实现的代码在Rust中也无法自行实现出来。所以目前只是第一阶段，即入门，以此为记。后面需要通过开源项目学习练手，通过了解常用的写法去深刻体验Rust的设计精髓。

## 学习与参考资料汇总

| 标题        | 说明|链接          | 
| ------------- |:----||:-------------| 
|The Rust Reference| 官方文档，也是本文的英文版 |[https://doc.rust-lang.org/reference/introduction.html](https://doc.rust-lang.org/reference/introduction.html) |
|Rust Primer |gitlab上的学习笔记|[https://hardocs.com/d/rustprimer/](https://hardocs.com/d/rustprimer/) |
|Rust Magazine |Rust月刊|[https://rustmagazine.github.io/rust_magazine_2021/chapter_1/rustc_part1.html](https://rustmagazine.github.io/rust_magazine_2021/chapter_1/rustc_part1.html) |
|Rust数据内存布局| 内存布局|[https://juejin.cn/post/6987960007245430797](https://juejin.cn/post/6987960007245430797) |
|The Rustonomicon |官方文档，说明一些语言的灰暗角落|[https://doc.rust-lang.org/nomicon/intro.html#the-rustonomicon](https://doc.rust-lang.org/nomicon/intro.html#the-rustonomicon) |
|The Unstable Book|官方文档，不稳定特性说明 |[https://doc.rust-lang.org/beta/unstable-book/the-unstable-book.html](https://doc.rust-lang.org/beta/unstable-book/the-unstable-book.html) |
|Std Lib Document|标准库文档|[https://doc.rust-lang.org/std/](https://doc.rust-lang.org/std/)|


## 安装与示例

如[官网](https://www.rust-lang.org/tools/install)所说，运行以下命令即可安装：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Rust相关的工具会被安装到```/Users/bytedance/.cargo/bin```这个目录下，如果没有把这个目录加到PATH下，添加即可使用。

### 创建Hello World程序

位于hello_world/main.rs

```rust
fn main(){
    println!("Hello world");
}
```
编译运行：

```
➜  hello_world git:(master) ✗ rustc main.rs
➜  hello_world git:(master) ✗ ./main
Hello world
```

我们注意到以上程序的几点，细节在后续章节中说明：缩进以4个空格为准；println!为宏，普通函数调用不需要```!```；你会发现去掉println最后的分号也能运行。

### 使用cargo

Cargo是Rust工具链中内置的构建系统及包管理器，常见的命令汇总如下：

| 命令        | 说明           | 
| ------------- |:-------------| 
| cargo new \<path\>    | 创建一个新的cargo项目，会生成Cargo.toml和src/main.rs| 
| cargo new \-\-lib  \<path\>   | 创建一个新的库项目，会生成Cargo.toml和src/lib.rs| 
| cargo build      |编译本项目，生成的可执行文件位于./target/debug/下；<br/>如果添加\-\-release，则会生成到./target/release/下；<br/>\-\-release参数将花费更多的时间来编译以优化代码，一般用于发布生产环境时使用   |  
| cargo run | 编译并运行本项目，也支持\-\-release参数，常用于运行压测； <br/>-p 用于工作空间下有多个二进制包时指定运行哪个包   |  
| cargo run \-\-bin \<target\>  | 编译并运行指定的bin文件，一般位于src/bin目录下，target不带.rs后缀   |  
| cargo check | 仅检查是否通过编译，由于不生成二进制文件，速度快于cargo build  |
| cargo doc | 在当前项目的target/doc目录生成使用到的库的文档，可以使用\-\-open选项直接打开浏览器  |
| cargo update | 忽略Cargo.lock文件中的版本信息，并更新为语义化版本所表示的最新版本，用于升级依赖包  |
| cargo test | 运行测试用例，默认情况下是多个测试case并行运行；<br/> cargo test接收两种参数，第一种传递给cargo test使用，第二种是传递给编译出来的测试二进制使用的；<br/>这两种参数中间使用\-\-分开;<br/>例如 cargo test -q  tests::it_works -- --test-threads=1；<br/> 这一命令，会以安静模式(-q)运行tests::it_works下的测试，并且只使用一个线程串行运行(--test-threads=1) |
|cargo publish | 发布项目到crate.io上，添加\-\-allow-dirty可以跳过本地git未提交的错误|
|cargo yank \-\-vers 0.0.1| 撤回某个版本，添加\-\-undo取消撤回操作|


Cargo.toml说明：

| 段名        | 说明           | 
| ------------- |:-------------| 
| package     | 本包(crate)的信息说明| 
| dependencies  |依赖的外部包，版本是语义化的版本，用于update时判断最新的可用版本    | 
| profile.dev  | 在非\-\-release模式下的编译参数，例如opt-level优化等级配置等，覆盖默认值，要省略   | 
|profile.release| 在\-\-release模式下的编译参数，覆盖默认值，可省略

crate是Rust中最小的编译单元，package是单个或多个crate的集合；crate和package都可以被叫作包，因为单个crate也是一个package，但package通常倾向于多个crate的组合。

Rust中的包(crate)代表了一系列源代码文件的集合。用于生成可执行程序的称为二进制包(binary crate)，而用于复用功能的称为库包(library crate，代码包)，例如rand库等。

创建项目：(hello_cargo项目)
```
➜  RustProject git:(master) ✗ cargo new hello_cargo
     Created binary (application) `hello_cargo` package
➜  RustProject git:(master) ✗ cd hello_cargo
➜  hello_cargo git:(master) ✗ tree .
.
├── Cargo.toml
└── src
    └── main.rs

1 directory, 2 files
```

Cargo.toml
```ini
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2018"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
rand = "0.8.0" # 手动添加的，默认没有这一行，用于说明
```

src/main.rs
```
fn main() {
    println!("Hello, world!");
}
```

运行：
```
➜  hello_cargo git:(master) ✗ cargo build

   Compiling hello_cargo v0.1.0 (/Users/bytedance/xiaochai/batman/RustProject/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 1.22s
➜  hello_cargo git:(master) ✗ ./target/debug/hello_cargo
Hello, world!


➜  hello_cargo git:(master) ✗ cargo run

   Compiling hello_cargo v0.1.0 (/Users/bytedance/xiaochai/batman/RustProject/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/hello_cargo`
Hello, world
```

## 猜数字例子

位于guessing_game中

```rust
// 标准库中定义的比较结果的枚举
use std::cmp::Ordering;
// 使用use语句进行包导入；rust默认会预导入(prelude)一部分常用的类型，而std::io不在此范围，需要使用use语句
use std::io;

// 首先使用了rand包，需要在Cargo.toml中添加rand = "0.8.0"
// 在run或者build的时候，会根据crates.io上的最新版本、依赖关系下载所需要的包
// rand::Rng为trait(后面解析)，gen_range定义于此Trait中
// 如果不导入，调用gen_range将报错，因为ThreadRng的对应实现定义于Rng trait中
use rand::Rng;

fn main() {
    // rand::thread_rng()将返回位于本地线程空间的随机数生成器ThreadRng，实现了rand::Rng这一trait
    // gen_range的参数签名在0.7.0的包和0.8.x的包上不一样，在旧版中支持两个参数，而新版本中只支持一个参数
    // 1..101的用法后面介绍，这一行表示生成[1,101)的随机数
    let secret_num = rand::thread_rng().gen_range(1..101);
    println!("secret number is {}", secret_num);

    // 死循环
    loop {
        // let关键字用于创建变量
        // 默认变量都是不可变的，使用mut关键字修饰可以使变量可变
        // String是标准库中的字符串类型，内部我问个他UTF-8编码并可动态扩展
        // new是String的一个关联函数(静态方法)，用于创建一个空的字段串
        let mut guess = String::new();

        println!("Guess the number!\nPlease input your guess:");

        // std::io::stdin()会返回标准输入的句柄
        // 参数&mut guess表示read_line接收一个可变字符串的引用(后面介绍)，将读取到的值存入其中
        // read_line返回io::Result枚举类型，有Ok和Err两个变体(枚举类型的值列表称为变体)
        // 返回Ok时表示正常并通过expect提取附带的值(字节数)；返回Err时expect将中断程序，并将参数显示出来
        // 不带expect时也能通过编译，但会收到Result没有被处理的警告(warning: unused `Result` that must be used)
        io::stdin().read_line(&mut guess).expect("Failed to read line");

        // Rust中允许使用同名新变量来隐藏(shadow)旧值
        // guess:u32是明确guess的类型，以此来使得让编译器推到出parse要返回包含u32的值
        // parse的返回值是一个Result枚举，有Ok和Err两个变体(枚举值)，用match来判断两种情况
        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(e) => {
                println!("Please type a number!");
                // continue回到loop开头继续
                continue;
            }
        };

        // {}为println!的占位符，第1个花括号表示格式化字符串后的第一个参数的值，以此类推
        println!("You guessed:{}", guess);

        // 模式匹配，由match表达式和多个分支组成，Rust可以保证使用match时不会漏掉任何一种情况
        // Rust会将secret_num也推导成u32与guess比较
        match guess.cmp(&secret_num) {
            Ordering::Less => println!("Too small!"),
            Ordering::Equal => {
                println!("You WIN!");
                // 退出循环
                break;
            }
            Ordering::Greater => { println!("Too big!") }
        }
    }
}
```

## 通用编程概念

本章节例子位于example/src/bin/main.rs中。

### 变量与可变性

变量默认是不可变的，这意味着一但赋值，再也无法改变：

```rust
    let x: i32;
    x = 5;
    let y: i32 = 10;
    // 以下行报错：Cannot assign twice to immutable variable [E0384]
    // y=9
```

可以变量名前添加mut使得此变量可变：

```rust
    let mut x = 10;
    x = 100;
    x = 1000;
```

常量使用const修饰，名称全部大写，并用下划线分隔；常量可以是全局的(例如main函数之外)，也可以是局部的；常量必须显示指定类型：

```rust
const MAX_SCORE: i32 = 199;
fn main() {
    // some other code 
    const MY_SCORE: i32 = 200;
    const MAX_SCORE: i32 = 299;

    // 200,299
    println!("{},{} ", MY_SCORE, MAX_SCORE);
}

```

隐藏变量是指使用相同名称来定义变量，重新定义后，之前的变量值和类型被隐藏了：

```rust
    let space = "   ";
    let space = space.len();
```

### 数据类型

Rust是一门静态语言，所以变量在编译时就确定了其数据类型。Rust的数据类型分为标量类型(scalar)和复合类型(compound)。

一般情况下，在编译器可以推断出类型的场景中，可以省略类型标注，但在无法推断的情况下，就必须显示的声明类型了。

```rust
    // 以下报错：type annotations needed
    // let k = ("32").parse().expect("not ok");
    let k: i32 = ("32").parse().expect("not ok");
```

标量类型是单个值类型的统称，有4种标量类型：整数、浮点数、布尔值及字符。

整数类型：i8、u8、i16、u16、i32、u32、isize、usize；以上除了isize和usize所占的字节数是根据平台(32位/64位)来确定的，其它的的类型都有明确的大小。

整数类型的默认推导是i32：

```rust
    // 整数类型字面量
    // 10进制，可以用下划分分隔
    let x: u32 = 98_000;
    let x: u32 = 0xff; // 十六进制
    let x: u32 = 0o77; // 八进制
    let x: u32 = 0b1111_0000; // 二进制
    let x = b'A'; // u8
```

对于整数溢出，编译期会尽可能的检查溢出可能，如果检测到，则直接编译报错。

如果使用debug编译，则在运行时发生溢出时，会触发panic；如果是release，则会执行数值环绕，从最小的重新开始记录。

```rust
    // 整数溢出
    let x: u8 = 252;
    let y: u8 =  ("32").parse().expect("not ok");
    // 以下行在debug模式下，会在运行时报错
    // thread 'main' panicked at 'attempt to add with overflow', src/main.rs:41:26
    // note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
    // 在release模式下，则不会报错，输出28
    println!("{},see!", x + y);
```

浮点数类型：f32，f64；默认推导为f64。

数值运算：加(+)、减(-)、乘(x)、除(/)、取余(%)；只有相同类型间才能进行操作：

```rust
    // 类型不一样，无法操作
    // let x:u8 = 10;
    // let y:u32 = 100;
    // let z = y+x;
```

布尔值，只拥有true和false，占据一个字节大小，常用于if的判断：

```rust
    let x:bool = false;
```

字符类型，单引号指定，是Unicode标量值，占4个字符：

```rust
    // 字符类型
    let x = 'c';
    let y = '李';
    let z:char = '李';
```

将多个不同类型的值合成一个类型，称为复合类型；Rust有两种内置复合类型：元组(tunple)和数组(array)；

元组类型，在括号内放置一系列以逗号分隔的值，即可组成元组：

```rust
    // 元组
    // 也可以省略类型，让编译器推断
    let x:(i64,f64,char) = (2,3.4, 'c');
    // 使用模式匹配来解构元组
    let (a,b,c) = x;
    // 通过点来访问元组
    println!("{},{},{}", x.0, x.1, x.2);
```

数组类型：
每一个元素必须类型一致，数组大小不可改变，在栈上分配：

```rust
    // 数组
    // 声明一个长度为5，元素为int32类型的数组；类型[i32;5]也可以省略，由编译器推断
    let x: [i32; 5] = [1, 2, 3, 4, 5];
    // 定义了一个由7个1组成的数组，即[1,1,1,1,1,1,1]
    let y = [1; 7];
    // 通过下标来访问，从0开始；以下输出3,1；下标的类型是usize的
    println!("{},{}", x[2], y[6]);
    // 越界时将发生严重错误
    // 编译时报错：index out of bounds: the length is 5 but the index is 10
    // 如果下标是运行时才确定的值，则这块的报错将在运行时报错
    // let k:usize = "10".parse().expect("not a number");
    // println!("{}", x[k]);
```


### 函数 

函数的命名由下划线分隔的多个小写单词组成：

```rust
fn my_sum(x: i32, y: i32) -> i32 {
    // 可以直接是return，也可以直接写表达式x+y，函数中将最后一个表达式的值做为返回值
    return x + y;
}
```

语句和表达式：
语句指执行操作，但不返回值的指令；表达式指进行计算并且产生结果的指令。
表达式是语句的一部分；字面量、函数调用、宏调用、新作用域的花括号都是表达式。


```rust
    // 语句，没有返回值
    let x = 6;
    // 所以不能将语句赋值给变量
    // let y = (let x = 7);
    // 以下也不行
    // let a = b = 6;
    // 花括号的代码块也是表达式，以下表达式的值为11
    let x = {
      let y = 10;
        // 注意这一行不能有分号，添加了分号后，这个代码块的值就是空元组了()
        y+1
    };
```

### 控制流

if的条件表达式必须是bool值；if表达式可以用于赋值：

```rust
    // if的用法，多分支判断，条件表达式的值只能是bool类型
    let num = 100;
    if num % 4 == 0 {
        println!("number is divisible by 4")
    } else if num % 3 == 0 {
        println!("number is divisible by 3")
    } else {
        println!("number is not divisible by 3,4")
    }

    // if为表达式，所以可以使用if来赋值
    // 此处要注意各个分支返回的数据类型要一样，否则编译期直接报错
    let condition = true;
    let x = if condition {
        10
    }else {
        20
    };
```

loop 循环：

```rust
  // loop表达式的值，可以从break返回
    let mut i = 1;
    let count = loop{
        i+=1;
        if i > 10 {
            break i
        }
        // 两个break的值类型要一样，所以以下这一行无法通过编译
        // break 'a'
    };
```

while表达式的值一直都是空值：

```rust
    // while表达式的值一直是空值，如果使用break，后面不能跟返回值
    let mut i = 1;
    let count:() = while i > 10 {
        i += 1;
    };
```

for：

```rust
    // y是一个Range<i32>类型，本身是一个迭代器；值为1,2(不包括3)
    // rev是从后往前遍历，所以这块打印的是2,1,
    let y = 1..3;
    for e in y.rev() {
        print!("{},", e)
    }
```

结尾习题：

```rust
// 摄氏温度与华氏温度的相互转换
// println!("celsius_2_fahrenheit(1):expect{}, actual:{}", 33.8, celsius_2_fahrenheit(1.0));
fn celsius_2_fahrenheit(celsius: f64) -> f64 {
    celsius * 1.8 + 32.0
}

// 生成一个n阶的斐波那契数列
// println!("fibonacci(10):expect{}, actual:{}", 34, fibonacci(10));
fn fibonacci(n: i64) -> i64 {
    if n == 1 {
        0
    } else if n == 2 {
        1
    } else {
        fibonacci(n - 1) + fibonacci(n - 2)
    }
}

// 打印圣诞颂歌The Twelve Days of Christmas的歌词，并利用循环处理其中重复的内容。
// 太长了，改成The Six Days of Christmas
// the_six_days_of_christmas();
fn the_six_days_of_christmas() {
    let num_map = ["first", "second", "third", "forth", "fifth", "sixth"];
    let gifts = ["a partridge in a pear tree",
        "two turtle doves",
        "three French hens",
        "four calling birds",
        "five golden rings",
        "six geese a-laying",
    ];

    for i in 0..6 {
        print!("On the {} day of Christmas, my true love sent to me:", num_map[i]);
        let mut j = i;
        while j > 0 {
            print!("{},", gifts[j]);
            j -= 1;
        }
        // 最后一个礼物不需要逗号
        println!("{}.", gifts[0]);
    }
}
```

## 所有权


不同语言管理内存的方式：

* Java：通过垃圾回收来管理内存；

* C/C++：开发者手动地分配和释放；

* Rust：通过应用所有权系统规则，在编译期间检查，来保证内容安全。

所有权系统使得Rust在没有垃圾回收的情况下，保证内存安全。其所有权规则包含以下三个规则：

1. <strong>Rust中每一个值都有一个变量作为他的所有者；</strong>

2. <strong>在同一个时间内，值有且仅有一个所有者；</strong>

3. <strong>当所有者离开他的作用域时，他所持有的值将被释放。</strong>

使用域的概念与其它语言类似，不再赘诉。

以下例子位于example/src/bin/main.rs中。

### String类型介绍

字符串的字面量是编译进二进制文件中，但运行时可动态变化的字符串类型则需要存储到堆上。

```rust
    // 字符串类型在堆上分配
    // String::from方法，使用字符串字面量来创建String类型，这里s必须是可变的
    let mut s = String::from("Hello");
    s.push_str(", world");
    println!("{}", s)
```

下面以例子的方式来说明所有权的动作规则：

```rust
    let s1 = String::from("Hello");
    let s2 = s1;
    println!("{}", s1)
```

String类型由两大部分组成，存储于栈上的元信息(ptr, len, cap)，即指向堆上的指针，字符串长度，分配容量；而实际的内容保存在ptr所指的堆上，如下图：

![字符串类型内存部局](/assets/images/string_mem_1.jpeg)

将s1赋值给s2时，由于Rust不会对堆上值也进行拷贝，只会将栈上的元数据进行拷贝，所以目前的状态有可能是s1，s2所指向的String元数据中的指针都指向了同一片堆区域。

![字符串类型内存部局](/assets/images/string_mem_2.jpeg)

在s1和s2变量离开作用域后，Rust会自动执行对应类型上的drop方法，释放对应的内存，问题就产生了，这将产生二次释放问题。

为了解决这个问题，Rust在种情况下，会将s1的变得无效，这就是之前例子中第三行无法通过编译的原因。

这种只有拷贝了栈上的数据而没有拷贝堆上的数据的浅拷贝，在Rust中称为移动(move)，上面例子中，s1被移动到s2了

Rust永远不会自动地创建数据的深度拷贝。因此在Rust中，任何自动的赋值操作都可以被视为高效的。


如果确实需要使用深拷贝，可以使用clone函数，如下例子可以通过编译

```rust
    // 对s1进行深拷贝，即将堆上的内容也进行了拷贝
    let s1 = String::from("Hello");
    let s2 = s1.clone();
    println!("{}, {}", s1, s2);
```

对于完全存储在栈上的数据，赋值本身已经将全部数据都拷贝，所以不用调用clone方法。**在Rust中，实现了Copy trait的类型，都可以在将变量赋值给其它变量时原变量保持可用**。

所有的标量类型都实现了Copy trait；元组或者数组中包含的元素是Copy的，则元组或者数组就是Copy的：

```rust
    // 如果这个元组加了String类型，如下，则不能通过编译
    let x = (1,2,3.0);
    // let x = (1, 2, 3.0, String::from("Hello"));
    let y = x;
    println!("{}", x.1);

    let x = [1, 2, 3];
    let y = x;
    println!("{}", x[1]);
```

**注意Copy和Drop是互斥的，如果一个类型本身或者成员变量实现了Copy，则这个类型就无法实现Drop**。

### 函数与所有权

函数参数与赋值是一样的，返回值也是一样的：

```rust
    fn take_owner(s: String) {}
    let s = String::from("hello");
    take_owner(s);
    // 将发生编译错误，因为s的所有权移进了take_owner中
    // println!("{}", s);

    fn take_owner_and_return(s: String)->String{
        // 函数又将s的所有权转移到返回值，所以s不会被drop掉
        return s;
    }
    let s1 = String::from("hellow");
    let s2 = s1;// 到这里，s1已经失效
    let s3 = take_owner_and_return(s2); // 到这里s2已经失效
    // 这里只有s3可用，其它的s1,s2失效

```

### 引用与借用

```rust
    // 引用传递时，并不取得所有权，但可以使用值
    fn get_len(s: &String) -> usize {
        // s是一个不可变引用，所以无法对s的值进行改变
        // 以下无法通过编译
        // s.push_str(", world");
        return s.len();
    }
    let s1 = String::from("hello");
    // s2为可变引用，默认的引用不可变
    let mut s2: &String = &s1;
    let mut s3 = String::from("hello");
    // 注意s2为可变引用的意思是可以改变s2引用到哪个值，而不能改变s2引用的值
    // 以下无法通过编译， 报错: cannot borrow `*s2` as mutable, as it is behind a `&` reference
    // s2.push_str(", world");
    // 因为两行可以运行，因为s2是可变引用，而且s3是可变String
    s2 = &mut s3;
    // 虽然s2引用了可变的s3，但由于s2的类型是&String不是&mut String，所以到下这一行还是无法通过编译
    // s2.push_str(", world");
    // 获取s1的长度，而不取得s1的所有权
    let size = get_len(&s1);
    {
        let s4 = String::from("you");
        // 由于s4的生命周期比s2短，所以s2无法引用s4，这避免了悬垂指针的出现
        // s2 = &s4;
    }
    // 在这里s1还是能用
    println!("{},{},{},{}", s1, s2, size, s1);
```

通过引用，可以在不取得所有权的情况下，使用对应值。当引用离开作用域时，由于不持有所有权，所以也不会释放所指向的值。

引用分成可变引用和不可变引用，但这块的可变是指可以改变指向哪个值，而无法改变值本身，注意以下两组的区别：

```rust
    let mut s:String = String::from("hello");
    let s1:&mut String = &mut s;
    s1.push_str(",world");

    let mut s:String = String::from("hello");
    let mut s2:&String = &mut s;
    // 以下无法通过编译，因为s2是&String不可变类型
    s2.push_str(", world");
```

另外，只能申明一个可变引用，如果某个变量已经被可变引用了，也不允许再被不可变引用。这可以很好的避免数据竞争：

```rust
    let mut s = String::from("hello");
    let s1 = &mut s;
    // cannot borrow `s` as mutable more than once at a time
    // let s2 = &mut s;
    // cannot borrow `s` as immutable because it is also borrowed as mutable
    // let s3 = &s;
    println!("{},{}, {}", s1, s2, s3);
```

总结出来以下规则：

1. **在任何一段给定的时间里，要么只能拥有一个可变引用，要么只能拥有任意数量的不可变引用**。

2. **引用总是有效的**。

### 切片

```rust
    // 字符串切片，类似与go，获取[begin,end)之间的内容，注意end最大是字符串的长度，超过后会报错
    let s = String::from("0123456789");
    // 以下两个hello和world等价
    let hello = &s[0..5];
    let hello: &str = &s[..5];
    let world = &s[5..10];
    let world = &s[5..];
    // 01234,56789
    println!("{},{}", hello, world);

    // 获取第一个单词，返回字符串切片
    // 这里的函数参数也可以使用&str，可以更通用
    fn first_world(s: &String) -> &str {
        // s.as_bytes()将字符串转成字节数组&[u8]
        // iter返回迭代器，enumerate将每一个元素按元组的形式返回
        for (i, &item) in s.as_bytes().iter().enumerate() {
            // 判断是空格，直接返回切片
            if item == b' ' {
                return &s[0..i];
            }
        }
        &s[..] // 使用&s也可以
    }
    // 输出hello
    println!("{}", first_world(&String::from("hello world")));

    let mut s = String::from("0123456789");
    let t = first_world(&s);
    // 以下无法通过编译，因为s已经是不可变引用了，s.clear又使用了可变引用
    // cannot borrow `s` as mutable because it is also borrowed as immutable
    // s.clear();
    println!("{},{}", s, t);
```

字符串字面量就是字符串切片，切片包括指向值的指针和长度。

其它类型的切片：

```rust
    // 其它切片
    let ia = [1, 2, 3, 4, 5, 6];
    let sia: &[i32] = &ia[1..3];
```

## 结构体

结构体的一些规则：(以下例子位于example/src/bin/main.rs中)

1. 一个结构体的实例是可变的，则这个结构体的所有成员变量都是可变的；

2. 在创建结构体实例时，如果变量名与字段名同名时，可以省略字段名，直接写变量名；

3. 可以使用```..old```这种语法来快速从old创建一个只有部分值改变的新变量；

4. 支持不带字段名的元组结构体；

5. 支持空结构体；

6. 如果结构体的成员是引用时，需要带上生命周期的标识。

```rust
    // 结构体定义
    struct User {
        username: String,
        email: String,
        sign_in_count: u64,
        active: bool,
    }
    // 创建实例
    let mut user1 = User {
        username: String::from("xiaochai"),
        email: "soso2501@mgail.comxxx".to_string(),
        sign_in_count: 1,
        active: true,
    };
    println!("{}", user1.email); // soso2501@mgail.comxxx
    // 访问和修改，注意一旦实例可变，则实例的所有成员都可变
    user1.email = String::from("soso2501@mgail.com");
    println!("{}", user1.email); // soso2501@mgail.com

    fn build_user(email: String, username: String) -> User {
        User {
            username, // 由于变量名了字段同名，所以可以省略掉字段名
            email,
            sign_in_count: 1,
            active: true,
        }
    }
    let mut user1 = build_user("soso2501@mgail.com".to_string(), "xiaochai".to_string());
    let mut user2 = User {
        username: "xiaochai2".to_string(),
        // 可以使用以下语法从user1复制剩下的字段
        ..user1
    };
    user1.email = "sosoxm@163.com".to_string();
    // soso2501@mgail.com,sosoxm@163.com
    println!("{},{}", user2.email, user1.email);

    // 元组结构体
    // 当成员变量没有名字时，结构体与元组类似，称为元组结构体
    struct Point(u32, u32, u32);
    let origin = Point(0, 0, 0);
    // 可以使用数字下标来访问
    println!("{},{},{}", origin.0, origin.1, origin.2);
    // 也可以通过模式匹配来结构
    let Point(x, y, z) = origin;
    println!("{},{},{}", x, y, z);

    // 空结构体，一般用于trait
    struct Empty{}

    // 如果结构体的成员是引用时，需要带上生命周期的标识
    struct User2<'a> {
        username: &'a str,
    }
```

### 实例

结构体的应用举例：

1. 通过结构体来更清晰表达字段含义；

2. 使用注解来快速实现trait，使得可以在println!中使用```{:?}```和`{:#?}`来输出自定义结构体；

3. 使用impl关键字为结构体实现方法；

4. 方法第一个参数如果是self，可以是获得所有权(self)，也可以是借用(&self)，还可以是可变的(&mut self或者是mut self)；

5. 同一个结构体，可以写多个impl，但不能多次定义同一个方法，即使参数不一样也不行；

6. 如果方法的第一个参数不为self，则称为关联函数，类似与静态方法。

```rust
    // 使用结构的例子，说明trait的使用
    #[derive(Debug)] // 添加注解来派生Debug trait
    struct Rectangle {
        width: u32,
        height: u32,
    }
    fn area(rect: &Rectangle) -> u32 {
        rect.width * rect.height
    }
    let rect1 = Rectangle { width: 10, height: 20 };
    // {:?}需要结构体实现Debug这一trait，也可以使用{:#?}来分行打印
    // the area of rectangle Rectangle { width: 10, height: 20 } is 200
    println!("the area of rectangle {:?} is {}", rect1, area(&rect1))

    // 为结构体定义方法
    impl Rectangle {
        // 方法的第一个参数永远是self
        fn area(&self) -> u32 {
            self.height * self.width
        }
    }
    println!("the area of rectangle {:?} is {}", rect1, rect1.area());

    impl Rectangle {
        // 以下无法通过编译，因为area重复定义了
        // fn area(&self, i: i32) -> u32 {
        //     self.height * self.width
        // }
        fn can_hold(&self, rect2: &Rectangle) -> bool {
            self.width > rect2.width && self.height > rect2.height
        }
        // 关联函数
        fn new(width: u32, height: u32) -> Rectangle {
            Rectangle {
                width,
                height,
            }
        }
    }
    println!("the area of rectangle {:?} is {}", Rectangle::new(3, 2), Rectangle::new(2, 3).area());
```

## 枚举

1. 枚举使用enum关键字定义，每一个枚举值称之为变体(variant)；

2. 每一个变体可以有不同的数据类型和数量的数据关联；

3. 枚举相校与结构体不同的地方在于，如果对变体的不数数据定义各自的结构，则他们属于不同类型，而使用枚举则可以使用一种类型来描述不同的数据结构；

4. 同样可以为枚举实现方法；

5. 使用match模式匹配处理每一种变体，必须处理所有的变体，否则编译不通过；当然可以使用通配符来匹配任意值/类型；

6. match还可以绑定匹配对应的部分值。

以下例子位于example/src/bin/main.rs中：

```rust
    enum IPAddr {
        // 变体中可以保存数值
        IPV4(u32, u32, u32, u32),
        IPV6(String),
    }
    // 可以为枚举定义函数
    impl IPAddr {
        fn print(&self) {
            // 使用match来处理每一种变体，注意需要处理所有变体，否则编译保险错
            match self {
                // 模式匹配可以直接解构变体内的数值
                IPAddr::IPV4(u1, u2, u3, u4) =>
                    println!("{}.{}.{}.{}", u1, u2, u3, u4),
                IPAddr::IPV6(s) => println!("{}", s),
            }
        }
    }
    let ipv4 = IPAddr::IPV4(1, 2, 3, 4);
    let ipv6 = IPAddr::IPV6("::1".to_string());
    ipv4.print();
    ipv6.print();
```

预导入库中的非常常用的Option类型，用在需要表示空值的场景，其定义为(省略了注解):

```rust
pub enum Option<T> {
    None,
    Some(T),
}
```
这里的\<T\>为泛型参数，None表示空值，Some表示有值，并持有值：

```rust
    // 标准库中的Option类型
    // 为一个Option值加1
    fn plus_one(c: Option<i32>) -> Option<i32> {
        match c {
            None => None,
            Some(i) => Some(i + 1)
        }
    }
    let five = plus_one(Some(4));
    let none = plus_one(None);
    match five {
        None => println!("none"),
        Some(i) => println!("val is {}", i)
    };
    match none {
        None => println!("none"),
        Some(i) => println!("val is {}", i)
    };

    // 必须匹配每一个可能的值
    let c = 2;
    match c {
        1 => println!("is 1"),
        2 => println!("is 2"),
        // 如果没有以下这一行，则编译报错
        // non-exhaustive patterns: `i32::MIN..=0_i32` and `3_i32..=i32::MAX` not covered
        _ => println!("other")
    }
```

在只关心某一种匹配而忽略其它匹配的时候，可以使用if let来简化代码：

```rust
    // 使用if let来简化处理
    let five: Option<i32> = Some(5);
    if let Some(i) = five {
        println!("has value {}", i)
    }
```

## 包管理

* 包(package：一个用于构建、测试并分享单元包的Cargo功能；

* 单元包(crate)：一个用于生成库或可执行文件的树形模块结构；

* 模块(module)及use关键字：它们被用于控制文件结构、作用域及路径的私有性；

* 路径(path)：一种用于命名条目的方法，这些条目包括结构体、函数和模块等。

以下为关于包的一些定义和规则：

* 用于生成可执行程序的的单元包称为二进制单元包;

* 用于生成库的单元包称为库单元包；

* 一个包至少要有一个单元包，并且最多只能包含一个库单元包，但可以包含多个二进制单元包；

* Rust编译时所使用的入口文件被称为根节点，例如src/main.rs；

* src/main.rs和src/lib.rs做为默认的二进制单元包和库单元包的根节点，无需在cargo.toml中指定；

* mod关键字可以定义模块，模块内可以嵌套定义子模块；

* 可以使用两模式定位到模块内的函数/枚举等：1. 使用单元包名或字面量crate从根节点开始的绝对路径；2. 使用单元包名或字面量crate从根节点开始的绝对路径；

* Rust中所有的条目包括函数、方法、结构体、枚举、模块、常量默认都是私有的；

* 对于模块来说，父级模块无法使用其子模块中的私有的条目，而子模块可以使用所有祖先模块中的条目；

* 公开的结构体其成员默认还是私有的，公开枚举时，其变体自动变成公开。

以下例子位于restaurant项目中：

```rust
// 定义模块，可以嵌套子模块
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}

        pub fn seat_at_table() {}
    }

    pub mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}

        mod back_of_house {
            fn fix_incorrect_order() {
                // 使用super关键字引用父模块的，由于子模块可以使用父模块的所有条目，包括私有
                super::serve_order();
                cook_order();
            }

            fn cook_order() {}

            pub struct Breakfast {
                pub toast: String,
                // 虽然结构体是公有的，但字段默认还是私有的，需要用pub指定
                season_fruit: String,
            }

            impl Breakfast {
                pub fn summer(toast: &str) -> Breakfast {
                    Breakfast {
                        toast: String::from(toast),
                        season_fruit: String::from("peaches"),
                    }
                }
            }

            pub enum Appetizer {
                // 以下两个变体是公开的
                Soup,
                Salad,
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // 以下两种调用是等价的
    // 使用绝对路径，从crate关键字（即根节点）开始
    crate::front_of_house::hosting::add_to_waitlist();
    // 使用相对路径，从当前模块开始
    front_of_house::hosting::add_to_waitlist();
}
```

* 使用use关键字可以简化引用路径；

* 使用as关键字使用新的名称，可以解决重名的问题；

* 使用pub use重导出名称，使用pub use的名称不仅在本作用域内可以使用，外部也可以通过引入本作用域来调用到pub use导出的包。可以用于重新组织包结构；

* 使用外部包与使用std包类似，只是需要在cargo.toml文件中的dependencies小节中添加包名以及对应的版本；

* 如果要导入一个树型包中的几个包，可以使用嵌套的语法来减少use语句的使用。


```rust
// 使用use关键字可以简化路径
// 以下两行等价，self关键字可能在后续版本中去掉
use front_of_house::hosting;
// use self::front_of_house::hosting;

pub fn eat_at_restaurant2() {
    hosting::add_to_waitlist();
}

// 为防止重名，使用as来重命名
use std::fmt::Result;
use std::io::Result as IOResult;
// 等价于导入std::cmp::Ordering和std::io这两个包
use std::{cmp::Ordering, fs};
// 等价于导入std::io和std::io::Write这两个包
use std::io::{self, Write};
// 导入std::collections下的所有包，一般不推荐，容易造成命名冲突
use std::collections::*;
pub fn test(){
    Result::Ok(());
    IOResult::Ok("FD");
}
```

可以将模块的层级关系使用目录关系来组织起来，例如原例子中在libs下面创建如下关系的包：

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}

        pub fn seat_at_table() {}
    }
```

可以将front_of_house移到front_of_house.rs中，则以下两个文件变成：

```rust
// 以下是位于lib.rs
mod front_of_house;
```


```rust
// 以下位于front_of_house.rs中
pub mod hosting {
    pub fn add_to_waitlist() {}

    pub fn seat_at_table() {}
}
```

也可以将front_of_house.rs再拆分：


```rust
// libs.rs
mod front_of_house;
```

```rust
// front_of_house.rs
mod hosting;
```

```rust
// front_of_house/hosting.rs
pub fn add_to_waitlist() {}
pub fn seat_at_table() {}
```

## 集合

以下例子位于example/src/bin/collection.rs中：

### 动态数组

* 动态数组Vec是范型，在无法推断类型时，必须显示指定类型；

* 使用vec!宏可以快速构建有初始值的数组；

* 数组中的元素会在动态数组销毁时跟着销毁；

* 数组元素的引用会对整个数组造成影响，即不可以在有只读引用的情况下push元素；

* 结合枚举，可以间接地在Vec中存储多种不同的类型。

```rust
    // 创建一个动态数组
    let v: Vec<i32> = Vec::new();
    // 使用vec!宏来快速创建一个带有初始值的数组
    let v = vec![1, 2, 3];
    // 必须是mut的动态数组才能push进数据
    let mut v: Vec<i32> = Vec::new();
    // 往动态数组里添加数据
    v.push(5);
    v.push(6);

    // 获取数组元素的引用，如果数组越界将发生panic
    let e1: &i32 = &v[0];
    // 返回Option<&T>类型，如果不越界将返回Option
    let e2: Option<&i32> = v.get(0);

    // 注意数组元素的引用会对整个数组造成影响，这就导致了在只读引用存在的情况下无法往数组中push元素
    // 以下行无法通过编译：cannot borrow `v` as mutable because it is also borrowed as immutable
    // v.push(7);
    println!("{}", e1);

    // 使用for来遍历所有元素，这里的i为&i32
    for i in &v {
        // 5 6
        println!("{}", i)
    }
    // 这里的i值为&mut i32
    for i in &mut v {
        // 将i解引用，指向对应的值，并修改
        *i *= 2;
    }
    for i in &v {
        // 10 12
        println!("{}", i)
    }
```

### 字符串

* 字符串本身是基于字节的集合，通过功能性的方法将字节解析为文本；

* Rust语言核心部分只有一种字符串类型，即字符串切片str，通常以引用形式出现(&str)，它是指向存储在别处的一些UTF8编码字符串的引用，例如字符串字面量；

* String类型定义在标准库中，不是语言核心的一部分，提供UTF8编码；

* 标准库还提供了OsString，OsStr，CString和CStr，一般以Str结尾的是借用版本，String结尾是所有权版本。这些类型提供了不同的编码或者不同内存布局的字符串类型；

* String类型实际使用Vec\<u8\>进行封装；

* 为了避免出现多字节情景下你拿到半个字符，所以Rust不允许使用下标访问获取字符串的字符。而是通过特定的功能函数指定对字节，字符，字形簇进行处理；

* 但是Rust却允许字符串切片的使用，但使用时要格外小心，因为如果截取的范围不是有效的字符串，将发生panic。

```rust


    // 字符串字面量是&str类型
    let c: &str = "ab";
    println!("{}", c);
    // 创建一个新空字符串
    let s: String = String::new();
    // 从字面量创建一个字符串的两种方法，String::from的静态方法，&str的to_string方法
    let s = String::from("hello");
    let s = "hello".to_string();
    // 修改字符串
    let mut s = String::from("abc");
    // 往后添加字符串，push_str的参数是引用的形式&str
    s.push_str("def");
    // 插入单个字符，单个字符使用单引号
    s.push('g');
    // 使用+号拼接字符串，加号的左边是String类型，右边是&str类型，左边的变量的所有权将被加号获取而不再有效
    let s1 = String::from("hello");
    let s2 = String::from(", world");
    // s1 的所有权将被转移，不再可用，而s2由于使用引用，所以可以继续使用
    // 加号的第二个签名是&str，而我们传入的是&String也是合法的，因为Rust使用使用解引用强制转换的技术，将&s2转化为&s2[..]
    // &s2[..] 是&str类型
    let s = s1 + &s2;
    println!("{},{}", s, s2);
    let k:&str = &s[2..];
    // 使用format!宏来拼接字符串，format!不会夺取任何参数的所有权
    let s = format!("{}, {}! {}.", "hello", "world", "lee");
    println!("{}", s);
    // String采用utf-8编码，所以一个中文占用3个字节；以下输出3
    println!("{}", "我".to_string().len());
    // 虽然字符串不允许使用下标直接访问，但可以使用切片获取某个范围的字符串
    println!("{}",  &s[0..1]);
    let s = "我是中国人".to_string();
    // 需要注意如果切片的范围不是一个合法的字符串，则会直接panic
    // 以下将发生运行时panic：thread 'main' panicked at 'byte index 1 is not a char boundary; it is inside '我' (bytes 0..3) of `我`', src/main.rs:69:21
    // println!("{}", &s[0..1]);

    // 使用chars函数，可以获取根据编码获取字符串中的字符值
    for i in s.chars(){
        println!("{}", i);
    }
    // 与此相对，使用bytes，则获取每一个字节的内容
    for i in s.bytes(){
        println!("{}", i);
    }
```

### HashMap

HashMap并没有在预加载库中，所以需要使用`use std::collections::HashMap;`进行导入。

HashMap如果键和值实现了CopyTrait，则会复制一份。如果持有所有权的类型，则会将所有权转移到HashMap中。如果是引用类型，则不会取得所有权，由生命周期保证引用的有效性。

```rust
    use std::collections::HashMap;
    // 初始化一个hashmap，不指定类型，编译器可以从h.insert里推断出类型来为HashMap<&str,i32>
    let mut h = HashMap::new();
    h.insert("lee", 1220);
    // 使用Vec来构建HashMap
    let teams = vec![String::from("blue"), String::from("yellow")];
    let scores = vec![10, 50];
    // h的类型声明是必须的，因为collect可以返回多种类型，需要明确这里需要返回的类型，但是泛型可以使用_代替，由编译器来推断
    // h的类型为HashMap<&String, &i32>
    let mut h: HashMap<_, _> = teams.iter().zip(scores.iter()).collect();
    // 获取HashMap中的值，注意这里的值是&String，不能直接使用&str
    let blue = String::from("blue");
    // get函数获取的值为Option，如果不存在，则返回None
    // get取得的结果是value的引用值，在这个场景中为&&i32
    let blue_team_score = match h.get(&blue) {
        // 由于值是&&i32，所以需要两次解引用成i32值，否则与None的返回值不匹配
        Some(i) => **i,
        None => 0,
    };
    println!("{}", blue_team_score);
    // 使用for循环获取HashMap里的值，由于使用&h，所以这里的key为&&String，value为&&i32
    for (key, value) in &h {
        println!("key:{}, value:{}", key, value);
    }


    let k = String::from("blue");
    // 更新值，如果是直接覆盖，使用insert即可
    h.insert(&k, &20);
    // 通过entry函数返回Entry枚举类型，其or_insert方法可以判断值是否存在，不存在则插入，存在则不处理
    // 其返回HashMap中value的可变引用，在此为&mut &i32，可以对其进行修改
    let e = h.entry(&k).or_insert(&30);
    *e = &11;
    // {"blue": 11, "yellow": 50}
    println!("{:?}", h);

    // 例子，查看一个字符串中每一个字符出现的次数
    let text = "hello world hello lee ok";
    let mut map = HashMap::new();
    for i in text.split_whitespace() {
        let count = map.entry(i).or_insert(0);
        *count += 1;
    }
    // {"ok": 1, "world": 1, "lee": 1, "hello": 2}
    println!("{:?}", map);
```

## 错误处理

* 不可恢复错误：使用panic!宏，其参数与println!类似，支持占位符；

* 访问Vec越界也会产生panic；

* 在cargo.toml中的profile.release节添加`panic= 'abort'`来减少bin文件的大小(因为减少了栈展开所需要的信息)；

* 添加`RUST_BACKTRACE=1`可以输出更加详细的panic信息，例如`cargo run --bin error --release`；

* 如果是可恢复错误，使用Result<T, E>做为返回值来处理包含正常情况和异常情况，正常情况下返回Ok(T)，异常时返回Err(E)。

```rust
enum Result<T, E>{
    Ok(T),
    Err(E),
}
```

以下例子位于example/src/bin/error.rs：

```rust
    let file_name = "Cargo.toml";
    // 对于有可能出错的函数可以返回Result，Ok表示正常返回，Err表示异常
    let mut f = match File::open(file_name) {
        Ok(file) => file,
        Err(e) => panic!("open file error:{:?}", e),
    };
    // 读取文件的内容，并输出
    let mut c = String::new();
    f.read_to_string(&mut c);
    println!("{}", c);

    let file_name = "hello.txt";
    let f = match File::open(file_name) {
        Ok(file) => file,
        // 使用e.kind()为区别不一样的类型
        Err(e) => match e.kind() {
            // 不存在的时候就创建，返回成功创建的句柄
            ErrorKind::NotFound => match File::create(file_name) {
                Ok(file) => file,
                Err(e) => panic!("create file error:{:?}", e),
            },
            // 其它错误统一命中这个分支，报错panic
            other_error => panic!("open file error:{:?}", other_error),
        }
    };

    // 使用Result.unwrap()函数来快速获取Ok的值，如果是Err，则直接panic
    let f: File = File::open(file_name).unwrap();
    // 与unwrap一样，只是传入了一个字符串做为panic时的信息
    let f: File = File::open(file_name).expect("Fail to open file");

    // 传播错误
    // 以下函数的功能等同于std::fs::read_to_string(file_name)
    fn get_content_by_file_name(name: &str) -> Result<String, io::Error> {
        let mut f = match File::open(name) {
            Ok(file) => file,
            Err(e) => return Err(e),
        };
        // 读取文件的内容，并输出
        let mut c = String::new();
        return match f.read_to_string(&mut c) {
            Ok(_) => Ok(c),
            Err(e) => Err(e),
        };
    }
    // 使用?运算符简化写法
    // 注意使用?运算符与match不一样的地方是在Err类型不匹配的时候，会自动调用from函数进行隐式转换(需要实现From trait)
    fn get_content_by_file_name2(name: &str) -> Result<String, io::Error> {
        // 如果需要将Result的Err返回，则在最后使用?表达式来达到目的
        let mut f = File::open(name)?;
        // 读取文件的内容，并输出
        let mut c = String::new();
        f.read_to_string(&mut c)?;
        Ok(c)
    }
    // 使用链式调用更加简化写法
    fn get_content_by_file_name3(name: &str) -> Result<String, io::Error> {
        let mut c = String::new();
        File::open(name)?.read_to_string(&mut c)?;
        Ok(c)
    }
```

## 泛型、Trait、生命周期

### 泛型


泛型代码的性能问题：Rust在编译期间将泛型代码单态化(monomorphization)，即将泛型代码根据调用时的类型生成对应的代码。所以不会对运行时造成性能影响。例如 Option\<T\>类型在应用到i32和i64上时，生成了以下两种类型Option_i32，Option_i64。

以下例子位于example/src/bin/generic.rs：

```rust
fn main() {
    // 在方法中使用泛型，在函数名称后添加尖括号，并在括号中添加类型说明，
    // <T:PartialOrd + Copy>表示这个类型必须实现PartialOrd和Copy这两个Trait
    // 参数为对应类型的数组切片，返回对应类型的值
    // 由于对元素使用了大于比较计算符，所以类型T必须实现std::cmp::PartialOrd
    // 由于需要从list[0]中取出数据，所以需要实现Copy；也可以使用引用来处理
    fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
        let mut max = list[0];
        for &item in list.iter() {
            if item > max {
                max = item
            }
        }
        max
    }
    // 使用引用的版本，不需要实现Copy
    fn largest2<T: PartialOrd>(list: &[T]) -> &T {
        let mut max = &list[0];
        for item in list.iter() {
            if *item > *max {
                max = item
            }
        }
        max
    }
    println!(
        "{},{},{}, {}",
        largest(&[1, 2, 3, 4, 5, 6, 9, 3, 4, 6]),
        largest(&[1.0, 3.0, 1.1, 5.5, -1.0, -2.4]),
        // 动态数组可以转化为数组切片
        largest(&vec![1, 2, 3, 4, 5, 4, 3, 2, 1]),
        largest(&vec!['a', 'b', 'e', 'd', 'k', 'i', 'g']),
    );

    // 在结构体中使用泛型，在结构体名之后使用尖括号来声明
    struct Point<T> {
        x: T,
        y: T,
    }
    impl<T> Point<T> {
        fn x(&self) -> &T {
            &self.x
        }
        // 在泛型的结构里定义泛型的方法
        fn other<U>(&self, other: Point<U>) -> Point<U> {
            other
        }
    }

    // 在枚举中使用泛型，我们之前看到的Option和Result都有使用，不再举例
    enum Option<T> {
        Some(T),
        None,
    }
    enum Result<T, E> {
        Ok(T),
        Err(E),
    }
}
```

### Trait 

* trait是指某些特定类型拥有的，而且可以被其它类型所共享的功能集合，类似于其它语言的interface。

* **实现trait的代码要么位于trait定义的包中，要么位于结构体定义的包中，而不能在这两个包外的其它包中，这个规则称之为孤儿规则，是程序一致性的组成部分**。

以下例子位于example/src/bin/trait.rs：

```rust
    // 定义多种文章共有的摘要功能trait
    pub trait Summary {
        fn summarize(&self) -> String;
        // trait也可以提供一个默认实现，这样实现了这一trait的结构体，如果没有提供实现，则以默认实现为准
        fn summarize2(&self) -> String {
            String::from("Read more")
        }
    }

    pub struct NewsArticle {
        pub headline: String,
        pub location: String,
        pub author: String,
        pub content: String,
    }
    // 为某一个结构实现trait，使用关键字impl和for
    // 实现的trait跟普通函数一样，可以被调用
    impl Summary for NewsArticle {
        fn summarize(&self) -> String {
            format!("{},{},{}", self.headline, self.author, self.location)
        }
    }
    pub struct Tweet {
        pub username: String,
        pub content: String,
        pub reply: bool,
        pub retweet: bool,
    }
    impl Summary for Tweet {
        fn summarize(&self) -> String {
            format!("{},{}", self.username, self.content)
        }
        // 重载了默认实现，这样就无法调用到默认实现了
        fn summarize2(&self) -> String {
            format!("summarize2....")
        }
    }
    let tweet = Tweet {
        username: "lee".to_string(),
        content: "content".to_string(),
        reply: false,
        retweet: false,
    };
    // trait实现的函数，可以像普通函数一样调用，summarize2调用则是默认的实现
    println!("tweet: {}, summary2:{}", tweet.summarize(), tweet.summarize2());

    // 将trait作为参数
    // 这个函数接收实现了Summary trait的结构体类型，在这里可传入Tweet和NewsArticle
    pub fn notify<T: Summary>(item: &T) {
        println!("breaking news1:{}", item.summarize())
    }
    notify(&tweet);
    // 可以使用impl形式的语法糖来简化写法，与之前的一致
    // 是否简化也区别于实际场景，例如多个函数使用同一个约束时，使用泛型表达式则更加方便
    pub fn notify2(item: &impl Summary) {
        println!("breaking news2:{}", item.summarize())
    }
    notify2(&tweet);

    // 使用多个约束时使用+号来处理，这里的item必须实现Display和Summary两个trait
    pub fn notify3<T: Display + Summary>(item: T) {}
    // 在复杂情况下使用where语句可以使得函数签名更清晰，以下两种方式是等价的
    fn some_func<T: Display + Clone, U: Clone + Debug>(t: T, u: U) -> i32 { 1 }
    fn some_func2<T, U>(t: T, u: U) -> i32 where T: Display + Clone, U: Clone + Debug { 1 }

    // 可以返回可以使用impl形式，但只能返回一中类型，要么是Tweet，要么是NewsArticle，不能在不同的分支返回两种类型
    fn return_summarizable() -> impl Summary {
        Tweet {
            username: "".to_string(),
            content: "".to_string(),
            reply: false,
            retweet: false,
        }
    }
    // 以下无法通过编译，对于泛型，需要深入研究一下机制，为什么以下函数无法通过编译
    // fn return_summarizable2<T: Summary>(item:T) -> T {
    //     Tweet {
    //         username: "".to_string(),
    //         content: "".to_string(),
    //         reply: false,
    //         retweet: false,
    //     }
    // }

    // 使用trait约束来有条件地实现方法
    struct Point<T> {
        x: T,
        y: T,
    }
    // 为所有类型的T的Point实现new方法
    impl<T> Point<T> {
        // 大写的Self与小写的self区别
        fn new(x: T, y: T) -> Self {
            Point { x, y }
        }
    }
    // 只为实现了PartialOrd和Display的Point实现cmp方法
    impl<T: PartialOrd + Display> Point<T> {
        fn cmp(&self) {
            if self.x > self.y {
                println!("x>y")
            } else {
                println!("x<=y")
            }
        }
    }
    // 也可以使用一个trait约束来实现另外一个trait，称之为覆盖实现(blanket implementation)
    // 例如以下的例子，为了实现了Display的类型实现Summary方法
    impl<T: Display> Summary for T {
        fn summarize(&self) -> String {
            format!("read more:{}", self)
        }
    }
    // 以下例子无法通过编译，因为Display不在此包中，T这一也不在此包中，受孤儿规则限制，将报错
    // 报错：Only traits defined in the current crate can be implemented for arbitrary types [E0117]
    // impl<T: Summary> Display for T {
    //     fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
    //         write!(f, "({}, {})", self.x, self.y)
    //     }
    // }

    // 因为上面为实现Display的类型实现了Summary，而i32实现了Display，所以i32实现了Summary
    // 输出read more:2
    println!("{}", 2.summarize());
```

### 生命周期

* 生命周期大部分情况下可以推导出来，当无法推导时，就必须手动标注生命周期；

* 生命周期最主要的目的是避免悬垂引用，进而避免程序引用到非预期的数据；

* Rust中不允许空值的存在；

* 借用检查器(borrow checker)：用于检查各个变量的生命周期长短，以判断引用是否合法。

生命周期的标注：

* 生命周期的标注以单引号开始，后跟小写字母(通常情况下)，通常非常简短，例如```'a```；

* 标注跟在&之后，并使用空格与引用类型区分开，例如`&'a i32`、`&'a mut i32`等。

每一个引用都有生命周期，而函数在满足一定条件下，可以省略生命周期声明，称为生命周期省略规则。

使用以下三条规则计算出生命周期后，如果仍然有无法计算出生命周期的引用时，则编译出错：

1. 每一个引用参数都有自己的生命周期，这一条用于计算输入生命周期；

2. 只存在一个输入生命周期时，这个生命周期将赋值给所有的输出生命周期参数，这一条用于计算输出生命周期；

3. 当拥有多个输入生命周期参数，而其中一个是&self或&mut self时，self的生命周期会被赋予给所有的输出生命周期参数。这条规则使方法更加易于阅读和编写，因为它省略了一些不必要的符号。

以下例子位于example/src/bin/live_time.rs：

```rust
    let mut r = &2;
    {
        let x = 5;
        // 以下无法通过编译，因为x在内部作用域内，而r在main作用域，r的生命周期大于x，无法使用x的引用。
        // `x` does not live long enough
        // r = &x
    }
    println!("{}", r);

    // 如果不加生命周期标注的话，无法确定返回值的生命周期，无法通过编译
    // 由于x,y两个参数都用于做为引用返回，所以x,y必须都要标明生命周期
    // 这里的'a会被具体化为x,y的生命周期中重叠的那一部分
    fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
        if x.len() > y.len() {
            x
        } else {
            y
        }
    }

    let s1 = String::from("s11");
    let mut s4 = "";
    {
        let s2 = String::from("s2");
        // longest返回值的生命周期是s1和s2中生命周期较短的那个，即s2的生命周期
        // s3的生命周期与s2一样，所以能通过编译
        let s3 = longest(&s1, &s2);
        println!("{}", s3);
        // 以下无法通过编译，因为s4的生命周期大于s2
        // s4 = longest(&s1, &s2);
    }
    println!("{}", s4);

    // 以下这个函数不满足生命周期省略规则，所以必须手动标注
    // fn longest(x:&str, y:&str)->&str{}
    // 以下函数应用规则1和规则2后，所有的输入输出引用参数周期都确定，所以可以省略
    // fn first_word(x:&str)->&str{}


    // 结构体中引用字段的生命周期标
    struct ImportantExcerpt<'a> {
        part: &'a str,
    }

    impl<'a> ImportantExcerpt<'a> {
        fn level(&self) -> i32 {
            2
        }
        // 应用第一条规则和第三条规则，可以得出正确的生命周期，所以以下这个可以周期可以省略
        fn announce_and_return_part(&self, announcement: &str) -> &str {
            self.part
        }
        // 应用第一条和第三条规则，得出的生命周期不正确，所以在没有生命周期房间里时编译报错
        fn display_part_and_return<'b>(&self, announcement: &'b str) -> &'b str {
            announcement
        }
    }

    // 'static是固定写法，表示生命周期是整个程序的执行周期
    // 所有字符串字面量都拥有'static生命周期
    let s: &'static str = "abc";

    use std::fmt::Display;
    // 同时使用生命周期，泛型，trait约束的例子
    // 生命周期必须在泛型类型声明之前，也可以使用where进行trait约束
    // 生命周期也是泛型的一种？？
    fn longest_with_announcement<'a, T:Display>(x: &'a str, y: &'a str, anno: T) -> &'a str {
        println!("{}", anno);
        if x.len() > y.len() {
            x
        } else {
            y
        }
    }
```

## 编写自动化测试

Rust中的单元测试一般与要测试的代码放在同一个文件中，使用的模块名称为tests，通过```#[cfg(test)]```来标记，让编译器只在cargo test时才编译和运行这一部分代码，在cargo build等场景会剔除这些代码。

在函数上使用```#[test]```称为属性(attribute)，与C#的attribute以及Java的annotation一样，用于给编译器提供更多的信息。

cargo test参数说明之\-\-之后的参数：

* \-\-test-threads=1：运行的并发数，默认是多个case并行执行，可以设置成1为串行执行；
* \-\-nocapture：将测试用例中打印出来内容输出显示出来。默认情况下这些内容会被捕获并丢弃；
* \-\-ignored：专门运行被```#[ignore]```标记的case。

cargo test参数说明之\-\-之前的参数：

* \-q：静默情况下运行测试用例，输出的信息比较有限；

* \-\-test file_name：用于指定运行集成测试的文件，注意不用跟.rs后缀名。

cargo test允许我们指定需要运行的用例名，例如cargo test adder，则所有case名中包含有adder的case都会被运行(例如：tests::adder_test)，这种方法只能指定一个匹配字符串，无法指定多个。

在```#[test]```标记之后，跟上```#[ignore]```的测试函数，默认情况下不会运行，只有使用\-\-ignored时，才会专门运行这些case，例如```cargo test -- --ignored```。

本单元的例子位于adder项目中：

```rust
//! # Adder
//!
//! 测试做为包的注释，包含有一些小组件

use std::ops::Add;

/// 定义一个泛型加法
///
/// # Example
///
/// 例子，一般是测试用例
/// ```
/// assert_eq!(5, adder::adder(3,2));
/// assert_eq!(9.8, adder::adder(3.3, 6.5));
/// ```
/// # Panics
///
/// 可能Panic的场景
///
/// # Errors
/// 如果返回Result时，这里写明Error返回的场景，以及返回的Error值
///
/// # Safety
///
/// 当使用了unsafe关键字时，这里可以说明使用unsafe的原因，以及调用者的注意事项
///
pub fn adder<T: Add + Add<Output=T>>(a: T, b: T) -> T {
    return a + b;
}

#[cfg(test)]
mod tests {
    // 引入所有父模块的所有包，这样可以直接使用adder方法，否则adder需要指定完整路径才能使用
    use super::*;
    use std::fs::File;
    use std::io::Read;

    // 标记以下函数是一个测试函数，如果没有这个标记，cargo test的时候不会运行
    #[test]
    fn it_works() {
        // 相等断言
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn adder_test() {
        // 注意使用了assert_eq和assert_ne这两个断言时，两个参数必须实现了PartialEq和Debug这两个trait，一个用于判断相等，一个用于出错时输出信息

        // 以下两个写法等价，推荐使用第一个写法，因为在失败时可以打印出两个参数的值，方便分析原因
        assert_eq!(adder(2, 2), 4);
        assert!(adder(2, 2) == 4); // assert!接收一个bool类型的参数，只有为true时测试才通过
        // assert_ne!用于断言两个值不相等
        assert_ne!(adder(2.0, 3.0), 6.0);

        // 这些断言在必要参数之后的信息都会被用于format!输出额外的信息
        assert_eq!(adder(3, 4), 7, "{}+{} is not equal 7", 3, 4);
    }

    #[test]
    // should_panic属性用于表示这个函数会发生panic
    // 参数expected会比较panic的信息是否与此相匹配，注意中人包含expected的内容即可
    #[should_panic(expected = "panicked")]
    fn check_panic() {
        panic!("i panicked")
    }

    #[test]
    // 使用Result做为测试用例的返回值时，只要有Err返回，就测试失败
    // 这种情况下可以使用?表达式来简化测试用例的编写
    fn use_result() -> Result<(), std::io::Error> {
        let mut f = File::open("./cargo.toml")?;
        let mut s = String::new();
        let _ = f.read_to_string(&mut s)?;
        return Ok(());
    }

    #[test]
    #[ignore] // 默认情况下忽略此case，可以通过--ignored来专门运行这种case
    fn long_time_test() {}
}
```


集成测试：

* 在src同级别建立tests目录，在这个目录下可以创建任意的集成测试用例；tests目录只在cargo test时进行编译和执行，其它情况会忽略；

* tests目录下每一个文件都是独立包名，所以不用担心测试函数会重名；

* 可以在tests目录下建立子目录，做为公共使用的部分，或者隐藏测试中的细节等等，子目录中的函数也可以标记为```#[test]```，但他只在tests目录下的文件引用到时执行；

* 如果将子目录做为公共部分使用，一般不在里面设置测试用例，因为如果多个测试模块引用的话，这个case将被运行多次；

* 无法在集成测试中引用main.rs，所以一般我们将复杂的操作移到lib.rs中，而main.rs中只保留简单的胶水代码逻辑。

```rust
// src/tests/integation.rs
#[test]
fn adder_test() {
    assert_eq!(adder::adder(9.0, 10.0), 19.0);
}

#[test]
fn my_note() {
    assert_eq!(adder::adder(9.0, 10.0), 19.0);
}
mod sub;
```

```rust
// src/tests/sub/mod.rs
#[test]
pub fn setup() {}
```

## minigrep例子

* `std::env::args()`获取命令行参数，格式与其它语言一样；

* `std::process::exit(1)`退出进程，这个函数签名为`pub fn exit(code: i32) -> !`，`!`表示从来不会返回；

* `std::fs::read_to_string()`读取文件内容；

* `std::env::var("CASE_INSENSITIVE")`获取环境变量值；

* `eprintln!`将错误信息打印到标准错误输出。

代码位于minigrep项目中：

```rust
// main.rs
use minigrep::*;

// main函数里的代码无法进行单元测试和集成测试，所以main函数这块保持简单，把逻辑移到lib.rs下
fn main() {
    // std::env::args()返回的是Args实现了Iterator，使用collect转化为Vec<String>
    // 因为collect返回的也是泛型，编译器无法自动推断需要返回的类型，所以给args的类型标注不可省略
    let args: Vec<String> = std::env::args().collect();

    // Result结构的unwrap_or_else方法接收一个函数来做错误处理
    // 处理函数包含一个闭包参数，使用竖线包起来，获取到的值为Result的E中的值
    // 处理函数必须返回Result的T值(正确的值)，但std::process::exit(1)直接退出进程，所以可以编译通过
    // exit的返回值为->!，表示从不会返回：pub fn exit(code: i32) -> !
    let config = Config::new(&args).unwrap_or_else(|err| {
        // 使用eprintln!将错误信息输出到标准错误输出
        eprintln!("Problem parsing arguments: {}", err);
        std::process::exit(1);
    });

    // // 使用迭代器的版本
    // let config = Config::new2(std::env::args()).unwrap_or_else(|err| {
    //     eprintln!("Problem parsing arguments: {}", err);
    //     std::process::exit(1);
    // });

    // 使用if let语法，只处理关心的变体
    if let Err(e) = run(&config) {
        eprintln!("Application error: {}", e);
        std::process::exit(1);
    }
}
```

```rust
// lib.rs
// 返回Result中的E为Box<dyn std::error::Error>，表示为实现了Error这一trait的类型
// 具体的类型需要在具体的场景中才能确定，这里的dyn关键字也说明了是一个动态的类型
pub fn run(config: &Config) -> Result<(), Box<dyn std::error::Error>> {
    let contents = std::fs::read_to_string(&config.filename)?;
    let result = if config.case_sensitive {
        search(&config.query, &contents)
    } else {
        search_case_insensitive(&config.query, &contents)
    };

    for l in result {
        println!("{}", l);
    }
    Ok(())
}

pub struct Config {
    query: String,
    filename: String,
    case_sensitive: bool,
}

impl Config {
    // 使用命令行参数来构造Config结构，返回Result结构，在出错时返回str
    // 返回值中的str中声明了生命周期为全局的，因为字面量常量可以是全局的，此处不设置其实也没有问题，生命周期与输入一致
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments!");
        }
        let query = args[1].clone();
        let filename = args[2].clone();
        // 读取环境变量来确定是否需要大小写敏感，读取到无error则case_sensitive=false，不区分大小写，如下
        // CASE_INSENSITIVE=1 cargo run Nobody poem.txt
        let case_sensitive = std::env::var("CASE_INSENSITIVE").is_err();
        // 变量与结构体字段重名时，可以使用此种方式快速构建
        Ok(Config { query, filename, case_sensitive })
    }
    // 使用迭代器版本
    pub fn new2(mut args: std::env::Args) -> Result<Config, &'static str> {
        args.next();
        let query = match args.next() {
            Some(q) => q,
            None => return Err("no query")
        };
        let filename = match args.next() {
            Some(f) => f,
            None => return Err("no filename")
        };
        let case_sensitive = std::env::var("CASE_INSENSITIVE").is_err();
        Ok(Config { query, filename, case_sensitive })
    }
}

// 这块需要指定生命周期，表明Vec返回的&str，与contents的生命周期绑定
// 如果contents失败了，那么返回值也将没有意义了
fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut ret: Vec<&str> = Vec::new();
    for line in contents.lines() {
        if line.contains(query) {
            ret.push(line)
        }
    }
    ret
    // 使用迭代器版本
    // contents.lines().filter(|line| line.contains(query)).collect()
}

fn search_case_insensitive<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut ret: Vec<&str> = Vec::new();
    let q = query.to_lowercase();
    for l in contents.lines() {
        if l.to_lowercase().contains(&q) {
            ret.push(l)
        }
    }
    ret
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_result() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
        ";
        assert_eq!(
            vec!["safe, fast, productive."],
            search(query, contents),
        );
    }

    #[test]
    fn case_insensitive() {
        let query = "rust";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
        ";
        assert_eq!(
            vec!["Rust:"],
            search_case_insensitive(query, contents),
        );
    }
}
```

## 函数式语言特性：迭代器与闭包

### 闭包

与闭包相关的三种trait： Fn, FnMut, FnOnce，所有闭包至少实现其中的一个。

这三个trait代表了函数接收参数的三种方式：不可变引用(Fn)，可变引用(FnMut)，获取所有权(FnOnce)。

rust自动从闭包的定义中推导出其所实现的trait。

所有函数都实现了这三个trait，所以要求传闭包的地方都可以传函数。

这三个trait的区别：

* 实现了FnOnce的闭包可以从环境中获取变量的所有权，所以这个类型的闭包只能被调用一次；

* 实现了FnMut的闭包从环境中可变地借用值；

* 实现了Fn的闭包从环境中不可变地借用值；

* 所有闭包都实现了FnOnce，实现了Fn的闭包也实现了FnMut。

以下例子位于example/src/bin/functional.rs中：

```rust
fn main() {
    // 闭包当作匿名函数的一般写法，参数和返回值的类型，由编译器推断出来
    let add_one = |x| {
        x + 1
    };
    // 如果无法推断，则需要写成这种详细的形式，与函数定义非常类似
    let add_one2 = |x: i32| -> i32{
        x + 1
    };
    // 在匿名函数没有捕获环境变量的情况下，与函数一样
    fn add_one_fn(x: i32) -> i32 {
        x + 1
    }

    fn use_fn(x: i32, f: fn(i32) -> i32) -> i32 {
        f(x)
    }

    // 输出2,2,2
    // 可见无捕获上下文的闭包与函数一样
    println!("{},{},{}", use_fn(1, add_one), use_fn(1, add_one2), use_fn(1, add_one_fn));

    // 如果捕获了环境变量，则闭包与函数就不能通用了
    let k = 1;
    let add_one_closure = |x: i32| {
        x + k + 1
    };
    // 这里报错，expected fn pointer, found closure
    // closures can only be coerced to `fn` types if they do not capture any variables
    // println!("{}", use_fn(1, add_one_closure));

    // 函数无法捕获上下文:can't capture dynamic environment in a fn item
    //  use the `|| { ... }` closure form instead
    // fn f_error(x: i32) -> i32 {
    //     x + k + 1;
    // }

    // 以下正常运行，输出12
    println!("{}", add_one_closure(10));

    // 多个参数时，使用逗号隔离开
    let sum = |x, y| {
        x + y
    };
    // 如果只有一行，可以省略掉大括号
    let sum2 = |x, y| x + y;
    println!("{},{}", sum(1, 2), sum2(2, 3));

    // 在不指定类型的闭包，只能推断出一种类型
    let closure = |x| x;
    println!("{}", closure(10));
    // 以下将报错，办为之前的调用已经推断closure为(i32)->i32的闭包，不能再使用&str类型了
    // expected integer, found `&str`
    // println!("{}", closure("10"));

    // 与闭包相关的三种trait： Fn, FnMut, FnOnce，所有闭包至少实现其中的一个
    // 这三个trait代表了函数接收参数的三种方式：不可变引用(Fn)，可变引用(FnMut)，获取所有权(FnOnce)
    // rust自动从闭包的定义中推导出其所实现的trait
    // 所有函数都实现了这三个trait，所以要求传闭包的地方都可以传函数

    // 这三个trait的区别：
    // 实现了FnOnce的闭包可以从环境中获取变量的所有权，所以这个类型的闭包只能被调用一次
    // 实现了FnMut的闭包从环境中可变地借用值
    // 实现了Fn的闭包从环境中不可变地借用值
    // 所有闭包都实现了FnOnce，实现了Fn的闭包也实现了FnMut
    // 接收Fn trait做为参数的函数
    fn do_1<T: Fn(i32) -> i32>(x: i32, f: T) -> i32 {
        f(x)
    }
    let k = vec![1, 2];
    let c_1 = |x| x + k[0] + 1;
    fn f_1(x: i32) -> i32 { x + 1 }
    //
    // 输出5,3
    println!("{},{}", do_1(1, c_1), do_1(1, f_1));
    println!("{}", c_1(1));

    // 使用move关键可以获取变量的所有权
    let c_1 = move |x| x + k[0] + 1;
    // ？？？很奇怪的现象，如果加上下面这一行，则后面的两次调用将报错: borrow of moved value: `c_1`
    // 但如果没有下面这一行，则后面的两次调用则可以通过
    // do_1(1, c_1);
    println!("{}", c_1(1));
    println!("{}", c_1(1));


    // FnOnce的例子
    fn do_2<T: Fn() -> String>(f: T) {
        f();
    }
    let a = "aa".to_string();
    // c_2因为返回了a变量，而String没有实现Copy trait，所以相当于c_2获取了a的所有权并返回了a，所以c_2只实现了FnOnce trait，无法被传递到Fn作为参数的函数中
    let c_2 = || a;
    // 以下一行将报错： this closure implements `FnOnce`, not `Fn`
    // do_2(c_2);
    fn do_3<T: FnOnce() -> String>(f: T) {
        f();
    }
    // 运行正常
    do_3(c_2);
    // 以下编译报错： use of moved value: `c_2`
    // 因为c_2是FnOnce没有实现Copy，所以无法被使用两次
    // do_3(c_2);

    // FnMut的例子
    let mut k = 3;
    let mut c_3 = || {
        k = k + 1;
        k
    };
    println!("{}", c_3());
    // 以下将无法通过编译，因为c_3使用k的可变引用，不能再拥有k的其它引用了
    // println!("{},{}", k, c_3());
}
```

### 迭代器

比起使用for循环的原始实现，Rust更倾向于使用迭代器风格；迭代器可以让开发者专注于高层的业务逻辑，而不必陷入编写循环、维护中间变量这些具体的细节中。通过高层抽象去消除一些惯例化的模板代码，也可以让代码的重点逻辑（例如filter方法的过滤条件）更加突出。

**迭代器是Rust语言中的一种零开销抽象(zero-cost abstraction)**，这个词意味着我们在使用这些抽象时不会引入额外的运行时开销。

以下例子位于example/src/bin/iterator.rs中：

```rust
fn main() {
    // 迭代器允许你依次为序列中的每一个元素执行某些任务
    // 迭代器是惰性的，除非主动调用方法来消耗，否则不会有任何作用
    // 迭代器实现了Iterator 这一trait，Iterator有多个方法，但大多都提供了默认的实现
    // 要实现Iterator只需要实现next方法即可
    trait Iterator1 {
        // 关联类型，用于存储next返回值的类型
        type Item;
        // Self::Item表示返回的Option存储的是Item的类型
        // next返回被包裹在Some中的元素，在遍历结束时返回None
        fn next(&mut self) -> Option<Self::Item>;
        // 省略默认实现的方法
        // ...
    }

    let mut v = vec![1, 2, 3];
    // 必须将iter标识成mut的，因为调用next会改变iter内部的状态
    // iter()方法返回的是一个不可变引用迭代器，next的返回值是数组中元素的不可变引用
    let mut iter = v.iter();
    // 1,2,3,true
    println!("{},{},{},{}", iter.next().unwrap(), iter.next().unwrap(), iter.next().unwrap(), iter.next() == None);
    // 返回可变引用
    for i in v.iter_mut() {
        *i += 1;
    }
    // [2,3,4]
    println!("{:?}", v);

    // 使用into_iter获取其所有权，后续v不再可用
    println!("{}", v.into_iter().next().unwrap());

    // 迭代适配器，以及与闭包共同实现
    let v = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
    let add2: Vec<i32> = v.iter().map(|x| x + 2).collect();
    let min = 5;
    // 这里使用filter的给到的闭包参数为&&x，要么使用**x解引用，要么在参数中使用&&x来表示x是一个i32
    let big: Vec<&i32> = v.iter().filter(|&&x| x + 2 > min).collect();
    // [3, 4, 5, 6, 7, 8, 9, 10, 11],[6, 7, 8, 9]
    println!("{:?},{:?}", add2, big);

    // 创建自定义的迭代器
    struct Counter {
        count: i32,
    }
    impl Counter {
        fn new() -> Counter {
            Counter { count: 0 }
        }
    }
    impl std::iter::Iterator for Counter {
        type Item = i32;

        fn next(&mut self) -> Option<Self::Item> {
            self.count += 1;
            if self.count > 5 {
                None
            } else {
                Some(self.count)
            }
        }
    }
    for i in Counter::new() {
        println!("{}", i)
    }
    // 一些迭代器复杂的用法
    // Iterator这个trait有很多方法的默认实现，依赖于next方法，我们可以直接使用完成复杂的功能
    // 以下有一个特殊的语法，在方法后面添加::<typeHint>，可以给编译器提示返回的值类型为typeHint，用于无法推断类型的场景时使用
    // Counter::new() is [1, 2, 3, 4, 5]
    // Counter::new().skip(1) is [2, 3, 4, 5]
    // Counter::new().zip(Counter::new().skip(1)) is [(1, 2), (2, 3), (3, 4), (4, 5)]
    //     .map(|(a,b)| a*b) is [2, 6, 12, 20]
    //     .filter(|x| x % 3 == 0) [6, 12]
    //     .sum() is 18
    let c: i32 = Counter::new().zip(Counter::new().skip(1))
        .map(|(a, b)| a * b)
        .filter(|x| x % 3 == 0)
        .sum();
    println!("Counter::new() is {:?}", Counter::new().collect::<Vec<i32>>());
    println!("Counter::new().skip(1) is {:?}", Counter::new().skip(1).collect::<Vec<i32>>());
    println!("Counter::new().zip(Counter::new().skip(1)) is {:?}", Counter::new().zip(Counter::new().skip(1)).collect::<Vec<(i32, i32)>>());
    println!("    .map(|(a,b)| a*b) is {:?}", Counter::new().zip(Counter::new().skip(1)).map(|(a, b)| a * b).collect::<Vec<i32>>());
    println!("    .filter(|x| x % 3 == 0) {:?}", Counter::new().zip(Counter::new().skip(1)).map(|(a, b)| a * b).filter(|x| x % 3 == 0).collect::<Vec<i32>>());
    println!("    .sum() is {:?}", c);
}
```

## 进一步认识Cargo及crates.io

Rust中的发布配置是一系列定义好的配置方案，例如cargo build时使用dev配置方案，添加`--release`后，使用release配置方案。

在Cargo.toml中添加`[profile.dev]`和`[profile.release]`配置段可以对这两个方案进行配置。

在没有配置时，有一套默认的配置，当自定义了配置时，会使用自定义配置的子集覆盖默认的配置。

提到的配置：

* `opt-level=1`：编译优化程序，0~3优化递增，release默认是3，dev为0。

### 文档注释

Rust中使用三斜线做为文档注释，支持markdown语法；被包在markdown里的代码片段会被当成测试case，在运行cargo test的时候运行。

```rust
// 位于adder项目中
/// 定义一个泛型加法
///
/// # Example
///
/// 例子，一般是测试用例
/// ```
/// assert_eq!(5, adder::adder(3,2));
/// assert_eq!(9.8, adder::adder(3.3, 6.5));
/// ```
/// # Panics
///
/// 可能Panic的场景
///
/// # Errors
/// 如果返回Result时，这里写明Error返回的场景，以及返回的Error值
///
/// # Safety
///
/// 当使用了unsafe关键字时，这里可以说明使用unsafe的原因，以及调用者的注意事项
///
pub fn adder<T: Add + Add<Output=T>>(a: T, b: T) -> T {
    return a + b;
}
```

可以使用```cargo doc --open```来打开文档查看。

使用```//!```开头的注释，不像```///```为紧跟的代码提供注释，而是为整个包，或者整个模块提供注释； 这种类型的注释，只能放在文件最开头。


### 使用pub use重新组织结构

```rust
// example/src/lib.rs
//! # Art
//!
//! 测试用于艺术建模的库

// 使用pub use 重新组织API结构
pub use crate::kinds::PrimaryColor;
pub use crate::kinds::SecondaryColor;
pub use crate::utils::mixed;

pub mod kinds {
    pub enum PrimaryColor {
        Red,
        Yellow,
        Blue,
    }

    pub enum SecondaryColor {
        Orange,
        Green,
        Purple,
    }
}

pub mod utils{
    use crate::kinds::*;

    pub fn mixed(c1:PrimaryColor, c2:PrimaryColor) -> SecondaryColor{
        SecondaryColor::Orange
    }
}
```

```rust
// example/src/bin/pub_use_example.rs

// use example::kinds::PrimaryColor;
// use example::utils::mixed;

// 使用pub use重新导出包结构后，就可以使用直接使用一级目录的结构，不用关心原包中的结构了
use example::PrimaryColor;
use example::mixed;

fn main(){
    let red = PrimaryColor::Red;
    let yellow = PrimaryColor::Yellow;
    mixed(red, yellow);

}
```

### 使用crates.io分享代码

创建步骤：

1. 使用github账号登录[https://crates.io/](https://crates.io/)；

2. 在账号设置中绑定邮箱，并验证；

3. 在账号设置中生成New Token；

4. 在本地使用cargo login xxxx(your token)来保存token到本地(~/.cargo/credentials)；

5. 在项目中填写足够的信息(Cargo.toml)：
```ini
[package]
name = "guessing_game_xiaochai"
version = "0.1.0"
authors = "[xiaochai<soso2501@gmail.com>]"
edition = "2018"
description = "a game demo"
license = "MIT"
```

6. 在命令行中运行cargo publish，此时，会将代码提交到远程：https://crates.io/crates/guessing_game_xiaochai。如果本地是git，并且有未提交的文件，将会生成错误，可以使用``` cargo publish --allow-dirty```忽略git信息。<br/>

更新版本：

1. 修改Cargo.toml，增加版本号；

2. 运行```cargo publish```即可提交新版本。

撤回某个版本：

* ```cargo yank --vers 0.1.0```可以撤回某个版本，虽然还能在crate.io上看到对应版本，但新的项目无法引用这个版本了；

* 使用```cargo yank --vers 0.1.0 --undo```可以取消撤回操作。

如果你分享的是一个二进制包，可以使用`cargo install guessing_game_xiaochai`来下载安装，会安装到~/.cargo/bin目录下。

### 工作空间

同一个工作空间下的项目使用同一个Cargo.lock文件，使用以下步骤新建一个工作空间：

1. 新起目录，例如workspace_example，cd workspace_example；

2. 创建Cargo.toml文件，内容为：
```ini
[workspace]
members = [
    "adder"
]
```

3. 在目录下使用cargo new来创建adder二进制包；

4. 此时不管在workspace_example目录下运行cargo run 还是在workspace_example/adder下，最终的target都会在workspace_example/target目录下；换种说法，adder项目目前已经不是一个独立的项目了，要么1. 在workspace_example/Cargo.toml添加exclude来排除adder项目；2. 或者是在workspace_example/adder/Cargo.toml中添加空的[workspace]段，这样才能将adder单独编译：
```ini
[workspace]
members = [
]
exclude = [
    "adder",
]
```
    
5. 添加add-one这个代码包```cargo new add-one --lib```；

6. adder的二进制文件需要依赖adder-one包，需要在adder/Cargo.toml的dependencies段添加```add-one = { path = "../add-one" }```；

7. 在main函数中使用。
```rust
fn main() {
    println!("Hello, world!");
    println!("{}", add_one::add_one(10));
}
```

8. 在workspace_example下运行```cargo run```，则运行了adder包中的二进制文件；如果一个工作空间下有多个二进制项目的话，可以使用\-p参数来指定项目
```cargo run -p adder```

### 扩展cargo

如果在$PATH中包含有cargo-something的可执行文件，那么可以使用cargo something来运行此文件。

例如刚安装的guessing_game_xiaochai程序：

```shell
➜  workspace_example git:(master) ✗ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/Users/bytedance/.cargo/bin
➜  workspace_example git:(master) ✗ mv ~/.cargo/bin/guessing_game_xiaochai ~/.cargo/bin/cargo-guessing_game_xiaochai
➜  workspace_example git:(master) ✗ cargo guessing_game_xiaochai
secret number is 86
Guess the number!
Please input your guess:
...
```

## 智能指针

* 指针是指包含内存地址的变量；

* 引用是最常用的指针，没有额外的开销；

* 智能指针是一些数据结构，他们的功能类似于指针，但拥有额外的元数据和附加功能；

* 引用只是借用数据指针，而智能指针一般拥有数据所有权；

* String和`Vec<T>`是智能指针，他们拥有一片内存区域并允许进行操作，他们还拥有元数据（如容量），并提供额外的功能或保障；

* 智能指针一般使用结构体来实现，需要实现Drop和Deref两个trait：
> Deref trait使得此结构体的实例可以拥有与引用一致的行为;<br/>
> Drop trait使得在离开作用域时运行一段自定义代码。

常用智能指针：

* `Box<T>`： 可用于在堆上分配值；

* `Rc<T>`: 允许多重所有权的引用计数智能指针；

* `Ref<T>`，`RefMut<T>`：可以通过`RefCell<T>`访问，是一种可以在运行时而非编译时执行借用规则的类型。

内部可变性：不可变对象可以暴露出能够改变内部值的API。

规避循环引用导致的内存泄露。

### 使用`Box<T>`在堆上分配内存

使用场景：

* 在需要固定尺寸变量的上下文中使用编译期无法确定大小的类型；

* 需要传递大量数据的所有权，但又不希望对数据进行复制；

* 当希望使用实现了某个trait的类型，而又不关心具体类型时。

基本使用方法：

1. 使用Box::new(T)在堆上空间，将T保存于这一空间内，并返回指向堆上这一空间的指针；

2. 在变量前加*(解引用运算符)来获取堆上真正的值，称为解引用。

以下代码位于example/src/bin/smart_pointer.rs中：

```rust
    // Box的基本使用方法
    // a和b都是Box<i32>类型，与i32不同的是，Box<i32>类似于指向堆上两个i32类型的指针
    let a = Box::new(128);
    let b = Box::new(256);
    // 所以a和b无法直接进行操作，因为Box实现了Deref这一trait，所以可以使用*来解引用
    let c: i64 = *a + *b;
    println!("{}", c); // 384
```

定义递归类型时需要使用Box，因为不能在编译期确定内存空间的大小

```rust
    // 递归类型必须使用Box
    enum List {
        Cons(i32, Box<List>),
        // 使用Cons(i32, List)将无法通过编译：recursive type `List` has infinite size
        Nil,
    }

    use List::{Nil, Cons};

    let list = Cons(
        1,
        Box::new(Cons(
            2,
            Box::new(Cons(
                3, Box::new(
                    Nil
                ),
            )),
        )),
    );

    fn print_list(l: List) {
        match l {
            Cons(i, nl) => {
                print!("{}=>", i);
                print_list(*nl);
            }
            Nil => {
                println!("end");
            }
        }
    }
    print_list(list);
```

### 自定义智能指针


```rust
   // 自定义类似于Box的智能指针(但数据存在在栈上)
    struct MyBox<T> (T); // 元组结构体
    impl<T> MyBox<T> {
        // 提供一个参数，并将此存入结构体中
        fn new(x: T) -> MyBox<T> {
            MyBox(x)
        }
    }
```

涉及到两个trait: Deref 和Drop。

#### Deref

Deref解引用trait，一个类型实现了Deref trait时，可以使用解引用运算符：

```rust
    // 为MyBox实现Deref，这样就可以使用解引用运算符
    impl<T> Deref for MyBox<T> {
        // 关联类型
        type Target = T;

        // 也可以写成fn deref(&self) -> &T {
        fn deref(&self) -> &Self::Target {
            // 以下等价于self.0
            match self {
                MyBox(i) => i
            }
        }
    }
    let a = MyBox(10);
    // 这里的*a类似于*(a.deref())，称之为隐式展开
    println!("{}", *a + 10)
```

隐式解引用转换：当函数参数为某个类型的引用时，如果传入的参数与此不匹配，则编译器会自动进行解引用转换，直到类型满足要求。

解可变引用：实现DerefMut trait，要实现这一trait，必须首先实现Deref trait。

可变性转换有三条：

1. 当T: Deref<Target=U>时，允许&T转换为&U；

2. 当T: DerefMut<Target=U>时，允许&mut T转换为&mut U；

3. 当T: Deref<Target=U>时，允许&mut T转换为&U；

这三条规则不会破坏借用规则。


```rust
    // 隐式解引用转换
    fn hello(name: &str) {
        println!("hello, {}", name);
    }
    let mb: MyBox<String> = MyBox::new("lee".to_string());
    // 正常的写法如下，其发生的步骤1. 需要将MyBox解引用转化为String，2. 使用[..]将String转化为切片&str，这样才符合参数要求
    hello(&(*mb)[..]);
    // 使用自动解引用也能满足这个要求，mb实现了Deref，所以可以获取到String，String也实现了deref，其返回为&str，所以编译器进行了两次解引用转换
    // 以上是编译期完成，不会有任何运行时开销
    hello(&mb);

    // 实现可变解引用运算符，实现DerefMut之前必须实现Deref
    impl<T> DerefMut for MyBox<T> {
        fn deref_mut(&mut self) -> &mut Self::Target {
            &mut self.0
        }
    }
    // 满足自动解引用的三条规则
    // 当T: Deref<Target=U>时，允许&T转换为&U。
    // 当T: DerefMut<Target=U>时，允许&mut T转换为&mut U。
    // 当T: Deref<Target=U>时，允许&mut T转换为&U。
    fn hello_exp(name: &mut String) -> &mut String {
        name.push_str(", hello!");
        name
    }

    let mut b = Box::new("abc".to_string());
    // 当T: DerefMut<Target=U>时，允许&mut T转换为&mut U，与&mut *b是一样的
    let c = hello_exp(&mut b);
    println!("{}", c);
    //  当T: Deref<Target=U>时，允许&mut T转换为&U。
    hello(&mut b);
```

#### Drop

Drop trait允许我们在离开变量作用域时执行某些自定义的操作，例如释放文件和网络连接等。

`Box<T>`类型通过Drop释放指向堆上的内存。

drop的执行顺序与变量的创建顺序相反。

无法禁用drop的功能，也无法手动调用Drop的drop方法，但可以使用std::mem::drop来提前清理某个值，这个函数在预导入模块中，所以可以直接使用drop来调用。

```rust
    // 实现Drop的例子
    {
        struct TestDropStruct {
            data:String,
        }
        impl Drop for TestDropStruct{
            fn drop(&mut self) {
                println!("{}", self.data)
            }
        }
        let _a = TestDropStruct{data:"first object".to_string()};
        let _b = TestDropStruct{data:"second object".to_string()};
        let _c = TestDropStruct{data:"third object".to_string()};
        println!("main end");
        // 手动使用std::mem::drop函数来提前清理_c的值
        drop(_a);

        // 以上输出顺序为
        // main end
        // first object
        // third object
        // second object
        // 对于_b，_c来说，丢弃顺序与创建顺序相反，所以_c先调用drop函数
        // _a则是由于手动释放导致先执行
    }
```

### `Rc<T>`基于引用计数的智能指针

`Rc<T>`只能用于单线程中，用于那些在编译期无法确认哪个部分会最后释放的场景。

`RC<T>`只能持有不可变的引用，否则会打破引用规则。

```rust
     {
        // 测试引用计数智能指针Rc<T>类型
        enum RcList {
            RcCons(i32, Rc<RcList>),
            RcNil,
        }
        use RcList::*;
        // 新建一个引用记录类型使用Rc::new来创建，此处a为Rc<RcList>类型
        let a = Rc::new( RcCons(3, Rc::new(
            RcCons(4, Rc::new(RcNil)),
        )));
        {
            // Rc::clone全程参数对应的引用计数增加1
            let _b = RcCons(1, Rc::clone(&a));
            let _c = RcCons(2, Rc::clone(&a));
            // 目前有a,_b,_c三个变量引用a，所以a的引用计数为3
            // 除了strong_count，还有week_count，用于避免循环引用
            println!("{}", Rc::strong_count(&a))
        }
        // _b，_c离开作用域，减少了引用计数，但a还在，所以这块的数量是1
        println!("{}", Rc::strong_count(&a))
    }
```


### `RefCell<T>`和内部可变性模式

内部可变性是Rust的设计模式之一，它允许你在只持有不可变引用的情况下修改数据。这在现有的借用规则下是禁止的，所以此类数据结构借用了unsafe代码来绕过可变性和借用规则的限制。

`RefCell<T>`是使用了内部可变性模式的类型。

与`Rc<T>`不同，`RefCell<T>`持有数据的维一所有权。而与`Box<T>`不同，`RefCell<T>`会在运行时检查借用规则，而非在编译时期，如果运行时发现不满足规则 ，则直接panic。所以`RefCell<T>`类型由开发者来保证借用规则 ，则不是编译器。

此类型只能用于单线程中。

`Box<T>`，`Rc<T>`，`RefCell<T>`三者的区别：

1. `Rc<T>`允许一份数据有多个所有者，而`Box<T>`和R`efCell<T>`都只有一个所有者；

2. `Box<T>`允许在编译时检查的可变或不可变借用，`Rc<T>`仅允许编译时检查的不可变借用，`RefCell<T>`允许运行时检查的可变或不可变借用；

3. 由于`RefCell<T>`允许我们在运行时检查可变借用，所以即便`RefCell<T>`本身是不可变的，我们仍然能够更改其中存储的值。

```rust
{
        // 假设有一个消息trait，需要实现send方法，而这一方法传递self的不可变引用
        pub trait Messenger {
            fn send(&self, msg: &str);
        }

        // 但是在测试的时候，我们使用Mock类来模拟Messenger的send的时候，需要把消息存储下来
        // 这样就可以验证存下来的消息是否符合预期，但传入不可变的self阻止了这种做法
        // 此时就需要使用RefCell来实现
        struct Mock {
            message: RefCell<Vec<String>>,
        }
        impl Mock{
            fn new()->Mock{
                Mock{
                    // 使用RefCell::new来创建新的RefCell
                    message:RefCell::new(vec![])
                }
            }
        }
        impl Messenger for Mock {
            fn send(&self, msg: &str) {
                // 如果这里的self.message是普通的Vec<String>，则无法执行push方法
                // 而使用RefCell的borrow_mut来绕过此限制，得到可变引用
                self.message.borrow_mut().push(String::from(msg))
            }
        }
        let m = Mock::new();
        m.send("message1");
        m.send("message2");
        // ["message1", "message2"]
        println!("{:?}", m.message.borrow());
        // 以下两行可以通过编译，但在运行时报错：thread 'main' panicked at 'already borrowed: BorrowMutError'
        // 这是因为a是不可变引用，在已经持有不可变引用的情况下，又搞出了一个可变的引用，破坏了借用规则 ，所以panic
        // let a = m.message.borrow();
        // let mut b = m.message.borrow_mut();
    }
```

结合使用`Rc<T>`和`RefCell<T>`来实现某个数据有多个所有者，并且都可以对数据进行修改。

```rust
    {
        #[derive(Debug)]
        enum RcRefCellList {
            RcRefCellCons(Rc<RefCell<i32>>, Rc<RcRefCellList>),
            RcRefCellNil,
        }
        use RcRefCellList::*;
        let val = Rc::new(RefCell::new(5));
        let a = Rc::new(RcRefCellCons(Rc::clone(&val), Rc::new(RcRefCellNil)));
        let b = RcRefCellCons(Rc::new(RefCell::new(6)), Rc::clone(&a));
        let c = RcRefCellCons(Rc::new(RefCell::new(6)), Rc::clone(&a));
        // 这块改动将a，b和c以及val都修改了
        *val.borrow_mut() = 10;
        // a:RcRefCellCons(RefCell { value: 10 }, RcRefCellNil)
        // b:RcRefCellCons(RefCell { value: 6 }, RcRefCellCons(RefCell { value: 10 }, RcRefCellNil))
        // c:RcRefCellCons(RefCell { value: 6 }, RcRefCellCons(RefCell { value: 10 }, RcRefCellNil))
        println!("a:{:?}", a);
        println!("b:{:?}", b);
        println!("c:{:?}", c);

    }
```

Rust不保证在编译器彻底防止内存泄露。我们可以创建出一个环状引用使得引用计数不会减到0，对应的值不会被丢弃，从而造成内存泄露。


```rust
    {
        // 创建出循环引用
        // 定义一个链接，为了方便改动，这次的链接使用ReCell来处理
        enum RefCellRcList {
            RefCellRcCons(i32, RefCell<Rc<RefCellRcList>>),
            RefCellRcNil,
        }
        use RefCellRcList::*;
        // 定义一个a，指向b
        // a -> 5 -> Nil
        let a = Rc::new(
            RefCellRcCons(5, RefCell::new(Rc::new(RefCellRcNil))),
        );
        println!("reference count:a:{}", Rc::strong_count(&a));

        // b -> 10 -> a
        let b = Rc::new(
            RefCellRcCons(10, RefCell::new(Rc::clone(&a))),
        );
        println!("reference count:a:{}, b:{}", Rc::strong_count(&a), Rc::strong_count(&b));
        // 将a -> b；最终变成a->b->10->a
        if let RefCellRcCons(i, r) = a.borrow() {
            *r.borrow_mut() = Rc::clone(&b);
        };
        println!("reference count:a:{}, b:{}", Rc::strong_count(&a), Rc::strong_count(&b));
        // reference count:a:1
        // reference count:a:2, b:1
        // reference count:a:2, b:2
        // 此时a和b的引用计数都是2，在结束时，先释放b，将b的引用计数减1，但此时b已经无法将引用计数减成0了，所以无法释放
    }
```

可以合理使用弱引用`Weak<T>`来规避这个问题，Rust在回收内存时不需要强制弱引用减成0。

与Rc::clone()类似，使用Rc::downgrade()获取`Rc<T>`的弱引用，获取对应弱引用的值时，使用对应弱引用的upgrade()方法，注意这个方法可能返回None。

```rust
    {
        // 使用Weak<T>创建树结构，子节点指向父节点使用弱引用
        #[derive(Debug)]
        struct Node {
            val: i32,
            // 多个子节点使用Vec来保存子节点的强引用，RefCell方便修改对应的值
            children: RefCell<Vec<Rc<Node>>>,
            // 父节点点使用弱引用
            parent: RefCell<Weak<Node>>,
        }

        let leaf = Rc::new(Node {
            val: 10,
            children: RefCell::new(vec![]),
            // Weak::new()创建出一个空的弱引用
            parent: RefCell::new(Weak::new()),
        });
        // 弱引用获取时，由于不确定值是否回收，所以使用upgrade()时会返回Option<T>，如果已经回收或者没有值，返回None
        // 以下返回None
        println!("{:?}", leaf.parent.borrow().upgrade());

        let branch = Rc::new(Node {
            val: 5,
            children: RefCell::new(vec![Rc::clone(&leaf)]),
            parent: RefCell::new(Weak::new()),
        });
        *(leaf.parent.borrow_mut()) = Rc::downgrade(&branch);
        println!("leaf's parent:{:?}", leaf.parent.borrow().upgrade());
        println!("branch's parent:{:?}", branch.parent.borrow().upgrade());
        {
            // 在另外一个作用域中添加branch的parent
            let new_branch = Rc::new(Node {
                val: 6,
                children: RefCell::new(vec![Rc::clone(&branch)]),
                parent: RefCell::new(Weak::new()),
            });
            *branch.parent.borrow_mut() = Rc::downgrade(&new_branch);
            println!("branch's parent in new area:{:?}", branch.parent.borrow().upgrade());
        }

        // 由于new_branch离开了作用域，所以被销毁，这块拿到的是None
        println!("branch's parent out area:{:?}", branch.parent.borrow().upgrade());
    }
```


## 线程

使用std::thread::spawn()向参数中传入一个闭包函数来支持多线程运行。

spawn返回线程句柄，其join方法会阻塞等待线程执行完成。

在闭包中使用move关键字可使得闭包函数获取变量的所有权。

此章节例子位于example/src/bin/thread.rs中：

```rust 
    let v = vec![1,2,3];

    // 使用thread::spawn启动一个线程，rust原生不支持协程，但有其它库提供支持
    // spawn的参数是一个无参数闭包或者函数，会在另外一个线程中运行这个函数的代码
    // 返回一个Handler，可以调用其join函数等待线程执行完成
    // 如果在闭包中使用环境中的值，需要将其所有权move到新线程中
    // 否则报错closure may outlive the current function, but it borrows `v`, which is owned by the current function
    let t = std::thread::spawn(move || {
        for i in 1..10 {
            println!("in thread {}", i + v[0]);
            std::thread::sleep(std::time::Duration::from_millis(1));
        }
    });
    for i in 1..5 {
        println!("out thread {}", i);
        std::thread::sleep(std::time::Duration::from_millis(1));
    }
    // 由于v的所有权已经被移入新线程了，所以这里就无法再使用v了
    // println!("v:{:?}", v);

    // 使用JoinHandler的join方法来等待线程执行完成
    // 返回的是Result<T, E>类型
    t.join().unwrap()
```

### 使用通道来传递消息

使用std::sync::mpsc::channel()创建一个通道，获得一个发送端和一个接收端。

发送端可以使用send来发送消息，接收端使用recv和try_recv来阻塞(非阻塞)地接收消息。

接收端还可以被当成有迭代器来处理接收到的消息。

使用std::sync::mpsc::Sender::clone()方法可以复制发送端，从而由多个发送源发送消息。

```rust
    // 使用通道(channel)在线程中传递信息
    // mpsc是multiple producer,single consumer的缩写，顾名思义，只能有一个消费者，但可以多个发送方
    let (tx, rx) = std::sync::mpsc::channel();

    std::thread::spawn(move || {
        let hi = "hi".to_string();
        tx.send(hi).unwrap();
        // send会将取得没有实现Copy trait的所有权，所以以下语句将报错
        // println!("send {}", hi);
    });

    // recv会阻塞线程，直到收到消息
    // 可以使用try_recv来非阻塞地试探是否有消息可以接收，没有消息时将返回Err
    println!("{}", rx.recv().unwrap());

    let (tx, rx) = std::sync::mpsc::channel();
    // mpsc支持多个发送方，可以通过clone方法来创建出多个发送端来
    let tx_2 = std::sync::mpsc::Sender::clone(&tx);
    std::thread::spawn(move || {
        for _i in 1..5 {
            tx.send("hi".to_string());
            std::thread::sleep(std::time::Duration::from_millis(100))
        }
    });
    std::thread::spawn(move || {
        for _i in 1..10 {
            tx_2.send("there".to_string());
            std::thread::sleep(std::time::Duration::from_millis(100))
        }
    });

    // 将rx当成迭代器来遍历收到的数据
    // 由于tx在线程退出时执行了Drop，整个通道就关闭了，所以rx的迭代就会结束了
    for m in rx {
        println!("got:{}", m)
    }
```

### 使用共享状态来实现消息传递

使用通道类似于单一所有权，使用共享状态类似于多重所有权。

并发原语(互斥体/mutex)一次只允许一个线程访问数据：

1. 必须在使用数据前尝试获取锁；

2. 必须在使用完互斥体守护的数据后释放锁，这样其他线程才能继续完成获取锁的操作。

使用std::sync::Mutex::new(T)创建一个互斥量，保存着一个T值。

lock返回一个智能指针，在离开作用域时自动解锁。

```rust
    // mutex的使用
    // 使用new函数创建互斥量，存储一个i32的值
    let m = std::sync::Mutex::new(10);
    {
        // 使用lock返回一个Result，正常时为MutexGuard是一个智能指针
        let mut i = m.lock().unwrap();
        // 修改值为20
        *i = 20;
        // 在这个作用域的结尾，智能指针执行了drop方法，将m解锁了
    }
    // m现在的值为20了
    // Mutex { data: 20, poisoned: false, .. }
    println!("{:?}", m);
```

在并发场景需要使用Mutex，需要配合引用计数智能指针使用。

`Rc<T>`无法用于并发场景，需要使用`Arc<T>`类型，并发场景下的引用计数智能指针。

多线程模式下两个重要的trait：Sync和Send。Sync和Send这两个trait是内嵌于语言实现的。

Send trait表示可以在线程间安全地转移所有权，Sync trait表示此类型可以安全地被多个线程引用。

除了裸指针外，所有基础类型都实现了Send trait，任何有Send类型组成的复合类型也都实现了Send；如果类型T是Send类型，则&T满足Sync约束。

Send和Sync属于标签trait(marker trait)，没有可供实现的方法，手动实现需要使用不安全的语言特性。

自动实现了Send和Sync的语法特性称之为自动trait(auto trait)，与此相对，如果不想使某个类型自动实现trait，则可以使用negative impl语法来处理，例如：

```rust
impl<T: ?Sized> !Send for MutexGuard<'_, T> {}
```

`Rc<T>`无法在多个线程场景下安全地更新引用计数值，所以Rc只设计用于单线程的场景，没有实现Send trait和Sync trait。

```rust
    // 并发场景下使用mutex
    use std::sync::{Mutex, Arc};
    use std::thread;
    // Arc<T>是并发场景下的Rc<T>
    // 使用Rc<T>会报错：`Rc<Mutex<i32>>` cannot be sent between threads safely
    // the trait `Send` is not implemented for `Rc<Mutex<i32>>`
    let counter = Arc::new(Mutex::new(0));
    // let countet1 = Rc::new(Mutex::new(0));
    let mut handlers = vec![];
    for i in 0..30 {
        let c = counter.clone();
        // let c2 = countet1.clone();
        let h = thread::spawn(move || {
            let mut t = c.lock().unwrap();
            // c2.lock().unwrap();
            *t += 1;
        });
        handlers.push(h);
    }
    for h in handlers {
        h.join().unwrap();
    }
    println!("{:?}", counter)
```

## 面向对象的语言特性

对象包含数据和行为：Rust中提供了struct和enum，可以使用impl来对这些数据实现操作方法；

封装细节：Rust提供了数据字段的公私有性；对于私有的属性，外部只能通过封装好的方法进行访问；另外只要公共的对外接口不变，内部的实现细节变动不影响外部使用方；

继承：Rust没有继承，但使用继承所能达到的目的，Rust可以通过其它方式来实现：
> 代码复用：通过trait的默认实现可以共享代码；<br/>
> 多态：如下，通过```Box<dyn Trait>```来实现。

### 实现多态

使用```Box<dyn Trait>```可以实现多态的能力:

```rust
    // 定义一个含有draw方法的trait
    trait Draw{
        fn draw(&self);
    }
    // 以下两个类型，都实现了Draw
    struct Button();
    impl Draw for Button{
        fn draw(&self) {
            println!("drawing Button")
        }
    }
    struct TextField();
    impl Draw for TextField{
        fn draw(&self) {
            println!("drawing TextField")
        }
    }

    // 使用vec来保存实现了Draw trait的变量
    // Box<dyn Draw>表示实现了Draw trait的对象
    // 与泛型不同，这种方式使得在component里可以存储任意多种类型，只要实现了Draw即可
    let mut components:Vec<Box<dyn Draw>> = Vec::new();

    // 可以将实现了Draw的类型push进components
    components.push(Box::new(Button{}));
    components.push(Box::new(TextField{}));
    // 并且可以遍历调用draw方法，而不需要关心存储的具体类型是什么
    for c in components{
        c.draw();
    }
```

泛型中使用的trait约束，会在编译期间展开成具体的类型，称之为静态派发。

而在使用trait对象时，编译期无法确定使用哪种具体类型，需要生成一些额外代码在运行期间查找应该调用的方法，这些称之为动态派发。

动态派发会产生一些运行时开销，例如对于trait对象来说，Rust会根据对象内部的指针来确定调用哪个方法，而动态派发还会阻止编译器内联代码，使得一些优化操作无法进行。但也带来了灵活性，需要根据具体场景确定使用哪种方式。

### 对象安全

只有满足对象安全的trait才能转成trait对象；如果一个trait中定义的所有方法满足以下两条规则，则它就是对象安全的：

1. 方法中不能返回Self类型。Self方法是当前实现此trait的类型别名，如果trait返回了Self，则rust无法确定具体会返回什么类型。例如Clone trait。

2. 方法中不包含任何泛型参数。泛型参数会被展开成具体的类型，这些具体类型会被视作当前类型的一部分。由于trait对象忘记了类型信息，所以我们无法确定被填入泛型参数处的类型究竟是哪一个。

如果使用了类型不安全的trait，会在编译时出错：

```rust
    // 不满足对象安全的trait不能转化为trait对象
    // `Clone` cannot be made into an object
    // note: the trait cannot be made into an object because it requires `Self: Sized`
    //  note: for a trait to be "object safe" it needs to allow building a vtable to allow the call to be resolvable dynamically;
    // let wrong:Vec<Box<dyn Clone>>  = vec![];
```

使用Rust实现状态模式的例子：

```rust
// 实现状态模式
// Post表示发布文章的流程，从草稿到审核再到发布
fn main() {
    let mut post = Post::new();
    post.add_text("I'm greate");
    println!("after add_text:{}", post.content());
    post.request_review();
    println!("after request_review:{}", post.content());
    post.approve();
    println!("after approve:{}", post.content());
}

struct Post {
    // 状态机：草稿->审核->发布
    // 为什么要用Option呢？如果不用Option在处理所有权的时候会比较麻烦，在所有权处理的时候需要注意
    state: Option<Box<dyn State>>,
    content: String,
}

impl Post {
    fn new() -> Post {
        Post {
            // 默认是草稿的状态
            state: Some(Box::new(Draft {})),
            content: String::new(),
        }
    }
    fn add_text(&mut self, text: &str) {
        self.content.push_str(text)
    }
    fn request_review(&mut self){
        // 将这些操作都代理给state，这些处理会导致新的状态，替换原来旧的状态
        // Option::take()获取变量的所有权，在这里把state的所有权取出，因为马上就要使用新的state来替换进去了
        if let Some(s) = self.state.take(){
            self.state = Some(s.request_review())
        }
    }    
    fn approve(&mut self){
        if let Some(s) = self.state.take(){
            self.state = Some(s.approve())
        }
    }
    fn content(&self)-> &str{
        self.state.as_ref().unwrap().content(self)
    }
}

trait State {
    fn request_review(self: Box<Self>) -> Box<dyn State>;
    fn approve(self: Box<Self>) -> Box<dyn State>;
    fn content<'a>(&self, post:&'a Post)->&'a str{
        ""
    }
}

struct Draft {}
impl State for Draft {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        Box::new(PendingReview{})
    }
    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }
}

struct PendingReview {}
impl State for PendingReview {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        self
    }
    fn approve(self: Box<Self>) -> Box<dyn State> {
        Box::new(Publish{})
    }
}

struct Publish {}
impl State for Publish {
    fn request_review(self: Box<Self>) -> Box<dyn State> {
        self
    }
    fn approve(self: Box<Self>) -> Box<dyn State> {
        self
    }
    fn content<'a>(&self, post:&'a Post)->&'a str{
        &post.content
    }
}
```


## 匹配模式

模式匹配分成可失败匹配(refutable)和不可失败匹配(irrefutable)：

* 不可失败匹配是指可以匹配任何输入值的场景，例如let x = 5；

* 可失败是指有可能出现某些值不匹配导致匹配失败的，例如let Some(x) = a; 如果a为None时，这个匹配就不成功了。

for、let、函数参数只接收不可失败的匹配，如果下代码将报错：

```rust
    // let只接收不可失败的匹配，所以下将编译报错
    // refutable pattern in local binding: `None` not covered
    //  `let` bindings require an "irrefutable pattern", like a `struct` or an `enum` with only one variant
    // let Some(x) = v.iter().next();
```


使用匹配模式的场景


| 模式匹配场景        | 可失败or不可失败          | 
| ------------- |:-------------| :----------|
|match |除了最后一个模式，其它模式是可失败的模式，最后一个可以是可失败的也可以是不可失败的|
|if let | 可失败，如果使用不可失败将收到warning| 
|while let |可失败，如果使用不可失败将收到warning| 
|for |不可失败, 这里的不可失败是指Some里面的值，而不包含Some匹配| 
|let | 不可失败| 
|函数参数 |不可失败| 

匹配的类型

| 模式匹配场景        | 举例          |
| ------------- |:-------------|
|字面量匹配| match m{<br/>1 => {}<br>...|
|变量名匹配| match m{<br/>x => {x}<br>...|
|使用\|的多重模式| match m{<br/>1\|2 => {}<br>...|
|使用..=来匹配区间，注意...已经不推荐使用| match m{<br/>1..=2 => {}<br>...|
|    解构结构体匹配|     if let Point { x, y } = p |
|    解构枚举匹配|    if let Some(c) = favorite_color { |
|    解构嵌套的枚举和结构体匹配|     let ((feat, inches), Point { x, y }) = ((3, 10), Point { x: 3, y: -10 });|
|    解析结构体和元组匹配|    let ((feat, inches), Point { x, y }) = ((3, 10), Point { x: 3, y: -10 }); |
|忽略模式匹配中的某些值|    let (x, _, z) = (1, 2, 3); |
|使用..来忽略值的剩余部分|    let (_first, .., _last) = (1, 2, 3, 4, 5, 6, 7, 8, 9); |
|使用匹配守卫(match guard)添加额外条件|    match c {<br/>        Some(x) if x > 6 => {}<br/>...|
|@绑定|    if let Some(i @ 1..=5) = c { |

以下例子位于example/src/bin/pattern.rs中：

```rust
    // match匹配模式
    // 必须穷尽所有的可能性；为了满足这一条件，可以使用两种方式
    // 1. 最后一个分支使用全匹配模式，可以使用一个变量名来处理
    // 2. 使用下划线这一特殊的模式来匹配所有值
    let m = 5;
    match m {
        // 字面量匹配
        1 => println!("is 1"),
        // 变量名匹配
        x => println!("is not 1, is {}", x)
    }
    match m {
        // 匹配区间值
        // 在老的版本中1..=5的语法也写作1...5，但最新的rust 2021只能使用1..=5，表示1~5包含1和5
        // 也可以使用|来表示，等价于1|2|3|4|5，但写起来更简单，字符类型也可以使用，例如'a'..='k'
        1..=5 => println!("between 1~5"),
        _ => println!("others")
    }

    // if let条件表达式
    // if let表达式只匹配match中的一种情况
    // 可以与if, else if, else, else if let等混合使用，以下是一个例子
    let favorite_color: Option<&str> = None;
    let is_friday = false;
    let age: Result<u8, _> = "34".parse();
    if let Some(c) = favorite_color {
        println!("using your favorite color: {}", c);
    } else if is_friday {
        println!("using friday color: red");
    } else if let Ok(a) = age {
        println!("your age {} colour: blue", a);
    } else {
        println!("default color: black");
    }

    // while let 条件循环
    // 与if let类似，当匹配不上时，结束循环
    let v = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
    let mut i = v.iter();
    while let Some(elem) = i.next() {
        // 123456789
        print!("{}", elem)
    }
    println!();
    let mut i = v.iter();
    // 任何能用于match的分支都能用于其它的匹配模式
    while let Some(1..=5) = i.next() {
        // aaaaa
        print!("a")
    }
    println!();

    // for循环
    // for循环自动把Some给解构了，并且自动调用了迭代器的next函数
    for (i, v) in v.iter().enumerate() {
        print!("({},{})", i, v);
    }
    println!();
    // 以上与以下等价
    let mut it = v.iter().enumerate();
    while let Some((i, v)) = it.next() {
        print!("({},{})", i, v);
    }
    println!();

    // let语句
    // 我们日常使用的let语句也是使用了模式匹配
    let (x, y, z) = (1, 2, 3);
    println!("x:{}, y:{}, z{}", x, y, z);

    // 函数参数也使用了模式匹配
    // 如下例子的函数参数类似于let &(x,y) = &p
    fn print_point(&(x, y): &(i32, i32)) {
        println!("point({},{})", x, y);
    }
    let p = (3, 4);
    print_point(&p); // point(3,4)

    // 可失败模式匹配和不可失败模式匹配
    // let, for, 函数参数必须是不可失败的模式匹配，在不可失败的模式匹配中使用可失败的模式，将发生编译报错
    // let只接收不可失败的匹配，所以下将编译报错
    // refutable pattern in local binding: `None` not covered
    //  `let` bindings require an "irrefutable pattern", like a `struct` or an `enum` with only one variant
    // let Some(x) = v.iter().next();

    // 在接收可失败的模式中使用不可失败模式，将收到编译器警告
    // irrefutable `if let` pattern
    // this pattern will always match, so the `if let` is useless
    if let x = 5 {
        println!("no meaning:{}", x)
    }
    let p = Point { x: 10, y: 10 };
    if let Point { x, y } = p {
        println!("pppp({}, {})", x, y);
    }

    // 使用解构来分解值
    // 可以使用模式来分解结构体、枚举、元组、引用
    // 解构结构体
    struct Point {
        x: i32,
        y: i32,
    }
    let p = Point { x: 10, y: 2 };
    // 指定字段值赋于的变量名a和b
    let Point { x: a, y: b } = p;
    println!("a:{}, b:{}", a, b); // a:10, b:2
    // 如果字段名与变量名一致时，可以简写成如下
    let Point { x, y } = p;
    println!("x:{}, x:{}", x, y); // x:10, x:2
    // 也可以使用match让某个字段指定某个值来匹配
    match p {
        Point { x: 0, y } => { println!("point at y axial, y:{}", y) }
        Point { x, y: 0 } => { println!("point at x axial, x:{}", x) }
        Point { x, y } => { println!("point at space:({}, {})", x, y) }
    }
    // 解构枚举之前看到的Option已经使用过多次了
    // 这里看一下解构嵌套的结构体和枚举
    let p = Some(Point { x: 10, y: 20 });
    if let Some(Point { x, y }) = p {
        println!("x:{}, x:{}", x, y); // x:10, x:20
    }
    // 解析结构体和元组
    let ((feat, inches), Point { x, y }) = ((3, 10), Point { x: 3, y: -10 });
    println!("{},{},{},{}", feat, inches, x, y); // 3,10,3,-10

    // 使用_来忽略某些值
    // 忽略第一个参数
    fn foo(_: i32, y: i32) {
        println!("{}", y);
    }
    // 忽略元组中的第二个元素
    let (x, _, z) = (1, 2, 3);
    println!("x:{}, z:{}", x, z);
    // 使用下划线开头的变量来防止编译器未使用的报警
    // 以下如果不使用_，则会有警告：unused variable: `x`
    // 注意，你还是可以使用下划线开头的变量的 println!("{}", _x);
    let _x = 10;
    // 下划线开头的变量依然会绑定值，这与纯下划线忽略值不一样
    let s = Some("hello".to_string());
    // 这里的_如果替换成_k，则最后打印s将报错，因为此时s中的值的所有权已经移到_k中了
    // 而_不会绑定值，所以还可以使用s
    if let Some(_) = s {}
    println!("{:?}", s);

    // 使用..来忽略值的值的剩余部分
    // 只匹配x的值，忽略剩下部分的字段
    let Point { x: _x, .. } = Point { x: 10, y: 10 };
    // 匹配第一个和最后一个，分别是1和9
    let (_first, .., _last) = (1, 2, 3, 4, 5, 6, 7, 8, 9);
    // 如果编译器无法确认匹配，即..产生歧义的匹配时，将报错
    //  can only be used once per tuple pattern
    // let (.., middle, ..) = (1,2,3,4,5,6,7,8,9);

    // 使用匹配守卫额外添加条件
    let c = Some(10);
    match c {
        // 在匹配分支后面添加if表达来额外限定匹配条件
        Some(x) if x > 6 => {}
        Some(_) => {}
        None => {}
    }

    // 使用@绑定
    // 用于像范围匹配这种条件的情况下，将匹配到的值赋值到变量
    let c = Some(2);
    if let Some(i @ 1..=5) = c {
        println!("c is between 1~5:{}", i);
    }
```

## 高级特性

### 不安全rust

不安全超能力(unsafe superpower)：

1. 解引用裸指针；

2. 调用不安全的函数或者方法；

3. 访问或者修改可变的静态变量；

4. 实现不安全的trait。


#### 裸指针

裸指针要么可变(\*mut T)，要么不可变(\*const T)，不可变意味着不能对解引用后的指针直接赋值


与引用和智能指针的区别：

1. 允许忽略借用规则，即可以同时拥有同一内存地址的可变和不可变指针，或者拥有多个同一内存地址的可变指针；

2. 不能保证自己总是指向了有效的内存地址；

3. 允许为空；

4. 没有实现任何自动清理机制。

优势：

1. 更好的性能；

2. 与其它语言、硬件交互的能力。

以下例子位于example/src/bin/unsafe.rs中：

```rust
    // 解引用裸指针
    let mut num = 5;
    // 如果只是创建裸针针，并不需要unsafe关键字
    // 使用as关键来转化类型，以下两个指针都是从有效引用创建的，所以是有效的
    let r1 = &num as *const i32;
    let r2 = &mut num as *mut i32;
    // 从任意地址创建指针，这里的r3可能就不是一个可用的指针
    let t = 0x423243242usize;
    let _r3 = t as *const i32;

    // 如果需要解引用裸指针，则要将代码包在unsafe里
    unsafe {
        // 只有可变的裸指针才能赋值，不能对*r1进行赋值
        // 其实以下如果不是裸指针，已经破坏了引用规则，同一个地址的可变和不可变引用，但在裸指针中不受此限制
        *r2 = 10;
        println!("r1 val:{}", *r1); // r1 val:10
        // 以下由于指到了不合法的内存地址，直接段错误： segmentation fault
        // println!("r3 val:{}", *_r3);
    }
```


裸指针一个主要用途是与C代码接口进行交互。

不安全的方法与普通方法一样，只是在fn之前添加unsafe关键字，在不安全的函数中不需要使用unsafe关键字就可以使用不安全的特性。

```rust
    // 使用不安全的函数
    // 不安全的方法与普通方法一样，只是在fn之前添加unsafe关键字
    // 在不安全的函数体内使用不安全特性就不需要包裹unsafe了
    unsafe fn dangerous() {}
    // 不安全的方法需要包裹在unsafe中调用
    unsafe {
        dangerous();
    }
```

使用不安全特性的函数不一定都是不安全的函数，可以基于不安全的代码创建一个安全的抽象，例如标准库中的split_at_mut方法：

```rust
    pub fn split_at_mut(&mut self, mid: usize) -> (&mut [T], &mut [T]) {
        assert!(mid <= self.len());
        // SAFETY: `[ptr; mid]` and `[mid; len]` are inside `self`, which
        // fulfills the requirements of `from_raw_parts_mut`.
        unsafe { self.split_at_mut_unchecked(mid) }
    }
```

这个函数无法仅仅使用安全的Rust来实现，因为返回的两个切片都是self的一部分，造成两个可变引用的存在。
我们尝试通过实现简化的版本来验证一下。

```rust
// 尝试实现自己的简化版本split_at_mut，使用了不安全特性
    fn split_at_mut(v: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
        assert!(mid <= v.len());
        // 仅仅使用安全的Rust，会报两个可变指针的错误，而我们能保证这两个可变指针其实指向的是切片非重合的两部分
        // (&mut v[..mid], &mut v[mid..])
        // 所以可以使用unsafe特性来实现
        // 获取指向切片的可变裸指针
        let p = v.as_mut_ptr();
        unsafe {
            // 以下的from_raw_parts_mut函数是unsafe的，所以这块要包含在unsafe中
            (core::slice::from_raw_parts_mut(p, mid),
             core::slice::from_raw_parts_mut(p.offset(mid as isize), v.len() - mid)
            )
        }
    }
    let mut v = vec![1, 2, 3, 4, 5];
    let (a, b) = split_at_mut(&mut v[..], 3);
    println!("{:?}, {:?}", a, b);
```

使用extern关键字可以引入其它语言的函数，所有通过extern引入的函数都是不安全的，需要使用unsafe关键字。

```rust
    extern "C"{
        fn abs(input:i32)->i32;
    }

    unsafe {
        println!("{}", abs(-20));
    }
```

#### 访问或者修改可变的静态变量

静态变量，也称为全局变量。

不可变的静态变量与常量类似，静态变量的值在内存中拥有固定的地址，使用它的值总是会访问到同样的数据。与之相反的是，常量则允许在任何被使用到的时候复制其数据。

静态变量还可以是可变的，但访问或者修改可变的静态变量，都是unsafe的操作。这是因为Rust无法保证全局变量的修改和访问是否有发生竞争。

```rust
// 可变静态变量
static mut COUNTER:u32 = 10;
// 访问和修改可变静态变量需要使用unsafe特性
fn incr_counter(){
    unsafe {
        COUNTER += 1;
    }
}
fn get_counter() -> u32{
    unsafe {
        COUNTER
    }
}
fn main(){
    incr_counter();
    println!("{}", get_counter()); // 11
}
```

#### 使用不安全的trait

当trait中存在至少一个拥有编译器无法校验的不安全因素时，这个trait也需要声明为unsafe。

实现这个unsafe trait的impl需要添加unsafe声明。


```rust
    // 不安全的trait
    unsafe trait Foo {}
    unsafe impl Foo for i32 {}
    
    // 在并发章节说明的Send和Sync这两个trait就是不安全的trait，要为某个不安全的类型实现trait，需要使用unsafe关键字
    struct Point {
        x: i32,
        y: i32,
    }
    unsafe impl Send for Point {}
    unsafe impl Sync for Point {}
```

### 高级trait

#### 在trait定义中使用关联类型指定占位类型

例如Iterator trait，使用关联类型定义了Item，这个Item类型做为next的返回值。

实现Iterator的时候，需要将Item赋值到对应的类型，这样next就能返回此类型。

与泛型不同的是，如果Iterator是泛型，那么我们需要实现某个特定版本的泛型，例如实现`Iterator<i32>`这种泛型，调用的时候也要显示地指定对应的类型。


```rust
    // 标准库中Iterator迭代器trait的声明，内有关联类型Item
    // next返回的类型是Option<Self::Item>类型，即返回Item指定的类型
    pub trait Iterator {
        type Item;
        fn next(&mut self) -> Option<Self::Item>;
    }

    // 定义一个无限计数器，将关联类型指定成i32，返回一个Some(i32)
    struct Counter(i32);
    impl Iterator for Counter {
        type Item = i32;
        fn next(&mut self) -> Option<Self::Item> {
            self.0 += 1;
            Some(self.0)
        }
    }

    // 如果使用泛型来实现就显得很奇怪
    pub trait Iterator2<T> {
        fn next(&mut self) -> Option<T>;
    }

    // 在指定实现泛型trait时，需要显示指定实现的版本是什么
    // 如果有多个类型的实现，在调用的时候还要指定调用的是哪个版本的实现
    // 而使用关联类型则可以保证只有一种实现
    impl Iterator2<i32> for Counter {
        fn next(&mut self) -> Option<i32> {
            self.0 += 1;
            Some(self.0)
        }
    }
```

#### 默认泛型参数

即在实现泛型的trait时，不指定实现的类型，此时默认泛型参数发挥作用，实现的这个默认类型。

这个功能经常用于运算符重载，Rust提供了有限的运算符重载功能。

这个功能还能让在原来的实现上添加新的类型而不用修改原来的代码实现，只需要在这个新的泛型类型上添加默认值即可。

```rust
    // 默认泛型参数
    // 公共库中的Add trait实现加法运算符的重载，默认类型与被加数(Right-hand side)相同(Rhs = Self)
    pub trait Add<Rhs = Self> {
        type Output;
        fn add(self, rhs: Rhs) -> Self::Output;
    }
    #[derive(Debug, PartialEq)]
    struct Point(i32, i32);
    // 为Point实现了Add trait，没有指定泛型的类型，默认是Self，即Point类型
    // 等价于impl std::ops::Add<Point> for Point
    impl std::ops::Add for Point {
        type Output = Point;

        fn add(self, rhs: Point) -> Self::Output {
            Point(self.0 + rhs.0, self.1 + rhs.1)
        }
    }
    assert_eq!(Point(1, 2) + Point(2, 3), Point(3, 5));

    // 为非默认类型(i32)实现Add操作
    impl std::ops::Add<i32> for Point {
        type Output = Point;
        fn add(self, rhs: i32) -> Self::Output {
            Point(self.0 + rhs, self.1 + rhs)
        }
    }
    assert_eq!(Point(1, 2) + 2, Point(3, 4));
```

#### 完全限定语法

两个trait可以定义同名的方法，而且一个类型可以同时实现这两个trait，但当调用方法时，就有可能出现冲突，编译器报错。

此时可以使用完全限定语法来处理，例子如下：

```rust
    // 有两个同名函数的trait，以及同时实现这两个trait的类型在调用时发生的歧义调用
    trait Pilot {
        fn fly(&self) {
            println!("Engine start!")
        }
        fn name(){
            println!("Pilot")
        }
    }

    trait Wizard {
        fn fly(&self) {
            println!("Up!")
        }
        fn name(){
            println!("Wizard")
        }
    }
    struct Human {}
    impl Pilot for Human {}
    impl Wizard for Human {}
    impl Human {
        fn fly(&self) {
            println!("Dreaming!")
        }
        fn name(){
            println!("Human")
        }
    }
    // Human实现了Wizard的fly、Pilot的fly、以及自己也有fly方法
    let h = Human {};
    // 此时在调用fly时，会直接使用类型定义的方法
    // 如果Human没有实现自己的fly，此时将出现编译错误：multiple `fly` found
    h.fly(); // Dreaming!
    // 可以使用全限定的语法来指定调用哪一个fly方法
    Human::fly(&h); // Dreaming!
    Wizard::fly(&h); // Up!
    Pilot::fly(&h); //Engine start!

    // 对于没有self参数的函数冲突，原来的办法无能为力
    // 以下报错：cannot infer type
    // note: cannot satisfy `_: Wizard`
    // Wizard::name();
    // Human可以直接调用，输出Human的方法内容
    Human::name(); // Human
    // trait不能直接调用其函数，需要使用以下的限定语法
    <Human as Pilot>::name(); // Pilot
    <Human as Wizard>::name(); // Wizard
```


#### 超trait

当一个trait功能依赖于另外一个trait时，被依赖的这个trait称为当前trait的超trait(super trait)。

```rust
    // 超trait，依赖于另外一个trait的trait
    trait Animal {
        fn class(&self){}
    }
    // 依赖于类型实现了Animal，因为需要调用其class方法
    trait Cat:Animal{
        fn miao(&self){
            self.class()
        }
    }
    struct Persian{}
    // Persian必须实现了Animal，才能实现Cat
    impl Animal for Persian{}
    impl Cat for Persian{}
```

#### newtype模式

newtype模式是指将一个类型使用struct的元组模式封装一下成为一个新类型，这个类型只有一个字段，这种类型称之为瘦封闭(thin wrapper)。

在Rust中，这一模式不会导致运行时开销，编译器在在编译阶段优化掉。

可以使用这一模式绕过为类型实现trait的孤儿规则，即可以在trait、类型包之外的其它包中为类型实现trait。

但其实并没有真正地为类型实现了对应的trait，毕竟进行了封装，但可以使用Deref来实现与原来类型一样的效果。

```rust
    // newtype模式
    // 绕过孤儿规则，为Vec<String>实现Display trait
    struct Wrapper<'a>(Vec<&'a str>);
    impl<'a> std::fmt::Display for Wrapper<'a> {
        fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
            write!(f, "[{}]", self.0.join(","))
        }
    }
    let w = Wrapper(vec!["i", "am", "supper", "man"]);
    println!("{}", w); // [i,am,supper,man]
    // 但是封装类型并没有实现所有Vec<&str>的能力，比如len函数，w.len()将报错，因为没有实现
    // 此时可以使用Deref解引用trait以及自动解引用的性质来实现Wrapper与Vec<&str>更一致
    impl<'a> std::ops::Deref for Wrapper<'a> {
        type Target = Vec<&'a str>;

        fn deref(&self) -> &Self::Target {
            &self.0
        }
    }
    println!("len:{}", w.len());
```

### 高级类型

* newtype模式实现的类型，可以隐藏原始类型的一些实现，提供封装抽象能力。并且新的类型与原来的类型为两种不同的类型，编译器检查为这两种类型不能混用提供了检查。

* 而类型别名，则与newtype不同，他只是原类型的别名，两者等价可以混用，一般用于简化类型的书写，例如io库中的Result。

```rust
pub type Result<T> = result::Result<T, Error>;
```

* 永不返回的Never类型(!)；一般用于在match中处理异常等情况，例如exit()，panic!等都是返回Never类型。

```rust 
pub fn exit(code: i32) -> ! {
    crate::sys_common::rt::cleanup();
    crate::sys::os::exit(code)
}
```

### 动态大小类型与Size trait

str是动态大小类型，只能在运行时确认类型的大小。

我们无法创建动态大小类型的变量，也无法使用其作为函数参数，这种类型需要放在某种指针的后面，例如&str。

Rust提供了一个特殊的Size trait，编译时可确定大小的类型自动实现了Size trait，另外Rust为泛型类型隐式地添加了Size约束，也就是说泛型默认只能用于编译期可确定大小的类型。但可以显示地使用?Size来解除限制。

```rust
// 解除了Size的限制，并且参数需要使用&T，因为在编译期无法确定大小的类型，必须使用某种指针来引用。
fn generic<T:?Size> (t:&T){}
```

### 高级函数与闭包

```rust
    // 我们之前试过使用函数指针，闭包的Fn, FnMut, FnOnce这些trait来实现参数传递
    // 除此之外，还可以返回函数类型和trait类型做为函数的返回值
    // 以下函数，以函数指针做为返回值
    fn return_fn() -> fn(i32) -> i32 {
        |x| x + 100
    }
    let t = return_fn();
    println!("{}", t(10)); // 110

    // 以下函数，返回实现了Fn trait的函数指针或者是闭包
    fn return_fn_trait() -> Box<dyn Fn(i32) -> i32> {
        Box::new(|x|  x + 100 )
    }
    let t= return_fn_trait();
    println!("{}", t(10));
```

## server服务程序的例子

以下例子实现了线程池、优雅退出等特性，但比较粗糙。

```rust
// lib.rs
use std::sync::{Arc, mpsc, Mutex};
use std::sync::mpsc::{Receiver, Sender};
use std::thread;

// 封闭的线程运行环境
pub struct Worker {
    id: usize,
    // 为什么要用Option，因为drop的时候，需要获取到thread的所有权
    // 使用take获取所有权之后，此处的值就是None了
    thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<Receiver<Message>>>) -> Worker {
        // 每一个worker会起一个线程来接收对应的消息
        let thread = thread::spawn(move || {
            loop {
                // receiver需要lock，这里在let语句结束之后，这个receive已经unlock了
                // 因为如果MutexGuard不再使用，则将drop掉
                let message = receiver.lock().unwrap().recv().unwrap();
                // 换成以下两句，则这个l走到job完成后才释放unlock，不满足要求
                // let l = receiver.lock().unwrap();
                // let message = l.recv().unwrap();
                match message {
                    Message::Terminal => {
                        break;
                    }
                    Message::NewJob(job) => {
                        print!("{} is doing the job：", id);
                        job();
                    }
                }
            }
        });
        let thread = Some(thread);
        Worker { id, thread }
    }
}

// 一个任务即一个闭包函数，因为需要用于在不同的线程之间传递，所以需要实现Send
pub type Job = Box<dyn FnOnce() + Send>;

// 用于发送任务用的Message，有两种类型
// 一种是Terminal结束线程运行，另外一种是NewJob消息，即新的任务
pub enum Message {
    Terminal,
    NewJob(Job),
}

// 线程池，包含有发送Message用的sender，以及运行的Worker
pub struct ThreadPool {
    sender: Sender<Message>,
    workers: Vec<Worker>,
}

impl ThreadPool {
    /// 创建一个指定线程数的线程池
    ///
    /// # Panics
    ///
    /// `new`函数会在参数为0时panic
    pub fn new(s: usize) -> ThreadPool {
        assert!(s > 0);
        // 使用mpsc::channel来与给多个线程传递信息，但由于不能有多个消费者(即Receiver没有实现Sync)
        let (sender, receiver) = mpsc::channel();
        // with_capacity可以用于预分配对应大小的动态数组，减少动态扩容
        let mut workers = Vec::with_capacity(s);

        // receiver没有实现Sync，需要使用Mutex包裹起来实现Sync，另外需要在多个线程中使用，必须使用Arc引用计数
        let receiver = Arc::new(Mutex::new(receiver));

        for id in 0..s {
            // 每一个线程就是一个worker，保存于workers中
            workers.push(Worker::new(id, receiver.clone()));
        }

        ThreadPool { sender, workers }
    }
    pub fn execute<T>(&self, f: T) where T: FnOnce() + Send + 'static {
        self.sender.send(Message::NewJob(Box::new(f))).unwrap();
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        for _ in &mut self.workers {
            println!("send terminal to workers");
            self.sender.send(Message::Terminal).unwrap();
        }
        for w in &mut self.workers {
            // 因为join需要获取所有权，所以这块使用了take
            if let Some(t) = w.thread.take() {
                t.join().unwrap();
                println!("No. {} thread has terminal!", w.id);
            }
        }
    }
}
```

```rust
// main.rs
use std::io::{Read, Write};
use std::net::TcpListener;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use signal_hook::consts::SIGINT;
use signal_hook::iterator::Signals;

use server::ThreadPool;

fn main() {
    // 起一个线程数量为4的线程池
    let thread_pool = ThreadPool::new(2);

    // 起一个线程单独处理信号，收到信号时，需要将信息传递给accept来结束接收连接，所以这里加了一个channel
    // 信号处理使用signal_hook包来处理
    let (terminal_sender, terminal_receiver) = mpsc::channel();
    let sig = thread::spawn(move || {
        let mut signal = Signals::new(&[SIGINT]).unwrap();
        for sig in signal.forever() {
            println!("rec sig:{}", sig);
            terminal_sender.send(()).unwrap();
            break;
        }
    });

    // 将listener放在单独的作用域里，这样当信号发出时，第一时间结束监听端口
    // 这样新的连接就不会打进来了，但旧的请求还是能被正常处理
    {
        // 使用TcpListener::bind让程序监听端口；
        // bind接收泛型参数，只要实现了ToSocketAddrs即可，例如String类型，不管是&str还是String都行
        let listener = TcpListener::bind("localhost:8888".to_string()).unwrap();

        // TcpListener的incoming返回迭代器，产生std::io::Result<TcpStream>类型
        // 也可以使用accept函数，将其放在loop中，其返回Result<(TcpStream, SocketAddr)>类型
        for stream in listener.incoming() {
            // 1. 最原始每一个请求阻塞处理
            // handler_connection(stream.unwrap());
            // 2. 每一个请求都启动一个线程来执行，但这样很快就会耗尽机器资源，容易被ddos攻击
            // thread::spawn(move || {
            //     handler_connection(stream.unwrap());
            // });
            // 3. 使用线程池来处理只保留有限的线程数来处理
            thread_pool.execute(move || {
                handler_connection(stream.unwrap());
            });
            // 由于把这个接收函数放在了接收任务时，所以这块有一个限制就是如果没有请求就无法运行到此处
            // 暂时没有想到很好的办法来处理这个
            if let Ok(_) = terminal_receiver.try_recv() {
                println!("get terminal sig!");
                break;
            }
        }
    }
    sig.join().unwrap();
    // 退出此作用域时，会调用thread_pool的drop函数来处理完请求
    println!("main end!");
}

// 处理每一个请求
fn handler_connection(mut stream: std::net::TcpStream) {
    let mut buffer = [0; 1000];
    let len = stream.read(&mut buffer).unwrap();
    let content = String::from_utf8_lossy(&buffer[0..10]);
    println!("receive a connection: remoteAddr {:?}, receive data len:{}, content:{:?}", stream.peer_addr().unwrap(), len, content);
    let index = b"GET / HTTP/1.1\r\n";
    let sleep = b"GET /sleep HTTP/1.1\r\n";
    if buffer.starts_with(index) {
        let response = "HTTP/1.1 200 OK\r\n\r\nOK";
        stream.write(response.as_bytes()).unwrap();
    } else if buffer.starts_with(sleep) {
        thread::sleep(Duration::from_secs(10));
        stream.write(b"HTTP/1.1 200 OK\r\n\r\nsleep").unwrap();
    } else {
        stream.write(b"HTTP/1.1 404 NOT FOUND\r\n\r\nnot found").unwrap();
    }
}
```



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

.postn ul {
    font-size: 0.75em;
    list-style-type: disc;
    padding-left: 16px;
    margin-top:0px;
}

</style>
