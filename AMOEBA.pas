program Amoeba;
uses graph, crt, printer;
type
  Place = ^Life;
  Life = record
           Age, Clone   : byte;
           Energy, X, Y : integer;
           Gene         : array[0..5] of byte;
           Rate         : array[0..5] of real;
           Prev, Next   : Place
         end;
const
  Size = 6;
  MatuAge = 7;
  MatuEnergy = 600;
  DeadAge = 35;
  BasicEnergy = 200;
  MoveEnergy = 5;
  BaseEcoli = 8000;
  NewEcoli = 4;
  EcoliEnergy =100;
  DirX : array[0..5] of integer = (0,2,2,0,-2,-2);
  DirY : array[0..5] of integer = (-2,-1,1,2,1,-1);
  EdenL = 144;
  EdenW = 70;
  Counter : integer = 0;
  GameOver : Boolean = false;
var
  Root, Bug, NextBug : Place;
  MaxX, MaxY : integer;

procedure Document;
begin
  clrscr;
  gotoXY(20,2);
  writeln('This program is a simulation of evolution.');
  gotoXY(11,6);
  writeln('One squre means one amoeba which can eat white spots as food.');
  writeln(' ':10,'There are 6 directions each amoeba could move on.');
  writeln(' ':10,'The age and energy decide when an amoeba will die or');
  writeln(' ':12,'process mitosis.');
  writeln(' ':10,'Except the center regin of screen, white spots are only');
  writeln(' ':12,'dropped at the beginning.');
  writeln(' ':10,'Its path depends on the relative ratio of its 6 genes');
  writeln(' ':12,'which may get mutation only at splitting.');
  writeln;
  writeln(' ':12,'LET  MatuAge=7   DeadAge=35       Gene-0:N   Gene-1:NE');
  write('':9,'BasicEnergy=200  EcoliEnergy=100  MoveEnergy=5  MatuEnergy=600');
  gotoXY(5,22);
  writeln('Make sure under the graphic mode ' +
          'and have better turn on your printer !');
  writeln(' ':18,'press [Esc] to exit, any other key to go ...');
  repeat until keypressed;
  if readKey = #27 then halt;
  clrscr
end;

procedure Set_Graph;
var
  GraphDevice,GraphMode : integer;
  PathtoBGI : string;
begin
  write('Please enter the path of .BGI ..... ');
  readln(PathToBGI);
  GraphDevice := detect;
  initGraph(GraphDevice,GraphMode,PathToBGI);
  if graphResult <> grOK then halt;
  setColor(white);
  MaxX := getMaxX;
  MaxY := getMaxY
end;

procedure Hardcopy;
type
  ScanPage = record
               PinByte : array[0..86,0..29,0..2] of char;
               Unused : array[0..361] of char
             end;
var
  Scan : array[0..3] of ScanPage absolute $B000:$0000;
  L, C, P, B : integer;
begin
  write(lst,#27#51#24);
  for C := 0 to 29 do
  begin
    write(lst,#27#42#38#92#1);
    for L := 86 downto 0 do for P := 3 downto 0 do for b := 0 to 2 do
      write(lst,Scan[P].PinByte[L,C,B]);
    writeln(lst)
  end
end;

procedure Title;
var DumbChr : char;
begin
  clearDevice;
  setTextStyle(defaultFont,horizDir,5);
  outTextXY(110,98,'AMOEBA');
  setColor(black);
  outTextXY(103,91,'AMOEBA');
  setColor(white);
  outTextXY(100,89,'AMOEBA');
  setFillStyle(wideDotFill,1);
  fillEllipse(500,100,50,80);
  setFillStyle(closeDotFill,1);
  fillEllipse(500,100,25,30);
  setTextStyle(defaultFont,horizDir,1);
  outTextXY(280,170,'----- Jau,Wei-Leung');
  outTextXY(200,250,'refer to  [ Scientific American May 1989, p.104~107 ]');
  outTextXY(100,300,'press [Enter] to start .....');
  line(0,333,MaxX,333);
  outTextXY(7,340,'{ON RUNNIMG} : [A]_Analyze   [C]_Clear   [F]_Feed'+
                   '   [H]_Hardcopy   [S]_Stop   [Esc]_Exit');
  repeat
    DumbChr := upcase(readKey);
    if DumbChr = 'H' then HardCopy;
    if DumbChr = #27 then halt
  until DumbChr = #13;
  clearDevice
end;

procedure Initiate;
const
  StartAmoebas = 20;
  ProGene = 6;
  I : byte = 0;
var
  NewNode, CurrNode : Place;
procedure CreateData(var Node : Place);
  var
    Base : word;
    J : byte;
  begin
    with Node^ do
    begin
      Age := 0;
      Energy := BasicEnergy + 10 + random(100);
      fillchar(Gene,sizeof(Gene),ProGene);
      Base := 6 * sqr(ProGene);
      for J := 0 to 5 do Rate[J] := sqr(Gene[J]) / Base;
      X := random(MaxX);
      Y := random(MaxY);
      Clone := I
    end
  end;

begin
  randomize;
  new(Root);
  Root^.Prev := Root;
  CreateData(Root);
  Root^.Next := Root;
  CurrNode := Root;
  Bug := Root;
  for I := 1 to StartAmoebas do
  begin
    new(NewNode);
    CurrNode^.Next := NewNode;
    NewNode^.Prev := CurrNode;
    CreateData(NewNode);
    NewNode^.Next := Root;
    Root^.Prev := NewNode;
    CurrNode := NewNode
  end
end;

procedure Put_Ecoli(EcoliNum,LowX,LowY,LenX,LenY : integer);
var
  EcoliX, EcoliY, I : integer;
begin
  for I := 1 to EcoliNum do
  begin
    EcoliX := random(LenX) + LowX;
    EcoliY := random(LenY) + LowY;
    putPixel(EcoliX,EcoliY,1);
    setActivePage(1);
    putPixel(EcoliX,EcoliY,1);
    setActivePage(0)
  end
end;

procedure Move_Amoeba;
var Rnd, Value : real;
    I : byte;
begin
  with Bug^ do
  begin
    setColor(black);
    rectangle(X,Y,X + Size,Y + Size);
    Rnd := random;
    Value := 0;
    I := 0;
    repeat
      Value := Value + Rate[i];
      inc(I)
    until (Value >= Rnd);
    dec(I);
    X := (X + DirX[I] + MaxX) mod MaxX;
    Y := (Y + DirY[I] + MaxY) mod MaxY;
    dec(Energy,MoveEnergy);
    setColor(white);
    rectangle(X,Y,X + Size,Y + Size);
  end
end;

procedure Die;
begin
  sound(58);
  delay(58);
  nosound;
  setColor(black);
  with Bug^ do
  begin
    rectangle(X,Y,X + Size,Y + Size);
    Prev^.Next := Next;
    Next^.Prev := Prev;
    if Bug = Root then if Next = Bug then GameOver := true else Root := Prev
  end;
  setColor(white);
  dispose(Bug)
end;

procedure Mitosis;
const
  Mutation : array[0..8] of -2..2 = (-2,-1,-1,0,0,0,1,1,2);
var
  I : boolean;
  Son : Place;
  Change, J : integer;
  Base : word;
begin
  for I := false to true do
  begin
    new(Son);
    with Son^ do
    begin
      Age := 0;
      Energy := Bug^.Energy shr 1;
      X := Bug^.X + DirX[random(6)];
      Y := Bug^.Y + DirY[random(6)];
      rectangle(X,Y,X + Size,Y + Size);
      Gene := Bug^.Gene;
      Change := Mutation[random(9)];
      if Change = 0 then Rate := Bug^.Rate
      else
      begin
        J := random(6);
        if Gene[J] + Change < 0 then Gene[J] := 0 else inc(Gene[J],Change);
        Base := 0;
        for J := 0 to 5 do inc(Base,sqr(Gene[J]));
        for J := 0 to 5 do Rate[J] := sqr(Gene[J]) / Base
      end;
      Clone := Bug^.Clone;
      Prev := Bug^.Prev;
      Prev^.Next := Son;
      Next := Bug;
      Next^.Prev := Son
    end
  end;
  Die
end;

procedure Predate;
var
  I, J, Ii, Jj : integer;
begin
  with Bug^ do
  begin
    setActivePage(1);
    for I := X to X+Size do for J := Y to Y+Size do
    begin
      Ii := I mod MaxX;
      Jj := J mod MaxY;
      if getPixel(Ii,Jj) = 1 then
      begin
        setActivePage(0);
        putPixel(Ii,Jj,0);
        setActivePage(1);
        putPixel(Ii,Jj,0);
        inc(Energy,EcoliEnergy)
      end
    end;
    setActivePage(0)
  end
end;

procedure Analyze;
type
  GraphPageMem = array[$0..$8000] of byte;
  AxisType = record
               Name : string[6];
               Grid : byte;
               Scale : byte
             end;
const
  AxisKey = '012345ACEVXYZB';
  Axis : array[0..length(AxisKey)] of AxisType = ((Name:'NONE';Grid:0;Scale:0),
         (Name:'GENE-0';Grid:15;Scale:1),(Name:'GENE-1';Grid:15;Scale:1),
         (Name:'GENE-2';Grid:15;Scale:1),(Name:'GENE-3';Grid:15;Scale:1),
         (Name:'GENE-4';Grid:15;Scale:1),(Name:'GENE-5';Grid:15;Scale:1),
         (Name:'AGE';Grid:17;Scale: 2),(Name:'CLONE';Grid:20;Scale:1),
         (Name:'ENERGY';Grid:20;Scale:60),(Name:'C.V.';Grid:20;Scale:8),
         (Name:'X coo.';Grid:20;Scale:35),(Name:'Y coo.';Grid:20;Scale:17),
         (Name:'ZONE';Grid:24;Scale:1),(Name:'BIG G.';Grid:5;Scale:1));
var
  PageNull : GraphPageMem absolute $B000:$0000;
  PageOne : GraphPageMem absolute $B800:$0000;
  Xscale, Yscale, AxN, AyN : byte;
  NeedCopy, AnalyzeEnd : boolean;
  DumbStr : string[4];
function WaitUpKey : char;
  begin
    repeat until keypressed;
    WaitUpKey := upcase(readkey)
  end;

  procedure SetAxes;
  begin
    fillchar(PageNull,sizeof(PageNull),0);
    setTextStyle(defaultFont,horizDir,2);
    str(Counter,DumbStr);
    outTextXY(338,20,DumbStr + 'th');
    outTextXY(90, 80,'[C]lone     co.[V]ariation     [A]ge');
    outTextXY(90,120,'Gene[0..5]     [E]nergy       [Z]one');
    outTextXY(90,160,'[B]iggest G.               ([X],[Y])');
    setTextStyle(defaultFont,horizDir,1);
    outTextXY(220,220,'Choose the Axis of X .....');
    AxN := pos(WaitUpKey,AxisKey);
    outTextXY(440,220,Axis[AxN].Name);
    outTextXY(220,245,'Choose the Axis of Y .....');
    AyN := pos(WaitUpKey,AxisKey);
    outTextXY(440,245,Axis[AyN].Name);
    outTextXY(210,310,'Do you want a HardCopy of it ? (Y/N)');
    NeedCopy := WaitUpKey = 'Y'
  end;

  procedure DrawAxes;
  var
    I : integer;
  begin
    fillchar(PageNull,sizeof(PageNull),0);
    line(30,315,710,315);
    line(90,347,90,10);
    outTextXY(30,335,DumbStr + 'th');
    setTextStyle(defaultFont,vertDir,1);
    outTextXY(30,140,Axis[AyN].Name);
    setTextStyle(defaultFont,horizDir,1);
    outTextXY(380,338,Axis[AxN].Name);
    if AxN = 0 then Xscale := 0 else Xscale := 575 div Axis[AxN].Grid;
    for I := 0 to Axis[AxN].Grid do
    begin
      str(I * Axis[AxN].Scale,DumbStr);
      outTextXY(110 + I * XScale,320,DumbStr)
    end;
    if AyN = 0 then Yscale := 0 else Yscale := 290 div Axis[AyN].Grid;
    for I := 0 to Axis[AyN].Grid do
    begin
      str(I * Axis[AyN].Scale,DumbStr);
      outTextXY(55,300 - I * Yscale,DumbStr)
    end
  end;

  procedure CollectData;
  var
    Xcoor, Ycoor : integer;
    NumOfBugs : array[0..24,0..24] of byte;
    function Index(AxisN : byte) : byte;
    var
      I : byte;
      Pre : word;
      SS : real;
    begin
      with Bug^ do case AxisN of
        0 : Pre := 0;
     1..6 : Pre := Gene[pred(AxisN)];
        7 : Pre := Age;
        8 : Pre := Clone;
        9 : Pre := Energy;
       10 : begin
              SS := 0;
              for I := 0 to 5 do SS := SS + sqr(Rate[I] - 1/6);
              Pre := round(sqrt(SS * 60000))
            end;
       11 : Pre := X;
       12 : Pre := MaxY - Y;
       13 : Pre := ((MaxY - Y) div EdenW) * 5 + X div EdenL;
       14 : begin
              Pre := 0;
              for I := 1 to 5 do if Gene[Pre] < Gene[I] then Pre := I
            end
      end;
      if AxisN = 0 then Index := 0 else Index := Pre div Axis[AxisN].Scale
    end;

  begin
    fillchar(NumOfBugs,sizeof(NumOfBugs),0);
    repeat
      Xcoor := Index(AxN);
      Ycoor := Index(AyN);
      str(NumOfBugs[Xcoor,Ycoor],DumbStr);
      setColor(black);
      outTextXY(110 + Xcoor*Xscale,300 - Ycoor*Yscale,DumbStr);
      inc(NumOfBugs[Xcoor,Ycoor]);
      str(NumOfBugs[Xcoor,Ycoor],DumbStr);
      setColor(white);
      outTextXY(110 + Xcoor*Xscale,300 - Ycoor*Yscale,DumbStr);
      Bug := Bug^.Next
    until Bug = Root
  end;

  procedure AskForEnd;
  begin
    if NeedCopy then HardCopy;
    setTextStyle(defaultFont,horizDir,1);
    outTextXY(210,0,'Do you want to Analyze it again ? (Y/N)');
    AnalyzeEnd := WaitUpKey = 'N'
  end;

  procedure ResetFigure;
  begin
    PageNull := PageOne;
    repeat
      with Bug^ do
      begin
        rectangle(X,Y,X + Size,Y + Size);
        Bug := Next
      end
    until Bug = Root
  end;

begin
  repeat
    SetAxes;
    DrawAxes;
    CollectData;
    AskForEnd;
  until AnalyzeEnd;
  ResetFigure
end;


begin
  Document;
  Set_Graph;
  Title;
  Initiate;
  Put_Ecoli(BaseEcoli,0,0,MaxX,MaxY);
  repeat
    Put_Ecoli(NewEcoli,(MaxX-EdenL) shr 1,(MaxY-EdenW) shr 1,EdenL,EdenW);
    repeat
      NextBug := Bug^.Next;
      Move_Amoeba;
      inc(Bug^.Age);
      if (Bug^.Energy < BasicEnergy) or (Bug^.Age > DeadAge) then Die
      else
        if (Bug^.Energy > MatuEnergy) and (Bug^.Age > MatuAge) then Mitosis
        else Predate;
      Bug := NextBug;
    until Bug = Root;
    inc(Counter);
    if keyPressed then
      case upcase(readKey) of
        'A' : Analyze;
        'C' : clearDevice;
        'F' : Put_Ecoli(BaseEcoli shr 2,0,0,MaxX,MaxY);
        'H' : HardCopy;
        'S' : repeat until keypressed;
        #27 : GameOver := true
      end;
  until GameOver;
  closeGraph
end.


