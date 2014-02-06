program DrawTree;
uses
  graph;
var
  EndLen : word;
  Offshoot, Cure : real;
  MaxX, MaxY : integer;

procedure Set_Graph;
var
  GraphDriver, GraphMode : integer;
begin
  GraphDriver := detect;
  initgraph(GraphDriver,GraphMode,'c:\pascal\bgi');
  if graphresult <> grok then
  begin
    write('can''t find !');
    halt
  end;
  MaxX := GetMaxX;
  MaxY := GetMaxY
end;

procedure Draw_Tree(MainAngle,SideAngle,MainDif,SideDif:real;EndLen,EndGrade:byte);

procedure Draw_Stem(X,Y:integer;Angle,StemLen:real;Grade,Order:byte);
var
  Xo, Yo : integer;
  SideLen : real;
begin
  if (StemLen > EndLen) and (Grade < EndGrade) then
  begin
    Xo := trunc(StemLen * cos(Angle)) + X;
    Yo := trunc(StemLen * sin(Angle)) + Y;
    line(X,MaxY-Y,Xo,MaxY-Yo);
    SideLen := StemLen * SideDif;
    begin
      Draw_Stem(Xo,Yo,Angle+SideAngle,SideLen*ord(odd(Order)),succ(Grade),Order);
      Draw_Stem(Xo,Yo,Angle-SideAngle,SideLen*ord(not odd(Order)),succ(Grade),Order);
      Draw_Stem(Xo,Yo,Angle+MainAngle,StemLen * MainDif,Grade,succ(Order));
    end
  end
end;

begin
  Draw_Stem(320,0,pi/2,80,1,1);
end;

begin
  Set_Graph;
  randomize;
  Draw_Tree(0,pi/3,0.8,0.4,1,7);
  readln;
  closegraph
end.
