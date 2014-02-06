program Worms;
uses crt, graph, Hercules;
const Length = 14;
      Width = 5;
var WormX, WormY : array[0..Length] of integer;
    Dir          : real;
    Tail         : integer;


procedure HercDriverProc;external;
  {$L HERC.OBJ }

procedure Link_Herc_BGI;
var i : integer;
begin
  i := registerBGIdriver(@HercDriverProc)
end;

procedure Title;
var s : char;
begin
  clrscr;
  writeln('This Pascal program is rewrited from Dewdney''s BASIC program.');
  writeln('[ "WORMS" ----- Scientific American, December 1987, p.98~102 ]');
  writeln;
  writeln('             Press any key to continue .......');
  repeat until keypressed;
  s := readkey
end;

procedure Initialize;
var i : integer;
begin
  Tail := 0;
  randomize;
  WormX[0] := random(MaxX);
  WormY[0] := random(MaxY);
  for i := 1 to Length do
  begin
    WormX[i] := WormX[0];
    WormY[i] := wormY[0]
  end;
  Dir := random * 6.28
end;

procedure NewStep;
var NexTail : integer;
begin
  NexTail := Tail;
  Tail := (Tail + 1) mod Length;
  setColor(black);
  circle(WormX[Tail],WormY[Tail],Width);
  setColor(white);
  putPixel(WormX[Tail],WormY[Tail],1);
  Dir := Dir + random/2 - random/2;
  WormX[Tail] := (WormX[NexTail] + round(6*cos(Dir)) + MaxX) mod MaxX;
  WormY[Tail] := (WormY[NexTail] + round(6*sin(Dir)) + MaxY) mod MaxY;
  circle(WormX[Tail],WormY[Tail],Width)
end;

BEGIN
  Title;
  Link_Herc_BGI;
  Set_Herc;
  Initialize;
  repeat
    NewStep;
  until keypressed;
  closeGraph
END.

