program PRIDE;
var N,I,T:integer;
begin
  writeln('Find the prime decomposition of  N');
  N:=1;
  while N > 0 do
    begin
      I:=1;
      while N < 2 do
        begin
          writeln('Please enter an integer > 1');
          write('N = ');
          readln(N)
        end;
      write('  = ');
      while N > 1 do
        begin
          I:=I+1;
          T:=0;
          while (N mod I)=0 do
            begin
              N:=N div I;
              T:=T+1
            end;
          if T > 0 then write(I,'^',T);
          if N*T > T then write(' * ')
        end;
      writeln;
      write('Finding another ?(1/0) ');
      readln(N);
      if N > 0 then N:=N div N;
      writeln
    end
end.



