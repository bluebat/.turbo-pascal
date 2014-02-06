{$A+,B-,D+,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}
program LundM;
uses crt;
type
  String2 = string[2];
const
  Finished : boolean = false;
var
  F : text;
  XSpace, YSpace : string;
  TopStr, InStr, MidStr, EndStr : string;
  Way : char;

procedure WriteXY(X,Y : byte; Prompt : string);
begin
  gotoxy(X,Y);
  write(Prompt)
end;

procedure Set_Title;
begin
  clrscr;
  directvideo := false;
  write(#27'T24,180,20,24,2,S;縱橫表格'#27'T24,181,21,24,2,X;縱橫表格');
  write(#27'T16;')
end;

procedure Open_File;
var
  FileName : string;
begin
  getdir(0,FileName);
  gotoxy(10,10);
  write('文 書 檔 案 路 徑 及 名 稱 : (' + FileName + ') ');
  clreol;
  readln(FileName);
  Finished := FileName = '';
  assign(F,FileName);
  {$I-}reset(F);{$I+}
  if (ioresult = 0) and not Finished then
  begin
    WriteXY(10,12,'檔案已存在！ 您欲對其 [A]_增添、[O]_覆寫 或 [Q]_跳離 ? ');
    repeat until keypressed;
    Way := upcase(readkey);
    case Way of
      'O' : rewrite(F);
      'A' : append(F)
    else Way := 'Q'
    end;
    write(Way)
  end else rewrite(F)
end;

procedure Draw_X_Line;
  procedure DrawLine(XS:string;var RowStr:string;Head,Body,Bone,Tail:String2);
  var
    I : integer;
    CutPoint, SpaceNum : shortint;
  begin
    RowStr := Head;
    while length(XS) > 0 do
    begin
      CutPoint := pred(pos(' ',XS));
      if CutPoint = -1 then CutPoint := length(XS);
      val(copy(XS,1,CutPoint),SpaceNum,I);
      delete(XS,1,CutPoint);
      while (XS[1] = ' ') and (length(XS) > 0) do delete(XS,1,1);
      for I := 1 to SpaceNum do RowStr := RowStr + Body;
      if length(XS) > 0 then RowStr := RowStr + Bone
    end;
    RowStr := RowStr + Tail
  end;

begin
  WriteXY(10,15,'輸入橫向空格數之字串：( 以雙行為單位 ) ');
  WriteXY(10,17,'n1 n2 ... ');
  clreol;
  readln(XSpace);
  while XSpace[1] = ' ' do delete(XSpace,1,1);
  if length(XSpace) > 0 then
  begin
    DrawLine(XSpace,TopStr,'┌','─','┬','┐');
    DrawLine(XSpace,InStr, '│','  ','│','│');
    DrawLine(XSpace,MidStr,'├','─','┼','┤');
    DrawLine(XSpace,EndStr,'└','─','┴','┘')
  end
end;

procedure Draw_Y_Line;
var
  I : integer;
  CutPoint, SpaceNum : shortint;
begin
  WriteXY(10,20,'輸入縱向空格數之字串： ');
  WriteXY(10,22,'n1 n2 ... ');
  clreol;
  readln(YSpace);
  while YSpace[1] = ' ' do delete(YSpace,1,1);
  if length(YSpace) > 0 then
  begin
    writeln(F,TopStr);
    while length(YSpace) > 0 do
    begin
      CutPoint := pred(pos(' ',YSpace));
      if CutPoint = -1 then CutPoint := length(YSpace);
      val(copy(YSpace,1,CutPoint),SpaceNum,I);
      delete(YSpace,1,CutPoint);
      while (YSpace[1] = ' ') and (length(YSpace) > 0) do delete(YSpace,1,1);
      for I := 1 to SpaceNum do writeln(F,InStr);
      if length(YSpace) > 0 then writeln(F,MidStr)
    end;
    writeln(F,EndStr)
  end
end;

begin
  Set_Title;
  repeat
    Open_File;
    if (Way <> 'Q') and not Finished then
    begin
      Draw_X_Line;
      Draw_Y_Line
    end;
    close(F)
  until Finished;
  write(#27'CL;')
end.

