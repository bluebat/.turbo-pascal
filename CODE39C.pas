program Code39C;
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
var Head, InputData, RealData : string[16];
    BarHigh : string[1];
    Checkable, Readable : boolean;

procedure Set_Bar;
var Check, Foot : string[1];
begin
  writeln;
  writeln('      ３９  條碼列印程式        趙惟倫');
  writeln;
  writeln('須於倚天中文下執行，並確定印表機已上線。');
  writeln('應先載入印表機驅動程式，但勿驅動平滑字型。');
  writeln('自 FE50 起之條碼造字檔 USRFONT.15M 為必需。');
  writeln;
  write('請輸入抬頭文字 ..... ');
  readln(Head);
  write('條碼的高度多少 ? (3) ');
  readln(BarHigh);
  if not(BarHigh[1] in ['1'..'9']) then BarHigh := '3';
  write('要包含檢查碼嗎 ? (N) ');
  readln(Check);
  Checkable := Check[1] in ['Y','y'];
  write('要加印原字碼嗎 ? (Y) ');
  readln(Foot);
  Readable := not(Foot[1] in ['N','n']);
  writeln
end;

procedure Input_Value;
var I : integer;
    Lawful : boolean;
begin
  repeat
    Lawful := true;
    RealData := '';
    write('請輸入字碼 ( 逕按 [Enter] 可結束 ) ..... ');
    readln(InputData);
    for I := 1 to length(InputData) do
      if InputData[i] < #128 then
	RealData := RealData + Code[InputData[i]]
      else
      begin
	writeln('對不起 ! 其中含有無法以３９碼列印的字 !');
	Lawful := false
      end;
    if length(InputData) = 0 then halt;
  until Lawful
end;

procedure Standarlize;
var CheckSum, I : integer;
begin
  if Checkable then
  begin
    CheckSum := 0;
    for I := 1 to length(RealData) do inc(CheckSum,pred(pos(RealData[i],List)));
    RealData := RealData + copy(List,succ(CheckSum mod 43),1)
  end;
  RealData := '*'+RealData+'*'
end;

procedure Print_Out;
var I, LR : integer;
begin
  LR := length(RealData);
  writeln(lst,'~T24D0W1Z1L6X1;');
  writeln(lst,'':round(4*LR/3-length(Head)/2),Head);
  write(lst,'~T16W2Z',BarHigh,';');
  for I := 1 to LR do
    write(lst,chr($FE),chr($50 + pred(pos(RealData[i],List))));
  writeln(lst);
  if Readable then
  begin
    write(lst,'~T24Z1;');
    write(lst,'':round(2*LR/3-length(InputData)/2),InputData)
  end;
  writeln(lst)
end;

begin
  Set_Bar;
  repeat
    Input_Value;
    Standarlize;
    Print_Out
  until false
end.