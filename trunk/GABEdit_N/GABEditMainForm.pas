unit GABEditMainForm;

INTERFACE

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  nxForm, dxLayoutControl, cxControls, dxCntner, dxEditor, dxExEdtr,
  dxEdLib, dxDBELib, nxStyleController, DB, dxmdaset, nxADO, dxDBEdtr,
  dxTL, dxDBCtrl, dxDBGrid, nxButton;

type
  TnxForm1 = class(TnxForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    nxStyleCtrlList: TnxStyleControllerList;
    NxnStyle: TnxFlatStyleController;
    BackgroundStyle: TnxFlatStyleController;
    ButtonsStyle: TnxFlatStyleController;
    NavigatorStyle: TnxWebStyleController;
    CaptionEditor: TnxWebStyleController;
    CaptionGrid: TnxWebStyleController;
    TitleStyle: TnxWebStyleController;
    dsrcGame: TnxDataSource;
    mdGame: TdxMemData;
    mdGameName: TStringField;
    mdGameAID: TIntegerField;
    dbgSubArmu: TdxDBGrid;
    dxLayoutControl1Item5: TdxLayoutItem;
    dbgSubArmuColumn1: TdxDBGridColumn;
    dbgSubArmuColumn2: TdxDBGridColumn;
    dbgSubArmuColumn3: TdxDBGridColumn;
    dxLayoutControl1Item1: TdxLayoutItem;
    dbgArmy: TdxDBGrid;
    dxDBGridColumn1: TdxDBGridColumn;
    dxDBGridColumn2: TdxDBGridColumn;
    dxDBGridColumn3: TdxDBGridColumn;
    dxLayoutControl1Item2: TdxLayoutItem;
    dbgGame: TdxDBGrid;
    dxDBGridColumn4: TdxDBGridColumn;
    dxDBGridColumn5: TdxDBGridColumn;
    dxDBGridColumn6: TdxDBGridColumn;
    dsrcArmy: TnxDataSource;
    mdArmy: TdxMemData;
    StringField1: TStringField;
    IntegerField1: TIntegerField;
    dsrcSubArmy: TnxDataSource;
    mdSubArmy: TdxMemData;
    StringField2: TStringField;
    IntegerField2: TIntegerField;
    mdArmyGID: TIntegerField;
    mdSubArmyAID: TIntegerField;
    nxButton1: TnxButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    procedure nxButton1Click(Sender: TObject);
  end;

var
  nxForm1 :TnxForm1;

IMPLEMENTATION

{$R *.DFM}

procedure TnxForm1.nxButton1Click(Sender: TObject);
begin
//
end;

END.
