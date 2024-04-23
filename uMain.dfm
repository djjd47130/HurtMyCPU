object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Hurt My CPU'
  ClientHeight = 532
  ClientWidth = 664
  Color = clBtnFace
  Constraints.MinHeight = 430
  Constraints.MinWidth = 680
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ShowHint = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblWarning: TLabel
    AlignWithMargins = True
    Left = 30
    Top = 57
    Width = 604
    Height = 63
    Margins.Left = 30
    Margins.Right = 30
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'WARNING: If you spawn more threads than you have CPU cores, you ' +
      'could lock up your PC! You are responsible for any damage as a r' +
      'esult of using this tool. You have been warned!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 8421631
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
    WordWrap = True
    StyleElements = [seClient, seBorder]
    ExplicitTop = 68
    ExplicitWidth = 647
  end
  object Label12: TLabel
    AlignWithMargins = True
    Left = 30
    Top = 5
    Width = 604
    Height = 44
    Margins.Left = 30
    Margins.Top = 5
    Margins.Right = 30
    Margins.Bottom = 5
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Stress-test your processor by spawning multiple threads which ea' +
      'ch do heavy amounts of work with no delay.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
    WordWrap = True
    ExplicitWidth = 598
  end
  object lstThreads: TListView
    AlignWithMargins = True
    Left = 3
    Top = 208
    Width = 658
    Height = 302
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Thread ID'
        Width = 100
      end
      item
        Caption = 'Current'
        Width = 135
      end
      item
        Caption = 'Total'
        Width = 135
      end
      item
        Caption = 'Progress'
        Width = 250
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawSubItem = lstThreadsCustomDrawSubItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 123
    Width = 664
    Height = 29
    Align = alTop
    BevelEdges = [beTop, beBottom]
    BevelOuter = bvSpace
    TabOrder = 1
    object Label1: TLabel
      AlignWithMargins = True
      Left = 258
      Top = 4
      Width = 60
      Height = 21
      Align = alLeft
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Count To:'
      Layout = tlCenter
      ExplicitLeft = 241
      ExplicitTop = 3
      ExplicitHeight = 27
    end
    object btnSpawn: TBitBtn
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 121
      Height = 21
      Cursor = crHandPoint
      Action = actSpawnThread
      Align = alLeft
      Caption = 'Spawn a Thread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421631
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      StyleElements = [seClient, seBorder]
      ExplicitLeft = 3
      ExplicitTop = 3
      ExplicitHeight = 27
    end
    object btnStop: TBitBtn
      AlignWithMargins = True
      Left = 131
      Top = 4
      Width = 121
      Height = 21
      Cursor = crHandPoint
      Action = actStopThreads
      Align = alLeft
      Caption = 'Stop All Threads'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421631
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      StyleElements = [seClient, seBorder]
      ExplicitTop = 3
    end
    object txtCountTo: TEdit
      AlignWithMargins = True
      Left = 324
      Top = 4
      Width = 117
      Height = 21
      Hint = 'Specifies the number to count up to (Default = Max Int64)'
      Align = alLeft
      TabOrder = 2
      Text = '2147483647'
    end
  end
  object Stat: TStatusBar
    Left = 0
    Top = 513
    Width = 664
    Height = 19
    Panels = <
      item
        Text = 'Created by Jerry Dodge - https://jerryszone.com'
        Width = 50
      end>
    ExplicitTop = 435
    ExplicitWidth = 860
  end
  object Tmr: TTimer
    Interval = 250
    OnTimer = TmrTimer
    Left = 16
    Top = 160
  end
  object Acts: TActionList
    Left = 64
    Top = 160
    object actSpawnThread: TAction
      Caption = 'Spawn a Thread'
      Hint = 'Create a new thread which will consume CPU resources'
      ShortCut = 120
      OnExecute = btnSpawnClick
    end
    object actStopThreads: TAction
      Caption = 'Stop All Threads'
      Hint = 'Terminate all currently active threads'
      ShortCut = 119
      OnExecute = btnStopClick
    end
  end
end
