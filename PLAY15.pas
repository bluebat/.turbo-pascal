program Play15;
type
  Step = word;
  Platt = word;
  Player = (Man, Computer);
var
  Way : array[1..105] of Step;
  F : file of Step;
  History : array[Player,1..8] of Platt;
  NowPlatt : Platt;

  procedure
  begin
  end;

  procedure
  begin
  end;

  procedure
  begin
  end;

begin
  Set_15;
  Head_15;
  repeat
    Draw_15;
    repeat
      if Player = Man then Man_15 else Computer_15;
    until Check_15;
    Learn_15;
    Report_15
  until Next_15;
  Quit_15
end.