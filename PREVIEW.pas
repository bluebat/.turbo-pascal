{~p9d0g1l2x5w1z1;}
{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
program Preview;
uses dos, crt;
type
  String3 = string[3];
  SideType = (Long, Wide);
  SideTypeInt = array[SideType] of word;
  SideTypeSideInt = array[SideType] of SideTypeInt;
const
  Esc = #27;
  EscT24 = Esc + 'T24,';
  MaxDot = 360;
  Max : SideTypeInt = (375,640);
  BoxSize : SideTypeSideInt = ((320,340),(256,590));
  SideBase : SideTypeSideInt = ((30,270),(95,25));
  ShowSite : array[1..7,SideType] of string[8]
           = ((('25,50'),('30,30')),(('25,90;縱'),('30,60;橫')),
              (('25,130'),('495,30')),(('25,170'),('495,60')),
              (('25,210'),('248,60')), (('25,250'),('232,30')),
              (('25,310'),('470,0')));
  CursorXY : SideTypeSideInt = ((16,23),(6,51));
  PageNum : byte = 1;
  LineNum : word = 0;
var
  F : text;
  Buf : array[0..4095] of char;
  FormStr : string[2];
  Side : SideType;
  Paper, Margin, Dot : SideTypeInt;
  PaperToBox : array[SideType] of real;
  UpXY, DownXY : array[SideType] of word;
  OutOfRight, Escape : boolean;

procedure Test_System;
var
  Regs : registers;
begin
  Regs.ax := $9100;
  intr($10,Regs);
  if Regs.ax = $9100 then
  begin
    writeln(#7,'Chinese System must be load first !!');
    halt
  end;
  Regs.ax := $804E;
  intr($10,Regs);
  Regs.ax := $8046;
  intr($10,Regs);
  Regs.ax := $8066;
  intr($10,Regs);
  directvideo := false;
  clrscr;
end;

procedure Input_Paper_Mode;
type
  String40 = string[40];
const
  FindFile : boolean = true;
var
  I : integer;
  FileName : String40;
  EntryWay : string[1];

  function AskString(X,Y:byte; Prompt:String40; PreSet:String3):String3;
  var
    Dumb : String3;
  begin
    gotoxy(X,Y);
    write(Prompt,'(',PreSet,') ');
    clreol;
    X := wherex;
    readln(Dumb);
    if Dumb = '' then Dumb := PreSet;
    Dumb[1] := upcase(Dumb[1]);
    gotoxy(X,Y);
    write(Dumb);
    AskString := Dumb
  end;

begin
  write(EscT24,'100,20,24,2,S;列印預視',EscT24,'101,21,24,2,X;列印預視');
  write(Esc,'FK;',EscT24,'450,48,2,1/1,S;Wilhelm Chao',Esc,'FM;');
  write(Esc,'T16;');
  getdir(0,FileName);
  gotoxy(10,8);
  write('目 前 所 在 路 徑 ： ' + FileName);
  repeat
    if not FindFile then write(#7);
    gotoxy(10,10);
    write('文 書 檔 名 ( 逕 按 Enter 即 結 束 ) ： ');
    clreol;
    if (paramcount > 0) and FindFile then
    begin
      FileName := paramstr(1);
      write(FileName)
    end
    else readln(FileName);
    assign(F,FileName);
    settextbuf(F,Buf);
    {$I-}reset(F);{$I+}
    FindFile := ioresult = 0
  until FindFile;
  if FileName = '' then
  begin
    write(Esc,'CL;');
    halt
  end;
  repeat
    FormStr := AskString(10,12,'列 印 紙 張 規 格 [ A0..C9 ] : ','A4')
  until (FormStr[1] in ['A'..'C']) and (FormStr[2] in ['0'..'9']);
  repeat
    EntryWay := AskString(10,14,'進 紙 方 向 [ L = 直 ] [ W = 橫 ] : ' ,'L')
  until EntryWay[1] in ['L','W'];
  Side := SideType(EntryWay = 'W');
  gotoxy(10,17);
  write('請 以 印 表 機 上 的 欄 位 數 回 答 下 面 二 個 問 題 !');
  repeat val(AskString(10,19,'紙 張 左 側 預 留 : ','4'),Margin[Wide],I) until I = 0;
  repeat val(AskString(10,21,'紙 張 頂 端 預 留 : ','4'),Margin[Long],I) until I = 0;
  clrscr;
  write(EscT24,'590,0,0,1;水平');
  write(EscT24,'0,0,0,1;',FileName);
  write(EscT24,ShowSite[1,Side],';紙張規格：',FormStr);
  write(EscT24,ShowSite[2,Side],'向進紙');
  write(EscT24,ShowSite[3,Side],';左邊界：',Margin[Wide]);
  write(EscT24,ShowSite[4,Side],';頂邊界：',Margin[Long]);
  write(EscT24,ShowSite[5,Side],';按 Esc 結束');
  write(EscT24,ShowSite[6,Side],';共 ',LineNum:3,' 行 ',PageNum,' 頁');
  Margin[Wide] := Margin[Wide] * MaxDot div 10;
  Margin[Long] := Margin[Long] * MaxDot div 10
end;

procedure DrawBox;
begin
  write(Esc,'L',UpXY[Wide],',',UpXY[Long],',',DownXY[Wide],',',DownXY[Long],',0,BF;');
  write(Esc,'L',UpXY[Wide],',',UpXY[Long],',',DownXY[Wide],',',DownXY[Long],',B;')
end;

procedure Set_Paper;
const
  ZeroForm : array['A'..'C'] of SideTypeInt
           = ((16855,11918),(20044,14173),(15113,10864));
var
  S : SideType;
  I : integer;
  PaperNum : byte;

  function FormSize(PT : char; PN : byte; ST : SideType) : word;
  begin
    if PN = 0 then FormSize := ZeroForm[PT,ST]
    else FormSize := FormSize(PT,pred(PN),SideType(1 - ord(ST))) shr ord(ST)
  end;

begin
  val(FormStr[2],PaperNum,I);
  for S := Long to Wide do
  begin
    UpXY[S] := SideBase[Side,S];
    DownXY[S] := BoxSize[Side,S] + SideBase[Side,S];
    Paper[S] := FormSize(FormStr[1],PaperNum,SideType(abs(ord(S) - ord(Side))));
    PaperToBox[S] := BoxSize[Side,S] / Paper[S];
    Dot[S] := Margin[S]
  end;
  if Side = Long then
    write(Esc,'L',UpXY[Wide]-10,',',(UpXY[Long]+DownXY[Long]) shr 1,',',
                DownXY[Wide]+10,',',(UpXY[Long]+DownXY[Long]) shr 1,';')
  else
    write(Esc,'L',(UpXY[Wide]+DownXY[Wide]) shr 1,',',UpXY[Long]-5,',',
                  (UpXY[Wide]+DownXY[Wide]) shr 1,',',DownXY[Long]+5,';');
  DrawBox
end;

procedure Character_Work;
type
  ComType = (I,P,T,D,W,Z,X,L);
  ComTypeByte = array[ComType] of byte;
  String4 = string[4];
const
  Density : array[7..8,0..4] of SideTypeInt
          = (((60,60),(60,120),(60,120),(60,240),(60,80)),
             ((180,180),(180,120),(180,90),(180,60),(180,360)));
  PreComNum : ComTypeByte = (0,7,24,0,1,1,12,6);
var
  OldDot, CharSize : SideTypeInt;
  DotRatio : array[SideType] of byte;
  Ch, LastChar : char;
  InChinese, OutOfLine, HighChange, PageChange : boolean;
  ComNum : ComTypeByte;
  CharNum, BetweenX : byte;

  procedure SetCharSize;
  var
    NewCharLong : word;
  begin
    DotRatio[Long] := MaxDot div Density[ComNum[P],ComNum[D]][Long];
    DotRatio[Wide] := MaxDot div Density[ComNum[P],ComNum[D]][Wide];
    NewCharLong := ComNum[T] * ComNum[Z] * DotRatio[Long];
    HighChange := (CharSize[Long] <> NewCharLong) and (OldDot[Long] < Dot[Long]);
    CharSize[Long] := NewCharLong;
    CharSize[Wide] := ComNum[T] * ComNum[W] * DotRatio[Wide];
    BetweenX := ComNum[X] * DotRatio[Wide]
  end;

  procedure DrawChar;
  var
    SpaceChar : boolean;
    TabNum : byte;
    RealCharWide : word;
    Corner : array[1..4] of word;
  begin
    OldDot[Wide] := Dot[Wide];
    Dot[Long] := OldDot[Long] + CharSize[Long];
    RealCharWide := CharSize[Wide];
    if InChinese then
    begin
      InChinese := false;
      SpaceChar := LastChar + Ch = '　'
    end else
    begin
      SpaceChar := (Ch = #32) or (Ch = #9);
      RealCharWide := (RealCharWide - BetweenX) shr 1;
      if Ch = #9 then
      begin
        TabNum := 7 - pred(CharNum) mod 8;
        inc(RealCharWide,(RealCharWide + BetweenX) * TabNum);
        inc(CharNum,TabNum)
      end
    end;
    inc(Dot[Wide],RealCharWide);
    Corner[3] := round(Dot[Wide] * PaperToBox[Wide]) + SideBase[Side,Wide];
    if (Corner[3] > BoxSize[Side,Wide] + SideBase[Side,Wide]) and not SpaceChar
      then OutOfLine := true;
    if not (SpaceChar or OutOfLine) then
    begin
      Corner[1] := round(OldDot[Wide] * PaperToBox[Wide]) + SideBase[Side,Wide];
      Corner[2] := round(OldDot[Long] * PaperToBox[Long]) + SideBase[Side,Long];
      Corner[4] := round(Dot[Long] * PaperToBox[Long]) + SideBase[Side,Long];
      write(Esc,'L',Corner[1],',',Corner[2],',',Corner[3],',',Corner[4],',B;')
    end;
    gotoxy(CursorXY[Side,Wide],CursorXY[Side,Long]);
    inc(Dot[Wide],BetweenX);
    if OutOfLine then
    begin
      OutOfRight := true;
      OutOfLine := false
    end
  end;

  procedure SetPrintMode;
  const
    ComList = 'PTDWZXLIGFHVRNCESUOAY;';
  var
    I : integer;
    EndCom : boolean;
    LastCom : String4;
    ComPos : byte;

    procedure ExplainCom;
    begin
      ComPos := pos(LastCom[1],ComList);
      case ComPos of
        2..7 : val(copy(LastCom,2,3),ComNum[ComType(ComPos)],I);
        1 : begin
                ComNum := PreComNum;
                val(copy(LastCom,2,3),ComNum[P],I);
                ComNum[P] := 7 + ord(ComNum[P] in [8..24])
            end;
        8 : ComNum := PreComNum;
       11 : write(EscT24,'590,0,0,1;水平');
       12 : write(EscT24,'590,0,0,1;垂直')
      end
    end;

  begin
    EndCom := false;
    while not EndCom do
    begin
      read(F,Ch);
      inc(CharNum);
      Ch := upcase(Ch);
      ComPos := pos(Ch,ComList);
      if ComPos > 0 then
      begin
        ExplainCom;
        if Ch = ';' then
        begin
          EndCom := true;
          SetCharSize;
          Dot[Long] := OldDot[Long] + CharSize[Long];
        end
        else LastCom := Ch
      end
      else LastCom := LastCom + Ch;
      if eoln(F) then
      begin
        EndCom := true;
        ExplainCom;
        SetCharSize
      end
    end
  end;

begin
  ComNum := PreComNum;
  OldDot[Long] := Dot[Long];
  SetCharSize;
  Escape := false;
  InChinese := false;
  OutOfLine := false;
  OutOfRight := false;
  LineNum := 0;
  while not (eof(F) or Escape) do
  begin
    CharNum := 0;
    HighChange := false;
    PageChange := false;
    Dot[Wide] := Margin[Wide];
    while not (eoln(F) or HighChange or PageChange) do
    begin
      read(F,Ch);
      inc(CharNum);
      if InChinese then DrawChar
      else case ord(Ch) of
              12      : PageChange := true;
             126      : SetPrintMode;
             128..255 : begin
                          LastChar := Ch;
                          InChinese := true
                        end
           else DrawChar
           end
    end;
    if keypressed then Escape := readkey = #27;
    if eoln(F) then
    begin
      readln(F);
      inc(LineNum)
    end;
    if CharNum = 0 then Dot[Long] := OldDot[Long] + CharSize[Long];
    OldDot[Long] := Dot[Long] + ComNum[L] * DotRatio[Long];
    if ((OldDot[Long] + CharSize[Long]) * PaperToBox[Long] > BoxSize[Side,Long])
      or PageChange then
    begin
      write(EscT24,ShowSite[6,Side],';共 ',LineNum:3,' 行 ',PageNum,' 頁');
      write(EscT24,ShowSite[5,Side],';按任意鍵繼續');
      gotoxy(CursorXY[Side,Wide],CursorXY[Side,Long]);
      repeat until readkey <> #0;
      write(EscT24,ShowSite[5,Side],';按 Esc 結束 ');
      inc(PageNum);
      OldDot[Long] := Margin[Long];
      DrawBox
    end
  end
end;

procedure Conclude;
begin
  write(EscT24,ShowSite[6,Side],';共 ',LineNum:3,' 行 ',PageNum,' 頁');
  if OutOfRight then write(#7,EscT24,ShowSite[7,Side],';字符超出右緣!!');
  write(Esc,'T16;');
  gotoxy(CursorXY[Side,Wide],CursorXY[Side,Long]);
  if not Escape then repeat until readkey = Esc;
  close(F);
  write(Esc,'CL;')
end;

begin
  Test_System;
  Input_Paper_Mode;
  Set_Paper;
  Character_Work;
  Conclude
end.

