program HurtMyCPU;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  CpuMonitor in 'CpuMonitor.pas',
  HurtMyCpuThread in 'HurtMyCpuThread.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.Title := 'Hurt My CPU';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
