unit Examples;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, StateMachine, StateEventExamples;

type
  TDemo = class(TForm)
    shpStart: TShape;
    shpEnd: TShape;
    shpRunning: TShape;
    shpStop: TShape;
    btnBegin: TButton;
    btnStop: TButton;
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
    procedure FormCreate(Sender: TObject);
  private
    FSMBuilder: TStateMachineBuilder<States, Events, TCustomContext>;
    FStateMachine: TStateMachine<States, Events, TCustomContext>;

    /// <summary> ����Ӧ��״̬���������ò�������һ����Ӧ��״̬�� </summary>
    procedure InitialStateMachine;
  public
    { Public declarations }
  end;

var
  Demo: TDemo;

implementation

{$R *.dfm}

procedure TDemo.FormCreate(Sender: TObject);
begin
  FSMBuilder := TStateMachineBuilder<States, Events, TCustomContext>.Create;

  /// ����״̬��
  FSMBuilder.ExternalTransition(States.stIdle, States.stRunning, Events.evtStart, nil, nil);
  FSMBuilder.ExternalTransition(States.stRunning, States.stPaused, Events.evtPause, nil, nil);
  FSMBuilder.ExternalTransition(States.stPaused, States.stRunning, Events.evtResume, nil, nil);
  FSMBuilder.ExternalTransition(States.stRunning, States.stStopped, Events.evtStop, nil, nil);

  /// ����״̬��
  FStateMachine := FSMBuilder.Build;
end;

procedure TDemo.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSMBuilder);
  FreeAndNil(FStateMachine);
end;

procedure TDemo.InitialStateMachine;
begin


end;

end.
