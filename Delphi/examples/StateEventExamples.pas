unit StateEventExamples;

interface

uses
  StateMachine;

type
  Events = (evtStart, evtStop, evtResume, evtPause);

  States = (stIdle, stRunning, stPaused, stStopped);

  /// <summary>
  ///   使用者自定义的上下文
  /// </summary>
  TCustomContext = class
  strict private
    FContext: string;
  public
    constructor Create(AContext: string);
    property Context: string read FContext;
  end;

  /// <summary>
  ///   使用者自定义的状态转移条件
  /// </summary>
  TCustomCondition<T: class> = class(TCondition<T>)
  public
    function isSatisfied(AContext: T): Boolean; override;
  end;

  TCustomAction<S, E; C: class> = class(TAction<S, E, C>)
  public
    procedure Execute(AFrom: S; ATo: S; AEvent: E; AContext: C); override;
  end;

implementation

{ TContext }

constructor TCustomContext.Create(AContext: string);
begin
  FContext := AContext;
end;

{ TCustomCondition<T> }

function TCustomCondition<T>.isSatisfied(AContext: T): Boolean;
begin

end;

{ TCustomAction<S, E, C> }

procedure TCustomAction<S, E, C>.Execute(AFrom, ATo: S; AEvent: E; AContext: C);
begin
  inherited;

end;

end.
