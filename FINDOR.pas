program Findor;
uses dos;
type String12=string[12];
var Rec:SearchRec;
    KeyWord:array[1..10] of string[10];
    KeyNum:integer;
procedure Input_index;
var i:integer;
begin
  writeln('Please put your disk into drive B:');
  writeln('Press [Enter] when ready .....');
  readln;
  write('How many keywords do you want to look for ? ');
  readln(KeyNum);
  writeln;
  for i:=1 to KeyNum do
  begin
    write(' ':10,i:2,': ');
    readln(KeyWord[i])
  end
end;

procedure Look_at(Filename:String12);
var F:text;
    WholeLine:String;
    FirstWord:string[10];
    i:integer;
begin
  assign(F,'B:' + Filename);
  reset(F);
  writeln('----------------------  ',Filename);
  while not eof(F) do
  begin
    readln(F,WholeLine);
    while copy(WholeLine,1,1) = ' ' do delete(WholeLine,1,1);
    FirstWord:=copy(WholeLine,1,pos(' ',WholeLine) - 1);
    for i:=1 to KeyNum do if FirstWord = KeyWord[i] then writeln(WholeLine)
  end;
  close(F);
  writeln
end;

begin
  Input_index;
  findfirst('B:*.prg',readonly+archive,Rec);
  while (doserror=0) do
  begin
    Look_at(Rec.name);
    findnext(Rec)
  end
end.