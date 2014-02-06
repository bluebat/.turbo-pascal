program Loan;
var Total,Pay,YearRate,MonthRate,rate: real;
    Years,i:integer;
begin
  writeln('This program will list money which you have to repay per month.');
  writeln;
  write('How much money do you borrow from the bank ? $ ');
  readln(Total);
  write('How many years do you borrow those money for ? ');
  readln(Years);
  write('How many percent is the year-rate of the interest ? % ');
  readln(YearRate);
  YearRate:=YearRate / 100;

  MonthRate:=exp(ln(1 + YearRate) / 12) - 1;
  rate:=exp(Years * 12 * ln(1 + MonthRate));
  Pay:=Total * MonthRate * rate / (rate - 1);

  writeln ;
  writeln('Total loans = $',Total:trunc(ln(Total) / ln(10) + 5):2);
  writeln('Rate per year = ',YearRate * 100:2:2,' %');
  writeln('Period = ',Years,' years');
  writeln;
  writeln('奼迋迋迋冞迋迋迋迋迋迋迋冞迋迋迋迋迋迋');
  writeln(' Month       Debt          Pay     ');
  writeln('昅迋迋迋怤迋迋迋迋迋迋迋怤迋迋迋迋迋迋');
  writeln('    0    ',Total:10:2,'   ','':13,'');
  for i := 1 to Years * 12 do
  begin
    Total:=Total * (1 + MonthRate) - Pay;
    writeln('',i:5,'    ',Total:10:2,'   ',Pay:10:2,'   ');
  end ;
  writeln('迋迋迋庋迋迋迋迋迋迋迋庋迋迋迋迋迋迋')
end.

