unit DPL24I;

interface

type
  String3 = string[3];
  String4 = string[4];
  String5 = string[5];
  ModeType = (D1,D2,D3,D4,D6,C1,C2,C3,SD2);
const
  { Font Set }
  ItalicOn = #27#52;
  ItalicOff = #27#53;

  { Font Style }
  Draft = #27#37#0#2;
  Courier = #27#37#0#0;
  Prestige = #27#37#0#1;
  BoldPS = #27#37#0#4;

  { Character Pitch }
  Pica = #27#80;
  Elite = #27#77;
  Compress = #27#37#0#3;
  PSOn = #27#112#1;
  PSOff = #27#112#0;

  { Character Highlight }
  EmphasizeOn = #27#69;
  EmphasizeOff = #27#70;
  DoubleHeightOn = #27#86#1;
  DoubleHeightOff = #27#86#0;
  DoubleWidthOn = #27#87#1;
  DoubleWidthOff = #27#87#0;
  UnderLineOn = #27#45#1;
  UnderLineOff = #27#45#0;
  SuperScriptOn = #27#83#0;
  SubScriptOn = #27#83#1;
  SScriptOff = #27#84;

  { Letter Per Inch }
{  LPI6 = #27#50;}
  LPI8 = #27#48;

  { Moving Control }
  LF = #10;
  ReverseLF = #27#10;
  FF = #12;
  BS = #8;
  CR = #13;


  { Reset }
  ResetPrinter = #27#64;

function BitImage(Pin:integer; Mode:ModeType; Total:integer) : String5;
function AbsHorPos(Total : integer) : String4;
function RollPaper(Dir : char; Dot : byte) : String3;
function LeftMargin(Column : byte) : String3;

implementation

function BitImage(Pin:integer; Mode:ModeType; Total:integer) : String5;
var M : char;
begin
  if Pin = 24 then
    case Mode of
      D1 : M := #32;
      D2 : M := #33;
      C3 : M := #38;
      D3 : M := #39;
      D6 : M := #40
    end
  else
    case Mode of
      D1 : M := #0;
      D2 : M := #1;
      SD2 : M := #2;
      D4 : M := #3;
      C1 : M := #4;
      C2 : M := #6
    end;
  BitImage := #27#42 + M + chr(lo(Total)) + chr(hi(Total))
end;

function AbsHorPos(Total : integer) : String4;
begin
  AbsHorPos := #27#36 + chr(lo(Total)) + chr(hi(Total))
end;

function RollPaper(Dir : char; Dot : byte) : String3;
begin
  if Dir in ['B','b','R','r'] then RollPaper := #27#106 + chr(Dot)
                              else RollPaper := #27#74 + chr(Dot)
end;

function LeftMargin(Column : byte) : String3;
begin
  LeftMargin := #27#108 + chr(Column)
end;

end.



