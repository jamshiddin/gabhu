program GABEdit;

uses
  Forms,
  GABEditMainForm in 'GABEditMainForm.pas' {nxForm1: TnxForm};

{$R *.RES}

BEGIN
  Application.Initialize;
  Application.CreateForm(TnxForm1, nxForm1);
  Application.Run;
END.