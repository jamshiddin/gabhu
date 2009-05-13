object frmMain: TfrmMain
  Left = 433
  Top = 274
  Width = 603
  Height = 323
  Caption = 'frmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 595
    Height = 29
    BorderWidth = 1
    Caption = 'ToolBar1'
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    TabOrder = 0
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 29
    Width = 595
    Height = 248
    ActivePage = TabSheet1
    Align = alClient
    TabIndex = 0
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
    end
  end
  object MainMenu1: TMainMenu
    Left = 520
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      OnClick = File1Click
    end
    object Settings1: TMenuItem
      Caption = 'Lists'
      object NewList1: TMenuItem
        Caption = 'New List'
        OnClick = NewList1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
    end
  end
  object dxMemData1: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 488
    Top = 8
  end
end
