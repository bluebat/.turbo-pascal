{$A+,B-,D+,E+,F-,I+,L+,N-,O-,R-,S+,V+}
{$M 16384,0,655360}
program ETTSR;
uses crt,dos;
var
  IntBuf : pointer;
  Regs : registers;
  KeyAddsByte : byte absolute $40:$17;

procedure ETPreSee;
type
  String3 = string[3];
  SideType = (Long, Wide);
  SideTypeInt = array[SideType] of integer;
  SideTypeSideInt = array[SideType] of SideTypeInt;
const
  Esc = #27;
  MaxDot = 360;
  Max : SideTypeInt = (375,640);
  BoxSize : SideTypeSideInt = ((320,340),(256,590));
  SideBase : SideTypeSideInt = ((15,150),(48,25));
var
  F : text;
  FormStr : string[2];
  Side : SideType;
  Paper, Margin, Dot : SideTypeInt;
  PaperToBox : array[SideType] of real;
  OutOf : array[SideType] of boolean;

procedure Input_Paper_Mode;
type
  String40 = string[40];
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
    X := wherex;
    readln(Dumb);
    if Dumb = '' then Dumb := PreSet;
    Dumb[1] := upcase(Dumb[1]);
    gotoxy(X,Y);
    write(Dumb);
    AskString := Dumb
  end;

begin
  directvideo := false;
  clrscr;
  write(Esc,'T24,180,20,24,2,S;列印預視',Esc,'T24,181,21,24,2,X;列印預視');
  write(Esc,'T16;');
  repeat
    getdir(0,FileName);
    gotoxy(10,8);
    write('文 書 檔 案 路 徑 及 名 稱 : (' + FileName + '\) ');
    readln(FileName);
    assign(F,FileName);
    {$I-}reset(F){$I+}
  until ioresult = 0;
  if FileName = '' then halt;
  FormStr := AskString(10,10,'列 印 紙 張 規 格 : ','B5');
  EntryWay := AskString(10,12,'進 紙 方 向 [ L = 直 ] [ W = 橫 ] : ' ,'L');
  if EntryWay = 'L' then Side := Long else Side := Wide;
  gotoxy(10,15);
  write('請 以 印 表 機 上 的 欄 位 數 回 答 下 面 二 個 問 題 !');
  val(AskString(10,17,'紙 張 左 側 預 留 : ','1'),Margin[Wide],I);
  Margin[Wide] := Margin[Wide] * MaxDot div 10;
  val(AskString(10,19,'紙 張 頂 端 預 留 : ','1'),Margin[Long],I);
  Margin[Long] := Margin[Long] * MaxDot div 10;
  clrscr;
  gotoxy(1,1);
  write(FileName)
end;

procedure Set_Paper;
const
  ZeroForm : array['A'..'C'] of SideTypeInt
           = ((16855,11918),(20044,14173),(15345,10850));
var
  S : SideType;
  I : integer;
  PaperNum : byte;
  UpXY, DownXY : array[SideType] of String3;

  function FormSize(PT : char; PN : byte; ST : SideType) : integer;
  begin
    if PN = 0 then FormSize := ZeroForm[PT,ST]
    else FormSize := FormSize(PT,pred(PN),SideType(1 - ord(ST))) shr ord(ST)
  end;

begin
  val(FormStr[2],PaperNum,I);
  for S := Long to Wide do
  begin
    str(SideBase[Side,S],UpXY[S]);
    str(BoxSize[Side,S] + SideBase[Side,S],DownXY[S]);
    Paper[S] := FormSize(FormStr[1],PaperNum,SideType(abs(ord(S) - ord(Side))));
    PaperToBox[S] := BoxSize[Side,S] / Paper[S];
    Dot[S] := Margin[S];
    OutOf[S] := false
  end;
  write(Esc+'L'+UpXY[Wide]+','+UpXY[Long]+','+DownXY[Wide]+','+DownXY[Long]+',B;')
end;

procedure Character_Work;
type
  ComType = (I,P,T,D,W,Z,X,L);
  ComTypeByte = array[ComType] of byte;
  String4 = string[4];
const
  Density : array[7..8,0..4] of SideTypeInt
	  = (((90,60),(90,120),(90,120),(90,240),(90,80)),
	     ((180,180),(180,120),(180,90),(180,60),(180,360)));
  PreComNum : ComTypeByte = (0,9,24,0,1,1,12,6);
var
  OldDot, CharSize : SideTypeInt;
  DotRatio : array[SideType] of byte;
  Ch, LastChar : char;
  InChinese, CharLine, OutOfLine, HighChange : boolean;
  ComNum : ComTypeByte;
  CharNum, BetweenX : byte;

  procedure SetCharSize;
  var
    NewCharLong : integer;
  begin
    DotRatio[Long] := MaxDot div Density[ComNum[P],ComNum[D]][Long];
    DotRatio[Wide] := MaxDot div Density[ComNum[P],ComNum[D]][Wide];
    NewCharLong := ComNum[T] * ComNum[Z] * DotRatio[Long];
    HighChange := (CharSize[Long] <> NewCharLong) and CharLine;
    CharSize[Long] := NewCharLong;
    CharSize[Wide] := ComNum[T] * ComNum[W] * DotRatio[Wide];
    BetweenX := ComNum[X] * DotRatio[Wide]
  end;

  procedure DrawChar;
  type
    String9 = string[9];
  var
    SpaceChar : boolean;
    SqrStr : string[24];
    TabNum : byte;

    function CornerStr(DrawDot : SideTypeInt):String9;
    var
      S : SideType;
      Dumb : integer;
      DumbStr : array[SideType] of String4;
    begin
      for S := Long to Wide do
      begin
	Dumb := round(DrawDot[S] * PaperToBox[S]);
	OutOf[S] := Dumb > BoxSize[Side,S];
	str(SideBase[Side,S] + Dumb,DumbStr[S])
      end;
      CornerStr := DumbStr[Wide] + ',' + DumbStr[Long]
    end;

  begin
    OldDot[Wide] := Dot[Wide];
    CharLine := true;
    if InChinese then
    begin
      InChinese := false;
      SpaceChar := LastChar + Ch = '　'
    end else
    begin
      SpaceChar := Ch in [#32,#9];
      CharSize[Wide] := (CharSize[Wide] - BetweenX) shr 1;
      if ord(Ch) = 9 then
      begin
	TabNum := 7 - pred(CharNum) mod 8;
	inc(CharSize[Wide],(CharSize[Wide] + BetweenX) * TabNum);
	inc(CharNum,TabNum)
      end
    end;
    inc(Dot[Wide],CharSize[Wide]);
    SqrStr := Esc + 'L' + CornerStr(OldDot) + ',' + CornerStr(Dot) + ',B;';
    if not (SpaceChar or OutOf[Wide] or OutOf[Long]) then write(SqrStr);
    gotoxy(61,1);
    inc(Dot[Wide],BetweenX);
    if OutOf[Wide] and not SpaceChar then
    begin
      OutOfLine := true;
      OutOf[Wide] := false
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
  begin
    if CharNum = 1 then CharLine := false;
    EndCom := false;
    while not (EndCom or eoln(F)) do
    begin
      read(F,Ch);
      inc(CharNum);
      Ch := upcase(Ch);
      ComPos := pos(Ch,ComList);
      if ComPos > 0 then
      begin
	ComPos := pos(LastCom[1],ComList);
	case ComPos of
	  2..7 : val(copy(LastCom,2,3),ComNum[ComType(ComPos)],I);
	  1 : begin
		  ComNum := PreComNum;
		  val(copy(LastCom,2,3),ComNum[P],I);
                  if ComNum[P] in [8..24] then ComNum[P] := 8
                                          else ComNum[P] := 7
              end;
          8 : ComNum := PreComNum
	end;
	if Ch = ';' then
	begin
	  EndCom := true;
	  CharLine := true
	end
	else LastCom := Ch
      end
      else LastCom := LastCom + Ch
    end
  end;

begin
  ComNum := PreComNum;
  SetCharSize;
  OldDot[Long] := Dot[Long];
  InChinese := false;
  OutOfLine := false;
  while not (eof(F) or OutOf[Long]) do
  begin
    CharNum := 0;
    CharLine := false;
    HighChange := false;
    Dot[Wide] := Margin[Wide];
    Dot[Long] := OldDot[Long] + CharSize[Long];
    while not (eoln(F) or HighChange) do
    begin
      read(F,Ch);
      inc(CharNum);
      if InChinese then DrawChar
      else case ord(Ch) of
	     126      : SetPrintMode;
	     128..255 : begin
			  LastChar := Ch;
			  InChinese := true
			end
	   else DrawChar
	   end;
      SetCharSize
    end;
    if eoln(F) then readln(F);
    if CharLine or (CharNum = 0) then
    begin
      OldDot[Long] := Dot[Long] + ComNum[L] * DotRatio[Long];
      Dot[Long] := OldDot[Long] + CharSize[Long]
    end
  end;
  if OutOfLine or OutOf[Long] then write(#7,'部份字元超出紙張!!');
  close(F);
  gotoxy(1,24)
end;

begin
  if (KeyAddsByte and $3) = $3 then
  begin
    Input_Paper_Mode;
    Set_Paper;
    Character_Work
  end;
  intr($66,Regs)
end;

begin
  getintvec($09,IntBuf);
  setintvec($66,IntBuf);
  setintvec($09,@ETPreSee);
  keep(exitcode)
end.