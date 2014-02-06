program Biograph;
uses graph, Ztype;
const
  FigNum = 10;
  DotNum = 100;
  Range = 4.0;
var
  GraphDriver, GraphMode, N, J, K, Zval : integer;
  Zc, Z : Complex;
  OutOf : boolean;
begin
{  GraphDriver := Detect;
  initGraph(GraphDriver,GraphMode,'');
  if graphResult <> grOK then halt(1);}
  Zc.RePart := 0.5;
  Zc.ImPart := 0;
  for j := 1 to DotNum do
    for k := 1 to DotNum do
    begin
      Z.RePart := -Range/2 + Range/DotNum * j;
      Z.ImPart := -Range/2 + Range/DotNum * k;
      N := 0;
      repeat
{       Z := Zadd(Zc,Zpower(Z,3)^)^;}
        Z := Zadd(Z,Zpower(Z,2)^)^;
{       Z := Zadd(Zc,Zpower(Z,4)^)^;
        Z := Zadd(Zc,Zpower(Z,5)^)^;
        Z := Zadd(Zc,Zpower(Z,6)^)^;
        Z := Zadd(Zc,ZpowerZ(Z,Z)^)^;
        Z := Zadd(Zc,Zadd(Zpower(Z,6)^,ZpowerZ(Z,Z)^)^)^;
        Z := Zadd(Zc,Zadd(Zpower(Z,5)^,ZpowerZ(Z,Z)^)^)^;
        Z := Zadd(Zc,Zexp(Z)^)^;
        Z := Zadd(Zc,Zsin(Z)^)^;
        Z := Zadd(Zc,Zadd(Zsin(Z)^,Zexp(Z)^)^)^;
        Z := Zadd(Zc,Zadd(Zsin(Z)^,Zpower(Z,2)^)^)^;
        Z := Zadd(Zc,Zadd(Zsin(Z)^,Zpower(Z,3)^)^)^;  }
{       OutOf := (abs(Z.RePart)>FigNum) or (abs(Z.ImPart)>FigNum) or (Zabs(Z)>FigNum);}
        Zval := round(Zabs(Z)*0.2);
        OutOf := Zabs(Z)>FigNum;
        inc(N)
      until OutOf or (N = FigNum);
      if (abs(Z.RePart)<FigNum) or (abs(Z.ImPart)<FigNum) then write(Zval,' ');
    end;
  write(#7);
  readln;
  closeGraph
end.


