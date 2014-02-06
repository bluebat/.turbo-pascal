program Ex5;
uses crt;
type Status=(Black,White,Empty);
var Cell                  :array[0..9,0..9] of Status;
    State                 :Status;
    Got                   :array[Status] of integer;
    Sign                  :array[Status] of char;
    Xset,Yset             :integer;
    Lawful,GameOver,Tired :boolean;

procedure Writexy(x,y:integer;sentence:string);
begin
  gotoxy(x,y);  write(sentence)
end;

procedure Document;
var Answer:char;
begin
  clrscr;
  Writexy(25,2,'<<    Change Color Chess    >>');
  Writexy(12,5,'This program will supply a board for you and your friend');
  Writexy(12,6,'to play the game.');
  Writexy(12,8,'The [ black ] side will play first !');
  Writexy(12,10,'Each player must set his chessman to change at least');
  Writexy(12,11,'one of opponent''s. If can''t, he may pass !!');
  Writexy(12,13,'Please press  X_coor. and  Y_coor. to locate a chessman !');
  Writexy(18,21,'Press any key when ready .....');
  Answer:=readkey
end;

procedure Initiate;
var i,j:integer;
begin
  for i:=0 to 9 do for j:=0 to 9 do Cell[i,j]:=Empty;
  Cell[4,5]:=White;  Cell[5,5]:=White;
  Cell[4,4]:=Black;  Cell[5,4]:=Black;
  Sign[Black]:=#176;  Sign[White]:=#219;
  Lawful:=true;
  GameOver:=false;
  State:=Black;
end;

procedure Draw_a_board;
var i,j:integer;

procedure Draw_a_line(head,body,tail:string);
var j:integer;
begin
  write('':18,head); for j:=1 to 7 do write(body); writeln(tail)
end;

begin
  Clrscr;
  gotoxy(1,5);
  for i:=1 to 17 do
  case i of
    1                  : Draw_a_line('','迋迕','迋芼');
    2,4,6,8,10,12,14,16: Draw_a_line('','   ','   ');
    3,5,7,9,11,13,15   : Draw_a_line('','闡霰','闡譯');
    17                 : Draw_a_line('','迋迍','迋芞')
  end;
  for i:=1 to 8 do
  begin
    gotoxy(17 + i*4,4);  write(i);
    gotoxy(17,4 + i*2);  write(i)
  end;
  for i:=4 to 5 do for j:=4 to 5 do
  begin
    writexy(17 + i*4,4 + j*2,Sign[Cell[i,j]]);
  end;
  Writexy(60,8,'X coor.= ');
  Writexy(60,10,'Y coor.= ');
  Writexy(60,5,'Player :  '+Sign[State]);
  Writexy(60,12,Sign[Black]+' : 2');
  Writexy(60,14,Sign[White]+' : 2');
  Writexy(60,17,'[Esc]:');
  Writexy(62,18,'[p] = pass');
  Writexy(62,19,'[s] = on/off sound');
  Writexy(62,20,'[q] = quit')
end;

procedure Locate_a_chessman;
var aKey:char;
    i:integer;
    Prelawful,Xsetted:boolean;

procedure Beep(f,time:integer);
const noise:boolean = true;
begin
  if (f = 0) and (time = 0) then noise:=boolean(1 - ord(noise));
  if noise then
  begin
    sound(f);  delay(time);  nosound
  end
end;

procedure Do_special;
var Event:char;
begin
  gotoxy(66,17);  Event:=readkey;
  case Event of
  'q','Q': halt;
  's','S': Beep(0,0);
  'p','P': State:=Status(1 - ord(State))
  end
end;

begin
  Prelawful:=false;
  Xsetted:=false;
  repeat
    if Lawful = false then
    begin
      Beep(900,300);
      Writexy(5,24,'You must kill at least one of opponent''s !!');
      Lawful:=true
    end;
    Writexy(70,5,Sign[State]);
    if Xsetted then gotoxy(70,10) else gotoxy(70,8);
    aKey:=readkey;  write(aKey);
    Beep(200,100);
    gotoxy(1,24);  delline;
    if aKey = #27 then Do_special else
      if not (aKey in ['1'..'8']) then
      begin
        Beep(900,300);  Writexy(5,24,'It must be 1..8 !!')
      end else
      if Xsetted then
      begin
        val(aKey,Yset,i);
        if Cell[Xset,Yset] <> Empty then
        begin
          Beep(900,300);  Writexy(5,24,'Here is not empty !!');
          Xsetted:=false
        end else Prelawful:=true
      end else
      begin
        val(aKey,Xset,i);  Xsetted:=true
      end
  until Prelawful
end;

procedure Check_and_kill;
var Xend,Yend,x,y,i,j:integer;
begin
  Lawful:=false;
  for i:=-1 to 1 do for j:=-1 to 1 do
  begin
    Xend:=Xset;
    Yend:=Yset;
    repeat
      Xend:=Xend + i;
      Yend:=Yend + j
    until (Cell[Xend,Yend] = State) or (Cell[Xend,Yend] = Empty);
    if (Cell[Xend,Yend] = State) and
      ((Xend <> Xset + i) or (Yend <> Yset + j)) then
    begin
      x:=Xset;
      y:=Yset;
      repeat
        Cell[x,y]:=State;
        Writexy(17 + x*4,4 + y*2,Sign[State]);
        x:=x + i;
        y:=y + j
      until (x = Xend) and (y = Yend);
      Lawful:=true
    end
  end
end;

procedure Chang_player;
var s:Status;
    i,j:integer;
begin
  State:=Status(1 - ord(State));
  for s:=Black to Empty do Got[s]:=0;
  for i:=1 to 8 do for j:=1 to 8 do Got[Cell[i,j]]:=Got[Cell[i,j]] + 1;
  gotoxy(64,12);  write(Got[Black]:2);
  gotoxy(64,14);  write(Got[White]:2);
  if Got[Empty] = 0 then GameOver:=true
end;

procedure Result;
var Answer:char;
begin
  Writexy(60,22,'The winer is  ');
  if Got[Black]>Got[White] then write(Sign[Black]) else write(Sign[White]);
  Writexy(40,24,'Do you want to play again ? (Y/N) ');
  Answer:=readkey;
  if Answer in ['Y','y'] then Tired:=false else Tired:=true
end;

begin
  Document;
  repeat
    Initiate;
    Draw_a_board;
    repeat
      repeat
        Locate_a_chessman;
        Check_and_kill
      until Lawful;
      Chang_player
    until GameOver;
    Result
  until Tired
end.

