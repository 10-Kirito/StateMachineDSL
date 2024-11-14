unit StateMachine;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TTransitionType = (tpINTERNAL, tpEXTERNAL);

  TTransition<S, E> = class;

  TEventTransition<S, E> = class;

  TState<S, E> = class
  strict private
    FStateId: S;
    FEventTransition: TEventTransition<S, E>;
  public
    constructor Create(AStateId: S);
    destructor Destroy; override;

    /// <summary></summary>
    /// <param name="AEvent"></param>
    /// <param name="ATarget"></param>
    /// <param name="ATransitionType"></param>
    /// <returns></returns>
    function AddTranstition(AEvent: E; ATarget: TState<S, E>;
      ATransitionType: TTransitionType): TTransition<S, E>;

    function GetEventTranstitions(AEvent: E): TObjectList<TTransition<S,E>>;
    property StateId: S read FStateId;
  end;

  TAction = TFunc<Boolean>;
  TCondition = TFunc<Boolean>;

  TTransition<S, E> = class
  strict private
    FSource: TState<S, E>;
    FTarget: TState<S, E>;
    FEvent: E;
    FCondition: TCondition;
    FType: TTransitionType;
    FAction: TAction;
  private
    /// <summary> 获取相应的状态转移条件</summary>
    function GetCondition: TCondition;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> 比较两个状态转移是否相同</summary>
    /// <param name="ATransition">目标状态转移</param>
    /// <returns></returns>
    /// <remarks>唯一标识组: [Event, Source, Target]</remarks>
    function Equal(const ATransition: TTransition<S, E>): Boolean;

    /// <summary> 状态转移函数</summary>
    function Transit: TState<S, E>;

    /// <summary> 相关属性设置以及访问</summary>
    property Source: TState<S, E> read FSource write FSource;
    property Target: TState<S, E> read FTarget write FTarget;
    property Event: E read FEvent write FEvent;
    property Condition: TCondition read GetCondition write FCondition;
    property TransType: TTransitionType read FType write FType;
    property Action: TAction read FAction write FAction;
  end;

  TEventTransition<S, E> = class
  strict private
    FEventTransition: TObjectDictionary<E,TObjectList<TTransition<S,E>>>;

    /// <summary> 同一个事件, 两个状态之间的状态转移只能存在一个, 不能存在多个</summary>
    /// <param name="AList"> 一个事件对应的所有的状态转移</param>
    /// <param name="ATransition"> 新的目标状态转移</param>
    procedure Verify(AList: TObjectList<TTransition<S, E>>; ANewTransition: TTransition<S, E>);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> 添加一个状态转移，一个事件可能对应多种状态转移</summary>
    /// <param name="AEvent"> 事件</param>
    /// <param name="ATransition"> 状态转移</param>
    procedure Put(AEvent: E; ANewTransition: TTransition<S, E>);

    /// <summary> 当事件触发的时候，返回该事件可以触发的所有的状态转移</summary>
    function Get(AEvent: E): TObjectList<TTransition<S,E>>;
  end;

  TTransitionBuilder<S, E> = class
  public

  end;

  /// <summary>
  ///   状态机类
  /// </summary>
  TStateMachine<S, E> = class
  strict private
    FStateMap: TObjectDictionary<S, TState<S, E>>;

    /// <summary> 获取当前给定<S, E>所对应的Transition</summary>
    /// <param name="ASource"> 当前状态: SourceState</param>
    /// <param name="AEvent"> 触发的事件: Event</param>
    /// <returns> 状态转移: TTransition</returns>
    /// <remarks> 其中在进行状态转移的时候，会进行相关条件的判断, 符合条件才可以进行状态转移</remarks>
    function RouteTransition(ASource: S; AEvent: E): TTransition<S, E>;

    /// <summary> 获取相应的状态</summary>
    /// <remarks> 如果相应状态不存在，则抛出异常</remarks>
    function GetState(AStateId: S): TState<S, E>;
  public
    constructor Create(var AStateMap: TObjectDictionary<S, TState<S, E>>);
    destructor Destroy; override;

    /// <summary> 状态机提供的触发事件的接口</summary>
    /// <param name="AEvent"> 事件</param>
    /// <returns> 返回触发事件导致转移的目标状态</returns>
    function FireEvent(ASource: S; AEvent: E): S;
  end;

  /// <summary>
  ///   状态机构建类, 提供相关接口用来定义状态机的结构: 状态、事件以及状态转移!
  /// </summary>
  TStateMachineBuilder<S, E> = class
  {$REGION '私有类型声明'}
  strict private type
    StateHeler<S1, E1> = class
    public
      /// <summary> 创建相应的状态，但是并不持有其生命周期</summary>
      /// <remarks> 从StateMap当中获取响应的状态，如果存在则直接返回; 反之则创建相应的状态</remarks>
      class function getState(var AMap: TObjectDictionary<S1, TState<S1, E1>>; AStateId: S1): TState<S1, E1>;
    end;
  {$ENDREGION}
  strict private
    {
      StateMap仅仅是持有相关对象的引用，其生命周期交由状态机来进行管理！
      为什么？因为Builder的存在时间周期是比较短的，而状态机是始终存在!
    }
    FStateMap: TObjectDictionary<S, TState<S, E>>;
    FStateMachine: TStateMachine<S, E>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>外部状态转移接口</summary>
    /// <param name="ASource"> 源状态</param>
    /// <param name="ATarget"> 目标状态</param>
    /// <param name="AEvent"> 触发的事件</param>
    /// <param name="ACondition"> 状态转移的条件</param>
    /// <param name="Action"> 目标状态对应的动作</param>
    procedure ExternalTransition(ASource: S; ATarget: S; AEvent: E;
      ACondition: TCondition; Action: TAction);

    /// <summary> 获取构建的状态机</summary>
    /// <remarks> 并不管理其生命周期，交由用户进行管理</remarks>
    function Build: TStateMachine<S, E>;
  end;

  TStateMachineExecption = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

implementation

uses
  CodeSiteLogging, TypInfo;

{ TStateMachine<S, E>.TState<S, E> }

function TState<S, E>.AddTranstition(AEvent: E;
  ATarget: TState<S, E>;
  ATransitionType: TTransitionType): TTransition<S, E>;
begin
  Result := TTransition<S, E>.Create;
  Result.Source := Self;
  Result.Target := ATarget;
  Result.Event := AEvent;
  Result.TransType := ATransitionType;

  FEventTransition.Put(AEvent, Result);
end;

constructor TState<S, E>.Create(AStateId: S);
begin
  FStateId := AStateId;
  FEventTransition := TEventTransition<S, E>.Create;
end;

destructor TState<S, E>.Destroy;
begin
  FreeAndNil(FEventTransition);
  inherited;
end;

function TState<S, E>.GetEventTranstitions(
  AEvent: E): TObjectList<TTransition<S, E>>;
begin
  Result := FEventTransition.Get(AEvent);
end;

{ TStateMachine<S, E> }

constructor TStateMachine<S, E>.Create(var AStateMap: TObjectDictionary<S, TState<S, E>>);
begin
  FStateMap := AStateMap;
end;

destructor TStateMachine<S, E>.Destroy;
begin
  FreeAndNil(FStateMap);
  inherited;
end;

function TStateMachine<S, E>.FireEvent(ASource: S; AEvent: E): S;
var
  LTransition: TTransition<S, E>;
begin
  LTransition := RouteTransition(ASource, AEvent);

  /// 如果不存在相应的状态转移，则维持当前状态
  if not Assigned(LTransition) then
  begin
    CodeSite.Send('该事件并未存在相关的状态转移！');
    Exit(ASource);
  end;

  Result := LTransition.Transit.StateId;
end;

function TStateMachine<S, E>.GetState(AStateId: S): TState<S, E>;
begin
  if not FStateMap.TryGetValue(AStateId, Result) then
   raise TStateMachineExecption.Create('Error Message');
end;

function TStateMachine<S, E>.RouteTransition(ASource: S; AEvent: E): TTransition<S, E>;
var
  LState: TState<S, E>;
  LTransitionList: TObjectList<TTransition<S, E>>;
  LTransition: TTransition<S, E>;
begin
  LState := GetState(ASource);
  LTransitionList := LState.GetEventTranstitions(AEvent);

  /// 如果该事件并没有对应的状态转移，则直接返回nil
  if (not Assigned(LTransitionList)) or (LTransitionList.Count = 0) then
    Exit(nil);

  /// - 如果相应的状态转移提前设置Condition, 则检查相关的Condition是否满足状态转移;
  /// - 如果相应的状态转移没有设置Condition, 则直接返回最后一个状态转移(一般情况下
  ///   用户没有设置相应的状态转移条件，一个事件对于一个状态，只能有一个结果状态)
  for LTransition in LTransitionList do
  begin
    if LTransition.GetCondition = nil then
       Result := LTransition
    else if LTransition.Condition() then
    begin
      Result := LTransition;
      Exit;
    end;
  end;
end;

{ TStateMachine<S, E>.TTransition<S, E> }

constructor TTransition<S, E>.Create;
begin

end;

destructor TTransition<S, E>.Destroy;
begin
  FreeAndNil(FSource);
  FreeAndNil(FTarget);
  FCondition := nil;
  FAction := nil;
  inherited;
end;


function TTransition<S, E>.Equal(
  const ATransition: TTransition<S, E>): Boolean;
begin
  Result := (FEvent = ATransition.Event) and
    (FSource.StateId = ATransition.Source.StateId) and
    (FTarget.StateId = ATransition.Target.StateId);
end;

function TTransition<S, E>.GetCondition: TCondition;
begin
  Result := FCondition;
end;

function TTransition<S, E>.Transit: TState<S, E>;
begin
  if (Assigned(FCondition)) or (FCondition()) then
  begin
    if Assigned(FAction) and FAction() then
      Exit(FTarget);
    Exit(FSource);
  end;

  CodeSite.Send('状态转移条件没有满足，保持当前状态');
  Exit(FSource);
end;

{ TStateMachineBuilder<S, E> }

function TStateMachineBuilder<S, E>.Build: TStateMachine<S, E>;
begin
  Result := FStateMachine;
end;

constructor TStateMachineBuilder<S, E>.Create;
begin
  FStateMap := TObjectDictionary<S, TState<S, E>>.Create;
  FStateMachine := TStateMachine<S, E>.Create(FStateMap);
end;

destructor TStateMachineBuilder<S, E>.Destroy;
begin
  {
    StateMap的生命周期交由状态机来进行管理，状态机创建之后交付使用，其生命周期交由
    用户进行管理!
  }
  inherited;
end;

procedure TStateMachineBuilder<S, E>.ExternalTransition(ASource, ATarget: S;
  AEvent: E; ACondition: TCondition; Action: TAction);
var
  LSource, LTarget: TState<S, E>;
  LTransition: TTransition<S, E>;
begin
  LSource := StateHeler<S, E>.getState(FStateMap, ASource);
  LTarget := StateHeler<S, E>.getState(FStateMap, ATarget);
  LTransition := LSource.AddTranstition(AEvent, LTarget, TTransitionType.tpEXTERNAL);
  LTransition.Condition := ACondition;
  LTransition.Action := Action;
end;

{ TEventTransition<S, E> }

constructor TEventTransition<S, E>.Create;
begin
  FEventTransition := TObjectDictionary<E,TObjectList<TTransition<S,E>>>.Create;
end;

destructor TEventTransition<S, E>.Destroy;
begin
  FreeAndNil(FEventTransition);
  inherited;
end;

function TEventTransition<S, E>.Get(AEvent: E): TObjectList<TTransition<S, E>>;
begin
  Result := nil;
  if FEventTransition.ContainsKey(AEvent) then
    Result := FEventTransition[AEvent];
end;

procedure TEventTransition<S, E>.Put(AEvent: E; ANewTransition: TTransition<S, E>);
var
  LTransitions: TObjectList<TTransition<S, E>>;
begin
  if FEventTransition.TryGetValue(AEvent, LTransitions) then
  begin
    Verify(LTransitions, ANewTransition);
    LTransitions.Add(ANewTransition);
  end
  else
  begin
    LTransitions := TObjectList<TTransition<S, E>>.Create;
    LTransitions.Add(ANewTransition);
    FEventTransition.Add(AEvent, LTransitions);
  end;
end;

procedure TEventTransition<S, E>.Verify(
  AList: TObjectList<TTransition<S, E>>; ANewTransition: TTransition<S, E>);
var
  LTransition: TTransition<S, E>;
begin
  for LTransition in AList do
  begin
    if LTransition.Equal(ANewTransition) then
      raise TStateMachineExecption.Create('该状态转移已经存在!');
  end;
end;

{ TStateMachineExecption }

constructor TStateMachineExecption.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

{ TStateMachineBuilder<S, E>.StateHeler<S, E> }

class function TStateMachineBuilder<S, E>.StateHeler<S1, E1>.getState(
  var AMap: TObjectDictionary<S1, TState<S1, E1>>; AStateId: S1): TState<S1, E1>;
begin
  if not AMap.TryGetValue(AStateId, Result) then
  begin
    Result := TState<S1, E1>.Create(AStateId);
    AMap.Add(AStateId, Result);
  end;
end;

end.
