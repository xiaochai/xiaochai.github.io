---
layout: post
title: "机器学习课程备忘(Week2)"
date: 2017-5-12
categories:
  - Tech
description: 
image: /assets/images/screenshot-octave-4-2.png
image-sm: /assets/images/screenshot-octave-4-2.png
---
<style>
.myMJSmall {
	font-size: 0.8em;
}
</style>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

### Lecture1: Multivariate Linear Regression

#### 多变量线性回归（Multivariate Linear Regression）

##### 符号

> $$n$$：特征数量<br/>
> $$x^{(i)}$$：第i个样本的所有特征<br/>
> $$x^{(i)}_j$$：第i个样本的第j个特征。特别的$$x^{(i)}_0 = 1$$

##### 预测函数(Hypothesis)

$$\class{myMJSmall}{h_\theta(x)=\theta_0x_0+\theta_1x_1+ \cdots + \theta_nx_n}\\ \theta^Tx$$

> 其中$$x_0 = 0$$

##### 代价函数(Cost Function/Squared Error Function/Mean Squared Error)

$$\class{myMJSmall}{J(\theta)=J(\theta_0,\theta_1,\ldots,\theta_n)=\frac 1{2m}\sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})^2}$$


##### 梯度下降(Gradient descent)


$$\class{myMJSmall}{\theta_j := \theta_j - \alpha \frac{\partial}{\partial \theta_j} J(\theta)}$$

$$ \class{myMJSmall}{\frac{\partial}{\partial \theta_j} J(\theta) = \frac{1}{m} \sum_{i=1}^m(h_\theta(x^{(i)})-y^{(i)})x^{(i)}_j}$$

##### 矩阵表示

$$\theta =  \begin{bmatrix}
  \theta_0 \\
  \theta_1 \\
  \vdots \\
  \theta_n\\
  \end{bmatrix}
$$

某一个样本的向量表示

$$x^{(i)} = \begin{bmatrix}
  x^{(i)}_0 \\
  x^{(i)}_1 \\
  \vdots \\
  x^{(i)}_n\\
  \end{bmatrix}
  \in \mathbb{R^{n+1}}
$$

输入的所有样本表示(Designed Matrix)

$$X = \begin{bmatrix}
  x^{(1)}_0 & x^{(1)}_1 & \cdots & x^{(1)}_n \\
  x^{(2)}_0 & x^{(2)}_1 & \cdots & x^{(2)}_n \\
  \vdots & \vdots & \ddots & \vdots \\
  x^{(m)}_0 & x^{(m)}_1 & \cdots & x^{(m)}_n \\
  \end{bmatrix}
$$

#### 实用技巧

* Feature Scaling：将所有的特征值控制在一个相似的范围（例如 $$-1 \le x \le 1$$）

* 均值规一化(Mean Normalization)：控制样本的均值为0

> $$x_i' = \frac{x_i-\mu_i}{s_i} \\$$
> 其中$$\mu_i$$为平均值，$$s_i$$为$$max_i-min_i$$（作业中使用的是标准差）

* 如何保证梯度下降算法工作正常？

> 查看$$J(\theta)$$与迭代次数的函数图，正常为$$J(\theta)$$持续减少<br/>
> 当$$J(\theta)$$的减少量小于$$\epsilon$$（0.001）时，识别为收敛<br/>
> 只要$$\alpha$$足够小，能保证$$J(\theta)$$每一次迭代都会减小

##### 多项式回归

* 多特征合并

> 例如： $$h(\theta)=\theta_0+\theta_1*width+\theta_2*height$$<br/>
> 可转化成：$$h(\theta)=\theta_0+\theta_1*area$$；其中$$area = width*heigth $$

* 降次

> 例如：$$h(\theta=\theta_0+\theta_1*x+\theta_2*x^2+\theta3*x^3$$<br/>
> 可转化为：$$h(\theta)=\theta_0+\theta_1*x_1+\theta_2*x_2+\theta_3*x_3$$；其中$$x_1 = x; x_2 = x^2; x_3 = x^3$$

* 特征的选择

> 不同的特征会有不同的函数图片，覆盖样本的效果也会不一样<br/>
> 如: $$h(\theta)=\theta_0+\theta_1*size+\theta_2*size^2$$<br/> 
> $$h(\theta)=\theta_0+\theta_1*size+\theta_2*\sqrt{size}$$


#### 正规方程

* 令$$\frac{d}{d\theta}J(\theta) = 0$$可求解出如下使用矩阵表示的最优$$\theta$$<br/>

> 求解过程todo

$$\theta=(X^TX)^{-1}X^Ty$$

##### 比较

> $$\class{myMJSmall}{\begin{array}{c|c}
> \text{梯度下降} & \text{正规方程} \\
> \hline \\
> \text{需要选择合适的}\alpha & \text{不需要选择}\alpha \\
> \text{需要多次迭代才能取得最小值} & \text{不需要多次迭代} \\
> \text{当n很大时，仍然能很好的工作} & \text{需要计算}(X^TX)^-1 \\
>    & \text{当n特别大时，计算量巨大}O(n^3) \\
> \end{array}
> }$$

##### 当$$X^TX$$不可逆时

* 去除掉重复的特征

* 太多特征项，可以适当减少特征项

---

### Octave基本操作

#### 基本操作

```matlab
%% Change Octave prompt  
PS1('>> ');
%% Change working directory in windows example:
cd 'c:/path/to/desired/directory name'
%% Note that it uses normal slashes and does not use escape characters for the empty spaces.

%% elementary operations
5+6
3-2
5*8
1/2
2^6
1 == 2 % false
1 ~= 2 % true.  note, not "!="
1 && 0
1 || 0
xor(1,0)


%% variable assignment
a = 3; % semicolon suppresses output
b = 'hi';
c = 3>=1;

% Displaying them:
a = pi
disp(a)
disp(sprintf('2 decimals: %0.2f', a))
disp(sprintf('6 decimals: %0.6f', a))
format long
a
format short
a


%%  vectors and matrices
A = [1 2; 3 4; 5 6]

v = [1 2 3]
v = [1; 2; 3]
v = 1:0.1:2   % from 1 to 2, with stepsize of 0.1. Useful for plot axes
v = 1:6       % from 1 to 6, assumes stepsize of 1 (row vector)

C = 2*ones(2,3) % same as C = [2 2 2; 2 2 2]
w = ones(1,3)   % 1x3 vector of ones
w = zeros(1,3)
w = rand(1,3) % drawn from a uniform distribution 
w = randn(1,3)% drawn from a normal distribution (mean=0, var=1)
w = -6 + sqrt(10)*(randn(1,10000));  % (mean = -6, var = 10) - note: add the semicolon
hist(w)    % plot histogram using 10 bins (default)
hist(w,50) % plot histogram using 50 bins
% note: if hist() crashes, try "graphics_toolkit('gnu_plot')" 

I = eye(4)   % 4x4 identity matrix

% help function
help eye
help rand
help help
```

#### Moving Data Around

``` matlab
%% dimensions
sz = size(A) % 1x2 matrix: [(number of rows) (number of columns)]
size(A,1) % number of rows
size(A,2) % number of cols
length(v) % size of longest dimension


%% loading data
pwd   % show current directory (current path)
cd 'C:\Users\ang\Octave files'  % change directory 
ls    % list files in current directory 
load q1y.dat   % alternatively, load('q1y.dat')
load q1x.dat
who   % list variables in workspace
whos  % list variables in workspace (detailed view) 
clear q1y      % clear command without any args clears all vars
v = q1x(1:10); % first 10 elements of q1x (counts down the columns)
save hello.mat v;  % save variable v into file hello.mat
save hello.txt v -ascii; % save as ascii
% fopen, fread, fprintf, fscanf also work  [[not needed in class]]

%% indexing
A(3,2)  % indexing is (row,col)
A(2,:)  % get the 2nd row. 
        % ":" means every element along that dimension
A(:,2)  % get the 2nd col
A([1 3],:) % print all  the elements of rows 1 and 3

A(:,2) = [10; 11; 12]     % change second column
A = [A, [100; 101; 102]]; % append column vec
A(:) % Select all elements as a column vector.

% Putting data together 
A = [1 2; 3 4; 5 6]
B = [11 12; 13 14; 15 16] % same dims as A
C = [A B]  % concatenating A and B matrices side by side
C = [A, B] % concatenating A and B matrices side by side
C = [A; B] % Concatenating A and B top and bottom

```

#### Computing on Data

``` matlab
%% initialize variables
A = [1 2;3 4;5 6]
B = [11 12;13 14;15 16]
C = [1 1;2 2]
v = [1;2;3]

%% matrix operations
A * C  % matrix multiplication
A .* B % element-wise multiplication
% A .* C  or A * B gives error - wrong dimensions
A .^ 2 % element-wise square of each element in A
1./v   % element-wise reciprocal
log(v)  % functions like this operate element-wise on vecs or matrices 
exp(v)
abs(v)

-v  % -1*v

v + ones(length(v), 1)  
% v + 1  % same

A'  % matrix transpose

%% misc useful functions

% max  (or min)
a = [1 15 2 0.5]
val = max(a)
[val,ind] = max(a) % val -  maximum element of the vector a and index - index value where maximum occur
val = max(A) % if A is matrix, returns max from each column

% compare values in a matrix & find
a < 3 % checks which values in a are less than 3
find(a < 3) % gives location of elements less than 3
A = magic(3) % generates a magic matrix - not much used in ML algorithms
[r,c] = find(A>=7)  % row, column indices for values matching comparison

% sum, prod
sum(a)
prod(a)
floor(a) % or ceil(a)
max(rand(3),rand(3))
max(A,[],1) -  maximum along columns(defaults to columns - max(A,[]))
max(A,[],2) - maximum along rows
A = magic(9)
sum(A,1)
sum(A,2)
sum(sum( A .* eye(9) ))
sum(sum( A .* flipud(eye(9)) ))


% Matrix inverse (pseudo-inverse)
pinv(A)        % inv(A'*A)*A'
```

#### Plotting Data

```matlab
%% plotting
t = [0:0.01:0.98];
y1 = sin(2*pi*4*t); 
plot(t,y1);
y2 = cos(2*pi*4*t);
hold on;  % "hold off" to turn off
plot(t,y2,'r');
xlabel('time');
ylabel('value');
legend('sin','cos');
title('my plot');
print -dpng 'myPlot.png'
close;           % or,  "close all" to close all figs
figure(1); plot(t, y1);
figure(2); plot(t, y2);
figure(2), clf;  % can specify the figure number
subplot(1,2,1);  % Divide plot into 1x2 grid, access 1st element
plot(t,y1);
subplot(1,2,2);  % Divide plot into 1x2 grid, access 2nd element
plot(t,y2);
axis([0.5 1 -1 1]);  % change axis scale

%% display a matrix (or image) 
figure;
imagesc(magic(15)), colorbar, colormap gray;
% comma-chaining function calls.  
a=1,b=2,c=3
a=1;b=2;c=3;
```

#### Control statements: for, while, if statements



```matlab
v = zeros(10,1);
for i=1:10, 
    v(i) = 2^i;
end;
% Can also use "break" and "continue" inside for and while loops to control execution.

i = 1;
while i <= 5,
  v(i) = 100; 
  i = i+1;
end

i = 1;
while true, 
  v(i) = 999; 
  i = i+1;
  if i == 6,
    break;
  end;
end

if v(1)==1,
  disp('The value is one!');
elseif v(1)==2,
  disp('The value is two!');
else
  disp('The value is not one or two!');
end
```

#### Functions

```matlab
function y = squareThisNumber(x)

y = x^2;
```

```matlab
function [y1, y2] = squareandCubeThisNo(x)
y1 = x^2
y2 = x^3
```

##### 学习资料

[课件和笔记](/assets/material/ml/)
[Octave编程作业](https://github.com/xiaochai/ml_assignment)
