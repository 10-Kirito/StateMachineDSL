program StateMachineDemo;

uses
  Vcl.Forms,
  Examples in 'Examples.pas' {Demo},
  StateMachine in '..\sources\StateMachine.pas',
  StateEventExamples in 'StateEventExamples.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDemo, Demo);
  Application.Run;
end.
