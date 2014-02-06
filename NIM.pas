program NIM;
const
  Piles = 3;                           { changeable }
  MaxStone = 9;                        { changeable }
  RestStone : word = 0;
type
  Stack = array[1..Piles] of byte;
var
  Stones : Stack;
  ManTurn : boolean;
  Pile, Stone, I, J : byte;

  function WinStep(Block:Stack; P,S:word):boolean;
  var I, J : byte;
      IsOdd : boolean;
  begin
    dec(Block[P],S);
    IsOdd := false;
    I := 0;
    repeat
      for J := 1 to Piles do IsOdd := odd(Block[J] shr I) xor IsOdd;
      inc(I)
    until IsOdd or (I > trunc(ln(MaxStone)/ln(2)));
    WinStep := not IsOdd
  end;

begin
repeat
  writeln;
  randomize;
  for I := 1 to Piles do
  begin
    Stones[I] := random(MaxStone)+1;
    inc(RestStone,Stones[I])
  end;
  repeat
    ManTurn := not ManTurn;
    write('Now we have : ');
    for I := 1 to Piles do write('<',I,'> ',Stones[I],'  ');
    writeln;
    if ManTurn then
    repeat
      write('':38,'You wanna take  PILE  STONE : ');
      readln(Pile,Stone)
    until (Pile in [1..Piles]) and (Stone in [1..Stones[Pile]]) else
    begin
      Pile := 0;
      Stone := 1;
      for I := 1 to Piles do for J := 1 to Stones[I] do
      if WinStep(Stones,I,J) then
      begin
        Pile := I;
        Stone := J
      end;
      if Pile = 0 then repeat inc(Pile) until Stones[Pile] > 0;
      writeln('':40,'I wanna take  PILE  STONE : ',Pile,' ',Stone)
    end;
    dec(Stones[Pile],Stone);
    dec(RestStone,Stone)
  until RestStone = 0;
  if ManTurn then writeln('You win !') else writeln('I win !');
  writeln('':38,'Press Ctrl-Break for ending.')
until false
end.

