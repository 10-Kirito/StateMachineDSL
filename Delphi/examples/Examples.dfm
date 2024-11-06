object Demo: TDemo
  Left = 0
  Top = 0
  Caption = 'Demo'
  ClientHeight = 598
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object btnBegin: TButton
    Left = 8
    Top = 8
    Width = 113
    Height = 49
    Caption = #21551#21160#29366#24577#26426
    TabOrder = 0
  end
  object btnStop: TButton
    Left = 144
    Top = 8
    Width = 113
    Height = 49
    Caption = #20572#27490' '
    TabOrder = 1
  end
  object grpEvents: TGroupBox
    Left = 8
    Top = 120
    Width = 249
    Height = 137
    Caption = 'Events'
    TabOrder = 2
    object btnEvStart: TButton
      Left = 11
      Top = 24
      Width = 102
      Height = 33
      Caption = 'Start'
      TabOrder = 0
    end
    object btnPause: TButton
      Left = 11
      Top = 80
      Width = 102
      Height = 33
      Caption = 'Pause'
      TabOrder = 1
    end
    object btnResume: TButton
      Left = 136
      Top = 24
      Width = 102
      Height = 33
      Caption = 'Resume'
      TabOrder = 2
    end
    object btnEvStop: TButton
      Left = 136
      Top = 80
      Width = 102
      Height = 33
      Caption = 'Stop'
      TabOrder = 3
    end
  end
  object grpStatus: TGroupBox
    Left = 8
    Top = 288
    Width = 249
    Height = 297
    Caption = 'Status'
    TabOrder = 3
    object lblPaused: TLabel
      Left = 16
      Top = 249
      Width = 61
      Height = 28
      Caption = 'Paused'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblRunning: TLabel
      Left = 160
      Top = 121
      Width = 73
      Height = 28
      Caption = 'Running'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblStart: TLabel
      Left = 36
      Top = 117
      Width = 33
      Height = 28
      Caption = 'Idle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblStopped: TLabel
      Left = 158
      Top = 247
      Width = 75
      Height = 28
      Caption = 'Stopped'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object shpEnd: TShape
      Left = 160
      Top = 176
      Width = 65
      Height = 65
      Pen.Color = clMedGray
      Pen.Width = 2
      Shape = stCircle
    end
    object shpRunning: TShape
      Left = 160
      Top = 50
      Width = 65
      Height = 65
      Pen.Color = clMedGray
      Pen.Width = 2
      Shape = stCircle
    end
    object shpStart: TShape
      Left = 16
      Top = 50
      Width = 65
      Height = 65
      HelpType = htKeyword
      Pen.Color = clMedGray
      Pen.Width = 2
      Shape = stCircle
    end
    object shpStop: TShape
      Left = 16
      Top = 178
      Width = 65
      Height = 65
      Pen.Color = clMedGray
      Pen.Width = 2
      Shape = stCircle
    end
  end
end
