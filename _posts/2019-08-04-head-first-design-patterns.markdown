---
layout: post
comments: true
title: "《Head First设计模式》读书笔记"
date: 2019-08-04
categories:
  - Reading
description: 设计原则 ● 找出应用中可能需要变化之处，把它们独立出来，不要和那些不需要变化的代码混在一起 把会变化的部分取出并封装起来，好让其他部分不会受到影响，这样可以导致代码的变化所引起的后果变少，代码更加可控并且不容易出问题。 大多数的模式都着眼于软件变化的主题，允许系统局部改变独立于其他部分。 ...
image: /assets/images/headFirstPattern.jpg
image-sm: /assets/images/headFirstPattern.jpg
---
## 设计原则

#### ● 找出应用中可能需要变化之处，把它们独立出来，不要和那些不需要变化的代码混在一起

把会变化的部分取出并封装起来，好让其他部分不会受到影响，这样可以导致代码的变化所引起的后果变少，代码更加可控并且不容易出问题。

大多数的模式都着眼于软件变化的主题，允许系统局部改变独立于其他部分。

#### ● 针对接口编程，而不是针对实现编程

这里的接口不一定指的interface关键字，而是说针对超类型编程，即利用多态，动态绑定对应的执行方法。

#### ● 多用组合，少用继承

“有一个”（have a）可能比“是一个（is a）”更好。

#### ● 为了交互对象之间的松耦合而努力

松耦合的设计之所以能让我们建立有弹性的OO系统，能够应对变化，是因为对象之间的互相依赖降低到了最低。

#### ● 类应该对扩展开放，对修改关闭

#### ● 依赖倒置原则 

要依赖抽象，不要依赖具体的类

#### ● 最少知识原则，只和你的密友交谈

即减少对象之间的交互，不要将太多的类耦合在一起，导致修改一部分影响大部分。

建议：在对象的方法内，我们应该只调用属于以下类型的方法：此对象本身的、被当成方法的参数而传进来的对象的、此方法所创建或者实例化的任何对象的、对象的任何组件的。

#### ● 好莱坞原则

防止循环依赖，在此原则下，我们允许低层组件将自己挂钩到系统上，但是高层组件会决定什么时候和怎么样使用这些低层组件。所以对于高层组件对待低层组件的方式是别调用我们，我们会调用你。

#### ● 单一责任原则

一个类应该只有一个引起变化的原因。

----

<br/>


## 设计模式


### 策略模式

策略模式定义了算法族，分别封装起来，让它们之间可以互相替换，此模式让算法的变化独立于使用算法的客户。

#### 例子

编写各种各样的鸭子类，定义基本的行为呱呱叫(quack)、游泳（swim）、展示（display）。

#### 使用继承

创建超类Duck，此超类中有swim和quack的具体实现方法，有一个抽象方法display，继承的子类就自动有了swim和quack的方法。

问题：如果在Duck超类中添加一个飞行（fly）方法，那么会导致某些不能飞的鸭子变得能飞，或者需要把那些不能飞的子类都要修改一遍。

#### 使用接口

创建超类Duck，但此类中无fly方法，单独开一个接口Flyable，只有会飞的鸭子才实现这一接口。

问题：导致大量飞行行为一致的鸭子类都要重新实现一套一样的fly方法，代码无法复用。

#### 设计原则

● 找出应用中可能需要变化之处，把它们独立出来，不要和那些不需要变化的代码混在一起

应用此设计原则，将fly的实现提取出来，根据飞行的不同，创建多个飞行类代表每种不同的飞行行为。

● 针对接口编程而不是针对对实现编程

如何实现独立出来的飞行方法呢？定义一个FlyBehavior的接口，具体的飞行类都实现此接口，而在Duck中添加此接口的成员，并实现performFly。

#### 代码实现

``` java
public abstract class Duck {
    public FlyBehavior flyBehavior;

    public void performFly() {
        flyBehavior.fly();
    }

    public abstract void display();
}

public class FakeDuck extends Duck {
    public FakeDuck() {
        flyBehavior = new FlyNoWay();
    }

    @Override
    public void display() {
        System.out.println("fake duck");
    }
}

public class NormalDuck extends Duck {

    public NormalDuck() {
        flyBehavior = new FlyWithWings();
    }

    @Override
    public void display() {
        System.out.println("normal duck");
    }
}

public interface FlyBehavior {
    public void fly();
}

public class FlyNoWay implements FlyBehavior {
    @Override
    public void fly() {
        System.out.println("can't fly");
    }
}

public class FlyWithWings implements FlyBehavior {
    @Override
    public void fly() {
        System.out.println("fly with wings");
    }
}

```

---

### 观察者模式

观察者模式定义了对象之间的一对多依赖，这样一来，当一个对象改变状态时，它的所有依赖者都会收到通知并自动更新。

在具体实现中有两个方面的角色，主题和观察者。主题提供了订阅、取消订阅方法，观察者为实现某一接口的一组对象，将自己订阅到主题中。在主题数据更新时，会回调所有已经订阅过的对象。

#### 例子

气象站有一个WeatherData类，用于获取数据并在数据变更时通知其它使用到气象数据的对象。

#### 一般实现

在数据更新的时候（measurementChanged方法），调用对应需要通知的对象的相应方法。

问题：如果以后添加需要通知的对象，就要修改measurementChanged方法，可维护性降低。

#### 使用观察者模式

``` java
public interface Observer {
    public void update(float temp, float humidity, float pressure);
}

public interface Subject {
    public void registerObserver(Observer o);
    public void removeObserver(Observer o);
    public void notifyObserver();
}

public class Display implements Observer {
    @Override
    public void update(float temp, float humidity, float pressure) {
        System.out.printf("current display data %f,%f,%f\n", temp, humidity, pressure);
    }
}

public class Logger implements Observer {

    @Override
    public void update(float temp, float humidity, float pressure) {
        System.out.printf("current log data %f,%f,%f\n", temp, humidity, pressure);
    }
}


public class WeatherData implements Subject {
    private float temperature, humidity, pressure;
    private ArrayList<Observer> observers;

    public WeatherData(){
        observers = new ArrayList<Observer>();
    }

    public void setHumidity(float humidity) {
        this.humidity = humidity;
        this.notifyObserver();
    }
    public void setTemperature(float temp){
        this.temperature = temp;
        this.notifyObserver();
    }

    public void setPressure(float pressure) {
        this.pressure = pressure;
        this.notifyObserver();
    }

    public double getTemperature() {
        return temperature;
    }

    public double getHumidity() {
        return humidity;
    }

    public double getPressure() {
        return pressure;
    }

    @Override
    public void registerObserver(Observer o){
        observers.add(o);
    }
    @Override
    public void removeObserver(Observer o){
        int i = observers.indexOf(o);
        if(i >= 0){
            observers.remove(i);
        }
    }

    @Override
    public void notifyObserver() {
        for(int i = 0;i<observers.size();i++){
            Observer o = observers.get(i);
            o.update(temperature, humidity, pressure);
        }
    }
}
```

测试用例：

``` java
public class WeatherDataTest {
    @Test public void testObserver() {
        WeatherData wd = new WeatherData();

        Observer l = new Logger();
        Observer d = new Display();
        wd.registerObserver(l);
        wd.registerObserver(d);
        wd.setTemperature(1.0f);
        wd.setHumidity(2.00f);
    }
}
```

#### 不足之处

如果后续此气象数据增加另外一个指标的话，是不是Observer的接口要变，以致于所有的观察者实现都要修改呢？我们来看一下Java内置观察者模式。


#### Java 内置的观察者模式

Java内置的观察者模式接口与我们实现的基本一致，主题接口为java.util.Observable，观察者接口为java.util.Observer。

Observer接口的update方法申明如下：

``` java
    void update(Observable o, Object arg);
```

他将主题对象和其它参数以Object都传给了观察者，这样即使有数据增加，只要主题实现对应的get方法，观察都就能拿到对应的数据，而又不会对旧的观察都产生影响。

另外一个不同点是Observal添加了一个changed的成员变量来控制通知的时机，这块就不再解释了。

Observable的实现为一个类，这在不支持多重继承的java里，会有一些限制。

#### 观察者模式在JDK中的使用

在GUI编程中的众多组件都使用了观察者模式在某个动作触发时调用对应的Listener。

---

### 装饰者模式

装饰者模式动态地将责任附加到对象上，若要扩展功能，装饰者提供了比继承更加有弹性的替代方案。

装饰对象和被装饰者有一个共同的父类或者接口，装饰者用于扩展被装饰者，使其具有某一增强功能。

#### 例子

咖啡店的订单系统，咖啡店卖咖啡，但是咖啡里可以加各种调料，例如豆浆、摩卡、糖、奶泡等等。要根据添加不同的东西收不一样的钱。

#### 使用继承

定义一个咖啡类，然后加各种不同的东西都定义一个对应的对应的类，例如加了糖和奶泡的咖啡就是CoffeeWithSugarAndMilk。

问题：导致定义太多类，类爆炸。

#### 使用成员变量

定义一个咖啡类，将添加的调料设置成成员变量，如果加了对应的调料就将成员变量设置成对应的值。

问题：调料价格的变动会改变现有的代码、一旦有新的调料就要修改cost方法和添加新的成员、以后会开发新的饮料且不适用某些调料但子类还是会继承这些方法、无法添加双倍的调料等等。

#### 使用装饰者模式

```java
public interface ICoffee {
    public double cost();

    public String desc();
}
public class Coffee implements ICoffee {

    @Override
    public double cost() {
        return 4.0;
    }

    @Override
    public String desc() {
        return "coffee";
    }
}

public class Milk implements ICoffee {
    ICoffee coffee;

    public Milk(ICoffee coffee) {
        this.coffee = coffee;
    }

    @Override
    public double cost() {
        return 0.3 + coffee.cost();
    }

    @Override
    public String desc() {
        return coffee.desc() + " with milk";
    }
}

public class Mocha implements ICoffee {
    ICoffee coffee;

    public Mocha(ICoffee coffee) {
        this.coffee = coffee;
    }

    @Override
    public double cost() {
        return 0.4 + coffee.cost();
    }

    @Override
    public String desc() {
        return coffee.desc() + " with mocha";
    }
}

public class Soy implements ICoffee {
    ICoffee coffee;

    public Soy(ICoffee coffee) {
        this.coffee = coffee;
    }

    @Override
    public double cost() {
        return 0.5 + coffee.cost();
    }

    @Override
    public String desc() {
        return coffee.desc() + " with soy";
    }
}
```

关于创建一杯加了双份摩卡、豆浆、奶的咖啡的测试用例：

```java
public class CoffeeTest {
    @Test
    public void testDeco(){
        ICoffee coffee = new Coffee();
        coffee = new Milk(coffee);
        coffee = new Soy(coffee);
        coffee = new Mocha(coffee);
        coffee = new Mocha(coffee);
        System.out.printf("%s costs %f\n", coffee.desc(), coffee.cost());
    }
}
```

#### 装饰者模式应用

Java的I/O库使用了装饰者模式，例如输入类的抽象基类为InputStream，有一些具体组件FileInputStream、StringBufferInputStream可以被LineNumberInputStream、DataInputStream这些类装饰起来。


---

### 工厂模式

工厂模式分类简单工厂、工厂方法模式和抽象工厂模式。

简单工厂：并非严格意义上的设计模式，而更多的是一种编程习惯，将条件判断创建不同对象的代码提取独立出来以供复用。

工厂方法模式：定义了一个创建对象的接口，但由子类决定要实例化的类是哪一个。工厂方法让类把实例化推迟到子类。

抽象工厂模式：提供一个接口，用于创建相关或依赖对象的家族，而不需要明确指定具体类。


#### 例子

有一个Pizza店，提供各种各样的Pizza订单。

#### 简单实现

``` java
 Pizza orderPizza(String type){
        Pizza pizza;
        if(type.equals("cheese")){
            pizza = new CheesePizza();
        }else if(type.equals("veggie")){
            pizza = new VeggiePizza();
        }else{
            pizza = new NormalPizz();
        }
        pizza.prepare();
        pizza.bake();
        pizza.cut();
        pizza.box();
        return pizza;
    }
```

问题：如果需要添加新的类型，需要修改这个类的，而且除了此处用到了这些判断外，其它地方也有可能用到这些判断。

#### 使用简单工厂

将变动部分抽离，独立封装成类:

```java
public class SimplePizzaFactory {
    public Pizza createPizza(String type){
        Pizza pizza;
        if(type.equals("cheese")){
            pizza = new CheesePizza();
        }else if(type.equals("veggie")){
            pizza = new VeggiePizza();
        }else{
            pizza = new NormalPizz();
        }
        return pizza;
    }
}

```

createPizza可以定义成静态的，称之为静态工厂，他使得不需要创建对象即可调用，但是无法通过继承来修改行为。

#### 多个Pizza店

现在多个不同地区新开了Pizza店，两个店里的Pizza种类有差异，但是订单流程是一样的。

所以我们先定义一个Pizza店的基类PizzaStoreBase，并定义两个商店类：

```java
public abstract class PizzaStoreBase {
    public Pizza orderPizza(String type){
        Pizza pizza = createPizza(type);
        pizza.prepare();
        pizza.bake();
        pizza.cut();
        pizza.box();
        return pizza;
    }

    public abstract Pizza createPizza(String type);
}
public class PizzaStore1 extends PizzaStoreBase {
    @Override
    public Pizza createPizza(String type) {
        Pizza pizza;
        if(type.equals("cheese")){
            pizza = new CheesePizza();
        }else{
            pizza = new NormalPizz();
        }
        return pizza;
    }
}
public class PizzaStore2 extends PizzaStoreBase {
    @Override
    public Pizza createPizza(String type) {
        Pizza pizza;
        if(type.equals("veggie")){
            pizza = new VeggiePizza();
        }else{
            pizza = new NormalPizz();
        }
        return pizza;
    }
}

```

可以看出基类定义了订单的流程，而具体的Pizza类型区分，各个店（子类）自己创建自己的工厂方法，这就是工厂方法模式。

#### 另外一种思路

如果将之前的createPizza方法使用某一个抽象工厂类来提供，那么就变成了抽象工厂模式。

```java
public interface PizzaFactory {
    public Pizza createPizza(String type);
}

public abstract class PizzaStoreBase {
    PizzaFactory pizzaFactory;
    public PizzaStoreBase(PizzaFactory pizzaFactory) {
        this.pizzaFactory = pizzaFactory;
    }

    public Pizza orderPizza(String type){
        Pizza pizza = pizzaFactory.createPizza(type);
        pizza.prepare();
        pizza.bake();
        pizza.cut();
        pizza.box();
        return pizza;
    }
}
public class PizzaFactory1 implements PizzaFactory {
    @Override
    public Pizza createPizza(String type) {
        Pizza pizza;
        if (type.equals("cheese")) {
            pizza = new CheesePizza();
        } else {
            pizza = new NormalPizz();
        }
        return pizza;
    }
}
public class PizzaFactory2 implements PizzaFactory {
    @Override
    public Pizza createPizza(String type) {
        Pizza pizza;
        if (type.equals("veggie")) {
            pizza = new VeggiePizza();
        } else {
            pizza = new NormalPizz();
        }
        return pizza;
    }
}
```

工厂方法通过继承的方式创建对象，而抽象工厂则通过组合来创建对象。

---

### 单件模式

确保一个类只有一个实例，并提供全局访问点。

#### 具体代码实现

```java
public class Singleton {
    private static Singleton uniqueInstance;

    private Singleton() {
    }

    public static Singleton getInstance() {
        if (uniqueInstance == null) {
            uniqueInstance = new Singleton();
        }
        return uniqueInstance;
    }
}
```

通过私有化构造函数，并提供静态创建方法即可实现单件模式。

#### 多线程并发问题

在多线程的情况下，可能导致创建多个对象。

解决办法1：在getInstance添加 synchronized关键字，使得这个方法同一时间只能有一个线程调用

问题：每次获取getInstanc都执行同步耗费性能

解决办法2：使用预先创建的办法

```java
public class SingletonPre {
    private static SingletonPre uniqueInstance = new SingletonPre();

    private SingletonPre() {
    }

    public static SingletonPre getInstance() {
        return uniqueInstance;
    }
}
```

#### 使用双重检查

```java
public class SingletonDoubleCheck {
    private static volatile SingletonDoubleCheck uniqueInstance;

    private SingletonDoubleCheck() {
    }

    public static synchronized SingletonDoubleCheck getInstance() {
        if(uniqueInstance == null){
            synchronized (Singleton.class){
                if(uniqueInstance == null){
                    uniqueInstance = new SingletonDoubleCheck();
                }
            }
        }
        return uniqueInstance;
    }
}
```

---

### 命令模式

将请求封装成对象，这可以让你使用不同的请求、队列，或者日志来参数化其它对象。命令模式也可以支持撤销操作。

#### 例子

有一个遥控器，有3个按钮，每一个按钮可能控制一些设备如灯、音箱等。后续这些按钮的功能可能变化，可控制的设备可能增加。

#### 实现

命令模式需要将众多不同的操作封装成一个统一的命令接口实现，这样使用方并不关心命令的实现细节。

抽象了一个命令接口：

```java
public interface Command {
    public void execute();
}
```

这样遥控器类的按钮上就只要装上Command的实现类即可：

```java
public class RemoteController {
    Command[] commands;

    public RemoteController() {
        commands = new Command[3];
        Command noCommand = new NoCommand();
        for (int i = 0; i < 3; i++) {
            commands[i] = noCommand;
        }
    }

    public void setCommands(int slot, Command command) {
        commands[slot] = command;
    }

    public void buttonPush(int slot) {
        commands[slot].execute();
    }
}
```

对于Command的子类，可以是各种各样的实现了Command的接口：

```java
public class LightOnCommand implements Command{
    private Light light;

    public LightOnCommand(Light light) {
        this.light = light;
    }

    @Override
    public void execute() {
        light.on();
    }
}
public class NoCommand implements Command{
    @Override
    public void execute() {
    }
}
public class CDCommand implements Command{
    private CD cd;

    public CDCommand(CD cd) {
        this.cd = cd;
    }

    @Override
    public void execute() {
        cd.setCD();
        cd.setVolume(11);
        cd.play();
    }
}
public class PartyCommand implements Command {
    private CD cd;
    private Light light;
    public PartyCommand(CD cd, Light light) {
    }
    @Override
    public void execute() {
        cd.setCD();
        cd.setVolume(20);
        cd.play();
        light.on();
    }

}
```

#### 命令模式的应用

队列：往队列中添加命令，而消费队列的进程将命令取出调用其execute方法，而不需要关心此命令的细节，达到队列与处理对象之间的解耦。

日志请求：事务数据库都会先将请求操作写入到日志，如果发生异常，则从日志里将数据恢复，而日志里各种各样的操作请求都是一个个的Command对象，只要加载并执行其execute方法即可。

---

### 适配器模式与外观模式

适配器模式：将一个类的接口，转换成客户期望的另一个接口。适配器让原本不兼容的类可以合作无间。

外观模式：提供 了一个统一的接口，用于访问子系统中的一群接口。外观定义了一个高层接口，让子系统更容易使用。

#### 适配器模式例子

适配器就是将原来不匹配的双方，通过适配器类，将双方重新连接起来。

之前命令模式可以理解成一个适配器：对于遥控器来说，支持Command的对象，而对于Light来说只提供了on和off方法，所以需要一个Light的命令适配器，将on或者off方法封装成execute方法。

此称之为对象适配器，因为在适配器中接收的是被适配者的对象，而另外一种适配器是类适配器，但需要多重继承才可实现。

#### 外观模式例子

外观模式是为了简化调用而改变接口的模式。

例如对于一个智能家庭来说，回家后需要做一些操作：开灯、开热水器、开空调等等，这都是遥控器上提供的一个个按钮，我们要从头到尾按一遍。

我们需要一个一键模式：添加一个Facade类，这个类接收家里所有的智能家居对象（如灯、热水器等），此类有一个一键准备方法，可以将这些设备对象都打开。这就是外观模式的应用。

#### 与装饰模式的不同点

装饰模式的出发点是增强功能，他不改变被装饰者的接口，因为他们同有一个超类。

而适配器模式是为了适配目标对象而改变了接口，这是将一个接口转换成了另外一个接口。

外观模式的出发点是为了让接口更加简单，他将一个或者多个对象封装起来，隐藏了复杂的操作细节。

---

### 模板方法模式

在一个方法中定义了算法的骨架，而将一些步骤延迟到子类中。模板方法使得子类可以在不改变算法结构的情况下，重新定义算法中的某些步骤。

#### 例子

泡咖啡与泡茶的步骤基本一致，都要经过煮水、冲泡、倒进杯子、添加调料这四个步骤，所以将这些步骤定义在超类中，而另外一部分细节在子类中定义：

```java
public abstract class CaffeineBeverage {
    public void prepareRecipe(){

    }
    public abstract void brew();
    public abstract void addCondiments();
    public void boilWater(){/* boil water*/}
    public void pourInCup(){/* pour in cup*/}
}
public class Coffee extends CaffeineBeverage {
    @Override
    public void brew() {
        // 添加咖啡粉
    }

    @Override
    public void addCondiments() {
        // 添加糖
    }
}
public class Tea extends CaffeineBeverage {
    @Override
    public void brew() {
        // 添加茶叶
    }

    @Override
    public void addCondiments() {
        // 添加柠檬
    }
}
```

以上超类定义了基本的步骤框架（算法框架），而具体某些步骤的实现放在子类中来实现。有时为了提高可拓展性，会加入一些钩子，用于在某一些步骤之后加入子类定义的步骤。

#### 应用

基础库的排序类定义了基本的排序算法，但具体对象的比较留有使用者来定义，虽然Arrays.sort不是使用继承，但定义算法框架，并且部分实现交有使用者的思想其实就是模板方法模式的应用。

Swing中的组件类，都有一个paint，他是一个钩子，默认啥也不干，但子类可以通过覆盖此方法来自定义组件的样式。

---

### 迭代器与组合模式

#### 迭代器模式

提供一种方法顺序访问一个聚合对象中的各个元素，而又不暴露其内部的细节。

#### 例子

A、B两家餐厅合二为一，但他们原本的菜单类完全不一样，现在要整合这两菜单。

##### 现状

这是原始的餐厅菜单对象，他们共用了一个MenuItem菜单项目，可以看出两个餐厅用了不一样的方式来存储菜单项（数组和ArrayList）。

``` java
public class MenuItem {
    public String name, desc;
    public double price;

    public MenuItem(String name, String desc, double price) {
        this.name = name;
        this.desc = desc;
        this.price = price;
    }
}
public class MenuOfA {
    ArrayList<MenuItem> menuItems;

    public MenuOfA() {
        menuItems = new ArrayList<>();
        addItem("拉面", "兰州拉面", 9.9);
        addItem("冷面", "延吉冷面", 19.9);
    }

    public void addItem(String name, String desc, double price) {
        MenuItem i = new MenuItem(name, desc, price);
        menuItems.add(i);
    }

    public ArrayList<MenuItem> getMenuItems(){
        return menuItems;
    }
}
public class MenuOfB {
    private static final int MAX_ITEMS = 6;
    private MenuItem[] menuItems;
    private int numOfItem;

    public MenuOfB() {
        menuItems = new MenuItem[MAX_ITEMS];
        addItem("尖椒腊肉盖饭", "尖椒腊肉盖饭", 11.9);
        addItem("红烧肉盖饭", "红烧肉盖饭", 21.9);
    }

    public void addItem(String name, String desc, double price) {
        MenuItem i = new MenuItem(name, desc, price);
        if(numOfItem >= MAX_ITEMS){
            return; //
        }
        menuItems[numOfItem++] = i;
    }

    public MenuItem[] getMenuItems(){
        return menuItems;
    }

    public int getNumOfItem() {
        return numOfItem;
    }
}
```

##### 使用简单的整合

简单整合两个菜单的话，遍历的代码变成如下，如果多个地方都写这一长串的代码，会很不友好。更重要的是，如果又合并一家餐厅，那么我们就要对所有遍历的地方做改动，那是个灾难。

```java
        MenuOfA a = new MenuOfA();
        MenuOfB b = new MenuOfB();
        for (MenuItem i : a.getMenuItems()){
            System.out.printf("A:%s, %s, %f\n", i.name,i.desc,i.price);
        }

        for (int j= 0; j < b.getNumOfItem(); j++){
            MenuItem i = b.getMenuItems()[j];
            System.out.printf("B:%s, %s, %f\n", i.name,i.desc,i.price);
        }
```

##### 使用迭代器整合

为了结合后的餐厅能够方便地提供完整菜单，我们对这两个菜单创建迭代器，使其使用同一种方式被迭代。

我们实现了一个数组的迭代器，用于迭代MenuOfB，而MenuOfA直接使用ArrayList提供的Iterator。

```java
public interface Menu {
    public Iterator<MenuItem> createIterator();
}
public class ArrayMenuIterator implements Iterator<MenuItem> {
    private MenuItem[] menuItems;
    int pos = 0;

    public ArrayMenuIterator(MenuItem[] menuItems) {
        this.menuItems = menuItems;
    }

    @Override
    public boolean hasNext() {
        return pos < menuItems.length && menuItems[pos] != null;
    }

    @Override
    public MenuItem next() {
        return menuItems[pos++];
    }
}
public class MenuOfA implements Menu{
    // 省略了与原来一样的代码
    @Override
    public Iterator<MenuItem> createIterator() {
        return menuItems.iterator();
    }
}
public class MenuOfB implements Menu {
    // 省略了与原来一样的代码
    @Override
    public Iterator<MenuItem> createIterator() {
        return new ArrayMenuIterator(menuItems);
    }
}
```

这样，就可以使用通用的方式来遍历数组了

```java
public class MenuCombine {
    HashMap<String, Menu> menus;
    public MenuCombine(){
        menus = new HashMap<>();
        menus.put("A",new MenuOfA());
        menus.put("B", new MenuOfB());
    }
    public void printAll(){
        for(String name :menus.keySet()){
            Iterator<MenuItem> i = menus.get(name).createIterator();
            while (i.hasNext()){
                MenuItem menuItem = i.next();
                System.out.printf("%s 餐厅: %s,%s,%f\n", name, menuItem.name, menuItem.desc, menuItem.price);
            }
        }
    }
}
```

迭代器模式提供了一个供外部使用的迭代器，使得使用者不关心对象的内部实现也可以实现对集合的遍历。

#### 组合模式

允许对象组成树型结构来表现整体和部分的层次结构。组合能让客户以一致的方式处理个别对象和对象组合。

##### 例子

餐厅又收购了C餐厅，这个餐厅的麻烦点是他的菜单不仅有主菜单，而且还有子菜单。现在的菜单结构图看起来像是一个树型结构。

所以为了更好的扩展，我们使用组合模式重新实现菜单类。

树的节点分成叶子节点(MenuItem)和非叶子结点(Menu)，所以我们创建两个类，他们都继承自同一个超类(MenuComponent)。

```java
public abstract class MenuComponent {
    public void add(MenuComponent menuComponent) {
        throw new UnsupportedOperationException();
    }

    public void remove(MenuComponent menuComponent) {
        throw new UnsupportedOperationException();
    }

    public MenuComponent getChild(int i) {
        throw new UnsupportedOperationException();
    }

    public String getName() {
        throw new UnsupportedOperationException();
    }

    public String getDesc() {
        throw new UnsupportedOperationException();
    }

    public Double getPrice() {
        throw new UnsupportedOperationException();
    }

    public void print(){
        throw new UnsupportedOperationException();
    }
}
public class Menu extends MenuComponent {
    private String name;
    private ArrayList<MenuComponent> menuComponents = new ArrayList<>();

    public Menu(String name) {
        this.name = name;
    }

    @Override
    public void add(MenuComponent menuComponent) {
        menuComponents.add(menuComponent);
    }

    @Override
    public void remove(MenuComponent menuComponent) {
        menuComponents.remove(menuComponent);
    }

    @Override
    public MenuComponent getChild(int i) {
        return menuComponents.get(i);
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public void print(){
        System.out.printf("===%s餐厅===\n", name);
        for(MenuComponent m: menuComponents){
            m.print();
        }
    }
}

public class MenuItem extends MenuComponent {
    private String name, desc;
    private Double price;

    public MenuItem(String name, String desc, Double price) {
        this.name = name;
        this.desc = desc;
        this.price = price;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getDesc() {
        return desc;
    }

    @Override
    public Double getPrice() {
        return price;
    }

    @Override
    public void print() {
        System.out.printf("%s, %s, %f\n", name, desc, price);
    }
}
```

有了这些类之后，合并之后的餐厅的菜单就像这样：

```java
        Menu all = new Menu("all");
        Menu menuA = new Menu("A");
        Menu menuB = new Menu("B");
        Menu menuC = new Menu("C");
        menuA.add(new DesignPatterns.Restaurent.Combine.MenuItem("拉面", "兰州拉面", 9.9));
        menuB.add(new DesignPatterns.Restaurent.Combine.MenuItem("尖椒腊肉盖饭", "尖椒腊肉盖饭", 11.9));


        Menu menuCDrink = new Menu("C Drink");
        menuCDrink.add(new DesignPatterns.Restaurent.Combine.MenuItem("啤酒", "哈尔滨啤酒", 99.9));
        menuC.add(new DesignPatterns.Restaurent.Combine.MenuItem("羊肉串", "羊肉串", 5.9));
        menuC.add(menuCDrink);

        all.add(menuA);
        all.add(menuB);
        all.add(menuC);
        all.print();
```


使用这种办法的优势就是在处理子节点的时候，与在处理根节点的时候是一样的。

---


### 状态模式

状态模式允许对象在内部状态改变时改变它的行为，对象看起来好像修改了它的类。

#### 例子

我们以数字判断状态机为例，来说明如何实现状态模式。

状态机状态变化如下：

![状态机](/assets/images/state.png)

代码实现：

```java
public class State {
    StateMachine stateMachine;
    public State(StateMachine stateMachine) {
        this.stateMachine = stateMachine;
    }

    public void meetNumber(){
        throw new UnsupportedOperationException();
    }

    public void meetDot(){
        throw new UnsupportedOperationException();
    }

    public void meetSpace(){
        throw new UnsupportedOperationException();
    }
}

public class StateBegin extends State {
    public StateBegin(StateMachine stateMachine) {
        super(stateMachine);
    }

    @Override
    public void meetNumber() {
        this.stateMachine.currentState = this.stateMachine.stateIntPart;
    }

    @Override
    public void meetDot() {
        this.stateMachine.currentState = stateMachine.stateFloatPart;
    }
}
public class StateIntPart extends State {
    public StateIntPart(StateMachine stateMachine) {
        super(stateMachine);
    }

    @Override
    public void meetNumber() {
    }

    @Override
    public void meetDot() {
        stateMachine.currentState = stateMachine.stateFloatPart;
    }

    @Override
    public void meetSpace() {
        stateMachine.currentState = stateMachine.stateFloatPart;
    }
}

public class StateFloatPart extends State {
    public StateFloatPart(StateMachine stateMachine) {
        super(stateMachine);
    }

    @Override
    public void meetNumber() {
    }

    @Override
    public void meetSpace() {
        stateMachine.currentState = stateMachine.stateBegin;
    }
}
public class StateMachine {
    StateBegin stateBegin;
    StateIntPart stateIntPart;
    StateFloatPart stateFloatPart;
    State currentState;

    public StateMachine() {
        this.stateBegin = new StateBegin(this);
        this.stateFloatPart = new StateFloatPart(this);
        this.stateIntPart = new StateIntPart(this);
        this.currentState = this.stateBegin;
    }
    public void meetNumber(){
        currentState.meetNumber();
    }
    public void meetDot(){
        currentState.meetDot();
    }
    public void meetSpace(){
        currentState.meetSpace();
    }
}
```

声明了一个状态机类以及继承自状态基类的4个状态类，对应图中的4个状态，然后状态机收到的行为会转到当前状态里，由当前状态对象来执行对应方法。

测试类如下：

```java
public class StateTest {
    @Test
    public void number() {
        String[] ss = {
                "0.1111 2.3.23.2.32.3.23",
                "333.222 322.321",
                "324. 234. 0.",
                ".234 .3232 .3242",
                "242 23a 342"
        };

        for (String s : ss) {
            StateMachine stateMachine = new StateMachine();
            String[] arr = s.split("");
            try {
                for (String ch : arr) {
                    if (ch.equals(".")) {
                        stateMachine.meetDot();
                    } else if (ch.equals(" ")) {
                        stateMachine.meetSpace();
                    } else if (Integer.parseInt(ch) >= 0) {
                        stateMachine.meetNumber();
                    }
                }
                System.out.printf("ok %s \n", s);
            } catch (NumberFormatException e) {
                System.out.printf("not dot or number %s \n", s);
            } catch (UnsupportedOperationException e) {
                System.out.printf("format error %s \n", s);
            }
        }
    }
}
```


---

### 代理模式

为另一个对象提供一个替身或占位符以控制对这个对象的访问

#### 例子

以java中的静态代理为例子介绍代理模式，再由此引出其它的代理模式实现。

```java
public class Fly {
    public void dofly(){
        System.out.println("do fly");
    }
}
public class FlyProxy extends Fly {
    Fly fly;

    public FlyProxy(Fly fly) {
        this.fly = fly;
    }

    @Override
    public void dofly(){
        System.out.println("do prepare");
        fly.dofly();
        System.out.println("finish");
    }
}
public class ProxyTest {
    @Test
    public void test(){
        Fly fly = new FlyProxy(new Fly());
        fly.dofly();
    }
}
```

我们通过代理类来调用实际的类时，可以在方法调用的前后添加各种操作。

#### 其它类型的代理

##### 远程代理

在实际中常常需要进行网络通信，如果能够像调用本地类一样调用远程方法，那将十分方便，而远程代理即提供了这种能力。

他在本地建立一个stub对象，这个stub对象与远程要访问的对象有着一样的调用接口，所以可以通过这个stub对象来代理远程对象的访问。


##### 虚拟代理

虚拟代理一般代理创建开销大的对象。在大对象准备好之前，都将请求打到这个代理对象。

例如在加载组件的时候，组件的icon是通过网络下载的，所以在真正显示icon之前，是有一个代理类来显示这个icon的。

##### 动态代理

java中的动态代理，是在运行时创建代理类，提供了很大的灵活性。


```java
public interface IBird {
    public void fly();
}

public class Bird implements IBird{

    @Override
    public void fly(){
        System.out.println("fly");
    }
}

public class ProxyFactory {
    private Object target;

    public ProxyFactory(Object o) {
        this.target = o;
    }
    public Object getProxyInstance(){
        return Proxy.newProxyInstance(target.getClass().getClassLoader(),
                target.getClass().getInterfaces(),
                (Object proxy, Method method, Object[] args)->{
                    System.out.println("before");
                    method.invoke(target, args);
                    System.out.println("after");
                    return null;
                }
        );
    }
}
public class ProxyTest {
    @Test
    public void DyProxy(){
        IBird b = new Bird();
        ProxyFactory proxyFactory = new ProxyFactory(b);
        b = (IBird)proxyFactory.getProxyInstance();
        b.fly();
    }
}
```


#### 其它代理

防火墙代理：控制网络的资源访问，保护主题免于坏客户的侵害。

智能引用代理：当主题被引用时，进行额外的动作，例如计算一个对象被引用 的次数。

缓存代理：为开销大的运算结果提供暂时存储：它也允许多个客户端共享结果，以减少计算或网络延迟。

同步代理：在多线程的情况下为了主题提供安全的访问。

复杂隐藏代理：用于隐藏一个类的复杂集合的复杂度，并进行访问控制。有时候也称之为外观代理。

写时复制代理：用于控制对象的复制，方法是延迟对象的复制，直到真正需要。

---

### 复合模式

以MVC举例来说明，MVC中使用了观察者模式，组合，策略等模式，而且MVC也是经典的编程思想。请看下面的例子。

这个例子是一个节拍控制器，通过滑动条可以控制节拍的频率。


```java
public interface BeatObserver {
    public void onBeat();
}
public interface BPMObserver {
    public void onChange(int bpm);
}
public class DJModel {
    private Integer bpm = 60;

    private List<BPMObserver> bpmObservers;
    private List<BeatObserver> beatObservers;

    public DJModel() {
        bpmObservers = new ArrayList<>();
        beatObservers = new ArrayList<>();
        this.beat();
    }

    public void setBPM(int bpm) {
        synchronized (this.bpm) {
            this.bpm = bpm;
        }

        for (BPMObserver bpmObserver : bpmObservers) {
            bpmObserver.onChange(bpm);
        }
    }

    public void beatNotify() {
        for (BeatObserver beatObserver : beatObservers) {
            beatObserver.onBeat();
        }
    }

    protected void beat() {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.execute(() -> {
            int bpm;
            do {
                synchronized (this.bpm) {
                    bpm = this.bpm;
                }
                this.beatNotify();
                try {
                    java.lang.Thread.sleep(60000 / bpm);
                } catch (InterruptedException e) {
                    System.out.println(e);
                }
            } while (true);
        });
    }

    public void registerBPMObserver(BPMObserver bpmObserver) {
        if (!bpmObservers.contains(bpmObserver)) {
            bpmObservers.add(bpmObserver);
        }
    }

    public void registerBeatObserver(BeatObserver beatObserver) {
        if (!beatObservers.contains(beatObserver)) {
            beatObservers.add(beatObserver);
        }
    }

    public void removeBPMObserver(BPMObserver bpmObserver) {
        bpmObservers.remove(bpmObserver);
    }

    public void removeBeatObserver(BeatObserver beatObserver) {
        beatObservers.remove(beatObserver);
    }
}

public class DJController {
    DJModel djModel;
    DJView djView;

    public DJController(DJModel djModel) {
        this.djModel = djModel;
        djView = new DJView(this, djModel);
    }

    public void setBPM(int bpm){
        djModel.setBPM(bpm);
    }

    public static  void main(String[] args){
        DJModel djModel = new DJModel();
        new DJController(djModel);
    }
}
public class DJView implements ChangeListener, BeatObserver, BPMObserver {
    private DJModel djModel;
    private DJController djController;

    private JFrame jFrame;
    private JPanel jPanel;
    private JSlider jSlider;
    private JLabel jLabel;
    private JProgressBar jProgressBar;

    public DJView(DJController c, DJModel m) {
        djModel = m;
        djController = c;

        jFrame = new JFrame();
        jPanel = new JPanel(new GridLayout(3,1));

        jSlider=new JSlider(30,300);
        jSlider.addChangeListener(this);

        jLabel = new JLabel();
        jLabel.setText("Current BPM: 60");

        jProgressBar=new JProgressBar(0,100);
        jProgressBar.setValue(23);

        jPanel.add(jSlider);
        jPanel.add(jLabel);
        jPanel.add(jProgressBar);
        jFrame.add(jPanel);
        jFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        jFrame.setSize(500,300);
        jFrame.setVisible(true);

        djModel.registerBeatObserver(this);
        djModel.registerBPMObserver(this);
    }

    @Override
    public void stateChanged(ChangeEvent e) {
        if(e.getSource() == jSlider){
            int bpm = jSlider.getValue();
            djController.setBPM(bpm);
        }
    }

    @Override
    public void onChange(int bpm) {
        jLabel.setText("Current BPM: " + bpm);
    }

    @Override
    public void onBeat() {
        for (int i = 0; i < 80; i++) {
            jProgressBar.setValue(i);
            try {
                java.lang.Thread.sleep(1);
            } catch (InterruptedException e) {
                System.out.println(e);
            }
        }
        for (int i = 80; i > 0; i--) {
            jProgressBar.setValue(i);
            try {
                java.lang.Thread.sleep(2);
            } catch (InterruptedException e) {
                System.out.println(e);
            }
        }
    }
}
```


---

### 桥接模式

桥接模式将抽象部分与它实现的部分分离，使它们都可以独立地变化。

桥接模式是使用组合的方式，将某些部分解耦，使得可独立修改，而不影响双方。

#### 例子

对于操作系统和软件，例如有OS1和OS2两个操作系统，又有Software1和Software2两个软件运行在这两个操作系统。

一般的实现可能是有两个操作系统父类，然后两个软件继承它们，或者两个软件基类，之下分别再有两个操作系统。无论哪种方式，都一共会产生4个类。

而桥接的模式就是将这两部分分离开，使用Has-a的关系，将软件组合到操作系统中，这样即使再新加或者修改软件或者操作系统，只要修改对应的部分即可，不影响另一部分。

```java
public abstract class OS {
    Software software;

    public OS(Software software) {
        this.software = software;
    }

    public abstract void run();
}

public class OSA extends OS {
    public OSA(Software software) {
        super(software);
    }

    @Override
    public void run() {
        System.out.println("osa");
        software.run();
    }
}

public class OSB extends OS {
    public OSB(Software software) {
        super(software);
    }

    @Override
    public void run() {
        System.out.println("osb");
        software.run();
    }
}

public interface Software {
    public void run();
}

public class Software1 implements Software {
    @Override
    public void run() {
        System.out.println("software 1");
    }
}

public class Software2 implements Software {

    @Override
    public void run() {
        System.out.println("software 2");
    }
}
```

测试

```java
public class BradgeTest {
    @Test
    public void test(){
        Software software1 = new Software1();
        Software software2 = new Software2();
        OS osa = new OSA(software1);
        OS osb = new OSB(software1);
        osa.run();
        osb.run();
    }
}
```


---

### 生成器模式（Builder Pattern)

或称建造者模式，它封装了一个产品的构造过程，并允许按步骤构造。

#### 与其它模式的区别

会有一个建造者(builder)或者指挥者(director)提供了一个建造的方法build()用来产生最终要生成的对象。

与工厂模式的不同是建造对象的步骤是多步的，包含有多个组成部分。

与模板方法不同之处在于，模板方法定义的不一定是创建对象，而更多的是一个方法流程，这个方法流程的某个步骤是由子类来实现。


#### 例子与应用

在Java中提供的xxxBuilder都是使用建造者模式来处理的。他规定了整个创建流程（即builder中的build方法），而流程中所需要的东西可以由其它的方法来提供，通过继承，子类可以重写这些方法。

```java
public class Company {
    private String name, address, postcode, tel, vary;

    public Company(String name, String address, String postcode, String tel, String vary) {
        this.name = name;
        this.address = address;
        this.postcode = postcode;
        this.tel = tel;
        this.vary = vary;
    }

    @Override
    public String toString() {
        return name + address + postcode + tel + vary;
    }
}
public class CompanyBuilder implements javafx.util.Builder<Company> {
    private String name, address, postcode, tel, vary;

    public CompanyBuilder(String name, String address, String tel) {
        this.name = name;
        this.address = address;
        this.tel = tel;
    }
    public CompanyBuilder setPostcode(String postcode){
        this.postcode = postcode;
        return this;
    }

    public CompanyBuilder setVary(String vary) {
        this.vary = vary;
        return this;
    }

    @Override
    public Company build() {
        return new Company(name, address, postcode, tel, vary);
    }
}

public class BuilderTest {
    @Test
    public void test(){
        CompanyBuilder companyBuilder = new CompanyBuilder("公司", "北京", "010 2222222");

        Company company = companyBuilder.setVary("图书").setPostcode("1111111").build();
        System.out.println(company.toString());
    }
}
```

生成器模式可以将复杂的对象创建封装起来，允许通过多个步骤来创建对象，并且可以改变这些过程。


---

### 责任链模式（Chain of Responsibility Pattern）

责任链模式可以让多于一个对象来处理某个请求。达到链式请求的目的。

#### 例子

这在插件化的http server中经常应用。

```java
public abstract class Handler {
    private Handler nextHandler;

    public void setNextHandler(Handler nextHandler) {
        this.nextHandler = nextHandler;
    }

    public void next(Request request){
        if(this.nextHandler !=null){
            this.nextHandler.handler(request);
        }
    }

    public abstract void handler(Request request);
}

public class Plugin1Handler extends Handler {
    @Override
    public void handler(Request request) {
        System.out.println("Plugin1: before run all plugin");
        next(request);
        System.out.println("Plugin1: after run all plugin");

    }
}

public class Plugin2Handler extends Handler {
    @Override
    public void handler(Request request) {
        System.out.println("Plugin2: before run all plugin");
        next(request);
        System.out.println("Plugin2: after run all plugin");
    }
}

public class PluginManager {
    private Request request;
    private Handler headHandler;
    private Handler currHandler;

    public PluginManager(Request request) {
        this.request = request;
    }

    public void addPlugin(Handler handler) {
        if (headHandler == null) {
            headHandler = handler;
        } else {
            currHandler.setNextHandler(handler);
        }
        currHandler = handler;
    }

    public void run() {
        if (headHandler != null) {
            headHandler.handler(request);
        }
    }
}

public class Request {
}
```

测试用例

```java
public class ChainTest {
    @Test
    public void test(){
        Request request = new Request();
        PluginManager pluginManager = new PluginManager(request);
        pluginManager.addPlugin(new Plugin1Handler());
        pluginManager.addPlugin(new Plugin2Handler());
        pluginManager.run();
    }
}
```



---

### 蝇量模式（Flyweight Pattern）

当一个类有许多实例，而这些实例能够被同一方法控制的时候，我们可以使用蝇量模式来减少对象的数量，但作为代价，我们将无法细化控制每一个实例的行为。

#### 例子

要渲染一个满天繁星的夜空，也许每一颗星星都是一个对象，有位置、亮度等属性。这样需要创建出大量的星星对象。而使用一个叫StarManage的对象，就可以轻松管理。但使用这种方法后，我们就没有办法细化控制某个星星应该显示在哪了。

```java
public class Star {
    public void display(int x ,int y,int brightness){
        // 根据x,y,brightness画出星星
    }
}
public class StarManager {
    private int count;
    private int[] brightness, xs, ys;
    private Star star;

    public StarManager(int count) {
        this.count = count;
        star = new Star();
        brightness = new int[count];
        xs = new int[count];
        ys = new int[count];
        for (int i = 0; i < count; i++) {
            brightness[i] = (int) (Math.random());
            xs[i] = (int) (Math.random());
            ys[i] = (int) (Math.random());
        }
    }

    public void draw() {
        for (int i = 0; i < count; i++) {
            star.display(xs[i], ys[i], brightness[i]);
        }
    }
}
```


---

### 中介者模式（Mediator Pattern）

中介者模式是在多个对象之间有错综复杂关系时，引入中介者来协调各个对象之间行为。

#### 优点

通过将对象彼此解耦，可以增加对象的复用性。

通过将控制 逻辑集中，可以简化系统维护。

可以让对象之间所传递的消息变得简单而大幅度减少。

#### 缺点

如果设计不当，中介者本身会变得过于复杂。

如同分布系统增加中心节点可以简化调度一样，中心节点也会成为瓶颈。

---

### 备忘录模式（Memento Pattern）

备忘录模式保存一个对象的某个状态，以便在适当的时候恢复对象。备忘录模式属于行为型模式。

备忘录模式可以在不破坏封装性的前提下，捕获一个对象的内部状态，并在该对象之外保存这个状态，以便后续恢复。

实现的关键是在原来关键对象的基础上独立出一个可供外部访问和可以全量恢复的状态对象，将此对象数据保存即可。

现实某些情况可使用序列化来代替此模式的实现（序列化可能也算是备忘录的实现）。

---

### 原型模式（Prototype pattern）


---

### 访问者模式


---

### 解释器模式


---

[代码地址](https://github.com/xiaochai/batman/tree/master/DesignPatterns)