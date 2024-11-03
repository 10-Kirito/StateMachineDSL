# State Machine DSL Version Implementation

## 1. About

入职之后，一直苦恼公司内部状态机实现，不同模块可能存在不同的状态机实现，每个人的写法均不相同！其中掺杂着大量的`switch case`选手，真是汗颜！想着在开源社区当中寻求一个合适的状态机引擎实现。在众多状态机引擎实现当中发现[@Frank(张建飞)](https://blog.csdn.net/significantfrank)所实现的状态机引擎十分简单高效，更是在大佬的一篇文章[实现一个状态机引擎，教你看清DSL的本质](https://blog.csdn.net/significantfrank/article/details/104996419)的熏陶下步入DSL(Domain Specific Language)世界大门！

本仓库模仿[cola-component-statemachine](https://github.com/alibaba/COLA/tree/master/cola-components/cola-component-statemachine)来实现各种语言版本的状态机！

## 2. Languages

### 2.1 [Delphi](./Delphi)

Delphi(Object Pascal)编程语言可能很多人没有听过，一门很古老的语言，个人感觉和C++挺像的，甚至某些方面比C++更加的舒服！因为迫切需要一个该语言版本的，所以优先实现该版本！

Delphi Version: 11.3.