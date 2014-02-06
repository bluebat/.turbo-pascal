unit Math;

interface

function NormRnd(Mean,StD:real):real;
function NormalRnd(Mean,StD:real):real;
function PolyChr(Code,N:byte):string;
function Sgn(Number:real):integer;
function Sinh(Number:real):real;
function Cosh(Number:real):real;
function Tanh(Number:real):real;
function DecToBin(Num : integer) : string[8];

implementation

function NormRnd(Mean,StD:real):real;
var RndA, RndB, RndR:real;
begin
  repeat
    RndA := 2 * random - 1;
    RndB := 2 * random - 1;
    RndR := sqrt(RndA) + sqrt(RndB)
  until RndR < 1;
  NormRnd := Mean + StD * RndA * sqrt(-2 * ln(RndR) / RndR)
end;

function NormalRnd(Mean,StD:real):real;
var Rnd:real;
    i:integer;
begin
  Rnd := 0;
  for i := 1 to 10 do Rnd := Rnd + random * 3.0518E-5;
  NormalRnd := Mean + StD * sqrt(12/10) * (Rnd - 10/2)
end;

function PolyChr(Code,N:byte):string;
var s:string;
begin
  fillChar(s,sizeOf(s),chr(Code));
  s[0] := chr(N);
  PolyChr := s
end;

function Sgn(Number:real):integer;
begin
  if Number > 0 then Sgn := 1
  else if Number = 0 then Sgn := 0
       else Sgn := -1
end;

function Sinh(Number:real):real;
begin
  Sinh := (exp(Number) - exp(-Number)) * 0.5
end;

function Cosh(Number:real):real;
begin
  Cosh := (exp(Number) + exp(-Number)) * 0.5
end;

function Tanh(Number:real):real;
begin
  Tanh := (exp(Number) - exp(-Number)) / (exp(Number) - exp(-Number))
end;

function DecToBin(Num : integer) : string[8];
var
   I, J : integer;
   St   : string[8];
begin
   for I := 8 downto 1 do begin
      St[i] := chr( (Num mod 2) + 48);
      Num := Num div 2;
   end;
   St[0] := chr(8);
   DecToBin := St;
end;

end.
