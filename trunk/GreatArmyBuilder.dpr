program GreatArmyBuilder;

uses
  Forms,
  GABMainForm in 'GABMainForm.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
