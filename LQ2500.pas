unit LQ2500;

interface

type
  String4 = string[4];
  String5 = string[5];
  ModeType = (D1,D2,D3,D4,D6,C1,C2,C3,SD2);
const
  { Font Set }
  ItalicOn = #27#52;
  ItalicOff = #27#53;
  GraphicCharacter = #27#116#1#27#54;

  { Font Style }
  Draft = #27#120#0;
  LQ = #27#120#1;
  SansSerif = #27#107#1;
  Courier = #27#107#2;
  Prestige = #27#107#3;
  Script = #27#107#4;
  BoldPS = #27#107#6;

  { Character Pitch }
  Pica = #27#80;
  Elite = #27#77;
  Compress = #27#15;
  PSOn = #27#112#1;
  PSOff = #27#112#0;

  { Character Highlight }
  EmphasizeOn = #27#69;
  DoubleHighOn = #27#119#1;
  DoubleWidthOn = #27#87#1;
  UnderLineOn = #27#45#1;
  EmphasizeOff = #27#70;
  DoubleHighOff = #27#119#0;
  DoubleWidthOff = #27#87#0;
  UnderLineOff = #27#45#0;

  { Letter Per Inch }
  LPI6 = #27#50;
  LPI8 = #27#48;

  { Moving Control }
  LF = #10;
  FF = #12;
  BS = #27#97#0#8;
  CR = #13;

  { Reset }
  ResetPrinter = #27#64;

function BitImage(Pin:integer; Mode:ModeType; Total:integer) : String5;
function AbsHorPos(Total : integer) : String4;

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

end.



