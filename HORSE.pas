program Ex6;
uses crt;
var Board:array[1..5,1..5] of integer;
    Order:integer;

procedure Initiate;
var i,j:integer;
    Answer:char;
begin
  clrscr;
  writeln('On the 5x5 chessboard, we try to jump a horse through all cells.');
  writeln;
  write('Press any key when ready .....');
  Answer:=readkey;
  writeln;
  for i:=1 to 5 do for j:=1 to 5 do Board[i,j]:=0;
  Order:=0
end;

procedure PrintBoard;
var i,j,LeftX:integer;
    Answer:char;

procedure Draw_a_line(Head,Body,Tail:string);
var i:integer;
begin
  gotoxy(LeftX,wherey);
  write(Head);  for i:=1 to 4 do Write(Body);  writeln(Tail)
end;

begin
  Order:=Order + 1;
  LeftX:=((Order - 1) mod 3) * 26 + 1;
  if LeftX = 1 then clrscr;
  gotoxy(LeftX,5);  writeln('(',Order,')');
  for i:=1 to 11 do
  case i of
     1: Draw_a_line('','迋迋','迋迋');
    11: Draw_a_line('','迋迋','迋迋');
  else
    if odd(i) then Draw_a_line('','闡闡','闡闡')
              else Draw_a_line('','    ','    ')
  end;
  for i:=1 to 5 do for J:= 1 to 5 do
  begin
    gotoxy(LeftX - 3 + i*5,5 + j*2);
    write(Board[i,j]:2)
  end;
  if LeftX = 53 then
  begin
    gotoxy(1,3);  write('Press any key when ready .....');
    Answer:=readkey;
    writeln
  end
end;

procedure Try(Steps,X,Y:integer);
var NewX,NewY,i,j:integer;
begin
  for i:=-2 to 2 do for j:=-2 to 2 do
    if (abs(i) - abs(j)) * i * j <> 0 then
    begin
      NewX:=X + i;
      NewY:=Y + j;
      if ([NewX,NewY] <= [1..5]) and (Board[NewX,NewY] = 0) then
      begin
        Board[NewX,NewY]:=Steps;
        if Steps = 25 then PrintBoard
                      else Try(Steps + 1,NewX,NewY);
        Board[Newx,NewY]:=0
      end
    end
end;

begin
  Initiate;
  Board[1,1]:=1;
  Try(2,1,1);
  writeln;write('The totel way are ',Order,' .')
end.


