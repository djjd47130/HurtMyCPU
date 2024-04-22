unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls,
  System.SyncObjs, System.Generics.Collections,
  HurtMyCpuThread,
  CpuMonitor, System.Actions, Vcl.ActnList;

type
  TfrmMain = class(TForm)
    lblWarning: TLabel;
    Label12: TLabel;
    lstThreads: TListView;
    Panel1: TPanel;
    Label1: TLabel;
    btnSpawn: TBitBtn;
    btnStop: TBitBtn;
    txtCountTo: TEdit;
    Tmr: TTimer;
    Stat: TStatusBar;
    Acts: TActionList;
    actSpawnThread: TAction;
    actStopThreads: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSpawnClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure TmrTimer(Sender: TObject);
    procedure lstThreadsCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FLock: TCriticalSection;
    FThreads: TObjectList<THurtMyCpuThread>;
    FTerminated: Boolean;
    procedure DoSpawn(const CountTo: Integer);
  public
    procedure AddRef(ARef: THurtMyCpuThread);
    procedure DeleteRef(ARef: THurtMyCpuThread);
    procedure UpdateRef(ARef: THurtMyCpuThread);
    function IsTerminated: Boolean;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function ListViewCellRect(AListView: TCustomListView; AColIndex: Integer;
  AItemIndex: Integer): TRect;
var
  I: Integer;
begin
  Result:= AListView.Items[AItemIndex].DisplayRect(TDisplayCode.drBounds);
  for I:= 0 to AColIndex-1 do
    Result.Left := Result.Left + AListView.Column[I].Width;
  Result.Width:= AListView.Column[AColIndex].Width;
end;

procedure DrawProgressBar(const ACanvas: TCanvas; const ARect: TRect;
  const APercent: Single;
  const ABackColor: TColor = clGray; const AForeColor: TColor = clNavy;
  const AText: String = '');
const
  DRAW_FLAGS = DT_SINGLELINE or DT_CENTER or DT_VCENTER;
var
  BR, FR, TR: TRect;
  S: String;
begin
  //Draw background
  BR:= ARect;
  InflateRect(BR, -2, -2);
  ACanvas.Pen.Width:= 1;
  ACanvas.Pen.Style:= psSolid;
  ACanvas.Pen.Color:= AForeColor;
  ACanvas.Brush.Style:= bsSolid;
  ACanvas.Brush.Color:= ABackColor;
  ACanvas.Rectangle(BR);

  //Draw foreground
  FR:= BR;
  InflateRect(FR, -1, -1);
  FR.Width:= Trunc(FR.Width * APercent);
  ACanvas.Pen.Style:= psClear;
  ACanvas.Brush.Color:= AForeColor;
  ACanvas.FillRect(FR);

  //Draw text
  TR:= BR;
  ACanvas.Font.Color:= clWhite;
  ACanvas.Font.Style:= [fsBold];
  ACanvas.Font.Height:= ARect.Height - 6;
  ACanvas.Pen.Style:= psClear;
  ACanvas.Brush.Style:= bsClear;
  if AText = '' then
    S:= FormatFloat('0%', APercent * 100)
  else
    S:= AText;
  DrawText(ACanvas.Handle, PChar(S), Length(S), TR, DRAW_FLAGS);

end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= True;
  {$ENDIF}
  lblWarning.Caption:= 'WARNING: If you spawn more threads than you have CPU cores ('+IntToStr(System.CPUCount)+'), you could lock up your PC! You are responsible for any damage as a result of using this tool. You have been warned!';
  lstThreads.Align:= alClient;
  FLock:= TCriticalSection.Create;
  FThreads:= TObjectList<THurtMyCpuThread>.Create(False);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FThreads);
  FreeAndNil(FLock);
end;

function TfrmMain.IsTerminated: Boolean;
begin
  Result:= FTerminated;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  btnStopClick(nil);
  FTerminated:= True;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  btnStopClick(nil);
end;

procedure TfrmMain.lstThreadsCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  Perc: Single;
  R: TRect;
  T: THurtMyCpuThread;
begin
  if (SubItem = 3) then begin
    DefaultDraw:= False;
    FLock.Enter;
    try
      T:= FThreads[Item.Index];
      T.Lock;
      try
        Perc:= T.Cur / T.CountTo;
      finally
        T.Unlock;
      end;
    finally
      FLock.Leave;
    end;
    R:= ListViewCellRect(Sender, SubItem, Item.Index);
    DrawProgressBar(Sender.Canvas, R, Perc);
    SetBkMode(Sender.Canvas.Handle, TRANSPARENT); // <- will effect the next [sub]item
  end else begin
    DefaultDraw:= True;
  end;
end;

procedure TfrmMain.btnSpawnClick(Sender: TObject);
var
  I: Int64;
begin
  I:= StrToIntDef(txtCountTo.Text, 0);
  if (I > 0) and (I <= 2147483647) then
    DoSpawn(I)
  else
    raise Exception.Create('Invalid input for "Count To".');
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
var
  X: Integer;
begin
  FLock.Enter;
  try
    for X := FThreads.Count-1 downto 0 do begin
      FThreads[X].Terminate;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TfrmMain.TmrTimer(Sender: TObject);
var
  I: TListItem;
  X: Integer;
  T: THurtMyCpuThread;
begin
  //We do all UI updates inside of a timer, rather than at the moment
  //  of receiving events from the threads. This is because when events
  //  are received, the calling worker thread is temporarily blocked until
  //  the synchronized event is done and returns. Instead, all we do in
  //  those events is capture the information in a variable, then later
  //  use it in the timer to update controls in the UI (which is heavier).

  //We also grab information about the current CPU usage, and update
  //  a progress bar to reflect the current load.

  try

    FLock.Enter;
    try

      //Ensure count matches
      while lstThreads.Items.Count <> FThreads.Count do begin
        if lstThreads.Items.Count < FThreads.Count then begin
          //Add a new list item...
          I:= lstThreads.Items.Add;
          I.SubItems.Add('');
          I.SubItems.Add('');
          I.SubItems.Add('');
        end else begin
          //Delete a list item
          if lstThreads.Items.Count > 0 then
            lstThreads.Items.Delete(0);
        end;
      end;

      //Update list items to match objects...
      for X := 0 to FThreads.Count-1 do begin
        T:= FThreads[X];
        I:= lstThreads.Items[X];
        T.Lock;
        try
          I.Caption:= IntToStr(T.ThreadID);
          I.SubItems[0]:= IntToStr(T.Cur);
          I.SubItems[1]:= IntToStr(T.CountTo);
          //I.SubItems[2]:= FormatFloat('0.000%', (T.Cur / T.CountTo) * 100);
          I.Update;
        finally
          T.Unlock;
        end;
      end;

    finally
      FLock.Leave;
    end;

  except
    on E: Exception do begin
      //TODO: Add to a log...
    end;
  end;

end;

procedure TfrmMain.AddRef(ARef: THurtMyCpuThread);
begin
  FLock.Enter;
  try
    ARef.Lock;
    try
      FThreads.Add(ARef);
    finally
      ARef.Unlock;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TfrmMain.DeleteRef(ARef: THurtMyCpuThread);
begin
  FLock.Enter;
  try
    ARef.Lock;
    try
      FThreads.Delete(FThreads.IndexOf(ARef));
    finally
      ARef.Unlock;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TfrmMain.UpdateRef(ARef: THurtMyCpuThread);
begin
  FLock.Enter;
  try

  finally
    FLock.Leave;
  end;
end;

procedure TfrmMain.DoSpawn(const CountTo: Integer);
var
  T: THurtMyCpuThread;
begin
  //Creates an instance of a thread which consumes 100% of a single CPU core/thread.
  T:= THurtMyCpuThread.Create(CountTo);
  T.OnAddRef:= AddRef;
  T.OnDeleteRef:= DeleteRef;
  T.Start;
end;

end.
