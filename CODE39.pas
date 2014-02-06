program Code39;
uses printer;
const Code : array[#0..#127] of string[2] = ('%U',
           '$A','$B','$C','$D','$E','$F','$G','$H','$I','$J','$K','$L','$M',
           '$N','$O','$P','$Q','$R','$S','$T','$U','$V','$W','$X','$Y','$Z',
           '%A','%B','%C','%D','%E',' ',
           '/A','/B','/C','/D','/E','/F','/G','/H','/I','/J','/K','/L','-',
           '.','/O','0','1','2','3','4','5','6','7','8','9','/Z',
           '%F','%G','%H','%I','%J','%V',
           'A','B','C','D','E','F','G','H','I','J','K','L','M',
           'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
           '%K','%L','%M','%N','%O','%W',
           '+A','+B','+C','+D','+E','+F','+G','+H','+I','+J','+K','+L','+M',
           '+N','+O','+P','+Q','+R','+S','+T','+U','+V','+W','+X','+Y','+Z',
           '%P','%Q','%R','%S','%T');
      List = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*';
      Model : array[0..43] of integer =
            ($A6D,$D2B,$B2B,$D95,$A6B,$D35,$B35,$A5B,$D2D,$B2D,
             $D4B,$B4B,$DA5,$ACB,$D65,$B65,$A9B,$D4D,$B4D,$ACD,$D53,$B53,$DA9,
             $AD3,$D69,$B69,$AB3,$D59,$B59,$AD9,$CAB,$9AB,$CD5,$96B,$CB5,$9B5,
             $95B,$CAD,$9AD,$925,$929,$949,$A49,$96D);
var Number              : array[0..15] of integer;
    InputData, RealData : string;
    DataLen             : integer;
    Checkable, Readable : boolean;

procedure Input_Value;
var i           : integer;
    Check, Foot : string[1];
begin
  writeln;
  writeln('Make sure your printer is on line !');
  writeln;
  write('Input the characters (or just [Enter] to exit) ...... ');
  readln(InputData);
  if length(InputData) = 0 then halt;
  writeln;
  write('Including the checking code ? (N) ');
  readln(Check);
  write('Also print the characters ? (Y) ');
  readln(Foot);
  Checkable := Check[1] in ['Y','y'];
  Readable := not(Foot[1] in ['N','n']);
  RealData := '';
  i := 1;
  repeat
    if InputData[i] < #128 then
    begin
      RealData := RealData + Code[InputData[i]];
      inc(i)
    end
    else
    begin
      writeln('Sorry ! We can''t do that on Bar Code .');
      halt
    end
  until i > length(InputData)
end;

procedure Numberlize;
var CheckSum, Value, i : integer;
begin
  Number[0] := Model[43];
  CheckSum := 0;
  DataLen := length(RealData);
  for i := 1 to DataLen do
  begin
    Value := pos(RealData[i],List) - 1;
    inc(CheckSum,Value);
    Number[i] := Model[Value]
  end;
  inc(DataLen);
  if Checkable then Number[DataLen] := Model[CheckSum mod 43]
               else Number[DataLen] := $0;
  inc(DataLen);
  Number[DataLen] := Model[43]
end;

procedure Print_Out;
const PinChar : array[boolean] of string[3] = (#0#0#0,#255#255#255);
var i, j, l : integer;
    PreBar, Bar : boolean;
begin
  writeln(lst);
  PreBar := false;
  for l := 1 to 2 do
  begin
    for i := 0 to DataLen do
    begin
      if Number[i] <> $0 then
      begin
        write(lst,#27,'*',#38,#15,#0);
        for j := 11 downto 0 do
        begin
          Bar := ((Number[i] shr j) and 1) = 1;
          write(lst,PinChar[Bar]);
          if Bar = PreBar then write(lst,PinChar[Bar]);
          PreBar := Bar
        end
      end;
      write(lst,#27,'*',#38,#1,#0);
      write(lst,PinChar[false]);
      PreBar := false
    end;
    writeln(lst,#27,#48)
  end;
  writeln(lst,' ':DataLen div 2,'*',InputData,'*');
  writeln(lst,#27,#50)
end;

begin
  repeat
    Input_Value;
    Numberlize;
    Print_Out
  until false
end.