---
layout: post_n
title: 《Rust权威指南》笔记
date: 2021-09-06
categories:
  - Reading
description: 
image: /assets/images/traffic_light.jpg
image-sm: /assets/images/traffic_light.jpg

---
* ignore but need
{:toc}


## 安装与示例

如[官网](https://www.rust-lang.org/tools/install)所说，运行以下命令即可安装：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

rust相关的工具会被安装到```/Users/bytedance/.cargo/bin```这个目录下，如果没有把这个目录加到PATH下，添加即可使用。

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

Cargo是Rust工具链中内置的构建系统及包管理器。

| 命令        | 说明           | 
| ------------- |:-------------| 
| cargo new \<path\>    | 创建一个新的cargo项目，会生成Cargo.toml和src/main.rs| 
| cargo new \-\-lib  \<path\>   | 创建一个新的库项目，会生成Cargo.toml和src/lib.rs| 
| cargo build      |编译本项目，生成的可执行文件位于./target/debug/下，如果添加\-\-release，则会生成到./target/release/下；<br/>\-\-release参数将花费更多的时间来编译以优化代码，一般用于发布生产环境时使用   |  
| cargo run | 编译并运行本项目，也支持\-\-release参数，常用于运行压测； -p 用于工作空间下有多个二进制包时指定运行哪个包   |  
| cargo run \-\-bin \<target\>  | 编译并运行指定的bin文件，一般位于src/bin目录下，target不带.rs后缀   |  
| cargo check | 仅检查是否通过编译，由于不生成二进制文件，速度快于cargo build  |
| cargo doc | 在当前项目的target/doc目录生成使用到的库的文档，可以使用\-\-open选项直接打开浏览器  |
| cargo update | 忽略Cargo.lock文件中的版本信息，并更新为语义化版本所表示的最新版本，用于升级依赖包  |
| cargo test | 运行测试用例，默认情况下是多个测试case并行运行；\n cargo test接收两种参数，第一种传递给cargo test使用，第二种是传递给编译出来的测试二进制使用的，这两种参数中间使用\-\-分开\n例如 cargo test -q  tests::it_works -- --test-threads=1；这一命令，会以安静模式(-q)运行tests::it_works下的测试，并且只使用一个线程串行运行(--test-threads=1) |
|cargo publish | 发布项目到crate.io上，添加\-\-allow-dirty可以跳过本地git未提交的错误|
|cargo yank \-\-vers 0.0.1| 撤回某个版本，添加\-\-undo取消撤回操作|


Cargo.toml说明：

| 段名        | 说明           | 
| ------------- |:-------------| 
| package     | 本包(crate)的信息说明| 
| dependencies  |依赖的外部包，版本是语义化的版本，用于update时判断最新的可用版本    | 

crate是Rust中最小的编译单元，package是单个或多个crate的集合，crate和package都可以被叫作包，因为单个crate也是一个package，但package通常倾向于多个crate的组合。

Rust中的包（crate）代表了一系列源代码文件的集合。用于生成可执行程序的称为二进制包（binary crate），而用于复用功能的称为库包（library crate，代码包），例如rand库等。

创建项目：
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

```rust
// 使用use语句进行包导入；rust默认会预导入(prelude)一部分常用的类型，而std::io不在此范围，需要使用use语句
use std::io;
// 首先使用了rand包，需要在Cargo.toml中添加rand = "0.8.0"
// 在run或者build的时候，会根据crates.io上的最新版本、依赖关系下载所需要的包
// 再次rand::Rng为trait(后面解析)，gen_range定义于此Trait中
// 如果不导入，调用gen_range将报氏(为什么?)
use rand::Rng;
// 标准库中定义的比较结果的枚举
use std::cmp::Ordering;

fn main() {

    // rand::thread_rng()将返回位于本地线程空间的随机数生成器ThreadRng，实现了rand::Rng这一trait
    // gen_range
    // gen_range的参数签名在0.7.0的包和0.8.x的包上不一样，在旧版中支持两个参数，而新版本中只支持一个参数
    // 1..101的用法后面介绍，这一行表示生成[1,101)的随机数
    let secret_num = rand::thread_rng().gen_range(1..101);
    println!("secret number is {}", secret_num);


    // 死循环
    loop {
        // let关键字用于创建变量
        // 默认变量都是不可变的，使用mut关键字修饰可以使变量可变。
        // String是标准库中的字符串类型，内部我问个他UTF-8编码并可动态扩展
        // new是String的一个关联函数(静态方法)，用于创建一个空的字段串
        let mut guess = String::new();

        println!("Guess the number!\nPlease input your guess:");

        // std::io::stdin()会返回标准输入的句柄
        // 参数&mut guess表示read_line接收一个可变字符串的引用(后面介绍)，将读取到的值存入其中
        // read_line返回io::Result枚举类型，有Ok和Err两个变体(枚举类型的值列表称为变体)；
        // 返回Ok时表示正常并通过expect提取附带的值(字节数)；返回Err时expect将中断程序，并将参数显示出来
        // 不带expect时也能通过编译，但会收到Result没有被处理的警告(warning: unused `Result` that must be used)
        io::stdin().read_line(&mut guess).expect("Failed to read line");

        // rust中允许使用同名新变量来隐藏(shadow)旧值
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

        // 模式匹配，由match表达式和多个分支组成，rust可以保证使用match时不会漏掉任何一种情况
        // rust会将secret_num也推导成u32与guess比较
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

### 变量与可变性

变量默认是不可变的，这意味着一但赋值，再也无法改变：

```rust
    let x: i32;
    x = 5;
    let y: i32 = 10;
    // 以下行报错Cannot assign twice to immutable variable [E0384]
    // y=9
```

可以变量名前添加mut使得此变量可变

```rust
    let mut x = 10;
    x = 100;
    x = 1000;
```

常量使用const修饰，名称全部大写，并用下划线分隔；常量可以是全局的(例如main函数之外)也可以是局部的；常量必须显示指定类型：

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

```
    let space = "   ";
    let space = space.len();
```

### 数据类型

rust是一门静态语言，所以变量在编译时就确定了其数据类型。rust的数据类型分为标量类型(scalar)和复合类型(compound)。

一般情况下，在编译器可以推断出类型的场景中，可以省略类型标注，但在无法推断的情况下，就必须显示的声明类型了。

```rust
    // 以下报错：type annotations needed
    // let k = ("32").parse().expect("not ok");
    let k: i32 = ("32").parse().expect("not ok");
```

标题类型是单个值类型的统称：4种标量类型：整数、浮点数、布尔值及字符

整数类型：i8,u8,i16,u16,i32,u32,isize,usize；以上除了isize和usize所占的字节数是根据平台(32位/64位)来确定的，其它的的类型都有明确的大小

整数类型的默认推导是i32

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
    // 在debug模式编译时，会在运行进报错
    // thread 'main' panicked at 'attempt to add with overflow', src/main.rs:41:26
    // note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
    // 在release模式下，则不会报错，输出28
    println!("{},see!", x + y);
```

浮点数类型：f32，f64；默认推导为f64。

数值运算：加(+)、减(-)、乘(x)、除(/)、取余(%)；只有相同类型间才能进行操作

```rust
    // 类型不一样，无法操作
    // let x:u8 = 10;
    // let y:u32 = 100;
    // let z = y+x;
```

布尔值，只拥有true和false，占据一个字节大小，常用于if的判断

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

将多个不同类型的值合成一个类型，称为复合类型；rust有两种内置复合类型：元组(tunple)和数组(array)

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
每一个元素必须类型一致，数组大小不可改变，在栈上分配。


### 函数 

命名由下划线分隔的多个小写单词组成。

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

if的条件表达式必须是bool值。if表达式可以用于赋值。

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

使用循环 loop，while，for

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

while: while表达式的值一直都是空值。

```rust
    // while表达式的值一直是空值，如果使用break，后面不能跟返回值
    let mut i = 1;
    let count:() = while i > 10 {
        i += 1;
    };
```

for
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



Java：通过垃圾回收来管理内存
C/C++：开发者手动地分配和释放
Rust：通过应用所有权系统规则，在编译期间检查，来保证内容安全。

所有权系统使得rust在没有垃圾回收的情况下，保证内存安全。

所有权规则：
1. Rust中每一个值都一个变量作为他的所有者；
2. 在同一个时间内，值有且仅有一个所有者；
3. 当所有者离开他的作用域时，他所持有的值将被释放。

使用域的概念与其它语言类似，不再赘诉。

String类型：
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

String类型由两大部分组成，存储于栈上的元信息(ptr, len, cap)，即指向堆上的指针，长度，容量；而实际的内容保存在ptr所指的堆上，如下图：
《《《《图》》》

将s1赋值给s2时，由于Rust不会对堆上值也进行拷贝，只会将栈上的元数据进行拷贝，所以目前的状态有可能是s1,s2所指向的String元数据中的指针都指向了同一片堆区域。
<<<图>>>


在s1和s2变量离开作用域后，Rust会自动执行对应类型上的drop方法，释放对应的内存，问题就产生了，这将产生二次释放问题。

为了解决这个问题，rust在种情况下，会将s1的变得无效，这就是之前例子中第三行无法通过编译的原因。

这种只有拷贝了栈上的数据而没有拷贝堆上的数据的浅拷贝，在rust中称为移动(move)，上面例子中，s1被移动到s2了

Rust永远不会自动地创建数据的深度拷贝。因此在Rust中，任何自动的赋值操作都可以被视为高效的。


如果确实需要使用深拷贝，可以使用clone函数，如下例子可以通过编译

```rust
    // 对s1进行深拷贝，即将堆上的内容也进行了拷贝
    let s1 = String::from("Hello");
    let s2 = s1.clone();
    println!("{}, {}", s1, s2);
```

对于完全存储在栈上的数据，赋值本身已经将全部数据 都拷贝，所以不用调用clone方法。在Rust中，实现了Copy trait的类型，实现了copy trait的类型，都可以在将变量赋值给其它变量时原变量保持可用。以下类型实现了copy trait:

所有的标量类型，元组或者数组中包含的元素是copy的，则元组或者数组就是copy的。

```rust
    // 如果这个元组加了String类型，如下，则不能通过编译
    // let x = (1,2,3.0);
    let x = (1, 2, 3.0, String::from("Hello"));
    let y = x;
    println!("{}", x.1);

    let x = [1, 2, 3];
    let y = x;
    println!("{}", x[1]);
```

注意copy和drop是互斥的，如果一个类型本身或者成员变量实现了copy，则这个类型就无法实现drop。



函数与所有权：
函数参数与赋值是一样的，返回值也是一样的

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

引用分成可变引用和不可变引用，但这块的可变是指可以改变指向哪个值，而无法改变值本身，注意以下两组的区别。

```rust
    let mut s:String = String::from("hello");
    let s1:&mut String = &mut s;
    s1.push_str(",world");

    let mut s:String = String::from("hello");
    let mut s2:&String = &mut s;
    // 以下无法通过编译，因为s2是&String不可变类型
    s2.push_str(", world");
```

另外一次只能申明一个可变引用，如果某个变量已经被可变引用了，也不允许再被不可变引用。这可以很好的避免数据竞争。

```rust
    let mut s = String::from("hello");
    let s1 = &mut s;
    // cannot borrow `s` as mutable more than once at a time
    // let s2 = &mut s;
    // cannot borrow `s` as immutable because it is also borrowed as mutable
    let s3 = &s;
    println!("{},{}, {}", s1, s2, s3);
```

总结出来以下规则：

1. 在任何一段给定的时间里，你要么只能拥有一个可变引用，要么只能拥有任意数量的不可变引用。
2. 引用总是有效的。

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

其它类型的切片

```rust
    // 其它切片
    let ia = [1, 2, 3, 4, 5, 6];
    let sia: &[i32] = &ia[1..3];
```

## 结构体

1. 一个结构体的实例是可变的，则这个结构体的所有成员变量都是可变的
2. 在创建结构体实例时，如果变量名与字段名同名时，可以省略字段名，直接写变量名
3. 可以使用```..old```这种语法来快速从old创建一个只有部分值改变的新变量
4. 支持不带字段名的元组结构体
5. 支持空结构体
6. 如果结构体的成员是引用时，需要带上生命周期的标识



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

通过结构体来更清晰表达字段含义
使用注解来快速实现trait，使得可以在println!中使用{:?}和{:#?}来输出自定义结构体。
使用impl关键字为结构体实现方法
方法第一个参数永远是self，可以是获得所有权（self），也可以是借用(&self)，还可以是可变的(&mut self或者是mut self)
同一个结构体，可以写多个impl，但不能多次定义同一个方法，即使参数不一样也不行
如果方法的第一个参数不为self,则称为关联函数，类似与静态方法


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

枚举使用enum关键字定义，每一个枚举值称之为变体(variant)
每一个变体可以有不同的数据类型和数量的数据关联
枚举相校与结构体不同的地方在于，如果对变体的不数数据定义各自的结构，则他们属于不同类型，而使用枚举则可以使用一种类型来描述不同的数据结构
同样可以为枚举实现方法
使用match模式匹配处理每一种变体，必须处理所有的变体，否则编译不通过；当然可以使用通配符来匹配任意值/类型
match还可以绑定匹配对应的部分值





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
这里的\<T\>为泛型参数，None表示空值，Some表示有值，并持有值。

```rust
    // 标准库中的Option类型
    // 为一个Option值加1
    fn plus_one(c:Option<i32>)->Option<i32>{
        match c {
            None => None,
            Some(i) => Some(i+1)
        }
    }
    let five = plus_one(Some(4));
    let none = plus_one(None);
    match five{
        None=>println!("none"),
        Some(i)=>println!("val is {}", i)
    };
    match none{
        None=>println!("none"),
        Some(i)=>println!("val is {}", i)
    };
```

```rust
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


在只关心某一种匹配而忽略其它匹配的时候，可以使用if let来简化代码

```rust
    // 使用if let来简化处理
    let five: Option<i32> = Some(5);
    if let Some(i) = five {
        println!("has value {}", i)
    }
```

## 包管理

包（package）：一个用于构建、测试并分享单元包的Cargo功能。
单元包（crate）：一个用于生成库或可执行文件的树形模块结构。
模块（module）及use关键字：它们被用于控制文件结构、作用域及路径的私有性。
路径（path）：一种用于命名条目的方法，这些条目包括结构体、函数和模块等

用于生成可执行程序的的单元包称为二进制单元包
用于生成库的单元包称为库单元包
一个包至少要有一个单元包，并且最多只能包含一个库单元包，但可以包含多个二进制单元包
rust编译时所使用的入口文件被称为根节点，例如src/main.rs
src/main.rs和src/lib.rs做为默认的二进制单元包和库单元包的根节点，无需在cargo.toml中指定


mod关键字可以定义模块，模块内可以嵌套定义子模块
可以使用两模式定位到模块内的函数/枚举等：1. 使用单元包名或字面量crate从根节点开始的绝对路径。2. 使用单元包名或字面量crate从根节点开始的绝对路径。
rust中所有的条目包括函数、方法、结构体、枚举、模块、常量默认都是私有的。
对于模块来说，父级模块无法使用其子模块中的私有的条目，而子模块可以使用所有祖先模块中的条目。

公开的结构体其成员默认还是私有的，公开枚举时，其变体自动变成公开。

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

使用use关键字可以简化引用路径
使用as关键字使用新的名称，可以解决重名的问题
使用pub use重导出名称，使用pub use的名称不仅在本作用域内可以使用，外部也可以通过引入本作用域来调用到pub use导出的包。可以用于重新组织包结构。
使用外部包与使用std包类似，只是需要在cargo.toml文件中的dependencies小节中添加包名以及对应的版本。


```rust
// 使用use关键字可以简化路径
// 以下两行等价，self关键字可能在后续版本中去掉
use front_of_house::hosting;
// use self::front_of_house::hosting;

pub fn eat_at_restaurant2() {
    hosting::add_to_waitlist();
}

```


如果要导入一个树型包中的几个包，可以使用嵌套的语法来减少use语句的使用，

```rust
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

可以将模块的层级关系使用目录关系来组织起来。
例如原例子中在libs下面创建如下关系的包
libs.rs
```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}

        pub fn seat_at_table() {}
    }
```

可以将front_of_house移到front_of_house.rs中，则以下两个文件变成
libs.rs
```rust
mod front_of_house;
```

front_of_house.rs 
```rust
pub mod hosting {
    pub fn add_to_waitlist() {}

    pub fn seat_at_table() {}
}
```

也可以将front_of_house.rs再拆分

libs.rs
```rust
mod front_of_house;
```

front_of_house.rs
```rust
mod hosting;
```

front_of_house/hosting.rs
```rust
pub fn add_to_waitlist() {}

pub fn seat_at_table() {}
```

## 集合

### 动态数组

动态数组Vec是范型，在无法推断类型时，必须显示指定类型
使用vec!宏可以快速构建有初始值的数组
数组中的元素会在动态数组销毁时跟着销毁
数组元素的引用会对整个数组造成影响，即不可以在有只读引用的情况下，无法push元素
结合枚举，可以间接地在Vec中存储多种不同的类型

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
    // 返回Option<&T>类型，如果不越界将返回None
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

字符串本身是基于字节的集合，通过功能性的方法将字节解析为文本。
rust语言核心部分只有一种字符串类型，即字符串切片str，通常以引用形式出现(&str)，它是指向存储在别处的一些UTF8编码字符串的引用，例如字符串字面串
String类型定义在标准库中，不是语言核心的一部分，提供UTF8编码。
标准库还提供了OsString，OsStr，CString和CStr，一般以Str结尾的是借用版本，String结尾是所有权版本。这些类型提供了不同的编码或者不同内存布局的字符串类型

String类型实际使用Vec\<u8\>进行封装。
为了避免出现多字节情景下你拿到半个字符，所以rust不允许使用下标访问获取字符串的字符。而是通过特定的功能函数指定对字节，字符，字形簇进行处理。
但是Rust却允许字符串切片的使用，但使用时要格外小心，因为如果截取的范围不是有效的字符串，将发生panic

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
HashMap并没有在预加载库中，所以需要使用`use std::collections::HashMap;`进行导入
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

不可恢复错误：使用panic!宏，其参数与println!类似，支持占位符
访问Vec越界也会产生panic
在cargo.toml中的profile.release节添加`panic= 'abort'`来减少bin文件的大小(因为减少了栈展开所需要的信息)
添加`RUST_BACKTRACE=1`可以输出更加详细的panic信息，例如`cargo run --bin error --release`


可恢复错误
使用Result<T, E>做为返回值来处理包含正常情况和异常情况，正常情况下返回Ok(T)，异常时返回Err(E)
```rust
enum Result<T, E>{
    Ok(T),
    Err(E),
}
```
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

泛型代码的性能问题：Rust在编译期间将泛型代码单态化(monomorphization)，即将泛型代码根据调用时的类型生成对应的代码。所以不会对运行时造成性能影响。
例如 Option\<T\>类型在应用到i32和i64上时，生成了以下两种类型Option_i32，Option_i64

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

trait是指某些特定类型拥有的，而且可以被其它类型所共享的功能集合，类似于其它语言的interface。
实现trait的代码要么位于trait定义的包中，要么位于结构体定义的包中，而不能在这两个包外的其它包中，这个规则称之为孤儿规则，是程序一致性的组成部分。

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

生命周期大部分情况下可以推导出来，当无法推导时，就必须手动标注生命周期
生命周期最主要的目的是避免悬垂引用，进而避免程序引用到非预期的数据
Rust中不允许空值的存在

借用检查器(borrow checker)：用于检查各个变量的生命周期长短，以判断引用是否合法

生命周期的标注以单引号开始，后跟小写字母(通常情况下)，通常非常简短，例如'a。
标注跟在&之后，并使用空格与引用类型区分开，例如`&'a i32`、`&'a mut i32`等

每一个引用都有生命周期，而函数在满足一定条件下，可以省略生命周期声明，称为生命周期省略规则。
使用以下三条规则计算出生命周期后，如果仍然有无法计算出生命周期的引用时，则编译出错
1. 每一个引用参数都有自己的生命周期，这一条用于计算输入生命周期
2. 只存在一个输入生命周期时，这个生命周期将赋值给所有的输出生命周期参数，这一条用于计算输出生命周期
3. 当拥有多个输入生命周期参数，而其中一个是&self或&mut self时，self的生命周期会被赋予给所有的输出生命周期参数。这条规则使方法更加易于阅读和编写，因为它省略了一些不必要的符号。

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
        // 应用第一条和第三条规则，得出的生命周期不正确，所以编译报错
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

rust中的单元测试一般与要测试的代码放在同一个文件中，使用的模块名称为tests，通过```#[cfg(test)]```来标记，让编译器只在cargo test时才编译和运行这一部分代码，在cargo build等场景会剔除这些代码

在函数上使用```#[test]``` 称为属性(attribute)，与c#的attribute以及java的annotation一样，用于给编译器提供更多的信息。

cargo test参数说明：

\-\-之后的参数：
\-\-test-threads=1:运行的并发数，默认是多个case并行执行，可以设置成1为串行执行
\-\-nocapture: 将测试用例中打印出来内容输出显示出来。默认情况下这些内容会被捕获并丢弃
\-\-ignored: 专门运行被```#[ignore]```标记的case

\-\-之前的参数：
\-q：静默情况下运行测试用例，输出的信息比较有限
\-\-test file_name：用于指定运行集成测试的文件，注意不用跟.rs后缀名

cargo test允许我们指定需要运行的用例名，例如cargo test adder，则所有case名中包含有adder的case都会被运行(例如：tests::adder_test)，这种方法只能指定一个匹配字符串，无法指定多个。

在```#[test]```标记之后，跟上```#[ignore]```的测试函数，默认情况下不会运行，只有使用\-\-ignored时，才会专门运行这些case，例如```cargo test -- --ignored```

集成测试
在src同级别建立tests目录，在这个目录下可以创建任意的集成测试用例；tests目录只在cargo test时进行编译和执行，其它情况会忽略
tests目录下每一个文件都是独立包名，所以不用担心测试函数会重名。
可以在tests目录下建立子目录，做为公共使用的部分，或者隐藏测试中的细节等等，子目录中的函数也可以标记为```#[test]```，只他只在tests目录下的文件引用到时执行
如果将子目录做为公共部分使用，一般不在里面设置测试用例，因为如果多个测试模块引用的话，这个case将被运行多次

无法在集成测试中引用main.rs，所以一般我们将复杂的操作移到lib.rs中，而main.rs中只保留简单的胶水代码逻辑。


## minigrep
std::env::args() 获取命令行参数，与其它程序一样
std::process::exit(1) 退出进程，这个函数签名为:pub fn exit(code: i32) -> !，!表示从来不会返回
std::fs::read_to_string() 读取文件内容
std::env::var("CASE_INSENSITIVE") 获取环境变量值
eprintln! 将错误信息打印到标准错误输出


## 函数式语言特性：迭代器与闭包

闭包：可以在定义他的作用域中捕获值，在函数中使用

std::thread::sleep()

迭代器：
比起使用for循环的原始实现，rust更倾向于使用迭代器风格；迭代器可以让开发者专注于高层的业务逻辑，而不必陷入编写循环、维护中间变量这些具体的细节中。通过高层抽象去消除一些惯例化的模板代码，也可以让代码的重点逻辑（例如filter方法的过滤条件）更加突出。

迭代器是Rust语言中的一种零开销抽象（zero-cost abstraction），这个词意味着我们在使用这些抽象时不会引入额外的运行时开销
## 进一步认识Cargo及crates.io

rust中的发布配置是一系列定义好的配置方案，例如cargo build时使用dev配置方案，添加`--release`后，使用release配置方案。
在Cargo.toml中添加`[profile.dev]`和`[profile.release]`配置段可以对这两个方案进行配置。

在没有配置时，有一套默认的配置，当自定义了配置时，会使用自定义配置的子集覆盖默认的配置。

提到的配置

opt-level=1 : 编译优化程序，0~3优化递增，release默认是3，dev为0

## 文档注释

rust中使用三斜线做为文档注释，支持markdown语法；被包在markdown里的代码片段会被当成测试case，在运行cargo test的时候运行。

```rust
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

使用```cargo doc --open```来打开文档查看

使用```//!```开头的注释，不像```///```为紧跟的代码提供注释，而是为整个包，或者整个模块提供注释； 这种类型的注释，只能放在文件最开头


使用pub use 重新组织结构：
```rust
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


main.rs
```rust
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

1. 使用github账号登录
2. 在账号设置中绑定邮箱，并验证
2. 在账号设置中生成New Token
3. 在本地使用cargo login xxxx(your token)来保存token到本地(~/.cargo/credentials)
4. 在项目中填写足够的信息(Cargo.toml)
```ini
[package]
name = "guessing_game_xiaochai"
version = "0.1.0"
authors = "[xiaochai<soso2501@gmail.com>]"
edition = "2018"
description = "a game demo"
license = "MIT"
```
5. 在命令行中运行cargo publish，此时，会将代码提交到远程：https://crates.io/crates/guessing_game_xiaochai
如果本地是git，并且有未提交的文件，将会生成错误，可以使用``` cargo publish --allow-dirty```忽略git信息。


更新版本：
1. 修改Cargo.toml，增加版本号
2. 运行```cargo publish```即可提交新版本

撤回某个版本

```cargo yank --vers 0.1.0```可以撤回某个版本，虽然还能在crate.io上看到对应版本，但新的项目无法引用这个版本了
使用```cargo yank --vers 0.1.0 --undo```可以取消撤回操作

如果你分享的是一个二进制包，可以使用 cargo install guessing_game_xiaochai  来下载安装，会安装到~/.cargo/bin目录下

### 工作空间

同一个工作空间下的项目使用同一个Cargo.lock文件

1. 新起目录，例如workspace_example，cd workspace_example
2. 创建Cargo.toml文件，内容为
```ini
[workspace]
members = [
    "adder"
]
```
3. 在目录下使用cargo new来创建adder二进制包
4. 此时不管在workspace_example目录下运行cargo run 还是在workspace_example/adder下，最终的target都会在workspace_example/target目录下
    换种说法，adder项目目前已经不是一个独立的项目了，要么1. 在workspace_example/Cargo.toml添加
```
    [workspace]
members = [
]
exclude = [
    "adder",
]
```
    或者是在workspace_example/adder/Cargo.toml中添加空的[workspace]段
    这样才可以将adder单独编译
5. 添加add-one这个代码包```cargo new add-one --lib```
6. adder的二进制文件需要依赖adder-one包，需要在adder/Cargo.toml的dependencies段添加```add-one = { path = "../add-one" }```
7. 在main函数中使用
```rust
fn main() {
    println!("Hello, world!");
    println!("{}", add_one::add_one(10));
}
```
8. 在workspace_example下运行```cargo run```，则运行了adder包中的二进制文件；如果一个工作空间下有多个二进制项目的话，可以使用\-p参数来指定项目
```cargo run -p adder```

### 扩展cargo
如果在$PATH中包含有cargo-something的可执行文件，那么可以使用cargo something来运行此文件
例如刚安装的guessing_game_xiaochai程序
```
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

指针是指包含内存地址的变量
引用是最常用的指针，没有额外的开销
智能指针是一些数据结构，他们的功能类似于指针，但拥有额外的元数据和附加功能
引用只是借用数据指针，而智能指针一般拥有数据所有权
String和Vec<T>是智能指针，他们拥有一片内存区域并允许进行操作，他们还拥有元数据（如容量），并提供额外的功能或保障。

智能指针一般使用结构体来实现，需要实现Drop和Deref两个trait。
Deref trait使得此结构体的实例可以拥有与引用一致的行为
Drop trait使得在离开作用域时运行一段自定义代码

常用指针：
Box<T>： 可用于在堆上分配值
Rc<T>: 允许多重所有权的引用计数智能指针
Ref<T>，RefMut<T>：可以通过RefCell<T>访问，是一种可以在运行时而非编译时执行借用规则的类型

内部可变性：不可变对象可以暴露出能够改变内部值的API
规避循环引用导致的内存泄露

### 使用Box<T>在堆上分配内存

使用场景
1. 在需要固定尺寸变量的上下文中使用编译期无法确定大小的类型
2. 需要传递大量数据的所有权，但又不希望对数据进行复制
3. 当希望使用实现了某个trait的类型，而又不关心具体类型时

基本使用方法：
使用Box::new(T)在堆上空间，将T保存于这一空间内，并返回指向堆上这一空间的指针。
在变量前加*(解引用运算符)来获取堆上真正的值，称为解引用



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

一个类型实现了Deref trait时，可以使用解引用运算符
隐式解引用转换：当函数参数为某个类型的引用时，如果传入的参数与此不匹配，则编译器会自动进行解引用转换，直到类型满足要求。

解可变引用：实现DerefMut trait，要实现这一trait，必须首先实现Deref trait
可变性转换有三条：
1. 当T: Deref<Target=U>时，允许&T转换为&U。
2. 当T: DerefMut<Target=U>时，允许&mut T转换为&mut U。
3. 当T: Deref<Target=U>时，允许&mut T转换为&U。
这三条规则 不会破坏借用规则

### 自定义智能指针

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




rustPrime: https://hardocs.com/d/rustprimer/heap-stack/heap-stack.html
Rust Magazine: https://rustmagazine.github.io/rust_magazine_2021/chapter_1/rustc_part1.html
Rust 数据内存布局: https://juejin.cn/post/6987960007245430797
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
