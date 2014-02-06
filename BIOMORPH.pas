program Biomorph;
uses graph, Ztype;
var
  GraphDriver, GraphMode, n, j, k : integer;
  Z1, Z2, Z : Complex;
  OutOf : boolean;
begin
  GraphDriver := Detect;
  initGraph(GraphDriver,GraphMode,'');
  if graphResult <> grOK then halt(1);
  Z1.RePart := 0.5;
  Z1.ImPart := 0;
  for j := 1 to 100 do
    for k := 1 to 100 do
    begin
      Z2.RePart := -1.5 + 0.03 * j;
      Z2.ImPart := -1.5 + 0.03 * k;
      Z := Z2;
      for n := 1 to 10 do
      begin
        Z := Zadd(Z1,Zpower(Z,2)^)^;
        OutOf := (abs(Z.RePart)>10) or (abs(Z.ImPart)>10);
        if OutOf or (Zabs(Z)>10) then n := 10
      end;
      if (abs(Z.RePart)<10) or (abs(Z.ImPart)<10) then putPixel(j,k,0)
      else putPixel(j,k,1)
    end;
  closeGraph
end.


