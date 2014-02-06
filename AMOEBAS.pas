program Amoebas;
uses graph, crt;
type Place = ^Life;
     Life = record
              Age, GrowEnergy, BreedEnergy, X, Y : integer;
              Size, MatuRate : integer;
              Next : Place
            end;
const StartAmoebas = 44;
      BaseEcoli = 3000;
      DropEcoli = 100;
      EcoliEnergy = 120;
      DirX : array[1..6] of integer = (0,2,2,0,-2,-2);
      DirY : array[1..6] of integer = (2,1,-1,-2,-1,1);
var Root, Bug, ProBug : Place;
    MaxX, MaxY : integer;

procedure Set_Graph;
var GraphDevice,GraphMode : integer;
    PathtoBGI : string;
begin
  PathToBGI := 'b:\tpu';
  GraphDevice := detect;
  initGraph(GraphDevice,GraphMode,PathToBGI);
  if graphResult <> grOK then Halt(1);
  MaxX := getMaxX;
  MaxY := getMaxY
end;

procedure Title;
begin
  clearDevice;
  setTextStyle(defaultFont,horizDir,5);
  outTextXY(100,100,'AMOEBAS');
  setFillStyle(wideDotFill,1);
  fillEllipse(500,100,50,80);
  setFillStyle(closeDotFill,1);
  fillEllipse(500,100,25,30);
  setTextStyle(defaultFont,horizDir,1);
  outTextXY(200,250,'refer to  [ Scientific American May 1989, p.104~107 ]');
  outTextXY(100,300,'press [Enter] to start .....');
  readln;
  clearDevice
end;

procedure Initiate;
var P : Place;
    i : integer;
begin
  randomize;
  Root := nil;
  for i := 1 to StartAmoebas do
  begin
    new(P);
    with P^ do
    begin
      Age := 0;
      Size := random(3) + 1;
      MatuRate := random(4) + 3;
      GrowEnergy := Size * 100 + random(100);
      BreedEnergy := Size * 200 + random(100);
      X := random(MaxX);
      Y := random(MaxY);
      rectangle(X - Size,Y - Size,X + Size,Y + Size);
      Next := Root
    end;
    Root := P
  end
end;

procedure Put_Ecoli(EcoliNum:integer);
var EcoliX, EcoliY, i : integer;
begin
  for i := 1 to EcoliNum do
  begin
    EcoliX := random(MaxX);
    EcoliY := random(MaxY);
    putPixel(EcoliX,EcoliY,1);
    setActivePage(1);
    putPixel(EcoliX,EcoliY,1);
    setActivePage(0)
  end
end;

procedure Move_Amoeba;
var MoveSpeed, Dir : integer;
begin
  with Bug^ do
  begin
    setColor(black);
    rectangle(X - Size,Y - Size,X + Size,Y + Size);
    Dir := random(6) + 1;
    MoveSpeed := Size * 1;
    X := (X + DirX[Dir]*MoveSpeed + MaxX) mod MaxX;
    Y := (Y + DirY[Dir]*MoveSpeed + MaxY) mod MaxY;
    setColor(white);
    rectangle(X - Size,Y - Size,X + Size,Y + Size)
  end
end;

procedure Check_Life;
var BasicEnergy, MatuEnergy, DeadAge, MoveEnergy : integer;

procedure Find_Food;
var Rv, i, j : integer;
begin
  with Bug^ do
  begin
    setActivePage(1);
    Rv := MatuRate * EcoliEnergy div 10;
    for i := X-Size-1 to X+Size+1 do for j := Y-Size-1 to Y+Size+1 do
      if getPixel(i,j) = 1 then
        if (j >= 0) and (j <= MaxY) and (i >= 0) and (i <= MaxX) then
        begin
          setActivePage(0);
          putPixel(i,j,0);
          setActivePage(1);
          putPixel(i,j,0);
          inc(BreedEnergy,Rv);
          inc(GrowEnergy,EcoliEnergy - Rv)
        end;
    setActivePage(0)
  end
end;

procedure Die;
begin
  sound(58);
  delay(58);
  nosound;
  setColor(black);
  with Bug^ do rectangle(X - Size,Y - Size,X + Size,Y + Size);
  if Bug = Root then Root := Bug^.Next
    else ProBug^.Next := Bug^.Next
end;

procedure Mitosis;
var Drift, i : integer;
    Son, PostSon : Place;
begin
  sound(1540);
  delay(58);
  nosound;
  setColor(black);
  with Bug^ do rectangle(X - Size,Y - Size,X + Size,Y + Size);
  Drift := 1;
  for i := 1 downto 0 do
  begin
    new(Son);
    with Son^ do
    begin
      Age := 0;
      GrowEnergy := Bug^.GrowEnergy div 2;
      BreedEnergy := 0;
      Size := Bug^.Size + round(random*random * Drift);
      if Size < 0 then Size := 0;
      MatuRate := Bug^.MatuRate + random(2) * Drift;
      if MatuRate > 10 then MatuRate := 10
        else if MatuRate < 0 then MatuRate := 0;
      X := Bug^.X + i * Drift;
      Y := Bug^.Y + i * Drift;
      Drift := -Drift;
      case i of
        1 : begin
              Next := Bug^.Next;
              PostSon := Son
            end;
        0 : begin
              Next := PostSon;
              if Bug = Root then Root := Son
                else
                begin
                  ProBug^.Next := Son;
                  ProBug := PostSon
                end
            end
      end
    end
  end;
  setColor(white);
  with PostSon^ do rectangle(X - Size,Y - Size,X + Size,Y + Size);
  with Son^ do rectangle(X - Size,Y - Size,X + Size,Y + Size)
end;

begin
  with Bug^ do
  begin
    MoveEnergy := Size * 1;
    BasicEnergy := Size * 100;
    DeadAge := Size * 10;
    MatuEnergy := Size * 250;
    inc(Age);
    inc(GrowEnergy,-MoveEnergy);
    Find_Food;
    if (GrowEnergy < BasicEnergy) or (Age > DeadAge) then Die
    else
      if (BreedEnergy > MatuEnergy) then Mitosis
      else ProBug := Bug
  end
end;

BEGIN
  Set_Graph;
  Title;
  Initiate;
  Put_Ecoli(BaseEcoli);
  repeat
    ProBug := Root;
    Bug := Root;
    Put_Ecoli(DropEcoli);
    repeat
      Move_Amoeba;
      Check_Life;
      Bug := Bug^.Next
    until Bug = nil
  until (Root = nil) or keyPressed;
  closeGraph
END.


