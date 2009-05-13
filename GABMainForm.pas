unit GABMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ToolWin, dxmdaset, DB;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Settings1: TMenuItem;
    Help1: TMenuItem;
    NewList1: TMenuItem;
    ToolBar1: TToolBar;
    pgcMain: TPageControl;
    TabSheet1: TTabSheet;
    dxMemData1: TdxMemData;
    procedure File1Click(Sender: TObject);
    procedure NewList1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.File1Click(Sender: TObject);
begin
//
end;

procedure TfrmMain.NewList1Click(Sender: TObject);
begin
//
end;

end.
