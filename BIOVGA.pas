program	BioVGA;
uses graph, Ztype;
{const
  DotNum = 100;
  Range	= 2.0;
  StartX = 0.0;
  StartY = 0.0;}
type Complex = record
		 RePart,ImPart :real
	       end;
     Complexp =	^Complex;
var
  DotNum : word;
  Range, StartX, StartY : real;
  GraphDriver, GraphMode, N, J,	K, Zval : integer;
  Zptr : Complexp;
  Z, Zz : Complex;
  OutOf	: boolean;
  FigNum : byte;

function Zabs(Z:Complex):real;
begin
  Zabs := sqrt(sqr(Z.RePart) + sqr(Z.ImPart))
end;

function Arg(Z:Complex):real;
begin
  if Z.RePart =	0 then Arg := pi / 2 + pi * ord(Z.ImPart < 0)
    else Arg :=	arctan(Z.ImPart	/ Z.RePart) + pi * ord(Z.RePart	< 0)
end;

function Zadd(Z1,Z2:Complex):Complexp;
begin
  Zptr^.RePart := Z1.RePart + Z2.RePart;
  Zptr^.ImPart := Z1.ImPart + Z2.ImPart;
  Zadd := Zptr
end;

function Zpower(Z:Complex;Power:real):Complexp;
var Value,Angle:real;
begin
  if Zabs(Z) = 0 then Value := 0 else Value := exp(Power * ln(Zabs(Z)));
  Angle	:= Power * Arg(Z);
  Zptr^.RePart := Value	* cos(Angle);
  Zptr^.ImPart := Value	* sin(Angle);
  Zpower := Zptr
end;

begin
  new(Zptr);
  write('Dotnum,Range,StartX,StartY = ? ');
  readln(DotNum,Range,StartX,StartY);
  GraphDriver := Detect;
  initGraph(GraphDriver,GraphMode,'');
  if graphResult <> grOK then halt(1);
  FigNum := getmaxcolor;
  for j	:= 1 to	DotNum do
    for	k := 1 to DotNum do
    begin
      Z.RePart := StartX + Range/DotNum * j;
      Z.ImPart := StartY + Range/DotNum * k;
      N	:= 0;
      repeat
        Zz := Zpower(Z,2)^;
	Z := Zadd(Z,Zz)^;
        Zval := round(Zabs(Z));
	OutOf := Zval > FigNum;
	inc(N)
      until OutOf or (N	> FigNum);
      if not OutOf then putPixel(j,k,Zval)
    end;
  write(#7);
  readln;
  closeGraph
end.


