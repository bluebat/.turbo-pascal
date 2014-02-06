{$I-}
unit Font;

interface

uses dos,graph;

type
  Str80 = string[80];
  Str2 = string[2];

const
  FontOK : byte = 0;
  FileNotOpen : byte = 1;
  OutofRange : byte = 2;

procedure SetFontFile(FFile : Str80;W,H : word;var Result : byte);
function Code2Position(PWord : Str2;var Result : byte) : word;
procedure PutFont(X,Y : word; Stat : char; Pnum : integer; var Result : byte);
procedure Print(X,Y : word;Step : byte;Stat : char;PString : Str80;var Result : byte);

implementation

const
  ErrorFlag : boolean = true;
var
  FontFile : file;
  Width,Hight : word;
  Pattern : array[1..76] of byte;
  HByte, LByte : byte;
  PNum, Num : word;
  NumLimit : word;

procedure SetFontFile(FFile : Str80;W,H : word;var Result : byte);
begin
  Width := W;
  Hight := H;
  if not ErrorFlag then close(FontFile);
  assign(FontFile,FFile);
  reset(FontFile,Width div 8 * Hight);
  if IOResult = 0 then
  begin
    ErrorFlag := false;
    NumLimit := FileSize(FontFile) - 1;
    Result := 0
  end else
  begin
    ErrorFlag := true;
    NumLimit := 0;
    Result := 1
  end
end;

function Code2Position(PWord : Str2;var Result : byte) : word;
begin
  HByte := ord(PWord[1]) - $A4;
  LByte := ord(PWord[2]);
  if LByte > $7F then dec(LByte,$A1-$7F);
  dec(LByte,$40);
  Num := HByte * 157 + LByte;
  if Num > 5400 then dec(Num,408);
  Code2Position := Num;
  if Num > NumLimit then
  begin
    Result := 2;
    exit
  end
end;

procedure PutFont(X,Y : word; Stat : char; Pnum : integer; var Result : byte);
var
  Logi : byte;
begin
  case Stat of
    'x' : Logi := 1;
    'o' : Logi := 2;
    'a' : Logi := 3;
    'n' : Logi := 0
  end;
  Pattern[1] := lo(Width-1);
  Pattern[2] := hi(Width);
  Pattern[3] := lo(Hight-1);
  Pattern[4] := hi(Hight);
  if ErrorFlag then
  begin
    Result := 1;
    exit
  end;
  seek(FontFile,PNum);
  blockread(FontFile,Pattern[5],1);
  PutImage(X,Y,Pattern,Logi);
  Result := 0
end;

procedure Print(X,Y : word;Step : byte;Stat : char;PString : Str80;var Result : byte);
var
  I : byte;
  PX,PY : word;
  PResult : byte;
begin
  PX := X;
  PY := Y;
  I := 1;
  PResult := 0;
  while (I < length(PString)) and (PResult = 0) do
  begin
    PNum := Code2Position(copy(PString,I,2),Result);
    PutFont(PX,PY,Stat,Pnum,PResult);
    inc(I,2);
    inc(PX,Width + Step)
  end;
  Result := PResult
end;

end.



