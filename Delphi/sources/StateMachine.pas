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
    /// <summary> ��ȡ��Ӧ��״̬ת������</summary>
    function GetCondition: TCondition;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> �Ƚ�����״̬ת���Ƿ���ͬ</summary>
    /// <param name="ATransition">Ŀ��״̬ת��</param>
    /// <returns></returns>
    /// <remarks>Ψһ��ʶ��: [Event, Source, Target]</remarks>
    function Equal(const ATransition: TTransition<S, E>): Boolean;

    /// <summary> ״̬ת�ƺ���</summary>
    function Transit: TState<S, E>;

    /// <summary> ������������Լ�����</summary>
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

    /// <summary> ͬһ���¼�, ����״̬֮���״̬ת��ֻ�ܴ���һ��, ���ܴ��ڶ��</summary>
    /// <param name="AList"> һ���¼���Ӧ�����е�״̬ת��</param>
    /// <param name="ATransition"> �µ�Ŀ��״̬ת��</param>
    procedure Verify(AList: TObjectList<TTransition<S, E>>; ANewTransition: TTransition<S, E>);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary> ���һ��״̬ת�ƣ�һ���¼����ܶ�Ӧ����״̬ת��</summary>
    /// <param name="AEvent"> �¼�</param>
    /// <param name="ATransition"> ״̬ת��</param>
    procedure Put(AEvent: E; ANewTransition: TTransition<S, E>);

    /// <summary> ���¼�������ʱ�򣬷��ظ��¼����Դ��������е�״̬ת��</summary>
    function Get(AEvent: E): TObjectList<TTransition<S,E>>;
  end;

  TTransitionBuilder<S, E> = class
  public

  end;

  /// <summary>
  ///   ״̬����
  /// </summary>
  TStateMachine<S, E> = class
  strict private
    FStateMap: TObjectDictionary<S, TState<S, E>>;

    /// <summary> ��ȡ��ǰ����<S, E>����Ӧ��Transition</summary>
    /// <param name="ASource"> ��ǰ״̬: SourceState</param>
    /// <param name="AEvent"> �������¼�: Event</param>
    /// <returns> ״̬ת��: TTransition</returns>
    /// <remarks> �����ڽ���״̬ת�Ƶ�ʱ�򣬻��������������ж�, ���������ſ��Խ���״̬ת��</remarks>
    function RouteTransition(ASource: S; AEvent: E): TTransition<S, E>;

    /// <summary> ��ȡ��Ӧ��״̬</summary>
    /// <remarks> �����Ӧ״̬�����ڣ����׳��쳣</remarks>
    function GetState(AStateId: S): TState<S, E>;
  public
    constructor Create(var AStateMap: TObjectDictionary<S, TState<S, E>>);
    destructor Destroy; override;

    /// <summary> ״̬���ṩ�Ĵ����¼��Ľӿ�</summary>
    /// <param name="AEvent"> �¼�</param>
    /// <returns> ���ش����¼�����ת�Ƶ�Ŀ��״̬</returns>
    function FireEvent(ASource: S; AEvent: E): S;
  end;

  /// <summary>
  ///   ״̬��������, �ṩ��ؽӿ���������״̬���Ľṹ: ״̬���¼��Լ�״̬ת��!
  /// </summary>
  TStateMachineBuilder<S, E> = class
  {$REGION '˽����������'}
  strict private type
    StateHeler<S1, E1> = class
    public
      /// <summary> ������Ӧ��״̬�����ǲ�����������������</summary>
      /// <remarks> ��StateMap���л�ȡ��Ӧ��״̬�����������ֱ�ӷ���; ��֮�򴴽���Ӧ��״̬</remarks>
      class function getState(var AMap: TObjectDictionary<S1, TState<S1, E1>>; AStateId: S1): TState<S1, E1>;
    end;
  {$ENDREGION}
  strict private
    {
      StateMap�����ǳ�����ض�������ã����������ڽ���״̬�������й���
      Ϊʲô����ΪBuilder�Ĵ���ʱ�������ǱȽ϶̵ģ���״̬����ʼ�մ���!
    }
    FStateMap: TObjectDictionary<S, TState<S, E>>;
    FStateMachine: TStateMachine<S, E>;
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
      ACondition: TCondition; Action: TAction);

    /// <summary> ��ȡ������״̬��</summary>
    /// <remarks> �����������������ڣ������û����й���</remarks>
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

  /// �����������Ӧ��״̬ת�ƣ���ά�ֵ�ǰ״̬
  if not Assigned(LTransition) then
  begin
    CodeSite.Send('���¼���δ������ص�״̬ת�ƣ�');
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

  CodeSite.Send('״̬ת������û�����㣬���ֵ�ǰ״̬');
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
    StateMap���������ڽ���״̬�������й���״̬������֮�󽻸�ʹ�ã����������ڽ���
    �û����й���!
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
      raise TStateMachineExecption.Create('��״̬ת���Ѿ�����!');
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
