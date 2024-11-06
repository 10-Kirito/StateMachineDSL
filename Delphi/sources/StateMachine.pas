unit StateMachine;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TTransitionType = (tpINTERNAL, tpEXTERNAL);

  TTransition<S, E; C: class> = class;

  TEventTransition<S, E; C: class> = class;

  TState<S, E; C: class> = class
  strict private
    FStateId: S;
    FEventTransition: TEventTransition<S, E, C>;
  public
    constructor Create(AStateId: S);
    destructor Destroy; override;

    /// <summary></summary>
    /// <param name="AEvent"></param>
    /// <param name="ATarget"></param>
    /// <param name="ATransitionType"></param>
    /// <returns></returns>
    function AddTranstition(AEvent: E; ATarget: TState<S, E, C>;
      ATransitionType: TTransitionType): TTransition<S, E, C>;

    function GetEventTranstitions(AEvent: E): TObjectList<TTransition<S,E,C>>;
    property StateId: S read FStateId;
  end;

  TCondition<C: class> = class
  public
    function isSatisfied(AContext: C): Boolean; virtual; abstract;
  end;

  TAction<S, E; C: class> = class
  public
    procedure Execute(AFrom: S; ATo: S; AEvent: E; AContext: C); virtual; abstract;
  end;

  TTransition<S, E; C: class> = class
  strict private
    FSource: TState<S, E, C>;
    FTarget: TState<S, E, C>;
    FEvent: E;
    FCondition: TCondition<C>;
    FType: TTransitionType;
    FAction: TAction<S, E, C>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> �Ƚ�����״̬ת���Ƿ���ͬ</summary>
    /// <param name="ATransition">Ŀ��״̬ת��</param>
    /// <returns></returns>
    /// <remarks>Ψһ��ʶ��: [Event, Source, Target]</remarks>
    /// <remarks>Ψһ��ʶ��: [Event, Source, Condition]</remarks>
    function Equal(const ATransition: TTransition<S, E, C>): Boolean;

    /// <summary> ��ȡ��Ӧ��״̬ת������</summary>
    function GetCondition: TCondition<C>;

    /// <summary> ״̬ת�ƺ���</summary>
    function Transit(AContext: C): TState<S, E, C>;

    /// <summary> ������������Լ�����</summary>
    property Source: TState<S, E, C> read FSource write FSource;
    property Target: TState<S, E, C> read FTarget write FTarget;
    property Event: E read FEvent write FEvent;
    property Condition: TCondition<C> read FCondition write FCondition;
    property TransType: TTransitionType read FType write FType;
    property Action: TAction<S, E, C> read FAction write FAction;
  end;

  TEventTransition<S, E; C: class> = class
  strict private
    FEventTransition: TObjectDictionary<E,TObjectList<TTransition<S,E,C>>>;

    /// <summary> ͬһ���¼�, ����״̬֮���״̬ת��ֻ�ܴ���һ��, ���ܴ��ڶ��</summary>
    /// <param name="AList"> һ���¼���Ӧ�����е�״̬ת��</param>
    /// <param name="ATransition"> �µ�Ŀ��״̬ת��</param>
    procedure Verify(AList: TObjectList<TTransition<S, E, C>>; ANewTransition: TTransition<S, E, C>);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> ���һ��״̬ת�ƣ�һ���¼����ܶ�Ӧ����״̬ת��</summary>
    /// <param name="AEvent"> �¼�</param>
    /// <param name="ATransition"> ״̬ת��</param>
    procedure Put(AEvent: E; ANewTransition: TTransition<S, E, C>);

    /// <summary> ���¼�������ʱ�򣬷��ظ��¼����Դ��������е�״̬ת��</summary>
    function Get(AEvent: E): TObjectList<TTransition<S,E,C>>;
  end;

  TTransitionBuilder<S, E; C: class> = class
  public

  end;

  /// <summary>
  ///   ״̬����
  /// </summary>
  TStateMachine<S, E; C: class> = class
  strict private
    FStateMap: TObjectDictionary<S, TState<S, E, C>>;

    /// <summary> ��ȡ��ǰ����<S, E, C>����Ӧ��Transition</summary>
    /// <param name="ASource"> ��ǰ״̬: SourceState</param>
    /// <param name="AEvent"> �������¼�: Event</param>
    /// <param name="AContext"> ������: Context</param>
    /// <returns> ״̬ת��: TTransition</returns>
    /// <remarks> �����ڽ���״̬ת�Ƶ�ʱ�򣬻��������������ж�, ���������ſ��Խ���״̬ת��</remarks>
    function RouteTransition(ASource: S; AEvent: E; AContext: C): TTransition<S, E, C>;

    /// <summary> ��ȡ��Ӧ��״̬</summary>
    /// <remarks> �����Ӧ״̬�����ڣ����׳��쳣</remarks>
    function GetState(AStateId: S): TState<S, E, C>;
  public
    constructor Create(var AStateMap: TObjectDictionary<S, TState<S, E, C>>);
    destructor Destroy; override;

    /// <summary> ״̬���ṩ�Ĵ����¼��Ľӿ�</summary>
    /// <param name="AEvent"> �¼�</param>
    /// <returns> ���ش����¼�����ת�Ƶ�Ŀ��״̬</returns>
    function FireEvent(ASource: S; AEvent: E; AContext: C): S;
  end;

  /// <summary>
  ///   ״̬��������, �ṩ��ؽӿ���������״̬���Ľṹ: ״̬���¼��Լ�״̬ת��!
  /// </summary>
  TStateMachineBuilder<S, E; C: class> = class
  {$REGION '˽����������'}
  strict private type
    StateHeler<S1, E1; C1: class> = class
    public
      /// <summary> ������Ӧ��״̬�����ǲ�����������������</summary>
      /// <remarks> ��StateMap���л�ȡ��Ӧ��״̬�����������ֱ�ӷ���; ��֮�򴴽���Ӧ��״̬</remarks>
      class function getState(var AMap: TObjectDictionary<S1, TState<S1, E1, C1>>; AStateId: S1): TState<S1, E1, C1>;
    end;
  {$ENDREGION}
  strict private
    {
      StateMap�����ǳ�����ض�������ã����������ڽ���״̬�������й���
      Ϊʲô����ΪBuilder�Ĵ���ʱ�������ǱȽ϶̵ģ���״̬����ʼ�մ���!
    }
    FStateMap: TObjectDictionary<S, TState<S, E, C>>;
    FStateMachine: TStateMachine<S, E, C>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>�ⲿ״̬ת�ƽӿ�</summary>
    /// <param name="ASource"> Դ״̬</param>
    /// <param name="ATarget"> Ŀ��״̬</param>
    /// <param name="AEvent"> �������¼�</param>
    /// <param name="ACondition"> ״̬ת�Ƶ�����</param>
    /// <param name="Action"> Ŀ��״̬��Ӧ�Ķ���</param>
    procedure ExternalTransition(ASource: S; ATarget: S; AEvent: E;
      ACondition: TCondition<C>; Action: TAction<S,E,C>);

    /// <summary> ��ȡ������״̬��</summary>
    /// <remarks> �����������������ڣ������û����й���</remarks>
    function Build: TStateMachine<S, E, C>;
  end;

  TStateMachineExecption = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

implementation

uses
  CodeSiteLogging, TypInfo;

{ TStateMachine<S, E, C>.TState<S, E, C> }

function TState<S, E, C>.AddTranstition(AEvent: E;
  ATarget: TState<S, E, C>;
  ATransitionType: TTransitionType): TTransition<S, E, C>;
begin
  Result := TTransition<S, E, C>.Create;
  Result.Source := Self;
  Result.Target := ATarget;
  Result.Event := AEvent;
  Result.TransType := ATransitionType;

  FEventTransition.Put(AEvent, Result);
end;

constructor TState<S, E, C>.Create(AStateId: S);
begin
  FStateId := AStateId;
  FEventTransition := TEventTransition<S, E, C>.Create;
end;

destructor TState<S, E, C>.Destroy;
begin
  FreeAndNil(FEventTransition);
  inherited;
end;

function TState<S, E, C>.GetEventTranstitions(
  AEvent: E): TObjectList<TTransition<S, E, C>>;
begin
  Result := FEventTransition.Get(AEvent);
end;

{ TStateMachine<S, E, C> }

constructor TStateMachine<S, E, C>.Create(var AStateMap: TObjectDictionary<S, TState<S, E, C>>);
begin
  FStateMap := AStateMap;
end;

destructor TStateMachine<S, E, C>.Destroy;
begin
  FreeAndNil(FStateMap);
  inherited;
end;

function TStateMachine<S, E, C>.FireEvent(ASource: S; AEvent: E; AContext: C): S;
var
  LTransition: TTransition<S, E, C>;
begin
  LTransition := RouteTransition(ASource, AEvent, AContext);

  /// �����������Ӧ��״̬ת�ƣ���ά�ֵ�ǰ״̬
  if not Assigned(LTransition) then
  begin
    CodeSite.Send('���¼���δ������ص�״̬ת�ƣ�');
    Exit(ASource);
  end;

  Result := LTransition.Transit(AContext).StateId;
end;

function TStateMachine<S, E, C>.GetState(AStateId: S): TState<S, E, C>;
begin
  if not FStateMap.TryGetValue(AStateId, Result) then
   raise TStateMachineExecption.Create('Error Message');
end;

function TStateMachine<S, E, C>.RouteTransition(ASource: S; AEvent: E;
  AContext: C): TTransition<S, E, C>;
var
  LState: TState<S, E, C>;
  LTransitionList: TObjectList<TTransition<S,E,C>>;
  LTransition: TTransition<S,E,C>;
begin
  LState := GetState(ASource);
  LTransitionList := LState.GetEventTranstitions(AEvent);

  /// ������¼���û�ж�Ӧ��״̬ת�ƣ���ֱ�ӷ���nil
  if (not Assigned(LTransitionList)) or (LTransitionList.Count = 0) then
    Exit(nil);

  /// - �����Ӧ��״̬ת����ǰ����Condition, ������ص�Condition�Ƿ�����״̬ת��;
  /// - �����Ӧ��״̬ת��û������Condition, ��ֱ�ӷ������һ��״̬ת��(һ�������
  ///   �û�û��������Ӧ��״̬ת��������һ���¼�����һ��״̬��ֻ����һ�����״̬)
  for LTransition in LTransitionList do
  begin
    if LTransition.GetCondition = nil then
       Result := LTransition
    else if LTransition.GetCondition.isSatisfied(AContext) then
    begin
      Result := LTransition;
      Exit;
    end;
  end;
end;

{ TStateMachine<S, E, C>.TTransition<S, E, C> }

constructor TTransition<S, E, C>.Create;
begin

end;

destructor TTransition<S, E, C>.Destroy;
begin
  FreeAndNil(FSource);
  FreeAndNil(FTarget);
  FreeAndNil(FCondition);
  FreeAndNil(FAction);
  inherited;
end;


function TTransition<S, E, C>.Equal(
  const ATransition: TTransition<S, E, C>): Boolean;
begin
  Result := (FEvent = ATransition.Event) and
    (FSource.StateId = ATransition.Source.StateId) and
    (FTarget.StateId = ATransition.Target.StateId);
end;

function TTransition<S, E, C>.GetCondition: TCondition<C>;
begin
  Result := FCondition;
end;

function TTransition<S, E, C>.Transit(AContext: C): TState<S, E, C>;
begin
  if (FCondition = nil) or (FCondition.isSatisfied(AContext)) then
  begin
    if Assigned(FAction) then
      FAction.Execute(FSource.StateId, FTarget.StateId, FEvent, AContext);
    Exit(FTarget);
  end;

  CodeSite.Send('״̬ת������û�����㣬���ֵ�ǰ״̬');
  Exit(FSource);
end;

{ TStateMachineBuilder<S, E, C> }

function TStateMachineBuilder<S, E, C>.Build: TStateMachine<S, E, C>;
begin

end;

constructor TStateMachineBuilder<S, E, C>.Create;
begin
  FStateMap := TObjectDictionary<S, TState<S, E, C>>.Create;
  FStateMachine := TStateMachine<S, E, C>.Create(FStateMap);
end;

destructor TStateMachineBuilder<S, E, C>.Destroy;
begin
  {
    StateMap���������ڽ���״̬�������й���״̬������֮�󽻸�ʹ�ã����������ڽ���
    �û����й���!
  }
  inherited;
end;

procedure TStateMachineBuilder<S, E, C>.ExternalTransition(ASource, ATarget: S;
  AEvent: E; ACondition: TCondition<C>; Action: TAction<S, E, C>);
var
  LSource, LTarget: TState<S, E, C>;
  LTransition: TTransition<S, E, C>;
begin
  LSource := StateHeler<S, E, C>.getState(FStateMap, ASource);
  LTarget := StateHeler<S, E, C>.getState(FStateMap, ATarget);
  LTransition := LSource.AddTranstition(AEvent, LTarget, TTransitionType.tpEXTERNAL);
  LTransition.Condition := ACondition;
  LTransition.Action := Action;
end;

{ TEventTransition<S, E, C> }

constructor TEventTransition<S, E, C>.Create;
begin
  FEventTransition := TObjectDictionary<E,TObjectList<TTransition<S,E,C>>>.Create;
end;

destructor TEventTransition<S, E, C>.Destroy;
begin
  FreeAndNil(FEventTransition);
  inherited;
end;

function TEventTransition<S, E, C>.Get(
  AEvent: E): TObjectList<TTransition<S, E, C>>;
begin
  Result := nil;
  if FEventTransition.ContainsKey(AEvent) then
    Result := FEventTransition[AEvent];
end;

procedure TEventTransition<S, E, C>.Put(AEvent: E;
  ANewTransition: TTransition<S, E, C>);
var
  LTransitions: TObjectList<TTransition<S,E,C>>;
begin
  if FEventTransition.TryGetValue(AEvent, LTransitions) then
  begin
    Verify(LTransitions, ANewTransition);
    LTransitions.Add(ANewTransition);
  end
  else
  begin
    LTransitions := TObjectList<TTransition<S,E,C>>.Create;
    LTransitions.Add(ANewTransition);
    FEventTransition.Add(AEvent, LTransitions);
  end;
end;

procedure TEventTransition<S, E, C>.Verify(
  AList: TObjectList<TTransition<S, E, C>>; ANewTransition: TTransition<S, E, C>);
var
  LTransition: TTransition<S, E, C>;
begin
  for LTransition in AList do
  begin
    if LTransition.Equal(ANewTransition) then
      raise TStateMachineExecption.Create('��״̬ת���Ѿ�����!');
  end;
end;

{ TStateMachineExecption }

constructor TStateMachineExecption.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

{ TStateMachineBuilder<S, E, C>.StateHeler<S, E, C> }

class function TStateMachineBuilder<S, E, C>.StateHeler<S1, E1, C1>.getState(
  var AMap: TObjectDictionary<S1, TState<S1, E1, C1>>; AStateId: S1): TState<S1, E1, C1>;
begin
  if not AMap.TryGetValue(AStateId, Result) then
  begin
    Result := TState<S1, E1, C1>.Create(AStateId);
  end;
end;

end.
