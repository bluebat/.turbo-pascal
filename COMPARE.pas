program Compare;
const
  BlockCount = 4;
type
  pointtype = record
		X, Y : integer
	      end;
  AngleSet = array[0..5] of real;
  Block = record
	    Xc, Yc : integer;
	    Side : byte;
	    Face : boolean;
	    Angle : AngleSet;
	    Corner : array[0..5] of pointtype
	  end;
  Toy = array[1..BlockCount] of Block;
  PointTypePtr = ^pointtype;
  CornerTrainPtr = ^CornerTrain;
  CornerTrain = record
		  Coor : pointtype;
		  Next : CornerTrainPtr
		end;
var
  GoodMake, GoodLength : boolean;
  ManList, SampleList : CornerTrain;
  FunToy, SavedToy : Toy;
  BlockNum : byte;

procedure Set_Block;
const
  OriginToy : Toy =
   ((Xc:230;Yc:200;Side:4;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:141),(X:50;Y:-141),(X:-50;Y:-141),(X:-50;Y:41),(X:50;Y:141),(X:0;Y:0))),
    (Xc:350;Yc:200;Side:5;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:141),(X:50;Y:-141),(X:-21;Y:-71),(X:-50;Y:-100),(X:-50;Y:41),(X:50;Y:141))),
    (Xc:490;Yc:200;Side:4;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:71;Y:50),(X:71;Y:-50),(X:-71;Y:-50),(X:30;Y:50),(X:71;Y:50),(X:0;Y:0))),
    (Xc:730;Yc:200;Side:3;Face:true;Angle:(0,0,0,0,0,0);
    Corner:((X:50;Y:50),(X:50;Y:-50),(X:-50;Y:-50),(X:50;Y:50),(X:0;Y:0),(X:0;Y:0))));
var
  I : integer;
begin
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
  end;
  SavedToy := FunToy
end;

procedure Creat_Train(AToy : Toy;var RootCorner : CornerTrain);
var
  OneCorner, TwoCorner, TreeCorner : CornerTrain;
  FoundEnd : boolean;

  procedure Toy_Corner(var BeginCorner : pointtype);
  var
    I, J : integer;
  begin
    BeginCorner.X := 0;
    BeginCorner.Y := 0;
    for I := 1 to BlockCount do with AToy[I] do
    for J := 0 to Side do with Corner[J] do
      if (X > BeginCorner.X) or (X = BeginCorner.X) and (Y > BeginCorner.Y)
        then BeginCorner := Corner[J]
  end;

  procedure Right_Corner(Corner0,Corner1,Corner2 : pointtype;var CornerR : pointtype);
    function Arg(TopCorner,SideCorner : pointtype) : real;
    begin
      with SideCorner do
      begin
	dec(X,TopCorner.X);
	dec(Y,TopCorner.Y);
	if X = 0 then Arg := pi / 2 + pi * ord(Y < 0)
		 else Arg := arctan(Y / X) + pi * ord(X < 0)
      end
    end;
  begin
    if (Arg(Corner0,Corner1) > Arg(Corner0,Corner2))
      xor (abs(Arg(Corner0,Corner1) - Arg(Corner0,Corner2)) > pi)
      then CornerR := Corner1 else CornerR := Corner2
  end;

  procedure Next_Corner(LastCorner : pointtype;var RealNext : pointtype);
  var
    MayBeNext : PointType;
    I, J : integer;
    HaveFound : boolean;
  begin
    HaveFound := false;
    for I := 1 to BlockCount do with AToy[I] do
      for J := 1 to Side do with Corner[J] do
	if (abs(X - LastCorner.X) < 3) and (abs(Y - LastCorner.Y) < 3) then
        begin
	  Right_Corner(Corner[J],Corner[pred(J)],Corner[succ(J) mod Side],MayBeNext);
	  if not HaveFound then RealNext := MayBeNext
            else Right_Corner(LastCorner,RealNext,MayBeNext,RealNext);
          HaveFound := true
        end
  end;

  function Distance(Corner0,Corner1,Corner2 : pointtype) : byte;
  begin
    Distance := 5
  end;

begin
  Toy_Corner(OneCorner.Coor);
  writeln;writeln('rd -> (',OneCorner.Coor.X,',',OneCorner.Coor.Y,')');
  new(OneCorner.Next);
  RootCorner := OneCorner;
  repeat
    with OneCorner do
    begin
      write('(',Coor.X,',',Coor.Y,')');
      Next_Corner(Coor,Next^.Coor);

      FoundEnd := (Next^.Coor.X = RootCorner.Coor.X) and (Next^.Coor.Y = RootCorner.Coor.Y);
    end;
    OneCorner := OneCorner.Next^;
    new(OneCorner.Next)
  until FoundEnd;
  writeln;
  OneCorner.Next := nil;
  OneCorner := RootCorner;
  repeat
    TwoCorner := OneCorner.Next^;
    TreeCorner := TwoCorner.Next^;
    write('(',OneCorner.Coor.X,',',OneCorner.Coor.Y,')');
    write('(',twoCorner.Coor.X,',',twoCorner.Coor.Y,')');
    writeln('(',treeCorner.Coor.X,',',treeCorner.Coor.Y,')');

    if Distance(OneCorner.Coor,TwoCorner.Coor,TreeCorner.Coor) < 3 then
      OneCorner.Next := TwoCorner.Next;
    OneCorner := OneCorner.Next^
  until TreeCorner.Next = nil
end;

procedure Reaction(Fitness : boolean);
begin
  if Fitness then writeln('Right !!') else writeln('Wrong !!');
  writeln
end;

begin
  writeln;writeln;writeln;
  set_block;
  Creat_Train(FunToy,ManList);
  Creat_Train(SavedToy,SampleList);
  GoodMake := true;
  repeat
    GoodMake := (abs(ManList.Coor.X - SampleList.Coor.X) < 3) and
		(abs(ManList.Coor.Y - SampleList.Coor.Y) < 3);
    ManList := ManList.Next^;
    SampleList := SampleList.Next^;
    if (ManList.Next = nil) xor (SampleList.Next = nil) then GoodMake := false;
    GoodLength := (ManList.Next = nil) and (SampleList.Next = nil)
  until not GoodMake or GoodLength;
  Reaction(GoodMake and GoodLength);
  readln
end.


