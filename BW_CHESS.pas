program BW_Chess;
uses crt;
const Box = 8;
type Status = (Black,White,Empty);
     BoardArray = array[0..Box+1,0..Box+1] of Status;
var Cell                   : BoardArray;
    State                  : Status;
    Sign                   : array[Status] of char;
    Xset,Yset              : integer;
    Operator               : array[Status] of string[8];
    Level                  : integer;
    Lawful,GameOver,Tired  : boolean;

procedure Writexy(x,Y : integer;sentence : string);
begin
  gotoxy(X,Y);  write(sentence)
end;

procedure Beep(f,time : integer);
const noise : boolean = true;
begin
  if (f = 0) and (time = 0) then noise := boolean(1 - ord(noise));
  if noise then
  begin
    sound(f);  delay(time);  nosound
  end
end;

function Got(State : Status;Board : BoardArray) : integer;
var I,J,G : integer;
begin
  G := 0;
  for I := 1 to Box do for J := 1 to Box do inc(G,ord(Board[I,J] = State));
  Got := G;
end;

procedure Document;
begin
  clrscr;
  Writexy(25,2,'<<    Change Color Chess    >>');
  Writexy(12,5,'This program will supply a board for you and your friend');
  Writexy(12,6,'to play the game.');
  Writexy(12,8,'The [ black ] side will play first !');
  Writexy(12,10,'Each player must set his chessman to change at least');
  Writexy(12,11,'one of opponent''s. If can''t, he may pass !!');
  Writexy(12,13,'Please press  X_coor. and  Y_coor. to locate a chessman !');
  Writexy(12,16,'Would you like to play first ? (Y/N) ');
  Writexy(18,21,'Press a key when ready .....');
  gotoxy(49,16);
  if readkey in ['y','Y']
    then begin  Operator[Black] := 'Human   ';  Operator[White] := 'Computer'  end
    else begin  Operator[Black] := 'Computer';  Operator[White] := 'Human   '  end
end;

procedure Initiate;
var I,J : integer;
begin
  for I := 0 to Box + 1 do for J := 0 to Box + 1 do Cell[I,J] := Empty;
  Cell[ Box div 2, Box div 2 + 1] := White;
  Cell[ Box div 2 + 1, Box div 2 + 1] := White;
  Cell[ Box div 2, Box div 2] := Black;
  Cell[ Box div 2 + 1, Box div 2] := Black;
  Sign[Black] := #176;  Sign[White] := #219;  Sign[Empty] := #32;
  Level := 2;
  Lawful := true;
  GameOver := false;
  State := Black
end;

procedure Draw_a_board;
var I,J : integer;

procedure Draw_a_line(head,body,tail : string);
var J : integer;
begin
  write('':17,head); for J := 1 to  Box - 1 do write(body); writeln(tail)
end;

begin
  Clrscr;
  gotoxy(1,4);
  for I := 1 to 2*Box + 1 do
  case I of
    1            : Draw_a_line('','迋迕','迋芼');
    2*Box + 1    : Draw_a_line('','迋迍','迋芞');
  else
    if odd(I) then Draw_a_line('','闡霰','闡譯')
              else Draw_a_line('','   ','   ')
  end;
  for I := 1 to Box do
  begin
    gotoxy(16 + I*4,3);  write(I);
    gotoxy(16,3 + I*2);  write(I)
  end;
  for I :=  Box div 2 to  Box div 2 + 1 do
    for J :=  Box div 2 to  Box div 2 + 1 do
    begin
      writexy(16 + I*4,3 + J*2,Sign[Cell[I,J]]);
    end;
  Writexy(60,7,'X coor.= ');
  Writexy(60,9,'Y coor.= ');
  Writexy(60,4,'Player :  ' + Sign[State] + '  ' + Operator[State]);
  Writexy(60,11,Sign[Black] + ' : 2');
  Writexy(60,13,Sign[White] + ' : 2');
  Writexy(60,16,'[Esc]:');
  Writexy(62,17,'[l] = level  ');  write(Level);
  Writexy(62,18,'[x] = back to X');
  Writexy(62,19,'[s] = on/off sound');
  Writexy(62,20,'[q] = quit')
end;

procedure Locate_a_chessman;
var Akey : char;
    I : integer;
    Prelawful,Xsetted : boolean;

procedure Do_special;
begin
  gotoxy(66,16);
  case upcase(readkey) of
    'X': Xsetted := false;
    'Q': halt;
    'S': Beep(0,0);
    'L': begin
           Level := (Level + 1) mod 5;
           gotoxy(75,17);  write(Level)
         end
  end
end;

begin
  Prelawful := false;
  Xsetted := false;
  repeat
    if Lawful = false then
    begin
      Beep(900,300);
      Writexy(5,24,'You must kill at least one of opponent''s !!');
      Lawful := true
    end;
    if Xsetted then gotoxy(70,9) else gotoxy(70,7);
    Akey := readkey;  write(Akey);
    Beep(200,100);
    gotoxy(1,24);  delline;
    if Akey = #27 then Do_special
      else if not (Akey in ['1'..'8']) then
      begin
        Beep(900,300);  Writexy(5,24,'It must be 1..8 !!')
      end
      else if Xsetted then
      begin
        val(Akey,Yset,I);
        if Cell[Xset,Yset] <> Empty then
        begin
          Beep(900,300);  Writexy(5,24,'Here is not empty !!');
          Xsetted := false
        end else Prelawful := true
      end
      else begin
             val(Akey,Xset,I);  Xsetted := true
           end
  until Prelawful
end;

procedure Change_the_board(Xset,Yset : integer;State : Status;
                           var Board : BoardArray);
var Xend,Yend,X,Y,I,J : integer;
begin
  for I := -1 to 1 do for J := -1 to 1 do
    if (Board[Xset + I,Yset + J] = Status(1 - ord(State)))
       and (I*I + J*J <> 0) then
    begin
      Xend := Xset;
      Yend := Yset;
      repeat
        inc(Xend,I);
        inc(Yend,J)
      until Board[Xend,Yend] in [State,Empty];
      if Board[Xend,Yend] = State then
      begin
        X := Xset;
        Y := Yset;
        repeat
          Board[X,Y] := State;
          inc(X,I);
          inc(Y,J)
        until (X = Xend) and (Y = Yend);
      end
    end;
end;

function Price(X,Y : integer; State : Status; Board : BoardArray) : integer;
var Maximum,Value,I,J : integer;
    NewCell : BoardArray;
    Pay : array[1..Box,1..Box] of integer;
begin
  NewCell := Board;
  Change_the_board(X,Y,State,NewCell);
  Value := Got(State,NewCell) - Got(State,Board);
  Maximum := 0;
  if (Value > 0) and (Got(Empty,Cell) - Got(Empty,NewCell) < Level) then
    for I := 1 to Box do for J := 1 to Box do
      if NewCell[I,J] = Empty then
      begin
        Pay[I,J] := Price(I,J,Status(1 - ord(State)),NewCell);
        if Pay[I,J] > Maximum then Maximum := Pay[I,J]
      end;
  Price := Value - Maximum
end;

procedure Find_a_step;
var I,J : integer;
    Pay : array[1..Box,1..Box] of integer;
begin
  Xset := 1;
  Yset := 1;
  Pay[Xset,Yset] := 0;
  for I := 1 to Box do for J := 1 to Box do
    if Cell[I,J] = Empty then
    begin
      Pay[I,J] := Price(I,J,State,Cell);
      Writexy(16 + I*4,3 + J*2,#250);
      if Pay[I,J] > Pay[Xset,Yset] then
      begin
        Xset := I; Yset := J
      end
    end;
  Beep(200,100);  delay(2);  Beep(200,100)
end;

procedure Check;
var NewCell : BoardArray;
    I,J,L : integer;
    Man : string[5];
begin
  Lawful := true;
  NewCell := Cell;
  Change_the_Board(Xset,Yset,State,NewCell);
  if Got(State,NewCell) - Got(State,Cell) = 0 then
  begin
    L := Level;
    Level := 0;
    Lawful := false;
    for I := 1 to Box do for J := 1 to Box do
      if (Cell[I,J] = Empty) and (Price(I,J,State,Cell) > 0) then
      begin
        Lawful := true;
        Xset := I;
        Yset := J
      end;
    if Lawful then Change_the_Board(Xset,Yset,State,NewCell);
    Level := L
  end;
  if Lawful then
  begin
    gotoxy(70,7);  write(Xset);
    gotoxy(70,9);  write(Yset);
    Cell := NewCell
  end
  else
  begin
    if Operator[State] = 'Human   ' then Man := 'You (' else Man := 'I (';
    Writexy(5,24,'Sorry ! ' + Man + Sign[State] + ') have to stop !');
    Lawful := true;
    Gameover := true
  end
end;

procedure Refresh;
var I,J : integer;
begin
  State := Status(1 - ord(State));
  Writexy(70,4,Sign[State] + '  ' + Operator[State]);
  for I := 1 to Box do
    for J := 1 to Box do Writexy(16 + I*4,3 + J*2,Sign[Cell[I,J]]);
  gotoxy(64,11);  write(Got(Black,Cell):2);
  gotoxy(64,13);  write(Got(White,Cell):2);  gotoxy(70,7);
  GameOver := Got(Empty,Cell) = 0
end;

procedure Result;
var
  Winner : Status;
begin
  if Got(Black,Cell) = Got(White,Cell) then Writexy(60,22,'You are equral !')
    else
    begin
      Winner := Status(Got(Black,Cell) < Got(White,Cell));
      gotoxy(40,22);
      write('The winner is  ',Sign[Winner],'  ( ',Operator[Winner],' )')
    end;
  Writexy(40,24,'Do you want play it again ? (Y/N) ');
  Tired := readkey in ['N','n']
end;

begin
  Document;
  repeat
    Initiate;
    Draw_a_board;
    repeat
      repeat
        if Operator[State] = 'Human   '
          then Locate_a_chessman
          else Find_a_step;
        Check
      until Lawful;
      Refresh
    until GameOver;
    Result
  until Tired
end.

