program Month;
var FirstOrder,Monthdays,day:integer;
begin
  writeln('This program will show a calendar of a month.');
  writeln('Please keyin the information......');
  writeln;
  repeat
    write('Order of First Day (0-6) = ');
    readln(FirstOrder)
  until (FirstOrder >= 0) and (FirstOrder <= 6);
  repeat
    write('All Days (28-31) = ');
    readln(MonthDays)
  until (MonthDays <= 31) and (MonthDays >= 28);
  writeln;
  writeln('SUN  MON  TUE  WED  THR  FRI  SAT');
  for day:=1 to FirstOrder*5 do write(' ');
  for day:=1 to MonthDays do
    begin
      write(day:2,'   ');
      if (FirstOrder+day) mod 7 = 0 then writeln
    end
end.