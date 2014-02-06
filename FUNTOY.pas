program FunFour;
uses graph,crt;
const
  XYRatio = 1;
  BlockCount = 4;
  BlockLine : array[boolean] of lineSettingsType
            = ((linestyle:solidln;pattern:0;thickness:normwidth),
               (linestyle:solidln;pattern:0;thickness:thickwidth));
  EndRun : boolean = false;
  Complexity : string[2] = ' 1';
  CostTime : string[2] = '00';
  XYCoor : string[15] = 'X : 000 Y : 000';
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
  XforS, YforS, XforC, YforC, XforP, YforP : word;
  FunToy, SavedToy : Toy;

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

procedure Ask_Menu;
begin
  assign(F,'BLOCK4.DAT');
end;

procedure Draw_Help;
  procedure Draw_Key(X, Y ,Time : integer; Prompt : char);
  begin
  end;

begin
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
  Complexity := '01';
  CostTime := '00';
  XforP := 8;
  YforP := Yunit * 7;
  TurnAngle := pi / 4
end;

procedure Draw_Stage;
begin
  cleardevice;
  rectangle(0,0,getmaxx,Yunit * 2);
  outtextxy(Xunit * 2,Yunit,'F1 : HELP');
  outtextxy(Xunit * 8,Yunit,'F2 : SAVE');
  outtextxy(Xunit * 14,Yunit,'F3 : HINT');
  outtextxy(Xunit * 20,Yunit,'F4 : NEXT');
  outtextxy(Xunit * 26,Yunit,'Esc : EXIT');
  rectangle(0,succ(Yunit * 6),Xunit * 6,pred(Yunit * 14));
  outtextxy(XforP,YforP,XYCoor);
  outtextxy(Xunit,Yunit * 9,'Complexity');
  outtextxy(Xunit * 3,Yunit * 10,Complexity);
  outtextxy(Xunit,Yunit * 12,'Cost Time');
  outtextxy(Xunit,Yunit * 13,CostTime + ' Minites');
  rectangle(0,Yunit * 14,getmaxx,getmaxy);
  outtextxy(Xunit,Yunit * 15,'1:LD  2:D  3:RD  4:L  6:R  7:LU  8:U  9:RU');
  outtextxy(Xunit * 17,Yunit * 15,'*:TURN  /:MIRROR  .:BACK  Enter:COMPARE')
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
      X := round(X div 2 * XYRatio);
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
  reset(F);
  seek(F,ToyPoint);
  read(F,SavedToy);
  setwritemode(copyput);
  for I := 1 to BlockCount do with SavedToy[I] do
    fillpoly(succ(Side),Corner);
  setwritemode(xorput);
  with BlockLine[true] do setlinestyle(linestyle,pattern,thickness)
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

procedure Special_Key;
const
  NewKey : array[#71..#83] of char = '789 456 1230.';

  procedure Save_Block;
  var
    SavedToy : Toy;
    Xo, Yo, I, J : integer;
  begin
    Toy_Center(Xo,Yo);
    for I := 1 to BlockCount do
    begin
      SavedToy[I] := FunToy[I];
      with SavedToy[I] do
      for J := 0 to Side do with Corner[J] do
      begin
        X := (X - Xo) div 4 + XforS;
        Y := (Y - Yo) div 4 + YforS
      end
    end;
    write(F,SavedToy);
    Key := '.'
  end;

begin
  Key := readkey;
  case Key of
    #71..#83 : begin
                 Key := NewKey[Key];
                 OneStep := false
               end;
    #59 : begin
            setvisualpage(1);
            repeat until keypressed;
            Key := chr(0 and ord(readkey))
          end;
{   #60 : Save_Block;}
    #61 : begin
            with SavedToy[BlockNum] do drawpoly(succ(Side),Corner);
            Key := #0
          end;
    #62 : begin
            ToyPoint := (ToyPoint + 1) mod filesize(F);
            Show_Sample;
            Key := #0
          end;
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
  XCoor, YCoor : string[3];
  I : integer;
begin
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  setcolor(black);
  outtextxy(XforP,YforP,XYCoor);
  setcolor(white);
  with FunToy[BlockNum] do with BlockWindow do
  begin
    inc(Xc,MoveDir[OneStep,Key].X);
    inc(Yc,MoveDir[OneStep,Key].Y);
    str(Xc - x1,XCoor);
    str(y2 - Yc,YCoor);
    for I := 0 to Side do
    begin
      inc(Corner[I].X,MoveDir[OneStep,Key].X);
      inc(Corner[I].Y,MoveDir[OneStep,Key].Y)
    end;
    drawpoly(succ(Side),Corner)
  end;
  OneStep := true;
  XYCoor := 'X : '+XCoor+' Y : '+YCoor;
  outtextxy(XforP,YforP,XYCoor)
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
      Xx := (X - Xc) / XYRatio;
      R := sqrt(Xx * Xx + Y * Y);
      Angle[I] := Angle[I] + TurnAngle;
      X := round(R * cos(Angle[I]) * XYRatio);
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
var
  XCoor, YCoor : string[3];
begin
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  with BlockLine[false] do setlinestyle(linestyle,pattern,thickness);
  with FunToy[BlockNum] do drawpoly(succ(Side),Corner);
  setcolor(black);
  outtextxy(XforP,YforP,XYCoor);
  setcolor(white);
  BlockNum := succ(BlockNum mod BlockCount);
  with FunToy[BlockNum] do
  begin
    str(Xc - BlockWindow.x1,XCoor);
    str(BlockWindow.y2 - Yc,YCoor);
    drawpoly(succ(Side),Corner);
    with BlockLine[true] do setlinestyle(linestyle,pattern,thickness);
    drawpoly(succ(Side),Corner)
  end;
  XYCoor := 'X : '+XCoor+' Y : '+YCoor;
  outtextxy(XforP,YforP,XYCoor)
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
begin
end;

procedure Game_Over;
begin
  EndRun := true;
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
  Ask_Menu;
  Draw_Help;
  Initiate;
  Draw_Stage;
  Set_Block;
  Change_Block;
  Show_Sample;
  repeat
    repeat until keypressed;
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