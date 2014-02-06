program Calendar;
uses crt;
var PointYear,BeginMonth,EndMonth     :integer;
    MonthDays                         :array [1..12] of integer;
    KnownYear,FirstOrder              :integer;
    year,month,lday,rday,lorder,rorder:integer;
    HaveNext                          :boolean;
    F                                 :text;
    Key                               :char;
function YearDays(year:integer):integer;
begin
  if (year mod 4)=0 then if (year mod 100)=0 then if (year mod 400)=0
    then YearDays:=2 else YearDays:=1 else Yeardays:=2 else YearDays:=1
end;
procedure DayLine(var day:integer;order:integer);
begin
  repeat
    if day = 0 then write(F,'':5*order);
    day:=day+1;
    if day <= MonthDays[month] then write(F,day:2,'   ') else write(F,' ':5)
  until (order + day) mod 7 = 0
end;

begin
  writeln('This program will show a calendar of a pointed year.');
  writeln;
  for month:=1 to 12 do
    case month of
      1,3,5,7,8,10,12 :MonthDays[month]:=31;
             4,6,9,11 :MonthDays[month]:=30;
                    2 :MonthDays[month]:=28
    end;
  write('Do you want to show it on [S]_CREEN or [P]_RINTER ? ');
  readln(Key);
  if Key in ['S','s'] then assign(F,'con') else assign(F,'prn');
  rewrite(F);
  writeln;
  writeln;
  write('Please keyin the YEAR-NUMBER....'); readln(PointYear);
  while PointYear < 1 do
  begin
    writeln;
    write('It''s must a natural number ( >0) !      year = ');
    readln(PointYear)
  end;
  writeln;
  write('From which month does this calendar BEGIN ?  '); readln(BeginMonth);
  write('  At which month does this calendar END ?  '); readln(EndMonth);
  while not ((BeginMonth>0) and (EndMonth<13) and (EndMonth>=BeginMonth)) do
  begin
    writeln;
    writeln('Your inputs are not lawful !');
    write('The first month = '); readln(BeginMonth);
    write(' The last month = '); readln(EndMonth)
  end;

  KnownYear:=1;
  FirstOrder:=1;
  for year:=KnownYear to PointYear - 1 do
    FirstOrder:=FirstOrder + YearDays(year);
  FirstOrder:=FirstOrder mod 7;
  if YearDays(PointYear) = 2 then MonthDays[2]:=29;

  writeln(F);
  if BeginMonth <> EndMonth then write(F,' ':30);
  writeln(F,'*** ',PointYear,' ***');
  month:=1;
  repeat
    if month >= BeginMonth then
    begin
      HaveNext:=month + 1 <= EndMonth;
      writeln(F);
      write(F,'=== ',month:2,' ===');
      if HaveNext then writeln(F,' ':29,'=== ',month+1:2,' ===') else writeln(F);
      writeln(F);
      write(F,'SUN  MON  TUE  WED  THR  FRI  SAT      ');
      if HaveNext then writeln(F,'SUN  MON  TUE  WED  THR  FRI  SAT')
                  else writeln(F);
      lday:=0; lorder:=FirstOrder;
      if HaveNext then
      begin
        FirstOrder:=(FirstOrder + MonthDays[month]) mod 7;
        rday:=0; rorder:=FirstOrder;
      end         else rday:=32;

      repeat
        DayLine(lday,lorder);
        write(F,' ':4);
        if HaveNext then
        begin
          month:=month + 1;
          DayLine(rday,rorder);
          month:=month - 1
        end;
        writeln(F)
      until (lday > MonthDays[month]) and (rday > MonthDays[month + 1]);

      month:=month + 1
    end;
    FirstOrder:=(FirstOrder + MonthDays[month]) mod 7;
    month:=month + 1
  until month > EndMonth;
  close(F)
end.