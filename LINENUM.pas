program LineNum;
var F:text;
    Ch:char;
    LineN,WordN:integer;
    InWord,Show:boolean;
begin
  writeln('This program will count the number of lines and that of words');
  writeln('     in the pointed file (DATA. )');
  writeln;
  write('Do you want to watch the contents ?(Y/N) '); readln(Ch);
  Show:=Ch in ['y','Y'];
  writeln;
  LineN:=0;
  WordN:=0;
  assign(F,'DATA');
  reset(F);
  while not eof(F) do
  begin
    InWord:=false;
    while not eoln(F) do
    begin
      read(F,Ch);
      if Show then write(Ch);
      if Ch in ['a'..'z','A'..'Z','0'..'9'] then
      begin
        if InWord = false then WordN:=WordN + 1;
        InWord:=true
      end
      else InWord:=false
    end;
    LineN:=LineN + 1;
    readln(F);
    if Show then writeln
  end;
    close(F);
    if Show then writeln;
    writeln('==>  The number of lines = ',LineN);
    writeln('     The number of words = ',WordN)
end.


