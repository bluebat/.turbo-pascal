program FunFour;
uses graph, dos, crt;
const
  BlockCount = 4;
  BlockLine : array[boolean] of lineSettingsType
            = ((linestyle:solidln;pattern:0;thickness:normwidth),
               (linestyle:solidln;pattern:0;thickness:thickwidth));
  EndRun : boolean = false;
  StepScale : string[5] = ' BIG ';
  CostTime : string[2] = '00';
  ToyPoint : word = 0;
  OneStep : boolean = true;
type
  AngleSet = array[0..5] of real;
  Block = record
            Xc, Yc : integer;
            Side : byte;
            Face : boolean;
            Angle : AngleSet;
            Corner : array[0..5] of pointtype
          end;
  Toy = array[1..BlockCount] of Block;
var
  F : file of Toy;
  Key : char;
  BlockNum : byte;
  Xunit, Yunit : integer;
  BlockWindow, HintWindow : viewporttype;
  TurnAngle : real;
  XforS, YforS, XforC, YforC, XforR, YforR : word;
  FunToy, SavedToy : Toy;
  StartHr, StartMin, StartSec, StartDs : word;

procedure Set_Graph;
var
  PathToBGI : string;
  GraphDevice, GraphMode : integer;
begin
  GraphDevice := detect;
  PathToBGI := '';
  initgraph(GraphDevice,GraphMode,PathToBGI);
  if graphresult <> grOK then halt
end;

procedure Initiate;
begin
  Xunit := succ(getmaxx) shr 5;
  Yunit := succ(getmaxy) shr 4;
  XforS := Xunit * 3;
  YforS := Yunit * 4;
  with BlockWindow do
  begin
    x1 := succ(Xunit * 6);
    y1 := succ(Yunit * 2);
    x2 := getmaxx;
    y2 := pred(Yunit * 14);
    clip := clipon
  end;
  with HintWindow do
  begin
    x1 := 0;
    y1 := succ(Yunit * 2);
    x2 := Xunit * 6;
    y2 := Yunit * 6;
    clip := clipon
  end;
  XforR := 8;
  YforR := Yunit * 7;
  TurnAngle := pi / 4
end;

procedure Draw_Help;
const
  I : byte = 1;
var
  T : text;
  CharList : string;
begin
  assign(F,'BLOCK4.DAT');
  reset(F);
  assign(T,'HELP.TOY');
  reset(T);
  setvisualpage(1);
  setactivepage(1);
  repeat
    readln(T,CharList);
    outtextxy(Xunit * 2,Yunit * I,CharList);
    inc(I)
  until eof(T);
  close(T);
  repeat until readkey <> #0;
  setvisualpage(0);
  setactivepage(0)
end;

procedure Draw_Stage;
begin
  rectangle(0,0,getmaxx,Yunit * 2);
  outtextxy(Xunit * 2,Yunit,'F1 : HELP');
  outtextxy(Xunit * 8,Yunit,'F2 : SAVE');
  outtextxy(Xunit * 14,Yunit,'F3 : HINT');
  outtextxy(Xunit * 20,Yunit,'F4 : NEXT');
  outtextxy(Xunit * 26,Yunit,'Esc : EXIT');
  rectangle(0,succ(Yunit * 6),Xunit * 6,pred(Yunit * 14));
  outtextxy(Xunit,Yunit * 9,'Step Scale');
  outtextxy(Xunit,Yunit * 12,'Cost Time');
  outtextxy(Xunit * 2,Yunit * 13,'Minites');
  rectangle(0,Yunit * 14,getmaxx,getmaxy);
  outtextxy(Xunit,Yunit * 15-16,'7  8  9');
  outtextxy(Xunit,Yunit * 15,'4     6 : MOVE BLOCK');
  outtextxy(Xunit,Yunit * 15+16,'1  2  3');
  outtextxy(Xunit * 11,Yunit * 15-16,'/ : TURN OVER     * : ROTATE');
  outtextxy(Xunit * 11,Yunit * 15,'Num Lock : SWITCH STEP SCALE');
  outtextxy(Xunit * 11,Yunit * 15+16,'0 : ALTER TARGET  . : RETURN');
  outtextxy(Xunit * 24,Yunit * 15,'Enter : COMPARE')
end;

procedure Set_Block;
const
  OriginToy : array[1..BlockCount] of Block =
   ((Xc:230;Yc:200;Side:4;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:141),(X:50;Y:-141),(X:-50;Y:-141),(X:-50;Y:41),(X:50;Y:141),(X:0;Y:0))),
    (Xc:350;Yc:200;Side:5;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:141),(X:50;Y:-141),(X:-21;Y:-71),(X:-50;Y:-100),(X:-50;Y:41),(X:50;Y:141))),
    (Xc:490;Yc:200;Side:4;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:71;Y:50),(X:71;Y:-50),(X:-71;Y:-50),(X:30;Y:50),(X:71;Y:50),(X:0;Y:0))),
    (Xc:630;Yc:200;Side:3;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:50),(X:50;Y:-50),(X:-50;Y:-50),(X:50;Y:50),(X:0;Y:0),(X:0;Y:0))));
var
  I : integer;
begin
  setcolor(white);
  setwritemode(xorput);
  with BlockLine[false] do setlinestyle(linestyle,pattern,thickness);
  with BlockWindow do rectangle(x1,y1,x2,y2);
  for BlockNum := 1 to BlockCount do
  begin
    FunToy[BlockNum] := OriginToy[BlockNum];
    with FunToy[BlockNum] do for I := 0 to Side do with Corner[I] do
    begin
      X := X div 2;
      Y := Y div 2;
      if X = 0 then Angle[I] := pi / 2 + pi * ord(Y < 0)
               else Angle[I] := arctan(Y / X) + pi * ord(X < 0);
      inc(X,Xc);
      inc(Y,Yc)
    end;
    if BlockNum = BlockCount then with BlockLine[true] do
      setlinestyle(linestyle,pattern,thickness);
    with FunToy[BlockNum] do drawpoly(succ(Side),Corner)
  end
end;

procedure Show_Sample;
var
  I : integer;
begin
  with HintWindow do setviewport(x1,y1,x2,y2,clip);
  clearviewport;
  setviewport(0,0,getmaxx,getmaxy,clipon);
  with BlockLine[false] do setlinestyle(linestyle,pattern,thickness);
  with HintWindow do rectangle(x1,y1,x2,y2);
  seek(F,ToyPoint);
  read(F,SavedToy);
  setwritemode(copyput);
  for I := 1 to BlockCount do with SavedToy[I] do
    fillpoly(succ(Side),Corner);
  setwritemode(xorput);
  with BlockLine[true] do setlinestyle(linestyle,pattern,thickness);
  gettime(StartHr,StartMin,StartSec,StartDs)
end;

procedure Show_State;
var
  Hr, Min, Sec, Ds, AbsMin : word;
  CostMin : string[2];
  Step : string[5];
begin
  gettime(Hr,Min,Sec,Ds);
  AbsMin := ((Hr*60+Min)*60+Sec - ((StartHr*60+StartMin)*60+StartSec)) div 60;
  str(AbsMin:2,CostMin);
  OneStep := mem[0:1047] and 32 > 0;
  if OneStep then Step := ' BIG ' else Step := 'SMALL';
  if (CostMin <> CostTime) or (Step <> StepScale) then
  begin
    setcolor(black);
    outtextxy(Xunit,Yunit * 13,CostTime);
    CostTime := CostMin;
    outtextxy(Xunit * 2,Yunit * 10,StepScale);
    StepScale := Step;
    setcolor(white);
    outtextxy(Xunit,Yunit * 13,CostTime);
    outtextxy(Xunit * 2,Yunit * 10,StepScale)
  end
end;

procedure Toy_Center(var Xo, Yo : integer);
var
  I, J : integer;
  RightX, LeftX, UpY, DownY : integer;
begin
  for I := 1 to BlockCount do with FunToy[I] do
  for J := 0 to Side do with Corner[J] do
  begin
    if (I = 1) and (J = 0) then
    begin
      RightX := X;
      LeftX := X;
      UpY := Y;
      DownY := Y
    end;
    if X > RightX then RightX := X;
    if X < LeftX then LeftX := X;
    if Y > DownY then DownY := Y;
    if Y < UpY then UpY := Y
  end;
  Xo := (RightX + LeftX) shr 1;
  Yo := (UpY + DownY) shr 1
end;

procedure Toy_Model(var ModelToy : Toy);
var
  Xo, Yo, I, J : integer;
begin
  Toy_Center(Xo,Yo);
  for I := 1 to BlockCount do
  begin
    ModelToy[I] := FunToy[I];
    with ModelToy[I] do
    for J := 0 to Side do with Corner[J] do
    begin
      X := (X - Xo) div 4 + XforS;
      Y := (Y - Yo) div 4 + YforS
    end
  end
end;

procedure Special_Key;
const
  NewKey : array[#71..#83] of char = '789 456 1230.';
var
  ModelToy : Toy;
begin
  Key := readkey;
  if Key in [#71..#83] then Key := NewKey[Key]
  else case Key of
    #59 : begin
            setvisualpage(1);
            repeat until readkey <> #0;
            setvisualpage(0)
          end;
    #60 : begin
            Toy_Model(ModelToy);
            seek(F,filesize(F));
            write(F,ModelToy);
            seek(F,ToyPoint)
          end;
    #61 : with SavedToy[BlockNum] do drawpoly(succ(Side),Corner);
    #62 : begin
            ToyPoint := (ToyPoint + 1) mod filesize(F);
            Show_Sample;
          end
  end
end;

procedure Move_Block;
const
  MoveDir : array[boolean,'1'..'9'] of pointtype
          =(((X:-1;Y:1),(X:0;Y:1),(X:1;Y:1),(X:-1;Y:0),(X:0;Y:0),
             (X:1;Y:0),(X:-1;Y:-1),(X:0;Y:-1),(X:1;Y:-1)),
            ((X:-10;Y:10),(X:0;Y:10),(X:10;Y:10),(X:-10;Y:0),(X:0;Y:0),
             (X:10;Y:0),(X:-10;Y:-10),(X:0;Y:-10),(X:10;Y:-10)));
var
  I : integer;
begin
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  with FunToy[BlockNum] do
  begin
    inc(Xc,MoveDir[OneStep,Key].X);
    inc(Yc,MoveDir[OneStep,Key].Y);
    for I := 0 to Side do
    begin
      inc(Corner[I].X,MoveDir[OneStep,Key].X);
      inc(Corner[I].Y,MoveDir[OneStep,Key].Y)
    end;
    drawpoly(succ(Side),Corner)
  end
end;

procedure Turn_Block;
var
  Xx, R : real;
  I : integer;
begin
  with FunToy[BlockNum] do
  begin
    drawpoly(succ(Side),Corner);
    for I := 0 to Side do with Corner[I] do
    begin
      dec(Y,Yc);
      Xx := X - Xc;
      R := sqrt(Xx * Xx + Y * Y);
      Angle[I] := Angle[I] + TurnAngle;
      X := round(R * cos(Angle[I]));
      Y := round(R * sin(Angle[I]));
      inc(X,Xc);
      inc(Y,Yc)
    end;
    drawpoly(succ(Side),Corner)
  end
end;

procedure Mirror_Block;
var
  I : integer;
begin
  with FunToy[BlockNum] do
  begin
    drawpoly(succ(Side),Corner);
    Face := not Face;
    for I := 0 to Side do
    begin
      Angle[I] := -Angle[I];
      with Corner[I] do Y := -(Y - Yc) + Yc
    end;
    drawpoly(succ(Side),Corner)
  end
end;

procedure Change_Block;
begin
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  with BlockLine[false] do setlinestyle(linestyle,pattern,thickness);
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  BlockNum := succ(BlockNum mod BlockCount);
  with FunToy[BlockNum] do
  begin
    drawpoly(succ(Side),Corner);
    with BlockLine[true] do setlinestyle(linestyle,pattern,thickness);
    drawpoly(succ(Side),Corner)
  end
end;

procedure Return_Block;
begin
  with BlockWindow do setviewport(x1,y1,x2,y2,clip);
  clearviewport;
  setviewport(0,0,getmaxx,getmaxy,clipon);
  Set_Block;
  Change_Block
end;

procedure Compare;
const
  Reaction : array[boolean,0..2] of string[17]
    = ((('Don''t so hurry!'),('Look it More!'),('Just try again!')),
       (('Wao! Genius!'),('It''s easy to you!'),('That is right!')));
var
  ModelToy : Toy;
  SameToy : boolean;
  I, J, AbsMin : integer;
begin
  SameToy := true;
  Toy_Model(ModelToy);
  for I := 1 to BlockCount do with ModelToy[I] do
  for J := 0 to Side do with Corner[J] do
  if (abs(X-SavedToy[I].Corner[J].X) > 1) or (abs(Y-SavedToy[I].Corner[J].Y) > 1)
    then SameToy := false;
  val(CostTime,AbsMin,I);
  case AbsMin of
       0 : ;
    1..5 : AbsMin := 1;
    else AbsMin := 2
  end;
  for I := 1 to 6 do
  begin
    outtextxy(XforR,YforR,Reaction[SameToy,AbsMin]);
    delay(42);
    setcolor(black);
    outtextxy(XforR,YforR,Reaction[SameToy,AbsMin]);
    setcolor(white)
  end
end;

procedure Game_Over;
begin
  EndRun := true;
  close(F);
  closeGraph
end;

procedure Mistake;
begin
  sound(1540);
  delay(16);
  nosound
end;

begin
  Set_Graph;
  Initiate;
  Draw_Help;
  Draw_Stage;
  Set_Block;
  Change_Block;
  Show_Sample;
  repeat
    repeat Show_State until keypressed;
    Key := readkey;
    if Key = chr(0) then Special_Key;
    case Key of
      '1'..'4','6'..'9' : Move_Block;
      '*'               : Turn_Block;
      '/'               : Mirror_Block;
      '.'               : Return_Block;
      '0'               : Change_Block;
      #13               : Compare;
      #0                : ;
      #27               : Game_Over
    else Mistake
    end
  until EndRun
end.


