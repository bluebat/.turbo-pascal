program Leben;
uses crt, dos, Intrs;
const Cell = #15;
      MaxY = 59;
      EndY : byte = 22;
      EndX = 79;
      EndM = 11;
      Alarm = 5750;
      BoardColor : byte = blue;
      Master : boolean = false;
type
  RowString = string[EndX];
  ScrRam = array[0..MaxY,0..EndX,0..1] of char;
var
  FrontScr : ScrRam absolute $B800:0000;
  BackScr : ScrRam absolute $BC00:0000;
  ScrSize : word;
  FuncKey : char;
  F : text;
  TextBuffer : array[1..4096] of char;
  LifeBuf : array[0..MaxY,0..9] of byte;
  DataSum : byte;
  NormalY, MouseUsable : boolean;
  SideY : array[0..MaxY,-1..1] of byte;
  SideX : array[0..EndX,-1..1] of byte;
  LifeFile, LifeData : RowString;
  ScrX, ScrY, LifeNum, LifeGen, LifeSum : integer;
  Menu : array[1..EndM*2] of RowString;

  procedure ShowGenSum;
  begin
    if not Master then
    begin
      Wwindow(1,EndY+2,EndX+1,EndY+3);
      textcolor(black);
      textbackground(lightgray);
      gotoxy(69,whereY);
      write(LifeGen:3);
      if LifeGen = 0 then write(#32);
      gotoxy(77,whereY);
      write(LifeSum:3)
    end
  end;

  procedure ShowMenu(Num1, Num2:byte);
  var
    CostKey : char;
    I, J, MenuNum : byte;
  begin
    Wwindow(1,EndY+2,EndX+1,EndY+3);
    textbackground(lightgray);
    for J := 1 to 2 do
    begin
      if J = 1 then MenuNum := Num1 else MenuNum := Num2;
      if not Master then
      begin
        gotoxy(1,J);
        clreol;
        textcolor(brown);
        if MenuNum > 0 then
        begin
          if ChineseMode then inc(MenuNum,EndM);
          for I := 0 to (EndX - length(Menu[MenuNum])) div 2 do write(#32);
          for I := 1 to length(Menu[MenuNum]) do
          begin
            if Menu[MenuNum][I] = ':' then textcolor(black)
              else if Menu[MenuNum][I] = #32 then textcolor(brown);
            write(Menu[MenuNum][I])
          end;
          if MenuNum mod EndM = 1 then ShowGenSum
        end
      end;
      if MenuNum mod EndM = 6 then
      begin
        repeat until keypressed or MousePressed;
        if keypressed then repeat CostKey := readkey until not keypressed
      end
    end
  end;

  function LawfulData(PreData:RowString):boolean;
  var Lawful : boolean;
      Cut : byte;
  begin
    Lawful:=pos(PreData[1],'EDC?')*pos(PreData[2],'CLI?')*pos(PreData[3],'CLI?') > 0;
    if PreData[4] <> '-' then Lawful := false;
    Cut := pos('.',PreData);
    if pos(PreData[Cut+1],'RB') = 0 then Lawful := false;
    LawfulData := Lawful
  end;

  procedure Para_Life;
  var Syntax : boolean;
      I : byte;
      Parameter : RowString;
  begin
    LifeFile := 'LEBEN.LIF';
    Syntax := true;
    for I := 1 to paramcount do
    begin
      Parameter := paramstr(I);
      if Parameter[1] <> '/' then LifeFile := Parameter else
      case upcase(Parameter[2]) of
        'C' : EndY := 22;
        'E' : EndY := 40;
        'V' : EndY := 47;
        'P' : EndY := 57;
        'S' : Beep(0);
        'B' : BoardColor := black;
        'M' : Master := true
        else Syntax := false
      end
    end;
    NormalY := EndY = 22;
    if Master then inc(EndY,2);
    ScrSize := (EndY+1)*(EndX+1)*2;
    assign(F,LifeFile);
    settextbuf(F,TextBuffer);
    {$I-}reset(F);{$I+}
    if ioresult <> 0 then
    begin
      {$I-}rewrite(F);{$I+}
      if ioresult <> 0 then Syntax := false
    end;
    if not Syntax then
    begin
      writeln('Illegal Parameter(s)!');
      writeln('Syntax : LEBEN [/{C|E|V|P}] [/S] [/B] [/M] [file name]');
      halt
    end
  end;

  procedure Set_Life;
  var I, J : integer;
  begin
    randomize;
    FuncKey := #13;
    LifeData := 'ECC-Xxxxx-2.R1 S0P1A3';
    ScrX := EndX div 2;
    ScrY := EndY div 2;
    for J := 0 to EndY do for I := -1 to 1 do SideY[J,I] := (J + I + EndY+1) mod (EndY+1);
    for J := 0 to EndX do for I := -1 to 1 do SideX[J,I] := (J + I + EndX+1) mod (EndX+1);
    fillchar(LifeBuf,sizeof(LifeBuf),$00);
    Menu[1] := ':move ^v<>:shif BAR:set 囁:grow TAB:step BS:look ESC:quit gen:000 sum:000';
    Menu[2] := 'H:elp N:ame S:ave L:oad X:nxt O:utp E:xpl C:lrs R:ota M:irr A:uto G:get P:put';
    Menu[3] := 'Enter the pattern-number (0 for UNDO, letters for SEARCH)   '#8#8;
    Menu[4] := '<classi.>-<discrip.>[-<foot num.>].<item type>[<item num.>] <other char.> ==';
    Menu[5] := 'I congratulate you on your discovery. Please send it to me ! OK ?';
    Menu[6] := 'Press any key to continue !';
    Menu[7] := 'It''s illegal to do with such a <life pattern> !';
    Menu[8] := 'No data can be found in this file !';
    Menu[9] := 'Are you sure to do that ? (Y/N) :';
    Menu[10] := 'BackSpace:stop_and_get_pattern    other keys:pass             gen:000 sum:000';
    Menu[11] := 'ESC:exit  1:command-line 2:function 3:rules 4:nomenclature 5:characters :';
    Menu[12] := ':移動 ^v<>:平移 □:替換 ←┘:生長 :單步 BS:尋找 ESC:結束 gen:000 sum:000';
    Menu[13] := 'H::助 N::名 S::存 L::載 X::次 O::檔 E::釋 C::清 R::旋 M::鏡 A::自 G::收 P::放';
    Menu[14] := '請 輸 入 <生 命 圖 樣> 號 碼 (0 代表 放棄, 文數字 代表 搜尋)   '#8#8;
    Menu[15] := '<分類別>-<描述字>[-<足碼>].<項模式>[<項碼>]<空白><其他特徵> ==';
    Menu[16] := '恭 喜 您 有 了 新 的 發 現 。 請 將 它 寄 給 我 好 嗎 ?';
    Menu[17] := '請 按 任 意 一 鍵 繼 續 !';
    Menu[18] := '對 此 <生 命 圖 樣> , 此 步 驟 是 不 合 程 序 的 !';
    Menu[19] := '檔 案 中 找 不 到 任 何 資 料 !';
    Menu[20] := '您 確 定 要 這 麼 做 嗎 ? (Y/N) :';
    Menu[21] := 'BackSpace:停止並收入圖樣       other keys:跳過                gen:000 sum:000';
    Menu[22] := 'ESC:離開   1:命令列  2:功能鍵  3:生長規則  4:命名法  5:其他特徵   :';
  end;

  procedure ListLife(ListStr:RowString);
  var ListNum : byte;
      ListData : RowString;
      ListName : string[20];
      RealPage : boolean;
  begin
    ListNum := 0;
    DataSum := 0;
    RealPage := false;
    Wwindow(1,2,EndX+1,EndY+1);
    textbackground(lightgray);
    reset(F);
    while not eof(F) do
    begin
      readln(F,ListData);
      if LawfulData(ListData) then
      begin
        if pos(ListStr,ListData) > 0 then
        begin
          RealPage := true;
          if pos(#32,ListData) = 0 then ListName := ListData
            else ListName := copy(ListData,1,pos(#32,ListData));
          gotoxy(ListNum mod 3 * 26 + 2,whereY);
          textcolor(black);
          write('(',DataSum+1:2,') ');
          textcolor(yellow);
          write(ListName);
          inc(ListNum);
          if ListNum mod 3 = 0 then writeln
        end;
        inc(DataSum);
        if (ListNum mod (EndY*3-3) = 0) and RealPage then
        begin
          RealPage := false;
          ShowMenu(0,6);
          move(BackScr,FrontScr,ScrSize)
        end;
	if ListNum mod (EndY*3-3) = 0 then Wwindow(1,2,EndX+1,EndY+1)
      end
    end
  end;

  procedure ClearBoard;
  begin
    if NormalY then window(3,2,EndX-1,22) else window(3,2,EndX-1,41);
    textcolor(lightcyan);
    textbackground(green);
    clrscr
  end;

  procedure Help_Life;
  var I, J : integer;
      HelpKey : char;
      HelpData : RowString;
      H : text;
  begin
    if ChineseMode then assign(H,'LEBEN.HLC') else assign(H,'LEBEN.HLP');
    {$I-}reset(H);{$I+}
    if ioresult <> 0 then ShowMenu(8,6) else
    begin
      if FuncKey = 'H' then move(FrontScr,BackScr,ScrSize);
      window(14,(EndY-14) div 2,EndX,(EndY-14) div 2+19);
      textcolor(lightcyan);
      textbackground(green);
      for I := 1 to 18 do
      begin
        readln(H,HelpData);
        writeln(HelpData)
      end;
      HelpKey := #0;
      J := 0;
      while (FuncKey = 'H') and (HelpKey <> #27) do
      begin
        ShowMenu(0,11);
        J := succ(J mod 5);
        if J in [1..5] then write(J,#8) else Beep(Alarm);
        HelpKey := #13;
        Cursor(true);
        repeat until keypressed or MousePressed;
        Cursor(false);
        if keypressed then HelpKey := readkey;
        if HelpKey = #13 then HelpKey := chr(J+48);
        if ord(HelpKey) in [49..54] then
        begin
          J := ord(HelpKey)-48;
          ClearBoard;
          reset(H);
          for I := 1 to 21*J do readln(H);
          for I := 1 to 20 do
          begin
            readln(H,HelpData);
            writeln(HelpData);
            if not NormalY then writeln
          end;
          readln(H)
        end
      end;
      if FuncKey = 'H' then move(BackScr,FrontScr,ScrSize);
      close(H)
    end
  end;

  procedure Head_Life;
  begin
    if NormalY then
    begin
      textmode(c80);
      ShowET;
    end else
    begin
      ReleaseET;
      textmode(font8x8+c80);
      if EndY > 50 then TextModeVGAplus
    end;
    MouseUsable := MouseInstalled;
    if MouseUsable then
    begin
      if Master then MouseMaxY(EndY+1) else MouseMaxY(EndY+3);
      MouseSpeed(16,16);
      MouseColor($7FFF,$3F00)
    end;
    Cursor(false);
    ListLife(chr(random(7)+50));
    Help_Life;
    if DataSum = 0 then ShowMenu(8,6) else ShowMenu(0,6)
  end;

  procedure Clear_Life;
  var J, I : byte;
  begin
    Wwindow(1,1,EndX+1,EndY+1);
    textcolor(yellow);
    textbackground(BoardColor);
    clrscr;
    LifeNum := 0;
    LifeSum := 0;
    LifeGen := 0
  end;

  procedure Key_Life;
  const Menu2T : string[14] = 'HNSLXOECRMAGP'#0;
  var InChinese, Actted : boolean;
      LastKey : char;
  begin
    LastKey := FuncKey;
    FuncKey := #0;
    InChinese := ChineseMode;
    if pos(LastKey,'HNSLED'#8#13) > 0 then ShowMenu(1,2);
    if pos(LastKey,' ACXPR') > 0 then ShowGenSum;
    Wwindow(1,1,EndX+1,EndY+1);
    textcolor(yellow);
    textbackground(BoardColor);
    gotoxy(ScrX+1,ScrY+1);
    Cursor(true);
    if MouseUsable then
    begin
      if MouseY <= EndY then GotoMouse(ScrX,ScrY);
      Mouse(true)
    end;
    Actted := false;
    repeat
      if keypressed then
      begin
        Actted := true;
        FuncKey := upcase(readkey)
      end;
      if not Actted and MouseUsable and MousePressed then
      begin
        Actted := true;
        if MouseY in [0..EndY] then
            begin
              ScrX := MouseX;
              ScrY := MouseY;
              FuncKey := #32
            end
          else if MouseY = EndY+2 then
               begin
                 if ((MouseX+5) mod 6) * ((MouseX+5) div 6) > 0 then
                   FuncKey := Menu2T[(MouseX+5) div 6] else Beep(Alarm)
               end
          else case MouseX of
                     11 : FuncKey := '^';
                     12 : FuncKey := 'V';
                     13 : FuncKey := '<';
                     14 : FuncKey := '>';
                 21..27 : FuncKey := #32;
                 29..36 : FuncKey := #13;
                 38..45 : FuncKey := #9;
                 47..53 : FuncKey := #8;
                 55..62 : FuncKey := #27
                 else Beep(Alarm)
               end;
      end
    until Actted;
    Cursor(false);
    if MouseUsable then Mouse(false);
    if (FuncKey = #13) and (LastKey = #13) then FuncKey := #0;
    if FuncKey <> #0 then if pos(FuncKey,'HNSLXOECRMA^V<>GP'#8#9#13#27#32) > 0
      then Beep(36) else Beep(Alarm)
  end;

  procedure Name_Life;
  var NameData : RowString;
      Lawful : boolean;
  begin
    if LifeSum > 0 then
    begin
      if Master then move(FrontScr,BackScr,Scrsize);
      Cursor(true);
      repeat
        ShowMenu(4,0);
        textcolor(white);
        write(LifeData);
        gotoxy(1,wherey);
        textcolor(black);
        readln(NameData);
        Lawful := LawfulData(NameData);
        if length(NameData) = 0 then Lawful := true;
        if not Lawful then Beep(Alarm)
      until Lawful;
      Cursor(false);
      if Master then move(BackScr,FrontScr,Scrsize);
      if length(NameData) > 0 then
      begin
        LifeNum := -1;
        LifeData := NameData
      end
    end else ShowMenu(7,6)
  end;

  procedure Save_Life;
  var
      X, Y : byte;
      XRange, YRange : integer;
  begin
    if LifeNum = -1 then
    begin
      XRange := EndX;
      YRange := EndY;
      for Y := 0 to EndY do for X := 0 to EndX do if FrontScr[Y,X,0] = Cell then
      begin
        if X < lo(XRange) then XRange := X + hi(XRange) shl 8;
        if X > hi(XRange) then XRange := X shl 8 + lo(XRange);
        if Y < lo(YRange) then YRange := Y + hi(YRange) shl 8;
        if Y > hi(YRange) then YRange := Y shl 8 + lo(YRange);
      end;
      XRange := (hi(XRange) + lo(XRange)) shr 1;
      YRange := (hi(YRange) + lo(YRange)) shr 1;
      append(F);
      writeln(F,LifeData);
      for Y := 0 to EndY do for X := 0 to EndX do
       if FrontScr[Y,X,0] = Cell then write(F,#32,X-XRange,#32,Y-YRange);
      writeln(F);
      move(FrontScr,BackScr,ScrSize);
      ListLife(LifeData);
      LifeNum := DataSum;
      ShowMenu(5,6);
      move(BackScr,FrontScr,ScrSize)
    end else ShowMenu(7,6)
  end;

  procedure Load_Life; {Next_Life}
  var LoadData : RowString;
      PassNum : byte;
      LoadNum, X, Y : integer;
  begin
    if FuncKey = 'L' then
    begin
      move(FrontScr,BackScr,ScrSize);
      repeat
        X := -1;
        ShowMenu(0,3);
        write(DataSum,' >= ');
        textcolor(black);
        Cursor(true);
        readln(LoadData);
        Cursor(false);
        move(BackScr,FrontScr,ScrSize);
        if length(LoadData) < 5 then val(LoadData,LoadNum,X);
        if X <> 0 then ListLife(LoadData)
      until (LoadNum >= 0) and (LoadNum <= DataSum) and (X = 0);
    end else LoadNum := succ(LifeNum) mod succ(DataSum);
    if LoadNum > 0 then
    begin
      PassNum := 0;
      reset(F);
      repeat
        readln(F,LoadData);
        if LawfulData(LoadData) then inc(PassNum)
      until (PassNum = LoadNum) or eof(F);
      if eof(F) then Beep(Alarm) else
      begin
        Clear_Life;
        LifeNum := LoadNum;
        LifeData := LoadData;
        repeat
          inc(LifeSum);
          read(F,X,Y);
          FrontScr[Y+EndY div 2,X+EndX div 2,0] := Cell
        until eoln(F)
      end
    end
  end;

  procedure ExplainC;
  var ExplData : RowString;
      Cut, I : integer;
  begin
    ExplData := LifeData;
    if LifeNum > 0 then write('(<生命圖樣>號碼 : ',LifeNum)
                   else write('(新命名圖樣');
    write(' 於 ',LifeFile,')');
    Wwindow(14,whereY+3,EndX-1,EndY);
    if not NormalY then writeln(#10#10#13);
    write('這 個 <生 命 形 式> 的 結 局 是 ');
    case ExplData[1] of
      'E' : writeln('基 本 型。');
      'D' : writeln('滅 絕 型。');
      'C' : writeln('複 合 型。')
      else writeln('未 知 型。')
    end;
    if not NormalY then writeln(#10#10#13) else writeln;
    for I := 2 to 3 do
    begin
      write('這 個 <生 命 形 式> ');
      if I = 2 then write('可 達 到 的 範 圍 是 ') else write('穩 定 時 的 細 胞 數 是 ');
      case ExplData[I] of
        'C' : writeln('固 定 的。');
        'L' : writeln('有 限 的。');
        'I' : writeln('無 限 的。')
        else writeln('未 知 的。')
      end;
      if not NormalY then writeln(#10#10#13) else writeln
    end;
    Cut := pos('.',ExplData);
    writeln('這 個 <生 命 形 式> 的 描 述 是 ',copy(ExplData,5,Cut-5),' 。');
    if not NormalY then writeln(#10#10#13) else writeln;
    delete(ExplData,1,Cut);
    Cut := pos(#32,ExplData);
    write('這 個 <生 命 圖 樣> 是 其 <生 命 形 式> ');
    case ExplData[1] of
      'B' : write('穩 定 前');
      'R' : write('循 環 中')
      else write('序 列 中')
    end;
    write(' 的 ');
    if ExplData[2] = #32 then write('一') else write('第 ',copy(ExplData,2,Cut-2));
    writeln(' 項。');
    if not NormalY then writeln(#10#10#13) else writeln;
    if Cut = 0 then ExplData := 'S-PunknownA1'
               else ExplData := copy(ExplData,Cut+1,length(ExplData)-Cut);
    write('這 個 <生 命 形 式> 對 稱 於 ');
    case ExplData[2] of
      '0' : writeln('無 任 何 軸。');
      '1' : writeln('X=0 互斥或 Y=0 軸。');
      '2' : writeln('X=0 及 Y=0 軸。');
      '3' : writeln('X=Y 互斥或 X=-Y 軸。');
      '4' : writeln('X=Y 及 X=-Y 軸。');
      '5' : writeln('原 點 180 。');
      '6' : writeln('原 點 90 。');
      '7' : writeln('X=0 及 Y=0 及 X=Y 及 X=-Y 軸。');
      else writeln('未 知 軸。')
    end;
    if not NormalY then writeln(#10#10#13) else writeln;
    Cut := pos('A',ExplData);
    writeln('這 個 <生 命 形 式> 的 穩 定 週 期 是 ',copy(ExplData,4,Cut-4),' 。');
    if not NormalY then writeln(#10#10#13) else writeln;
    delete(ExplData,1,Cut);
    if length(ExplData) < 5 then
    begin
      val(ExplData,Cut,I);
      if Cut = 0 then ExplData := '無 限 多'
    end else ExplData := '許 多';
    write(ExplData:2,' 個 <生 命 形 式> 是 彼 此 相 似 的。')
  end;

  procedure ExplainE;
  var ExplData : RowString;
      Cut, I : integer;
  begin
    ExplData := LifeData;
    if LifeNum > 0 then write('(Pattern-Number : ',LifeNum)
                   else write('(New Named Pattern');
    write(' in ',LifeFile,')');
    Wwindow(14,whereY+3,EndX-1,EndY);
    if not NormalY then writeln(#10#10#13);
    write('The ending of this <life form> is ');
    case ExplData[1] of
      'E' : writeln('elementary.');
      'D' : writeln('dead.');
      'C' : writeln('compound.')
      else writeln('unknown.')
    end;
    if not NormalY then writeln(#10#10#13) else writeln;
    for I := 2 to 3 do
    begin
      if I = 2 then write('The reachable range') else write('The stable amount');
      write(' of this <life form> is ');
      case ExplData[I] of
        'C' : writeln('constant.');
        'L' : writeln('limited.');
        'I' : writeln('infinite.')
        else writeln('unknown.')
      end;
      if not NormalY then writeln(#10#10#13) else writeln
    end;
    Cut := pos('.',ExplData);
    writeln('The discription of this <life form> is ',copy(ExplData,5,Cut-5),'.');
    if not NormalY then writeln(#10#10#13) else writeln;
    delete(ExplData,1,Cut);
    Cut := pos(#32,ExplData);
    write('This <life pattern> is an');
    if ExplData[2] <> #32 then write(#8#8,'the #',copy(ExplData,2,Cut-2));
    write(' item ');
    case ExplData[1] of
      'B' : writeln('before stable.');
      'R' : writeln('in the repeat.')
      else writeln('in the series.')
    end;
    if not NormalY then writeln(#10#10#13) else writeln;
    if Cut = 0 then ExplData := 'S-PunknownA1'
               else ExplData := copy(ExplData,Cut+1,length(ExplData)-Cut);
    write('This <life form> has symmetry to ');
    case ExplData[2] of
      '0' : writeln('no axis.');
      '1' : writeln('X=0 xor Y=0.');
      '2' : writeln('X=0 and Y=0.');
      '3' : writeln('X=Y xor X=-Y.');
      '4' : writeln('X=Y and X=-Y.');
      '5' : writeln('zero point (180).');
      '6' : writeln('zero point (90).');
      '7' : writeln('X=0 and Y=0 and X=Y and X=-Y.');
      else writeln('unknown axis.')
    end;
    if not NormalY then writeln(#10#10#13) else writeln;
    Cut := pos('A',ExplData);
    writeln('The stable period of this <life form> is ',copy(ExplData,4,Cut-4),'.');
    if not NormalY then writeln(#10#10#13) else writeln;
    delete(ExplData,1,Cut);
    if length(ExplData) < 5 then
    begin
      val(ExplData,Cut,I);
      if Cut = 0 then ExplData := 'Infinite'
    end else ExplData := 'Many';
    write(ExplData,' <life form>');
    if Cut = 1 then write(' is') else write('s are');
    writeln(' alike in structure.')
  end;

  procedure Explain_Life;
  begin
    if LifeNum <> 0 then
    begin
      move(FrontScr,BackScr,ScrSize);
      ClearBoard;
      gotoxy((EndX-length(Menu[4])) div 2+2,2);
      writeln(Menu[4],#8#8#32#32);
      if not NormalY then writeln(#10#10#13) else writeln;
      write('':(EndX-length(Menu[4])) div 2+3,': ',LifeData,'':6);
      if ChineseMode then ExplainC else ExplainE;
      ShowMenu(0,6);
      move(BackScr,FrontScr,ScrSize)
    end else ShowMenu(7,6)
  end;

  procedure Output_Life;
  var I, J, Blank : byte;
      PreLine, ThisLine : boolean;
      P : text;
  begin
    if LifeSum > 0 then
    begin
      assign(P,'LEBEN.PRN');
      {$I-}append(P);{$I+}
      if ioresult <> 0 then rewrite(P);
      writeln(P);
      if LifeNum = 0 then LifeData := '???-Unknown.H S?P?A?';
      writeln(P,'(',LifeNum:2,') ',LifeData);
      PreLine := false;
      Blank := 0;
      for J := 0 to EndY do
      begin
        I := 0;
        ThisLine := false;
        repeat
          inc(I);
          if ThisLine
          then if FrontScr[J,I,0] = Cell then write(P,'O') else write(P,#32)
          else if (FrontScr[J,I,0] = Cell) then
          begin
            for I := 1 to Blank do writeln(P);
            Blank := 0;
            ThisLine := true;
            I := 0
          end;
        until I = EndX;
        if ThisLine then
        begin
          writeln(P);
          PreLine := true
        end else if PreLine then inc(Blank)
      end;
      close(P)
    end else ShowMenu(7,6)
  end;

  procedure Shift_Life;
  var I, J : byte;
      DirX, DirY : integer;
  begin
    DirX := 0;
    DirY := 0;
    case FuncKey of
      '^' : DirY := 1;
      'V' : DirY := -1;
      '<' : DirX := 1;
      '>' : DirX := -1
      else Beep(Alarm)
    end;
    if DirX+DirY <> 0 then
    begin
      for J := 0 to EndY do for I := 0 to EndX do
        BackScr[J,I] := FrontScr[SideY[J,DirY],SideX[I,DirX]];
      move(BackScr,FrontScr,ScrSize)
    end
  end;

  procedure Mirrow_Life;
  var I, J : byte;
  begin
    for J := 0 to EndY do for I := 0 to EndX do
      BackScr[J,I] := FrontScr[J,EndX-I];
    move(BackScr,FrontScr,ScrSize)
  end;

  procedure Rotate_Life;
  var I, J : integer;
      NewSum, MidX, MidY : byte;
  begin
    NewSum := 0;
    MidX := EndX div 2;
    MidY := EndY div 2;
    move(FrontScr,BackScr,ScrSize);
    for J := -MidY to MidY do for I := -MidY to MidY do
    begin
      if FrontScr[I+MidY,-J+MidX,0] = Cell then inc(NewSum);
      BackScr[J+MidY,I+MidX] := FrontScr[I+MidY,-J+MidX]
    end;
    move(BackScr,FrontScr,ScrSize);
    if LifeSum <> NewSum then
    begin
      Beep(Alarm);
      LifeNum := 0;
      LifeGen := 0
    end
  end;

  procedure Memory_Life;
  var I, J : byte;
  begin
    if FuncKey = 'G' then
    begin
      fillchar(LifeBuf,sizeof(LifeBuf),$00);
      for J := 0 to EndY do for I := 0 to EndX do if FrontScr[J,I,0] = Cell
        then LifeBuf[J,I shr 3] := LifeBuf[J,I shr 3] or (1 shl (I mod 8));
    end else
    for J := 0 to EndY do for I := 0 to EndX do
      if odd(LifeBuf[J,I shr 3] shr (I mod 8)) and (FrontScr[J,I,0] <> Cell) then
      begin
        LifeGen := 0;
        LifeNum := 0;
        FrontScr[J,I,0] := Cell;
        inc(LifeSum)
      end
  end;

  procedure Move_Life;
  begin
    if keypressed then case readkey of
      #72 : ScrY := (ScrY + EndY) mod (EndY+1);
      #80 : ScrY := (ScrY + 1) mod (EndY+1);
      #75 : ScrX := (ScrX + EndX) mod (EndX+1);
      #77 : ScrX := (ScrX + 1) mod (EndX+1)
      else Beep(Alarm)
    end
  end;

  procedure Grow_Life;
  var
    StopGrow : boolean;
    X, Y, I, J : integer;
    Neighbor : byte;
    Memo : array[0..MaxY,0..9] of byte;
  begin
    delete(Menu[1],33,4);
    insert('stop',Menu[1],33);
    delete(Menu[1+EndM],34,4);
    insert('停止',Menu[1+EndM],34);
    if FuncKey = #13 then ShowMenu(1,2);
    move(FrontScr,BackScr,ScrSize);
    repeat
      fillchar(Memo,sizeof(Memo),$00);
      for Y := 0 to EndY do for X := 0 to EndX do if FrontScr[Y,X,0] = Cell then
        for I := -1 to 1 do for J := -1 to 1 do
          Memo[SideY[Y,J],SideX[X,I] shr 3]
          := Memo[SideY[Y,J],SideX[X,I] shr 3] or (1 shl (SideX[X,I] mod 8));
      LifeSum := 0;
      for Y := 0 to EndY do for X := 0 to EndX do
        if odd(Memo[Y,X shr 3] shr (X mod 8)) then
      begin
        if FrontScr[Y,X,0] = Cell then Neighbor := 8 else Neighbor := 0;
        for J := -1 to 1 do for I := -1 to 1 do
          if FrontScr[SideY[Y,J],SideX[X,I],0] = Cell then inc(Neighbor);
        if (Neighbor = 3) or (Neighbor = 11) or (Neighbor = 12) then
        begin
          BackScr[Y,X,0] := Cell;
          inc(LifeSum)
        end else BackScr[Y,X,0] := #32
      end;
      move(BackScr,FrontScr,ScrSize);
      inc(LifeGen);
      ShowGenSum;
      StopGrow := keypressed or (LifeSum = 0) or (FuncKey = #9);
      if FuncKey = #13 then StopGrow := StopGrow or MousePressed
    until StopGrow;
    if not keypressed and (FuncKey = #13) then FuncKey := #8;
    delete(Menu[1],33,4);
    insert('grow',Menu[1],33);
    delete(Menu[1+EndM],34,4);
    insert('生長',Menu[1+EndM],34)
  end;

  procedure Toggle_Life;
  begin
    LifeNum := 0;
    LifeGen := 0;
    FrontScr[ScrY,ScrX,0] := chr(ord(Cell)+32-ord(FrontScr[ScrY,ScrX,0]));
    if FrontScr[ScrY,ScrX,0] = Cell then inc(LifeSum) else dec(LifeSum)
  end;

  procedure Auto_Life;
  var X, Y, I : integer;
    procedure AddCell(CY,CX : integer);
    begin
      CY := succ(CY+ScrY+EndY) mod succ(EndY);
      CX := succ(CX+ScrX+EndX) mod succ(EndX);
      if FrontScr[CY,CX,0] <> Cell then
      begin
        inc(LifeSum);
        FrontScr[CY,CX,0] := Cell
      end
    end;

  begin
    Clear_Life;
    X := ScrX-random(3);
    Y := ScrY-random(3);
    randomize;
    I := trunc(random * 7)+1;
    repeat
      X := X + trunc(random * 4.6-2.3);
      Y := Y + trunc(random * 4.6-2.3);
      AddCell(Y-ScrY,X-ScrX);
      case I of
        1 : AddCell(Y-ScrY,ScrX-X);
        2 : begin
              AddCell(Y-ScrY,ScrX-X);
              AddCell(ScrY-Y,X-ScrX);
              AddCell(ScrY-Y,ScrX-X)
            end;
        3 : AddCell(ScrX-X,ScrY-Y);
        4 : begin
              AddCell(ScrX-X,ScrY-Y);
              AddCell(-ScrX+X,-ScrY+Y);
              AddCell(ScrY-Y,ScrX-X)
            end;
        5 : AddCell(ScrY-Y,ScrX-X);
        6 : begin
              AddCell(ScrX-X,-ScrY+Y);
              AddCell(ScrY-Y,ScrX-X);
              AddCell(-ScrX+X,ScrY-Y)
            end;
        7 : begin
              AddCell(Y-ScrY,ScrX-X);
              AddCell(ScrY-Y,X-ScrX);
              AddCell(ScrX-X,ScrY-Y);
              AddCell(-ScrX+X,-ScrY+Y);
              AddCell(ScrX-X,-ScrY+Y);
              AddCell(-ScrX+X,ScrY-Y);
              AddCell(ScrY-Y,ScrX-X)
            end
      end
    until (random(12-I) = 0) and (LifeSum > 6)
  end;

  procedure Delete_Life;
  var U : text;
      PassNum : byte;
      TransChar : char;
      TransData : string;
  begin
    if LifeNum > 0 then
    begin
      move(FrontScr,BackScr,ScrSize);
      ListLife(LifeData);
      ShowMenu(0,9);
      if upcase(readkey) = 'Y' then
      begin
        write('Y');
        assign(U,'LEBEN.BAK');
        {$I-}erase(U);{$I+}
        PassNum := ioresult;
        close(F);
        rename(F,'LEBEN.BAK');
        reset(F);
        assign(U,LifeFile);
        rewrite(U);
        PassNum := 0;
        while not eof(F) do
        begin
          readln(F,TransData);
          if LawfulData(TransData) then inc(PassNum);
          if PassNum = LifeNum then readln(F,TransData) else
          begin
            writeln(U,TransData);
            while not eoln(F) do
            begin
              read(F,TransChar);
              write(U,TransChar)
            end;
            readln(F);
            writeln(U)
          end
        end;
        close(F);
        close(U);
        assign(F,LifeFile);
	settextbuf(F,TextBuffer);
	reset(F);
	LifeNum := 0
      end else write('N');
      move(BackScr,FrontScr,ScrSize)
    end else ShowMenu(7,6)
  end;

  procedure Look_Life;
  begin
    ShowMenu(10,0);
    repeat
      Auto_Life;
      FuncKey := 'G';
      Memory_Life;
      repeat
        FuncKey := #9;
        Grow_Life
      until keypressed or MousePressed or (LifeSum = 0) or (LifeGen = 128);
      Beep(36);
      if keypressed then FuncKey := upcase(readkey)
    until FuncKey = #8
  end;

  procedure Quit_Life;
  begin
    ShowMenu(0,9);
    Cursor(true);
    if LifeNum = -1 then
    repeat
      Beep(36);
      Beep(Alarm)
    until keypressed;
    if upcase(readkey) = 'Y' then
    begin
      close(F);
      textmode(c80);
      textcolor(lightgray);
      textbackground(black);
      window(1,1,80,25)
    end else
    begin
      FuncKey := #13;
      Cursor(false)
    end
  end;

begin
  Para_Life;
  Set_Life;
  Head_Life;
  Clear_Life;
  repeat
    Key_Life;
    case FuncKey of
      'H' : Help_Life;
      'N' : Name_Life;
      'S' : Save_Life;
  'L','X' : Load_Life;
      'E' : Explain_Life;
      'O' : Output_life;
      'C' : Clear_Life;
'^','V','<','>':Shift_Life;
      'M' : Mirrow_Life;
      'R' : Rotate_Life;
  'G','P' : Memory_Life;
      'A' : Auto_Life;
      'D' : Delete_Life;
      #8  : Look_Life;
      #0  : Move_Life;
   #9,#13 : Grow_Life;
      #32 : Toggle_Life;
      #27 : Quit_Life
    end
  until FuncKey = #27
end.
