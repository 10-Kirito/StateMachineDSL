# StateMachineDSL Implement Details

# 0. 状态机选型

> 参考资料：
>
> - [实现一个状态机引擎，教你看清DSL的本质](https://blog.csdn.net/significantfrank/article/details/104996419);

不同于往常的状态机实现原理，该状态机参考DSL(Domain Specific Languages)的设计理念来实现的状态机！原因很简单：“因为状态机DSL（Domain Specific Languages）带来的表达能力，相比较于if-else的代码，要更优雅更容易理解。另一方面，状态机很简单，不像流程引擎那么华而不实。”(-by Frank(张建飞))

对于我最直观的感受就是使用状态机的DSL来表示状态之间的流转可能比使用其他的方式**更能直接的表达出状态之间的流转**！这样会增强代码的可读性以及可维护性！

[现有的DSL状态机实现](https://github.com/alibaba/COLA/tree/master/cola-components/cola-component-statemachine)当中对状态之间的描述可能长这样:

```java
builder.externalTransition()
          .from(States.STATE1)
          .to(States.STATE2)
          .on(Events.EVENT1)
          .when(checkCondition())
          .perform(doAction());
```

你先别急着怼我，我当时第一次看到这行代码的时候直接破口大骂，直呼“这是人能写出来的？！”。



# 1. 核心概念

## 1.1 状态

即状态机当中的状态。

### 1.1.1 Case1: class

程序员在使用状态机的时候，有的状态机是要求每一种状态都必须封装为相应的类，里面存在相应的状态执行方法。这样做有什么好处呢？当出现问题的时候，如果定位到相关的状态，我们很容易定位到相应的问题，因为与之相关的内容全部都封装在状态类当中。[C++ Boost Statechart](https://www.boost.org/doc/libs/1_79_0/libs/statechart/doc/index.html)的做法正是如此！

```C++
struct Active : sc::simple_state< Active, StopWatch, Stopped >
{
  public:
    typedef sc::transition< EvReset, Active > reactions;

    Active() : elapsedTime_( 0.0 ) {}
    double ElapsedTime() const { return elapsedTime_; }
    double & ElapsedTime() { return elapsedTime_; }
  private:
    double elapsedTime_;
};

struct Running : sc::simple_state< Running, Active >
{
  public:
    typedef sc::transition< EvStartStop, Stopped > reactions;

    Running() : startTime_( std::time( 0 ) ) {}
    ~Running()
    {
      // Similar to when a derived class object accesses its
      // base class portion, context<>() is used to gain
      // access to the direct or indirect context of a state.
      // This can either be a direct or indirect outer state
      // or the state machine itself
      // (e.g. here: context< StopWatch >()).
      context< Active >().ElapsedTime() +=
        std::difftime( std::time( 0 ), startTime_ );
    }
  private:
    std::time_t startTime_;
};
```

### 1.1.2 Case2: procedure

但是当遇到需要定义十几个状态的情景，可能程序员不愿意再一一定义相应的类来分别处理相应状态需要做的事情！他们可能更偏向于枚举或者数字来表示一些状态！接着就是:

```pascal
procedure TTestClass.ProcessState;
begin
  case FNextState of
      State1:
        begin
          // ...
        end;
      State2:
        begin
          // ...
        end;
      State3:
        begin
          // ...
        end;
      State4, State5:
        begin
          // ...
        end;
      State6:
        begin
          // ...
        end;
      State7:
        begin
          // ...
        end;
      State7, State8:
        begin
          // ...
        end;
      // ...
   end;
end;
```

这样可能更能符合他们的预期，每一种状态所需要处理的事情可能就是几行代码所做的事情，没有太多的必要去书写一个相应的类来对其封装，这样就属于过渡封装了！

### 1.1.3 Implement

以上两种写法可能在不同的场景的确是好的解决办法，对于不同的场景，我们的确得学会变通，不能按部就班，这样Case2的程序员可能要去骂街了!

本状态机实现能不能综合考虑两种情况来进行实现呢？既可以接受枚举类型的状态(此时状态的声明和状态要做的事情可能会分开), 又可以接受状态类的这种写法呢？



应该可以吧！！！

## 1.2 事件





## 1.3 状态转移(Transition)

状态机当中的状态转移由四元组(起始状态(Source)，目标状态(Target)，触发事件(Event)，转换条件(Condition))唯一确定。(四元组一定对应一个唯一的Action)。

对于同一事件(Event)， 在不同的转换条件之下，可能有不同的[Source, Target], 即同一起始状态，同一事件，在不同的转换条件下可能会转换为不同的状态！

但是，对于同一Event，同一Source，同一Target，同一转换条件不能存在多个!



如果状态转移存在条件，则**满足条件**才发生状态转移；

如果状态转移不存在条件，则**直接返回**相应的状态转移即可；

### 1.3.1 External Transition(外部状态转移)





### 1.3.2 Internal Transition(内部状态转移)





## 1.4 Condition







## 1.5 Action

Action和状态的行为通常是不同的概念。

- **`action`**：是指在状态转换过程中执行的特定操作，通常绑定到从一个状态转换到另一个状态的过程中。例如，从状态 A 转到状态 B 时，可能需要执行 `action` 来更新某些数据、触发事件或记录日志。它可以被视为一种**转换操作**，只在某一状态之间转换时执行；
- **状态的行为**：通常是每个状态在**自身内部**的行为或任务，与状态转换无关。例如，当系统处于某个状态时，可以定义其特定的操作逻辑，通常是这个状态会持续进行的任务。例如，在“加载中”状态下，可以定义自动加载数据的操作。状态的行为通常在进入或停留在该状态时执行，而不依赖于其他状态的转换。



状态机绑定行为的时候，可以在两个地方进行绑定：

- 在状态迁移的过程中进行相关行为的绑定，意味着当状态发生迁移的时候，行为就会被执行；
- 在状态上绑定行为，意味着当状态机进入这个状态的时候，行为就会被调用；



## 1.6 StateMachine









# 2. 接口定义





# 3. 状态机使用







# FAQ

## 1. 瞬时状态转移和非瞬时状态转移(❌)

有的状态转移是瞬时的，有的状态转移是非瞬时的，这个时候应该如何处理呢？

都放在Condition当中处理吗？**应该是可以的！**



## 2. 同一事件支持不同Condition状态转移(✅)

> [同一个事件支持不同condition状态流转](https://github.com/alibaba/COLA/pull/158)

该功能应该挺必要的，因为同一个事件确实可能在不同的条件在转移至不同的状态！

## 3. 状态转移保护(✅)

用户在使用状态机的时候，必须要保证状态机是正确的，添加的状态转移不能重复！否则抛出异常！

## 4. 异常保护(❌)

状态机应当有异常保护，异常代码是否需要仍待商榷！

## 5. 生命周期管理(✅)

> Builder的生命周期按理来讲存在的时间是比较短的，所以说相关变量`Map<S, State<S, E, C>>`的生命周期应该交由状态机来进行管理！



## 6. 事件的触发(❌)

事件的触发除了单线程还特么有多线程？？？



## 7. 关于异常处理(❌)