unit Examples;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, StateMachine;

type
  Events = (evtStart, evtStop, evtResume, evtPause);

  States = (stIdle, stRunning, stPaused, stStopped);

  TDemo = class(TForm)
    shpIdle: TShape;
    shpStopped: TShape;
    shpRunning: TShape;
    shpPaused: TShape;
    lblStart: TLabel;
    lblRunning: TLabel;
    lblPaused: TLabel;
    lblStopped: TLabel;
    btnEvStart: TButton;
    grpEvents: TGroupBox;
    btnPause: TButton;
    btnResume: TButton;
    btnEvStop: TButton;
    grpStatus: TGroupBox;
    procedure FormDestroy(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnEvStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnEvStartClick(Sender: TObject);
  private
    FSMBuilder: TStateMachineBuilder<States, Events>;
    FStateMachine: TStateMachine<States, Events>;

    function Condition: Boolean;

    /// <summary> ����Ӧ��״̬���������ò�������һ����Ӧ��״̬�� </summary>
    procedure InitialStateMachine;
  public
    { Public declarations }
  end;

var
  Demo: TDemo;

implementation

{$R *.dfm}

procedure TDemo.btnEvStartClick(Sender: TObject);
begin
  Assert(FStateMachine.FireEvent(stIdle, evtStart) = stRunning, '״̬[stIdle -> stStart]ʧ��');
end;

procedure TDemo.btnEvStopClick(Sender: TObject);
begin
  Assert(FStateMachine.FireEvent(stRunning, evtStop) = stStopped, '״̬[stRunning -> stStopped]ʧ��');
end;

procedure TDemo.btnPauseClick(Sender: TObject);
begin
  Assert(FStateMachine.FireEvent(stRunning, evtPause) = stPaused, '״̬[stRunning -> stPaused]ʧ��');
end;

procedure TDemo.btnResumeClick(Sender: TObject);
begin
  Assert(FStateMachine.FireEvent(stPaused, evtResume) = stRunning, '״̬[stPaused -> stRunning]ʧ��');
end;

function TDemo.Condition: Boolean;
begin
  Result := True;
end;

procedure TDemo.FormCreate(Sender: TObject);
begin
  InitialStateMachine;
end;

procedure TDemo.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSMBuilder);
  FreeAndNil(FStateMachine);
end;

procedure TDemo.InitialStateMachine;
begin
  FSMBuilder := TStateMachineBuilder<States, Events>.Create;

  /// ����״̬��
  FSMBuilder.ExternalTransition(States.stIdle, States.stRunning, Events.evtStart, Condition,
    function: Boolean
    begin
      shpIdle.Brush.Color := clWhite;
      shpRunning.Brush.Color := clRed;
      Result := True;
    end);
  FSMBuilder.ExternalTransition(States.stRunning, States.stPaused, Events.evtPause, Condition,
    function: Boolean
    begin
      shpRunning.Brush.Color := clWhite;
      shpPaused.Brush.Color := clRed;
      Result := True;
    end);
  FSMBuilder.ExternalTransition(States.stPaused, States.stRunning, Events.evtResume, Condition,
    function: Boolean
    begin
      shpPaused.Brush.Color := clWhite;
      shpRunning.Brush.Color := clRed;
      Result := True;
    end);
  FSMBuilder.ExternalTransition(States.stRunning, States.stStopped, Events.evtStop, Condition,
    function: Boolean
    begin
      shpRunning.Brush.Color := clWhite;
      shpStopped.Brush.Color := clRed;
      Result := True;
    end);

  /// ����״̬��
  FStateMachine := FSMBuilder.Build;
end;

end.

