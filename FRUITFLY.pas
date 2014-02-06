program FruitFly;
uses crt, printer;
type
  History = (Egg, Lava, Pupa, Younger, Adult, Parent, Sterile);
  Gene = (XX, y, w, cv, v, f, vg, st, e);
  Chromosome = array[1..3,0..1] of set of Gene;
  Gender = (Female, Male);
  LifePtr = ^Life;
  Life = record
           AbsMin, RelMin : word;
           X, Y : byte;
           Stage      : History;
           Genome     : Chromosome;
           Sex        : Gender;
           Energy     : word;
           Prev, Next : LifePtr
         end;
  TextPageMem = array[1..25,1..80] of array[0..1] of char;
  OneRow = string[80];
const
  DeadHour = 360;
  RipeHour : array[History] of byte = (40,100,70,8,1,50,70);
  Body : array[History] of char = ('o','','','','','','');
  Sexual : array[Gender] of char = (#112,#7);
  EggSpace : byte = 128;
  StepinHour = 20;
  MoveEnergy = 1;
  BreedEnergy : array[Gender] of byte = (80,10);
  BaseEnergy = (DeadHour + 80) * StepinHour * MoveEnergy;
  Counter : word = 0;
  GameOver : boolean = false;
  MaxX = 79;
  MaxY = 20;
  MinX = 2;
  MinY = MinX;
  TopY = 23;
var
  PageNull : TextPageMem absolute $B000:$0000;
  PageOne : TextPageMem absolute $B200:$0000;
  PageTwo : TextPageMem absolute $B400:$0000;
  Root, Fly, NextFly : LifePtr;
  Movable : boolean;
  AbsAge, RelAge : word;
  Pair, FlyNum : byte;
  FlyGenome : array[Gender] of Chromosome;
  FlyStage : History;

function WaitUpKey : char;
begin
  repeat until keypressed;
  WaitUpKey := upcase(readkey)
end;

procedure WriteXY(X, Y : byte;S :OneRow);
var
  Cn : byte;
begin
  gotoXY(X,Y);
  Cn := pos('|',S);
  if Cn = 0 then write(S) else
  begin
    case S[succ(Cn)] of
      'I' : begin
              textbackground(lightgray);
              textcolor(black)
            end;
      'B' : textcolor(lightgray + blink);
      'H' : highvideo
    end;
    delete(S,Cn,2);
    write(S);
    textAttr := lightgray
  end
end;


procedure Title;
begin                                                                 {.Title}
  clrscr;
  WriteXY(24,4,'FRUIT  FLY|H');
  WriteXY(39,6,'----- Wilhelm Chao');
  WriteXY(33,10,'DATE : July  1991');
  WriteXY(12,15,'Do you have turn on your printer, if you want some copy ? ');
  if WaitUpKey = 'Y' then write(lst,#27#116#1#27#54);
  WriteXY(31,19,'HOT KEY on running|H');
  WriteXY(15,20,'[A]_Analyze        [K]_Kill fly        [S]_Stop');
  WriteXY(25,21,'[W]_Watch design      [Esc]_Exit');
  WriteXY(25,23,'press [Enter] to read next page|B');
  repeat until readkey = #13
end;                                                                  {.Title}

procedure Document;
begin                                                              {.Document}
  clrscr;
  WriteXY(19,2,'This program is a simulation of genetics.|H');
  gotoXY(13,6);
  writeln('One character means one fruit fly which living in the tube.');
  writeln(' ':12,'There are 9 directions each fruit fly could move on.');
  writeln(' ':12,'The age and energy decide when a fruit fly will die or');
  writeln(' ':12,'process fertilization.');
  writeln(' ':12,'Its type depends on the genes on the three pairs of');
  writeln(' ':12,'chromosomes, which you can deside.');
  WriteXY(24,14,'LET  StepinHour=20  DeadHour=360');
  WriteXY(16,15,'BaseEnergy=460  BreedEnergy=80,10  MoveEnergy=1');
  WriteXY(24,22,'Press [Enter] to design mutants|B');
  repeat until readkey = #13
end;                                                               {.Document}

procedure Design_Mutant;
type
  SquarePtr = ^Square;
  Square = record
             Xs, Xth : byte;
             Info : string[7];
             Prev, Next : SquarePtr
           end;
const
  GeneString = 'y    w    cv    v    f       vg      st    e';
  StageString = 'Egg   Lava   Pupa   Younger   Adult   Parent   Sterile';
  Yc : array[0..3] of byte = (4,7,10,13);
var
  GeneSet : array[0..3] of set of Gene;
  Head : SquarePtr;

  procedure ShowGenome;
  const
    DNA = '闡霰闡闡鼴闡霰闡闡霰闡闡鼴闡  闡鼴  闡霰闡闡霰闡';
  var
    J : byte;
  begin                                                        {..Show Genome}
    fillchar(GeneSet,sizeOf(GeneSet),0);
    WriteXY(31,2,'SET UP the MUTANTS|H');
    WriteXY(8,5,'Female');
    PageNull[5,16,0] := Body[Adult];
    PageNull[5,16,1] := Sexual[Female];
    WriteXY(9,11,'Male');
    PageNull[11,16,0] := Body[Adult];
    PageNull[11,16,1] := Sexual[Male];
    WriteXY(22,5,DNA);
    WriteXY(22,6,DNA);
    WriteXY(22,11,DNA);
    WriteXY(22,12,DNA);
    WriteXY(22,12,'闡闡闡闡闡闡闡闡闡闡闡闡闡闡');
    for J := 0 to 2 do WriteXY(25,Yc[J],GeneString);
    WriteXY(54,Yc[3],'vg      st    e');
    WriteXY(19,16,#26#27#24#25'...Move   <'#196'...Select/Un   [Esc]...OK')
  end;                                                         {..Show Genome}

    function SetMenu(S :OneRow) : SquarePtr;
    var
      Root, NewNode, CurrNode : SquarePtr;
      Site, ItemNum : byte;
      EndString : boolean;

      procedure CreateData(var Node : SquarePtr);
      var
        EndItem : boolean;
      begin                                                   {...Create Data}
        with Node^ do
        begin
          Xth := ItemNum;
          inc(ItemNum);
          Info := '';
          repeat
            case S[Site] of
              ' ' : EndItem := length(Info) > 0;
              else  begin
                      EndItem := false;
                      if Info = '' then Xs := 24 + Site;
                      Info := Info + S[Site]
                    end
            end;
            inc(Site);
            EndString := Site > length(S)
          until EndItem or EndString
        end
      end;                                                    {...Create Data}

    begin                                                         {..Set Menu}
      Site := 1;
      ItemNum := 1;
      new(Root);
      Root^.Prev := Root;
      CreateData(Root);
      Root^.Next := Root;
      CurrNode := Root;
      repeat
        new(NewNode);
        CurrNode^.Next := NewNode;
        NewNode^.Prev := CurrNode;
        CreateData(NewNode);
        NewNode^.Next := Root;
        Root^.Prev := NewNode;
        CurrNode := NewNode
      until EndString;
      SetMenu := Root
    end;                                                          {..Set Menu}

  procedure GetGenome;
  var
    R : byte;
    Fkey : char;
    EndGet : boolean;

  begin                                                         {..Get Genome}
    R := 0;
    EndGet := false;
    WriteXY(Head^.Xs,Yc[R],Head^.Info + '|B');
      repeat
        repeat until keypressed;
        with Head^ do if Gene(Xth) in GeneSet[R]
          then WriteXY(Xs,Yc[R],Info + '|I') else WriteXY(Xs,Yc[R],Info);
        Fkey := readkey;
        if Fkey = #0 then Fkey := readkey;
        case Fkey of
          #77 : Head := Head^.Next;
          #75 : Head := Head^.Prev;
          #13 : GeneSet[R] := (GeneSet[R]+[Gene(Head^.Xth)])
                            - (GeneSet[R]*[Gene(Head^.Xth)]);
          #72 : R := (R - 1 + 4) mod 4;
          #80 : R := succ(R) mod 4;
          #27 : EndGet := true
        end;
        with Head^ do
        begin
          if (R = 3) and (Xth < 6) then R := 2;
          if Gene(Xth) in GeneSet[R] then FKey := 'I'
            else if EndGet then FKey := 'N' else FKey := 'B';
          WriteXY(Xs,Yc[R],Info + '|' + FKey)
        end
      until EndGet
  end;                                                          {..Get Genome}

procedure GetLife;
var
  Sex : Gender;
  I, Ii, StageN : byte;
begin                                                             {..Get Life}
  for Sex := Female to Male do for I := 0 to 1 do
  begin
    Ii := I + ord(Sex) shl 1;
    FlyGenome[Sex][1,I] := [y,w,cv,v] * GeneSet[Ii] + [XX];
    FlyGenome[Sex][2,I] := [vg] * GeneSet[Ii];
    FlyGenome[Sex][3,I] := [st,e] * GeneSet[Ii]
  end;
  FlyGenome[Male][1,1] := [y,w,cv,v];
  WriteXY(13,18,StageString);
  WriteXY(13,19,'[0]    [1]    [2]     [3]      [4]      [5]      [6]');
  WriteXY(26,21,'Which Stage do you want ?|H');
  repeat
    gotoXY(53,21);
    readln(StageN)
  until StageN in [0..6];
  FlyStage := History(StageN);
  WriteXY(31,23,'How many pairs ?  |H');
  repeat
    gotoXY(49,23);
    readln(Pair)
  until Pair in [1..5];
  FlyNum := Pair + Pair;
  WriteXY(28,25,'press [Enter] to return|B')
end;                                                              {..Get Life}

procedure ReleaseMenu;
var
  NextHead : SquarePtr;
  EndHead : boolean;
begin                                                         {..Release Menu}
  NextHead := Head;
  repeat
    Head := NextHead;
    NextHead := Head^.Next;
    EndHead := NextHead = Head;
    Head^.Prev^.Next := Head^.Next;
    Head^.Next^.Prev := Head^.Prev;
    dispose(Head)
  until EndHead
end;                                                          {..Release Menu}

begin                                                         {.Design Mutant}
  clrscr;
  ShowGenome;
  Head := SetMenu(GeneString);
  GetGenome;
  GetLife;
  ReleaseMenu;
  PageTwo := PageNull
end;                                                          {.Design Mutant}

procedure Set_Mutant;
var
  NewNode, CurrNode : LifePtr;
  G : Gender;
  I : byte;

  procedure CreateData(var Node : LifePtr);
  var
    S : History;
  begin                                                        {..Create Data}
    with Node^ do
    begin
      AbsMin := 0;
      if FlyStage > Egg then
        for S := Egg to pred(FlyStage) do inc(AbsMin,RipeHour[S] * StepinHour);
      RelMin := 0;
      Sex := G;
      Energy := BaseEnergy;
      Genome := FlyGenome[Sex];
      Stage := FlyStage;
      X := random(MaxX-MinX+1)+MinX;
      case Stage of
        Egg  : Y := MaxY;
        Lava : Y := random(TopY-MaxY)+succ(MaxY);
        Pupa : Y := MinY;
        else   Y := random(MaxY-MinY+1)+MinY
      end
    end
  end;                                                         {..Create Data}

begin
  randomize;                                                      {.Set Mutant}
  new(Root);
  Root^.Prev := Root;
  CreateData(Root);
  Root^.Next := Root;
  CurrNode := Root;
  for I := 1 to Pair do for G := Female to Male do
  begin
    new(NewNode);
    CurrNode^.Next := NewNode;
    NewNode^.Prev := CurrNode;
    CreateData(NewNode);
    NewNode^.Next := Root;
    Root^.Prev := NewNode;
    CurrNode := NewNode
  end;
  Root^.Prev^.Next := Root^.Next;
  Root^.Next^.Prev := Root^.Prev;
  dispose(Root);
  Root := CurrNode
end;                                                             {.Set Mutant}

procedure Design_Tube;
var I, J : byte;
begin                                                           {.Design Tube}
  clrscr;
  for J := 1 to TopY do
  begin
    PageNull[J,1,0] := '';
    PageNull[J,80,0] := ''
  end;
  PageNull[24,1,0] := '';
  PageNull[24,80,0] := '';
  for I := MinX to MaxX do PageNull[24,I,0] := '';
  for J := succ(MaxY) to TopY do for I := MinX to MaxX do
    PageNull[J,I,0] := '';
  WriteXY(8,25,'0 Hours');
  WriteXY(19,25,'[A]nalyze   [K]ill   [S]top   [W]atch   [Esc]|H');
  repeat
    with Fly^ do
    begin
      PageNull[Y,X,0] := Body[Stage];
      PageNull[Y,X,1] := Sexual[Sex];
      Fly := Next
    end
  until Fly = Root;
  gotoXY(68,25);
  write(FlyNum:3,' ind.');
  WriteXY(29,1,'Press [Enter] to start');
  readln;
  for I := MinX to MaxX do PageNull[1,I,0] := '_'
end;                                                            {.Design Tube}

procedure Die;
begin                                                                   {.Die}
  sound(58);
  delay(58);
  nosound;
  with Fly^ do
  begin
    Prev^.Next := Next;
    Next^.Prev := Prev;
    if Fly = Root then if Next = Fly then GameOver := true else Root := Prev;
    if Y > MaxY then PageNull[Y,X,0] := '' else PageNull[Y,X,0] := ' ';
    PageNull[Y,X,1] := Sexual[Male]
  end;
  dispose(Fly)
end;                                                                    {.Die}

procedure SelfStage;
var
  I, J : -1..1;
  JustMake, Damnable : boolean;
  Hx, Hy : byte;

  procedure ShiftStage;
  begin                                                        {..Shift Stage}
    with Fly^ do
    begin
      RelMin := 0;
      inc(Stage);
      PageNull[Y,X,0] := Body[Stage]
    end
  end;                                                         {..Shift Stage}

  procedure Fertilize(HisX, HisY : byte);
  var
    Mate : LifePtr;

  procedure Spawn;
  var
    I, J, K : byte;
    Offspring : LifePtr;
  begin                                                             {...Spawn}
    Fly^.RelMin := 0;
    Fly^.Stage := Sterile;
    for I := 1 to EggSpace shr 3 do
    begin
      new(Offspring);
      with Offspring^ do
      begin
        AbsMin := 0;
        RelMin := 0;
        Stage := Egg;
        Energy := BaseEnergy + random(10);
        for K := 1 to 3 do for J := 0 to 1 do
          Genome[K,J] := FlyGenome[Gender(J)][K,random(2)];
        Sex := Gender(not (XX in Genome[1,0] * Genome[1,1]));
        repeat
          X := random(succ(MaxX-MinX)) + MinX;
          Y := MaxY - random(2)
        until (PageNull[Y,X,0] = ' ') and (PageNull[Y+1,X,0] in ['','o']);
        PageNull[Y,X,0] := 'o';
        PageNull[Y,X,1] := Sexual[Sex];
        Prev := Fly^.Prev;
        Prev^.Next := Offspring;
        Next := Fly;
        Next^.Prev := Offspring
      end
    end;
    dec(EggSpace,EggSpace shr 3)
  end;                                                              {...Spawn}

  begin                                                          {..Fertilize}
      dec(Fly^.Energy,BreedEnergy[Fly^.Sex]);
      FlyGenome[Fly^.Sex] := Fly^.Genome;
      Mate := Fly;
      repeat Mate := Mate^.Next until (Mate^.X = HisX) and (Mate^.Y = HisY);
      FlyGenome[Mate^.Sex] := Mate^.Genome;
      if Fly^.Sex = Male then Fly := Mate;
      Spawn
  end;                                                           {..Fertilize}

begin                                                             {.SelfStage}
  Damnable := false;
  with Fly^ do
  begin
    inc(AbsMin);
    AbsAge := AbsMin div StepinHour;
    inc(RelMin);
    RelAge := RelMin div StepinHour;
    if RelAge > RipeHour[Stage] then
    case Stage of
      Egg : begin
              inc(EggSpace);
              ShiftStage
            end;
      Lava: if (PageNull[Y-1,X,0] = '_') or (PageNull[Y-2,X,0] = '_') and
               (PageNull[Y-1,X,0] = '') then ShiftStage;
      Pupa : ShiftStage;
      Younger: ShiftStage;
      Adult: begin
               JustMake := false;
               for I := -1 to 1 do for J := -1 to 1 do
               if (PageNull[Y + J,X + I,0] = Body[Adult]) and
                 (PageNull[Y + J,X + I,1] = Sexual[Gender(1 - ord(Sex))]) then
               begin
                 JustMake := true;
                 Hx := X + I;
                 Hy := Y + J
               end;
               if JustMake then Fertilize(Hx,Hy)
                 else if RelAge > RipeHour[Adult] + RipeHour[Parent] then
                 begin
                   RelMin := 0;
                   Stage := Sterile;
                   PageNull[Y,X,0] := Body[Sterile]
                 end
             end;
      Sterile: Damnable := (Energy = 0) or (AbsAge = DeadHour)
    end;
    Movable := not ((Stage in [Egg,Pupa]) or Damnable)
  end;
  if Damnable then Die
end;                                                              {.SelfStage}

procedure Action;
var
  I, J : -1..1;
  Xn, Yn : byte;
  Place, Behave, Possible : boolean;

begin                                                                {.Action}
  with Fly^ do
  begin
    Possible := false;
    if Y > MaxY then PageNull[Y,X,0] := '' else PageNull[Y,X,0] := ' ';
    PageNull[Y,X,1] := Sexual[Male];
    repeat
      Xn := X + pred(random(3));
      Yn := Y + pred(random(3));
      if pos(PageNull[Yn,Xn,0],' ') > 0 then
      begin
        Place := false;
        Behave := true;
        case Stage of
          Lava : begin
                   for I := -1 to 1 do for J := -1 to 1 do
                     if pos(PageNull[Yn+J,Xn+I,0],'捱_') > 0
                       then Place := true;
                   if RelAge > RipeHour[Lava] then
                     Behave := (Yn <= Y) and ((X-40)*(Xn-X)*(Y-MaxY+1) >= 0)
                   else Behave := Yn >= MaxY
                 end;
          else   Place := Yn <= MaxY
        end;
        Possible := Place and Behave;
        if (Yn = Y) and (Xn = X) then Possible := true;
        if Possible then
        begin
          PageNull[Yn,Xn,0] := Body[Stage];
          PageNull[Yn,Xn,1] := Sexual[Sex];
          dec(Fly^.Energy,MoveEnergy);
          X := Xn;
          Y := Yn
        end
      end
    until Possible
  end
end;                                                                 {.Action}

procedure Show_Count;
begin
  inc(Counter);
  gotoXY(6,25);
  write(Counter div StepinHour:3);
  gotoXY(68,25);
  write(FlyNum:3)
end;

procedure Analyze;
type
  AxisType = record
               Name : string[10];
               Grid : byte;
               Scale : word
             end;
const
  Ox = 15;
  Oy = 21;
  AxisKey = '12345678AEGSXY';
  Axis : array[0..length(AxisKey)] of AxisType = ((Name:'NONE';Grid:0;Scale:1),
         (Name:'yellow bo.';Grid:1;Scale:1),(Name:'white eyes';Grid:1;Scale:1),
         (Name:'c.veinless';Grid:1;Scale:1),(Name:'ver. eyes';Grid:1;Scale:1),
         (Name:'forked br.';Grid:1;Scale:1),(Name:'v. wings';Grid:1;Scale:1),
         (Name:'scar. eyes';Grid:1;Scale:1),(Name:'ebony body';Grid:1;Scale:1),
         (Name:'AGE (hr.)';Grid:12;Scale:54),(Name:'ENERGY';Grid:13;Scale:677),
         (Name:'GENDER';Grid:1;Scale:1),(Name:'LIFE STAGE';Grid:6;Scale:1),
         (Name:'X coor.';Grid:10;Scale:8),(Name:'Y coor.';Grid:12;Scale:2));
var
  Xscale, Yscale, AxN, AyN : byte;

  procedure SetAxes;
  begin                                                           {..Set Axes}
    clrscr;
    write(' ':35,Counter div StepinHour,' Hours');
    WriteXY(13,4,'[S]tage    [G]ender    [A]ge    [E]nergy    ([X],[Y])');
    WriteXY(24,6,'Genome[ 1, 2, 3, 4, 5, 6, 7, 8 ]');
    WriteXY(30,7,'( y  w  cv v  f  vg st e )');
    WriteXY(23,10,'Choose the Axis of X .....');
    AxN := pos(WaitUpKey,AxisKey);
    write(Axis[AxN].Name);
    WriteXY(23,12,'Choose the Axis of Y .....');
    AyN := pos(WaitUpKey,AxisKey);
    write(Axis[AyN].Name);
    WriteXY(27,16,'Make sure and press [Enter]|B');
    readln
  end;                                                            {..Set Axes}

  procedure DrawAxes;
  var
    I : byte;
  begin                                                          {..Draw Axes}
    clrscr;
    for I := 10 to 58 do PageNull[Oy,I,0] := '';
    for I := 6 to 23 do PageNull[I,Ox,0] := '';
    PageNull[Oy,Ox,0] := '';
    gotoXY(35,3);
    write(Counter div StepinHour,' Hours');
    WriteXY(11,5,Axis[AyN].Name);
    WriteXY(60,Oy,Axis[AxN].Name);
    Xscale := 40 div (Axis[AxN].Grid+1);
    for I := 0 to Axis[AxN].Grid do
    begin
      gotoXY(Ox + (I+1) * Xscale,22);
      write(I * Axis[AxN].Scale)
    end;
    Yscale := 14 div (Axis[AyN].Grid+1);
    for I := 0 to Axis[AyN].Grid do
    begin
      gotoXY(10,Oy - (I+1) * Yscale);
      write(I * Axis[AyN].Scale)
    end
  end;                                                           {..Draw Axes}

  procedure CollectData;
  var
    Xcoor, Ycoor, Xc, Yc : byte;
    CellNum : array[1..14,1..14] of byte;
    function Index(AxisN : byte) : byte;
    var
      Pre : word;
    begin                                                           {...Index}
      with Fly^ do case AxisN of
        0 : Pre := 0;
     1..5 : Pre := ord(Gene(AxisN) in Genome[1,0]*Genome[1,1]);
        6 : Pre := ord(Gene(AxisN) in Genome[2,0]*Genome[2,1]);
      7,8 : Pre := ord(Gene(AxisN) in Genome[3,0]*Genome[3,1]);
        9 : Pre := AbsMin div StepinHour;
       10 : Pre := Energy;
       11 : Pre := ord(Sex);
       12 : pre := ord(Stage);
       13 : Pre := X;
       14 : Pre := TopY - Y;
      end;
      Index := Pre div Axis[AxisN].Scale
    end;                                                            {...Index}

  begin                                                       {..Collect Data}
    fillchar(CellNum,sizeof(CellNum),0);
    repeat
      Xcoor := Index(AxN)+1;
      Ycoor := Index(AyN)+1;
      inc(CellNum[Xcoor,Ycoor]);
      Xc := Ox + Xcoor*Xscale;
      Yc := Oy - Ycoor*Yscale;
      gotoxy(Xc,Yc);
      write(CellNum[Xcoor,Ycoor]:2);
      Fly := Fly^.Next
    until Fly = Root
  end;                                                        {..Collect Data}

begin                                                               {.Analyze}
  PageOne := PageNull;
  repeat
    SetAxes;
    DrawAxes;
    CollectData;
    WriteXY(20,1,'Do you want to Analyze it again ? (Y/N)|B')
  until WaitUpKey = 'N';
  PageNull := PageOne
end;                                                                {.Analyze}

procedure KillFly;
var
  KillChar : char;
  I :byte;
begin                                                              {.Kill Fly}
  WriteXY(18,1,'    Kill it ? (Y/N)      [Esc] to return    ');
  repeat
    with Fly^ do
    begin
      NextFly := Next;
      repeat
        gotoXY(38,1);
        gotoXY(X,Y)
      until keypressed;
      KillChar := upcase(readkey)
    end;
    if KillChar = 'Y' then Die;
    Fly := NextFly
  until KillChar = #27;
  for I := MinX to MaxX do PageNull[1,I,0] := '_'
end;                                                               {.Kill Fly}

procedure WatchDesign;
begin                                                          {.Watch Design}
  PageOne := PageNull;
  PageNull := PageTwo;
  repeat until readkey = #13;
  PageNull := PageOne
end;                                                           {.Watch Design}


begin                                                              {Fruit Fly}
  Title;
  Document;
  Design_Mutant;
  Set_Mutant;
  Fly := Root;
  Design_Tube;
  repeat
    FlyNum := 0;
    repeat
      NextFly := Fly^.Next;
      SelfStage;
      if Movable then Action ;
      Fly := NextFly;
      inc(FlyNum)
    until Fly = Root;
    Show_Count;
    if keyPressed then
      case upcase(readKey) of
        'A' : Analyze;
        'K' : KillFly;
        'S' : repeat until keypressed;
        'W' : WatchDesign;
        #27 : GameOver := true
      end
  until GameOver
end.                                                               {Fruit Fly}


