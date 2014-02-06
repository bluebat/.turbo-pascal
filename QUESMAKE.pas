{~p9d0g1l4x6w1z1;}
program	QuesMake;
uses dos, crt;
type
  String16 = string[16];
const
  Esc =	#27;
  EscT24 = Esc + 'T24,';
  LevelStr = ' 難中易';
var
  InF, OutF : text;
  SkillNum : string[6];
  SkillName : string16;
  QuesNum : word;
  Level	: byte;
  MakeUnit : string[8];
  CheckUnit : string[6];
  Broke	: boolean;

procedure Test_System;
var
  Regs : registers;
begin
  Regs.ax := $9100;
  intr($10,Regs);
  if Regs.ax = $9100 then
  begin
    writeln(#7,'Chinese System must be load first !!');
    halt
  end;
  Regs.ax := $804E;
  intr($10,Regs);
  Regs.ax := $8046;
  intr($10,Regs);
  Regs.ax := $8066;
  intr($10,Regs);
  clrscr;
  directvideo := false
end;

procedure Input_Const_Data;
var
  I : integer;
  FileName : String16;

  function AskString(X,Y:byte; Prompt:String16;	PreSet:String16):String16;
  var
    Dumb : String16;
  begin
    gotoxy(X,Y);
    write(Prompt,'(',PreSet,') ');
    X := wherex;
    readln(Dumb);
    if Dumb = '' then Dumb := PreSet;
    gotoxy(X,Y);
    write(Dumb);
    AskString := Dumb
  end;

begin
  write(EscT24,'60,20,24,2,S;測驗題轉換',EscT24,'61,21,24,2,X;測驗題轉換');
  write(Esc,'FK;',EscT24,'450,48,2,1/1,S;828 CTC',Esc,'FM;');
  write(Esc,'T16;');
  gotoxy(5,7);
  write('測 驗 題 庫 格 式 範 例 ： 易＼ＨＥ意同＼她＼他＼它＼牠＼Ｂ＼');
  repeat
    gotoxy(5,9);
    write('測 驗 題 庫 文 書 檔 名 ( 空白表示跳離 ) ： ');
    readln(FileName);
    if FileName = '' then halt;
    assign(InF,FileName);
    {$I-}reset(InF){$I+}
  until	ioresult = 0;
  gotoxy(5,11);
  write('測 驗 題 卡 文 書 檔 名 ( PRN 表示列印 ) ： ');
  readln(FileName);
  assign(OutF,FileName);
  {$I-}append(OutF);{$I+}
  if ioresult <> 0 then	rewrite(OutF);
  SkillNum := AskString(5,14,'專 長 號 碼 ：','4G02');
  SkillName := AskString(5,16,'專 長 名 稱 ：','飛機修護參謀官');
  repeat val(AskString(5,18,'起 始 題 號 ：' ,'1'),QuesNum,I) until I =	0;
  repeat Level := pos(AskString(45,18,'題 目 難 易 度：','難'),LevelStr) div 2	until Level > 0;
  MakeUnit := AskString(5,20,'命 題 單 位 ：','828 聯隊');
  CheckUnit := AskString(45,20,'審 核 單 位 ：','');
  Broke	:= pos(AskString(5,22,'是 否 間 斷 ：','N'),'Yy') > 0
end;

procedure Trans_Data;
const
  DachS	= '----------------';
  DachM	= '--------------------';
  DachL	= '---------------------------------------------------------';
var
  Question : string;
  Name,	Item, Answer, Analysis : string;
  NameSub : string[64];
  Ana :	array[1..3] of char;
  I : integer;
  Wait : char;

  procedure GetSection(var SecStr : string);
  var Deli : byte;
  begin
    Deli := pos('＼',Question);
    SecStr := copy(Question,1,pred(Deli));
    delete(Question,1,succ(Deli));
  end;

begin
  Ana := '   ';
  Ana[Level] :=	'V';
  writeln(OutF,#126,'p9d0g2x10l6;');
  while	not eof(Inf) do
  begin
    readln(Inf,Question);
    GetSection(Analysis);
    if pos(Analysis,LevelStr) div 2 = Level then
    begin
      if Broke then
      begin
	gotoxy(45,22);
	write(#7,'按 任 意 鍵 繼 續 !');
	repeat until keypressed;
        Wait := readkey;
	gotoxy(45,22);
	clreol
      end;
      GetSection(Name);
      writeln(OutF,' ':25,'空軍軍職專長測驗題卡');
      writeln(OutF);
      writeln(OutF,'  專長號碼  ',SkillNum:6,'專長名稱  ':30,SkillName);
      writeln(OutF,' ':10,DachM,' ':16,DachM);
      write(OutF,'┌');	for I := 1 to 33 do write(OutF,'─'); writeln(OutF,'┐');
      NameSub := copy(Name,1,54);
      writeln(OutF,'│ (',QuesNum:3,')   ',NameSub,'':54-length(NameSub),'   │');
      writeln(OutF,'│       ',DachL,'  │');
      for I := 0 to 2 do
      begin
	NameSub	:= copy(Name,55+I*60,60);
	writeln(OutF,'│   ',NameSub,'':60-length(NameSub),'   │');
	writeln(OutF,'│  -----',DachL,'  │')
      end;
      GetSection(Item);
      writeln(OutF,'│  答案 (A) ',Item,'':29-length(Item),'┌────────────┤');
      writeln(OutF,'│',DachS:26,'│':16,'題目難易度分析':19,'│':7);
      for I := 1 to 3 do
      begin
        GetSection(Item);
        write(OutF,'│','(':8,chr(I+65),') ',Item,'':29-length(Item),'│  ');
        if I = 1 then writeln(OutF,DachM,'  │') else writeln(OutF,DachS:18,'│':6);
        writeln(OutF,'│',DachS:26,'│ ':17,copy(LevelStr,I+I,2),Ana[I]:10,'│':13);
      end;
      GetSection(Answer);
      Answer[1]	:= chr(64+pos(Answer,' ＡＢＣＤ') div 2);
      writeln(OutF,'│  正確答案 (   (',Answer[1],')   ) ','│':19,DachS:20,'│':6);
      writeln(OutF,'└────────────────────┴────────────┘');
      writeln(OutF,'  命題單位  ',MakeUnit:8,'審核單位  ':28,CheckUnit);
      writeln(OutF,' ':10,DachM,' ':16,DachM);
      for I := 1 to 3 do writeln(OutF);
      inc(QuesNum)
    end
  end
end;

procedure Conclude;
begin
  gotoxy(45,22);
  writeln('終 止 題 號 ：( ',QuesNum-1,' )');
  close(InF);
  close(OutF)
end;

begin
  Test_System;
  Input_Const_Data;
  Trans_Data;
  Conclude
end.



