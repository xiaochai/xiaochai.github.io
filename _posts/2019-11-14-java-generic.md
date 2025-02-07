---
layout: post
title: 对Java泛型的理解
date: 2019-11-14
categories:
  - Tech
description: Java自JDK 5引入泛型以来，泛型已经体现在我们代码的各个角落。借助看《Java编程思想》的机会，来全方面理清一下对泛型的理解。
image: "{{ site.baseurl }}/assets/images/java.jpg"
image-sm: "{{ site.baseurl }}/assets/images/java.jpg"
---

Java自JDK 5引入泛型以来，泛型已经体现在我们代码的各个角落。例如我们日常中不断使用的各种容器：

```java
Map<String, Object> map = new HashMap<>(10);
```

但反过来想想，我们真的了解泛型吗？

本文从泛型中的各种用法出发不断探求泛型的原理以及在日常中的应用方式，以此来窥探泛型内部的运行机制。

### 泛型的基本用法

#### 泛型类

泛型类经常作为容器使用，如标准库中的容器类型。以下我们自己定义一个二元组容器：

```java
public class Tuple<E,F> {
    private final E first;
    private final F second;
    public Tuple(E a, F b){
        first = a;
        second = b;
    }
    public E getFirst(){
        return first;
    }
    public F getSecond(){
        return second;
    }
    public static void main(String[] args){
        Tuple<Integer, String> tuple = new Tuple<>(10, "人");
        Integer i = tuple.getFirst();
        String s = tuple.getSecond();
    }
}

```

#### 泛型接口

泛型接口除了作为抽象的泛型类来使用外，还可以用于其它方面。例如生成器：

```java
public interface Generator<T> {
    T next();
}

class Fibonacci implements Generator<Integer> {
    private int count = 0;

    private int fib(int n) {
        if (n < 2) return 1;
        return fib(n - 2) + fib(n - 1);
    }

    @Override
    public Integer next() {
        return fib(count++);
    }

    public static void main(String[] args) {
        Fibonacci gen = new Fibonacci();
        for (int i = 0; i < 18; i++) {
            System.out.print(gen.next() + " ");
        }
    }
}
```

#### 泛型方法

独立应用于非泛型类的泛型方法，常常做为工具函数使用：

```java
public class SetHelper {
    public static <T> Set<T> union(Set<T> a, Set<T> b){
        Set<T> result = new HashSet<>(a);
        result.addAll(b);
        return result;
    }
    public static void main(String[] args){
        HashSet<Integer> a = new HashSet<>();
        a.add(10);
        HashSet<Integer> b = new HashSet<>();
        b.add(11);
        Set<Integer> u = SetHelper.union(a,b);
        System.out.println(u);
    }
}
```

#### 总结

看了以上三种用法，可以看出泛型的重要作用就是将一段代码作用于多种类型上。而这里所指的代码即可是类，也可以是接口或者方法。

有了这些例子，就会对Java的泛型有一个基本的了解了。我们再在深入了解一下Java泛型一个重要的实现方式：类型擦除。

### 类型擦除

提到类型擦除，经常我们可以看到这样的例子：

```java
public class TypeErasure {
    public static void main(String[] args){
        Class c1 = new ArrayList<String>().getClass();
        Class c2 = new ArrayList<Integer>().getClass();
        System.out.println(c1); // java.util.ArrayList
        System.out.println(c2); // java.util.ArrayList
        System.out.println(c1==c2); // true
    }
}
```

对于c1和c2是同一个类型，我们感到意外，而另外一个意外的约束是我们可以声明ArrayList.class，却不能声明ArrayList\<String\>.class，这里的关键点就是Java的泛型使用的是类型擦除机制(Type Erasure)。

所谓类型擦除，就是无法在泛型内部无法获取到任何有关泛型参数类型的信息。

如果我们使用Class.getTypeParameters()这样专门的函数来获取，也只能得到泛型参数的个数，但对于类型，无能为力。

```java
        Class c3 = new HashMap<String, Integer>().getClass();
        System.out.println(Arrays.toString(c1.getTypeParameters())); // [E]
        System.out.println(Arrays.toString(c2.getTypeParameters())); // [E]
        System.out.println(Arrays.toString(c3.getTypeParameters())); // [K, V]
```

#### 看看字节码

为了加深对类型擦除的理解，我们通过javap这个工具，看看Tunple这个类的字节码：(javac Tuple.java; javap -c Tuple;)

```java
 public Tuple(E, F);
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: aload_0
       5: aload_1
       6: putfield      #2                  // Field first:Ljava/lang/Object;
       9: aload_0
      10: aload_2
      11: putfield      #3                  // Field second:Ljava/lang/Object;
      14: return

  public E getFirst();
    Code:
       0: aload_0
       1: getfield      #2                  // Field first:Ljava/lang/Object;
       4: areturn

  public F getSecond();
    Code:
       0: aload_0
       1: getfield      #3                  // Field second:Ljava/lang/Object;
       4: areturn

  public static void main(java.lang.String[]);
    Code:
       0: new           #4                  // class Tuple
       3: dup
       4: bipush        10
       6: invokestatic  #5                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
       9: ldc           #6                  // String 人
      11: invokespecial #7                  // Method "<init>":(Ljava/lang/Object;Ljava/lang/Object;)V
      14: astore_1
      15: aload_1
      16: invokevirtual #8                  // Method getFirst:()Ljava/lang/Object;
      19: checkcast     #9                  // class java/lang/Integer
      22: astore_2
      23: aload_1
      24: invokevirtual #10                 // Method getSecond:()Ljava/lang/Object;
      27: checkcast     #11                 // class java/lang/String
      30: astore_3
      31: return
```

看其中对于字段的描述，成员first和second全部都是Object。get函数也是直接将这个Object直接返回，但是在看main函数的19行和27行，对get到的数据进行了强制类型转换。

**在Java的泛型机制中，对传入到泛型类、泛型对象的值会进行额外的编译期检查，而对传递出去的值进行类型转换。在编译泛型类时将泛型类型擦除到第一边界（如果无边界则为Object，多个边界取第一边界），在运行时无法获取到泛型参数的具体类型。** 

#### 边界

所谓边界即是对泛型参数类型的限制条件。这些限制条件带来两个好处，既可以检查传入对象的类型，更重要的可以按照这些边界来调用边界类型的方法。

extends关键字被重用来做为泛型边界的限制，看看以下这些例子:

```java
class Human extends Age implements Flyable, Runable{
    @Override
    public void fly() {}
    @Override
    public void run() {}
}

interface Flyable{ void fly(); }

interface Runable{ void run(); }

class Age{ int age; }

// 可以限制多个边界，使用 & 符号连接
// 边界为类的只能有一个，并且必须是第一个
// 接口可以是多个
public class Boundary<T extends Age & Flyable & Runable>{
    public T item;
    public Boundary(T item) { this.item = item; }
    public void fly(){ item.fly(); }
    public static void main(){
        // 写进Boundary的对象必须继承自Age，并且实现了Flyable和Runable
        Boundary<Human> h = new Boundary<>(new Human());
    }
}

// 如果继承了某个泛型类，注意至少需要定义同样的边界或者更多的边界限制
// class Boundary2<T extends Age> extends Boundary<T>这样就无法通过编译，因为这个T不满足Boundary的限制
class Boundary2<T extends Age & Flyable & Runable> extends Boundary<T>{
    public Boundary2(T item) {
        super(item);
    }
}
```

#### 边界与擦除

之前我们说过类型擦除会擦除到第一边界。所谓第一边界即第一个限制边界，如之前的Boundary类型的第一边界为Age，所以item的类型为Age。那么问题来了，在fly方法中，一个Age类型的对象如何才能调用fly呢？答案是强制转换：

```java
 public void fly();
    Code:
       0: aload_0
       1: getfield      #2                  // Field item:Llab/generics/boundary/Age;
       4: checkcast     #3                  // class lab/generics/boundary/Flyable
       7: invokeinterface #4,  1            // InterfaceMethod lab/generics/boundary/Flyable.fly:()V
      12: return
```

可以思考一下，如果没有checkcast强制类型转换，是否也可以呢？

#### 为什么使用类型擦除

泛型于Java SE5引入，将之前大量的类，特别是容器类都被改造成了泛型。而于此相对应的，也有大量的使用了这些容器的业务代码，类库；而这些是无法在短时间内统一升级成使用泛型语法的。基于迁移兼容性的考虑，类型擦除这一不完整的泛型方案才得以使用。

这里所说的兼容不仅仅是代码上的兼容，如果只是代码上的兼容，添加一些语法糖即可解决；这里的兼容指的是二进制方面的兼容。

具体的，我们看以下两段代码编译出来的二进制度，其关键的代码几乎一模一样:


```java
public class SimpleHolder {

    private Object obj;
    public Object getObj() {
        return obj;
    }
    public void setObj(Object obj) {
        this.obj = obj;
    }
    public static void main(String[] args){
        SimpleHolder holder = new SimpleHolder();
        holder.setObj("Item");
        String s = (String)holder.getObj();
    }
}

class GenericHolder<T> {
    private T obj;

    public T getObj() {
        return obj;
    }

    public void setObj(T obj) {
        this.obj = obj;
    }

    public static void main(String[] args) {
        GenericHolder<String> holder = new GenericHolder<>();
        holder.setObj("Item");
        String s = holder.getObj();
    }
}
```


![一样的字节码]({{ site.baseurl }}/assets/images/samecode.png)


使用类型擦除另外一个原因是使用真实泛型的"Code specialization"实现会有代码膨胀的缺陷，因为当不同类应用于泛型时，都要产生一份字节码或者机器码，而Java的"Code sharing"方式则可以避免这个问题。

另外一种C#使用的机制则是结合了这两种方式，使用JIT的方式在运行时将其展开成特化代码。

当然擦除机制无论如何也是一种折衷和妥协的方式，必然存在其一定的缺陷。要充分理解其原理，避开弱点，发挥其长处。

### 协变（covariance）、逆变（contravariance）、不变（invariance）

协变、逆变、不变这些表示的是类型转化后的关系。

定义 f(t) 表示某种类型转换，初始类型为t；A ≤ B 表示A是比B更加派生/特定（more derived type/more specific）的类型；一般理解为A继承自B，或者可以将B类型赋值给A。

当 A ≤ B 时：

如果 f(A) ≤ f(B)，则类型转换f是协变的，或称之为具有协变性；

如果 f(B) ≤ f(A)，则类型转换f是逆变的，或称之为具有逆变性；

如果既不是 f(A) ≤ f(B) 也不是 f(B) ≤ f(A)，则类型转换f是不可变的，或称之为具有不变性。

#### 数组的协变性

对于Java的数组，可以将Integer\[\]赋值给Number\[\]，这说明了Java的数组具有协变性质。

但这引起了一些问题，如下代码：

```java
Number n[] = new Integer[2];
n[0] = 10;
n[1] = 11.2; // 编译期没有问题，但在运行时会出错，ArrayStoreException异常
```

#### 重写返回值的协变性

Java中另外一个具有协变性质的是重写(override)函数的返回值。从Java5开始，重写函数支持协变返回值，即可以返回超类方法指定类型的子类型：

```java
class Base1{
    public Number f(){ return 3;}
}
class Derive1 extends Base1{
    @Override
    public Integer f(){return 4;}
}
```

#### 泛型的不变性与通配符

对于Java的泛型，其本身是不变性的，所以以下语句不能编译通过```List<Number> l = new List<Integer>(); ```。

为了解决此问题，引入了通配置符(?)和上界通配符(? extends)以及下界通配符(? super)。

看以下的例子：

```java
class Food{}
class Meat extends Food{}
class Fruit extends Food{}
class Apple extends Fruit {}
class Banana extends Fruit {}
public class TypeTransform {
    public static void main(String[] args){
        ArrayList<? extends Fruit> fruits = new ArrayList<Apple>();
        // 以下代码都无法通过编译，使用了上界通配符之后，就无法对其赋值，但可以正常取出
        //fruits.add(new Fruit());
        //fruits.add(new Apple());
        //fruits.add(new Food());
        Fruit f = fruits.get(0);

        ArrayList<? super Fruit> fruits2 = new ArrayList<Food>();
        fruits2.add(new Fruit());
        fruits2.add(new Apple());
        // 任何Fruit的超类List都可以赋值到fruits2，所以fruits2里的元素只能是Fruit或者其子类才能满足这个要求
        // 以下句子无法通过编译，因为如果fruits2的值是ArrayList<Fruit>，此时的Food无法转型成Fruit
        // fruits2.add(new Food());
        // 以下代码无法通过编译，使用了下界通配符之后，无法确定获取的返回值，因为fruits的元素可能是任何Fruit的超类对象
        // Fruit f2 = fruits2.get(0);
        // 毕竟，可以把任何对象赋值给Object
        Object f3 = fruits2.get(0);
    }
}
```

如何理解以上这个例子呢？我们一个一个看。

首先我们来看一下fruits这个变量，他是一个```ArrayList<? extends Fruit>```，这使得fruits能够接收任何Fruit子类的ArrayList，例如```ArrayList<Apple>```, ```ArrayList<Banana>```等等。 

既然这样，编译器无法确定是这之中的哪一种，自然也无法将Apple或者Banana这些类型添加到ArrayList。

表现出现就是任何对象都无法被add进去。但取出来的结果可以确定其至少是一个Fruit。

与此相反，fruits2使用```ArrayList<? super Fruit>```实现了泛型的逆变，即它可以接收Fruit本身以及其超类的ArrayList，例如ArrayList<Fruit>, Array<Food>。

编译器无法确认是这些中的哪一个，所以在取出时无法确认会是哪一个基类的容器，只能确认是一个Object，因为Object是所有类的基类。但是任何Fruit的子类都可以向上转型成Fruit的基类，所以对其进行赋值是安全的。


#### 无界通配符

无界通配符\<\*\>意味着任一类型。例如ArrayList<\*>表示存储任何类型的ArrayList容器，看起来与原生类型ArrayList类似，也与```ArrayList<Object>```类似，我们来看看他们之间的区别：

```java
        ArrayList<?> list = new ArrayList<Fruit>();
        // 因为无法确认list的边界，所以以下4个语句无法编译通过
        // list.add(new Food());
        // list.add(new Fruit());
        // list.add(new Apple());
        // Food f1 = list.get(0);
        Object o1 = list.get(0);


        ArrayList list2 = new ArrayList<Fruit>();
        list2.add(new Food());
        list2.add(new Fruit());
        list2.add(new Meat());
        Object o2 = list2.get(0);

        // 泛型的不变性，以下语句无法编译通过
        // ArrayList<Object> list3 = new ArrayList<Fruit>();
```

对于list，编译器无法知道这个ArrayList真实是用来存储哪一种类型的，所以任何类型都不能安全的加入到这个容器中，表现为所有的add都编译不通过。获取时也一样，只能确认它是一个Object。

list2原生类型的写法，其实就回归到泛型之前的写法了，会得到一个unchecked的warning，可以使用```@SuppressWarnings("unchecked")```抑制警告。任何类型都可以赋值给它，虽然他实际是一个Fruit，但在被赋值给list2时，这个Fruit信息也已经丢失了。

由于泛型的不变性，list3不会赋值成功。

#### 何时使用extends和super

从上面的说明可以看出使用extends的泛型容器，无法向里添加元素；而使用super的泛型容器可以向里添加元素，但无法取出确切的类型。

以容器的角度看，从容器里取东西，这时候容器是生产者；往容器里添加东西，这时候容器是消费者，这就导出了PECS原则（Producer extends Consumer super）。

即：

如果只需要从集合中获得类型T , 使用<? extends T>通配符

如果只需要将类型T放到集合中, 使用<? super T>通配符

如果既要获取又要放置元素，则不使用任何通配符。例如```List<Apple>```。


看两个典型的例子：

```java
public class Pecs {
    // Comparable需要用super的理由是如果实现Comparable的不一定是本类，也有可能是基类，这个? super T涵盖了这种情况
    // 如果直接使用Comparable<T>，并且Collection没有使用extends的话，则max(apples)将会编译失败
    // 参数Collections添加? extends T，是为了在函数中不修改这个集合
    public static <T extends Comparable<? super T>> T max(Collection<? extends T> c) {
        if (c.isEmpty()) {
            return null;
        }
        Iterator<? extends T> iterator = c.iterator();
        T max = iterator.next();
        while (iterator.hasNext()) {
            T t = iterator.next();
            if (t.compareTo(max) > 0) {
                max = t;
            }
        }
        return max;
    }

    // src只读，dest只写
    public static <T> void copy(ArrayList<? extends T> src, ArrayList<? super T> dest) {
        for (int i = 0; i < src.size(); i++) {
            dest.set(i, src.get(i));
        }
    }

    public static void main() {
        List<Fruit> fruits = new ArrayList<Fruit>();
        List<Apple> apples = new ArrayList<Apple>();
        max(fruits);
        max(apples);
    }


    class Fruit implements Comparable<Fruit> {
        @Override
        public int compareTo(Fruit o) {
            return 0;
        }
    }

    class Apple extends Fruit {
    }
}
```

#### 捕获转换（capture conversion）

捕获转换是将通配符参数化类型转化成具体参数化类型的过程。

我们知道以下代码无法通过编译：

```java
    public static void testGetSet(ArrayList<?> list){
        list.add(list.get(0)); // list.add的方法都会失败
    }
```

但我们加一个helper就可以成功：

```java
    public static void testGetSet(ArrayList<?> list){
        getSetHelper(list);
    }

    public static <T>  void getSetHelper(ArrayList<T> list){
        list.add(list.get(0));
    }
```

对于这其中的原理，我们可以简单这样理解，testGetSet接收的ArrayList可以是装任意类型的ArrayList容器，但可以肯定的是必须是一种类型。

而调用getSetHelper就是由于这种确定性，使得list可以传到getSetHelper当中，而对于确定的类型，list.add的操作自然是合法的。

这个解释只处于理解层面，更深层的原理可以参见[Going wild with generics, Part 1](https://www.ibm.com/developerworks/java/library/j-jtp04298/index.html)，以及[官方文档](https://docs.oracle.com/javase/tutorial/java/generics/capture.html)。


### 自限定类型

假设某一个描述生物属性的类Creature，有一个物种属性species；另外一个描述猫的类Cat，有一个属性为毛色coatColor，定义如下：

```java
public class Creature {
    private String species;
    public void setSpecies(String species){
        this.species = species;
    }
    public String getSpecies(){
        return species;
    }
    public static void main(String[] args){
        Cat cat = new Cat();
        cat.setSpecies("cat");
        cat.setCoatColor("red");
        System.out.println(String.format("%s,%s", cat.getSpecies(), cat.getCoatColor()));
    }
}

class Cat extends Creature{
    private String coatColor;
    public void setCoatColor(String coatColor){
        this.coatColor = coatColor;
    }
    public String getCoatColor(){
        return coatColor;
    }
}
```

如果我们要使用时下流行的链式赋值的话，一般我们会在setSpecies和setCoatColor返回this:

```java
public class CreatureL {
    private String species;
    public CreatureL setSpecies(String species){
        this.species = species;
        return this;
    }
    public String getSpecies(){
        return species;
    }
    public static void main(String[] args){
        // 以下代码无法通过编译
        // CatL cat = new CatL().setSpecies("cat").setCoatColor("red");
        // 并没有达到链式调用的目的
        CatL cat = new CatL();
        cat.setSpecies("cat");
        cat.setCoatColor("red");
        System.out.println(String.format("%s,%s", cat.getSpecies(), cat.getCoatColor()));
    }
}

class CatL extends CreatureL{
    private String coatColor;
    public CatL setCoatColor(String coatColor){
        this.coatColor = coatColor;
        return this;
    }
    public String getCoatColor(){
        return coatColor;
    }
}
```

查看无法通过编译的那一行，原因是setSpeices返回CreateL，这个类并没有setCoatColor方法。所以能够实现链式调用的前提是基类的set方法能够返回子类类型。如何才能实现呢？看一下以下这个代码：

```java
public class CreatureSelfBounded<T extends CreatureSelfBounded<T>> {
    private String species;

    public T setSpecies(String species) {
        this.species = species;
        return (T) this;
    }

    public String getSpecies() {
        return species;
    }

    public static void main(String[] args) {
        CatSelfBounded cat = new CatSelfBounded().setSpecies("cat").setCoatColor("red");
        System.out.println(String.format("%s,%s", cat.getSpecies(), cat.getCoatColor()));
    }
}

class CatSelfBounded extends CreatureSelfBounded<CatSelfBounded> {
    private String coatColor;

    public CatSelfBounded setCoatColor(String coatColor) {
        this.coatColor = coatColor;
        return this;
    }

    public String getCoatColor() {
        return coatColor;
    }
}
```

这一程序实现了链式调用的目的而且运行得还算可以，我们来理解一下：

首先CreatureSelfBounded为自限定类型，即将定义的泛型类做为自己的边界来使用，有时候也称之为泛型循环。

也就是说这个CreatureSelfBounded类的泛型类型参数必须是自己本身或者是继承自己的子类。关键地，setPecies返回将this强转成了类型T，这个T可能是其子类，也就是说这个基类有了返回自己子类的能力。

接着CatSelfBounded继承了CreatureSelfBounded<CatSelfBounded>，此时对于setSpecies来说，T指代CatSelfBounded，返回的类型也自然成了CatSelfBounded。

这里用到自限定类型的一个重要的用法，在基类中使用导出类做为返回值。与此类似，还可以使用导出类做为参数：

```java
interface SelfBoundSetter<T extends SelfBoundSetter<T>> {
    void set(T arg);
}
```

自限定并非完全强制的，在上一个例子中，我们希望子类定义都为```Class Sub extends CreatureSelfBounded<Sub>```这种类型的，但以下这个子类也能通过编译：

```java
// 以下这个语句无法通过编译
// SmallCatSelfBounded scat = new SmallCatSelfBounded().setSpecies("smallcat").setSize();

class SmallCatSelfBounded extends CreatureSelfBounded<CatSelfBounded>{
    private Integer size;
    public SmallCatSelfBounded setSize(Integer size){
        this.size = size;
        return this;
    }
    public Integer getSize(){
        return size;
    }
}
```

回到setSpecies的代码中，通过字节码会发现这个强制类型转换的(T) this，并没有真正产生指令。真正产生作用的是在main函数中调用setSpecies返回的CreatureSelfBounded类型进行了强制转换成CatSelfBounded。但这个强制转换不能省，不然编译器无法检查通过：

```java
  public CreatureSelfBounded();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  public T setSpecies(java.lang.String);
    Code:
       0: aload_0
       1: aload_1
       2: putfield      #2                  // Field species:Ljava/lang/String;
       5: aload_0
       6: areturn

  public java.lang.String getSpecies();
    Code:
       0: aload_0
       1: getfield      #2                  // Field species:Ljava/lang/String;
       4: areturn

  public static void main(java.lang.String[]);
    Code:
       0: new           #3                  // class CatSelfBounded
       3: dup
       4: invokespecial #4                  // Method CatSelfBounded."<init>":()V
       7: ldc           #5                  // String cat
       9: invokevirtual #6                  // Method CatSelfBounded.setSpecies:(Ljava/lang/String;)LCreatureSelfBounded;
      12: checkcast     #3                  // class CatSelfBounded
      15: ldc           #7                  // String red
      17: invokevirtual #8                  // Method CatSelfBounded.setCoatColor:(Ljava/lang/String;)LCatSelfBounded;
      20: astore_1
      21: getstatic     #9                  // Field java/lang/System.out:Ljava/io/PrintStream;
      24: ldc           #10                 // String %s,%s
      26: iconst_2
      27: anewarray     #11                 // class java/lang/Object
      30: dup
      31: iconst_0
      32: aload_1
      33: invokevirtual #12                 // Method CatSelfBounded.getSpecies:()Ljava/lang/String;
      36: aastore
      37: dup
      38: iconst_1
      39: aload_1
      40: invokevirtual #13                 // Method CatSelfBounded.getCoatColor:()Ljava/lang/String;
      43: aastore
      44: invokestatic  #14                 // Method java/lang/String.format:(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
      47: invokevirtual #15                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      50: return
```

#### 自限定与枚举

Java中的枚举类型，其实是一个语法糖，例如如下的枚举定义：

```java
public enum CatPecies {
    Persian,ScotishFold,Ragdoll
}
```

使用javap返回的反编译代码如下：

```java
public final class CatPecies extends java.lang.Enum<CatPecies> {
  public static final CatPecies Persian;

  public static final CatPecies ScotishFold;

  public static final CatPecies Ragdoll;

  public static CatPecies[] values();
    Code:
       0: getstatic     #1                  // Field $VALUES:[LCatPecies;
       3: invokevirtual #2                  // Method "[LCatPecies;".clone:()Ljava/lang/Object;
       6: checkcast     #3                  // class "[LCatPecies;"
       9: areturn

  public static CatPecies valueOf(java.lang.String);
    Code:
       0: ldc           #4                  // class CatPecies
       2: aload_0
       3: invokestatic  #5                  // Method java/lang/Enum.valueOf:(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;
       6: checkcast     #4                  // class CatPecies
       9: areturn

  static {};
    Code:
       0: new           #4                  // class CatPecies
       3: dup
       4: ldc           #7                  // String Persian
       6: iconst_0
       7: invokespecial #8                  // Method "<init>":(Ljava/lang/String;I)V
      10: putstatic     #9                  // Field Persian:LCatPecies;
      13: new           #4                  // class CatPecies
      16: dup
      17: ldc           #10                 // String ScotishFold
      19: iconst_1
      20: invokespecial #8                  // Method "<init>":(Ljava/lang/String;I)V
      23: putstatic     #11                 // Field ScotishFold:LCatPecies;
      26: new           #4                  // class CatPecies
      29: dup
      30: ldc           #12                 // String Ragdoll
      32: iconst_2
      33: invokespecial #8                  // Method "<init>":(Ljava/lang/String;I)V
      36: putstatic     #13                 // Field Ragdoll:LCatPecies;
      39: iconst_3
      40: anewarray     #4                  // class CatPecies
      43: dup
      44: iconst_0
      45: getstatic     #9                  // Field Persian:LCatPecies;
      48: aastore
      49: dup
      50: iconst_1
      51: getstatic     #11                 // Field ScotishFold:LCatPecies;
      54: aastore
      55: dup
      56: iconst_2
      57: getstatic     #13                 // Field Ragdoll:LCatPecies;
      60: aastore
      61: putstatic     #1                  // Field $VALUES:[LCatPecies;
      64: return
}
```

大概的意思是通过enum定义的枚举类型，实际是继承了java.lang.Enum类，与普通的类对比除了无法继承等没有太大区别。而定义的枚举成员，都为这个类的对象，也是这个类的静态成员。这些都进行了静态初使化，并将所有的对象都放入了VALUES数组中。

这里我们关心这个类的定义：class CatPecies extends java.lang.Enum<CatPecies>，而Enum本身是一个自限定泛型类，实现了Compareable和Serializable接口：

```java
public abstract class Enum<E extends Enum<E>> implements Comparable<E>, Serializable{
    // 省略了一些其它方法
    public final int compareTo(E o) {
        // 省略了方法体
    }
}
```

这里的自限定的作用是啥呢？

我们留意一下Enum的Comparable实现compareTo方法，其接受的参数是E，即Enum的类型参数，对于使用enum关键字创建的枚举类来说，这个类型参数的值为正在定义的枚举类，这是编译器强制要求的。

这就产生了一个重要的限制，只有两个类型一致的枚举类型才能进行比较。这也就是这个自限定类型的重要作用。


### 被忽略的语法

考虑一下返回参数是泛型的情况。我们创建了一个非常简单的类，可能这个类并没有实际意义，只是出于演示效果，但在某些复杂的场景下会产生类似的问题。

```java
class Dummy {
    private Object object;
    public <T> T get(){
        return (T) object;
    }
    public <T> void set(T t){
        object = t;
    }
}
```

如果我们要运行如下代码：

```java
Dummy dummy = new Dummy();
dummy.set("hello world");
// 留意以下这个语句
String[] s = dummy.get().split(" ");

System.out.println(Arrays.toString(s));
```

发现编译无法通过，因为dummy.get()没有任何可以用来推断返回值类型的线索，它不像String h = dummy.get()这样用赋值暗示返回的是String。

此时编译器怎么处理呢？它按类型擦除的原则，将dummy.get()返回的值解析成泛型的边界（这里是Object），自然无法在Object上调用split方法，导致编译失败。

有什么办法解决这个问题吗？除了使用中间变量赋值的办法？也是无意中看到以下这个语法可以解决这个问题：

```java
String[] s = dummy.<String>get().split(" ");
```

查了[Java官方的Specification](https://docs.oracle.com/javase/specs/jls/se7/html/jls-15.html#jls-15.12)，发现对于方法调用，本来就支持在调用的方法前面添加非通配符的类型参数。

> MethodInvocation:<br/>
> &nbsp;&nbsp;  MethodName ( ArgumentListopt )<br/>
> &nbsp;&nbsp;  Primary . NonWildTypeArguments<sub>opt</sub> Identifier ( ArgumentList<sub>opt</sub> )<br/>
> &nbsp;&nbsp;  super . NonWildTypeArguments<sub>opt</sub> Identifier ( ArgumentList<sub>opt</sub>)<br/>
> &nbsp;&nbsp;  ClassName . super . NonWildTypeArguments<sub>opt</sub> Identifier ( ArgumentListopt )<br/>
> &nbsp;&nbsp;  TypeName . NonWildTypeArguments Identifier ( ArgumentList<sub>opt</sub>)<br/>

这里的NonWildTypeArgumentsopt指的就是返回值的类型暗示。对于这种语法，也可以在返回值为非泛型的函数上使用，但不会有任何效果。

另外需要说明的是这只是欺骗编译器的手段，并不会生成任何的额外的字节码。




### 参考

[通过javap命令分析java汇编指令](https://www.jianshu.com/p/6a8997560b05)

[为什么Java的泛型要做类型擦除](https://www.jianshu.com/p/8c6586880b2c)

[Java的类型擦除](https://www.hollischuang.com/archives/226)

[Java为什么要用类型擦除实现泛型?](http://www.pulpcode.cn/2017/12/30/why-java-generic-use-type-eraser/)

[Java中的协变与逆变](https://extremegtr.github.io/2016/07/11/Covariance-And-Contravariance-In-Java/)

[Covariance, Invariance and Contravariance explained in plain English?](https://stackoverflow.com/questions/8481301/covariance-invariance-and-contravariance-explained-in-plain-english)

[Difference between <? super T> and <? extends T> in Java](https://stackoverflow.com/questions/4343202/difference-between-super-t-and-extends-t-in-java)

[JavaSE学习笔记 - 泛型进阶](https://extremegtr.github.io/2016/05/30/JavaSE-study-advanced-generics/#u901A_u914D_u7B26_uFF08Wildcard_uFF09)



