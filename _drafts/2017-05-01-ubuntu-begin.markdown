---
layout: post
title: "ubuntu环境搭建"
date: 2017-5-1
categories:
  - Tech
description: 
image: http://ww3.sinaimg.cn/large/6a1f6674jw1elllqltqifj21kw11x4dp.jpg
image-sm: http://ww3.sinaimg.cn/mw1024/6a1f6674jw1elllqltqifj21kw11x4dp.jpg
---
## The Language

### Getting Started


* dofile & loadfile 

* _VERSION: underscore follow by some upper-case letters, reserved for special usage

* interpreter options 

> lua -i lib.lua
> lua -e "print(math.sin(12));"
> lua -i -l lib -e "print(fact(10))"

* lua init script

> export LUA_INIT="@./lib.lua"
> export LUA_INIT="print(22)"


### Types and Values

* each value carries its own type.

* Lua 中有八种基本类型： nil, boolean, number, string, function, userdata, thread, and table

* functions are first-class values in Lua

* condition value: consider false and nil as false, anything else as true(even 0 or "")

#### number type 

* number type : double-precision floating-point (IEEE 754 ?) 

* integers do have exact representations and therefore do not have rounding errors

* Most modern CPUs do floating-point arithmetic as fast as (or even faster than) integer arithmetic? 


#### string type 

* 8-byte clean, can hold any value 

* Strings in Lua are immutable values

* #s

* long string 

> [[ ]] or [===[ ]===] also for comments

* Coercions 

* tostring, tonumber

#### table type 

* The table type implements associative arrays.

* constructor expression

> a={}
> a={a=22,b=33}

* represent records

> a.a
> a["a"]


### Expressions

* Expressions in Lua include the numeric constants and string literals, variables, unary and binary operations, and function calls.

#### Arithmetic Operators

* the binary '+' (addition), '-' (subtraction), '*' (multiplication), '/' (division), '^' (exponentiation), '%' (modulo), and the unary '-' (negation).

* All of them operate on real numbers.

* a % b = a - math.floor(a/b)*b


#### Relational Operators

* < > <= >= == ~=

* If the values have different types, Lua considers them not equal

#### Logical Operators

* and or not 

* Both and and or use short-cut evaluation

* x = x or v

* a and b or c

* The not operator always returns a boolean value


#### Concatenation 

* ..

#### The Length Operator


* The length operator(#) works on strings and tables.


#### Precedence

> ^ 
> not # -(unary)
> * / %
> + - 
> ..
> < > <= >= == ~= 
> and 
> or 


* All binary operators are left associative, except for '^' (exponentiation) and '..' (concatenation), which are right associative.


#### Table Constructors

* empty: {}

* lists: {"Sunay", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}

* the first element of the constructor has index 1, not 0

* dict: {x=10, y=10}


### Statements

* assignment, control structures, and procedure calls; multiple assignments and local variable declarations

#### Assignment

* In a multiple assignment, Lua first evaluates all values and only then executes the assignments

#### Local Variables and Blocks

* local

* do-end 

#### Control Structures

* if then elseif then end

* while do end 

* repeat until

* numeric for: for var = begin; max; step do ... end ; step default 1

* If you want a loop without an upper limit, you can use the constant max.huge

* general for: for k, v = pairs(t) do ... end

* some iterators: iterate over the lines of a file (io.lines), the pairs of a table (pairs), the entries of a sequence (ipairs), the words of a string (string.gmatch), and so on.

#### break, return, and goto

* The break and return statements allow us to jump out of a block. The goto statement allows us to jump to almost any point in a function

*  ::labelname::   goto labelname

* A typical and well-behaved use of a goto is to simulate some construction that you learned from another language but that is absent from Lua, such as continue, multi-level break, multi-level continue, redo, local error handling, etc


### Functions

* if the function has one single argument and that argument is either a literal string or a table constructor, then the parentheses are optional

* object-oriented calls: o:f(x) == o.f(o,x)

* Lua adjusts the number of arguments to the number of parameters, as it does in a multiple assignment: extra arguments are thrown away; extra parameters get nil.

#### Multiple Results

* functions can return multiple results

* force a call to return exactly one result by enclosing it in an extra pair of parentheses

* table.unpack  just unpack a array, not a dict


#### Variadic Functions

* function add(...)


#### Named Arguments

* table base arguments: remane{old="dir", new="dir2"}

### More about Functions

* Functions in Lua are first-class values with proper lexical scoping.

* functions are anonymous;

* function foo() print "foo" end; just a syntactic sugar; equal to foo = function() print "fool" end

* table.sort(t, function(a,b) return a> b end)

* A function that gets another function as an argument is what we call a higher-order function

* tail-call elimination

### Iterators and the Generic for

#### Iterators and Closures

* use closure to hold states

#### The Semantics of the Generic for

#### Stateless Iterators

#### Iterators with Complex State

#### True Iterators

### Compilation, Execution, and Errors

*the distinguishing feature of interpreted languages is not that they are not compiled, but that it is possible (and easy) to execute code generated on the fly

#### Compilation

* loadfile compiles the chunk and returns the compiled chunk as a function, and does not raise errors, but instead returns error codes

> function dofile(filename) 
> 	local f = assert(loadfile(filename))
> 	return f()
> end

* load function: load always compiles its chunks in the global environment

#### Precompiled Code

* luac  -o iterator.lc iterator.lua

* lua iterator.lc

* lua -l iterator.lua

* string.dump: it receives a Lua function and returns its precompiled code as a string, properly formatted to be loaded back by Lua.

#### C Code

* package.loadlib: two string arguments: the complete path of a library and the name of a function in that library

> local path="/usr/local/lib/lua/5.1/socket.so"
> local f = package.loadlib(path, "luaopen_socket")

* require

#### Errors

* assert

* return a error code or raise a error ?

#### Error Handling and Exceptions

* pcall: call its first argument in protected mode. if no error happen, return true plus any values returned by the call, or return false and a error message

* pcall will return any Lua value that you pass to error

#### Error Messages and Tracebacks

* xpcall, debug.debug

### Coroutines

* The main difference between threads and coroutines is that, conceptually (or literally, in a multiprocessor machine), a program with threads runs several threads in parallel. Coroutines, on the other hand, are collaborative: at any given time, a program with coroutines is running only one of its coroutines, and this running coroutine suspends its execution only when it explicitly requests to be suspended

#### Coroutine Basics

* Lua packs all its coroutine-related functions in the "coroutine" table

* A coroutine can be in one of four states: suspended, running, dead, and normal

* create, resume, yield, wrap

* yield returns any extra arguments passed to the corresponding resume and resume returns any extra arguments passed to the corresponding yield

* asymmetric coroutines / semi-coroutines 

#### Pipes and Filters

* producer–consumer problem

* consumer-driven design

#### Coroutines as Iterators

* coroutine.wrap

#### Non-Preemptive Multithreading

* While a coroutine is running, it cannot be stopped from the outside. It suspends execution only when it explicitly requests so (through a call to yield

* a parallel download example 

!!example not finish!!

### Complete Examples

!!example not finish!!

#### The Eight-Queen Puzzle

#### Most Frequent Words

#### Markov Chain Algorithm


-----

## Tables and Objects

### Data Structures

#### Arrays

* just table 

* it is customary in Lua to start arrays with index 1. The Lua libraries adhere to this convention; so does the length operator

#### Matrices and Multi-Dimensional Arrays

* use an array of arrays

* composing the two indices into a single one( (i-1)*M+j or i .. " " .. j)

#### Linked Lists

* every element is a table with value and next

#### Queues and Double Queues


#### Sets and Bags

* In Lua, an efficient and simple way to represent such sets is to put the set elements as indices in a table.


#### Graphs

* find a path (depth-first traversal)


### Data Files and Persistence

* Besides all the kinds of data that a correct file can contain, a robust program should also handle bad files gracefully

#### Data Files

* The technique is to write our data file as Lua code that, when run, builds the data into the program(with a callback function)

* self-describing data

#### Serialization

* With this format ("%a"), the read number will have exactly the same bits of the original one

> serialize(3.434353623534132141424)
> 3.4343536235341
> 0x1.b798e647fd357p+1

* "%q" surrounds the string with double quotes and properly escapes double quotes, newlines, and some other characters inside the string

* Saving tables without cycles & Saving tables with cycles

### Metatables and Metamethods

* metatable & metamethod

* Each value in Lua can have an associated metatable. Tables and userdata have individual metatables; values of other types share one single metatable for all values of that type. Lua always creates new tables without metatables

* getmetatable & setmetatable

* From Lua we can set the metatables only of tables; to manipulate the metatables of values of other types we must use C code

#### Arithmetic Metamethods

* __add __mul __sub __div __unm(for negation) __mod __pow __concat

* if the first value as a metatable with an __add field, Lua uses this field as the metamethod, independently of the second value; otherwise, if the second value has a metatable with an __add field, Lua uses this field as the metamethod; otherwise, Lua raises an error

#### Relational Metamethods

* __eq __lt __le 

* If two objects have different basic types or different metamethods, the equality operation results in false, without even calling any metamethod


#### Library-Defined Metamethods 

* __tostring

#### Table-Access Metamethods

* __index: access an absent field in a table

* the __index metamethod does not need to be a function: it can be a table, instead

* rawget(t,i)

* __newindex: When you assign a value to an absent index in a table, the interpreter looks for a __newindex metamethod

* rawset(t,i,v)

* read-only tables, tables with default values, and inheritance for object-oriented programming

* Tracking table accesses: empty proxy table

* __pairs

### The Environment

* Lua keeps all its global variables in a regular table, called the global environment(_G)

#### Global Variables with Dynamic Names

#### Global-Variable Declarations

#### Non-Global Environments

* Lua compiles any chunk in the scope of an upvalue called ❴❊◆❱

* The compiler translates any free name var to _ENV.var

* The load (or loadfile) function initializes the first upvalue of a chunk with the global environment.

#### Using _ENV

#### load and _ENV

* f = loadfile("test.lua", t, {}); f()

* debug.setupvalue(f,1,{})

*f = loadwithprefix("local _ENV=...", io.lines(filename, "*L")); f({})


### Modules and Packages

#### The require Function

* The first step of require is to check in table package.loaded whether the module is already loaded. If so, require returns its corresponding value

* To force require into loading the same module twice, we simply erase the library entry from package.loaded

* The path that require uses to search for Lua files is always the current value of variable package.path

* LUA_PATH

* Lua substitutes the default path for any substring ;;

* package.cpath & LUA_CPATH

* package.searchpath

#### The Basic Approach for Writing Modules in Lua

> local M = {}
> M.new = function()....
> return M

#### Using Environments

> local M = {}
> _ENV = M
> function new() ... end
> return M


#### Submodules and Packages

* when searching for a file that defines that submodule, require translates the dot into another character, usually the system’s directory separator

### Object-Oriented Programming

* : and self

#### Classes

* prototype

#### Inheritance

* using the index metamethod, is probably the best combination of simplicity, performance, and flexibility

#### Multiple Inheritance

* search the method(name) all over the parents

#### Privacy

* The basic idea of this alternative design is to represent each object through two tables: one for its state and another for its operations, or its interface

#### The Single-Method Approach

### Weak Tables and Finalizers

* Lua does automatic memory management: garbage collection

* Weak tables allow the collection of Lua objects that are still accessible to the program, while finalizers allow the collection of external objects that are not directly under control of the garbage collector


#### Weak Tables

* The weakness of a table is given by the field __mode of its metatable.(k,v,kv)

* collectgarbage()

* Notice that only objects can be collected from a weak table

* Irrespective of the table kind, when a key or a value is collected the whole entry disappears from the table.

#### Memoize Functions

#### Object Attributes

#### Revisiting Tables with Default Values


#### Ephemeron Tables

* That the value (the constant function) associated with an object refers back to its own key

* these objects will not be collected until version 5.2 use ephemeron tables to solve this

#### Finalizers

* __gc

## The Standard Libraries


### The Mathematical Library

#### 






