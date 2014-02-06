program Lied;
uses crt, dos;
const
  Frequenz : array['1'..'7'] of real
           = (523.25,587.33,659.26,698.46,783.99,880,987.77);
  TaktDauer : integer = 640;
  Bindebogen : boolean = false;
  Fermate : boolean = false;
  Ruhe = 32767;
  TaktZahl : 1..9 = 4;
  PreKey : char = #0;
type
  RowString = string[79];
  NoteString = string[9];
var
  FuncKey : char;
  FreQuote : real;
  F : text;
  LiedDatei : RowString;

  procedure Set_Lied;
  begin
    nosound;
    FreQuote := exp(ln(2)/12);
    chdir('C:\PROGRAM\PASPRO\LIED')
  end;

  procedure Head_Lied;
  begin
   textmode(font8x8+c80);
    writeln;
    writeln('LIED   version 1.0    P.D.    (C) 1994    Wilhelm Chao');
    writeln
  end;

  procedure Help_Lied;
  begin
    writeln;
    writeln('LIED [-{l|s|n|p|r}] [/O|/o] [/#|/b] [/T|/t] [/1..9] [Dateiname]');
    writeln;
    writeln('':9,'O : + fr alle     o : - fr alle');
    writeln('':9,'# : # fr alle     b : b fr alle');
    writeln('':9,'T : langsamer      t : schneller');
    writeln('':9,'1..9 Taktzahl pro Absatz  (default=4)');
    writeln
  end;

  procedure Kommando(Note:NoteString);
  var
    C : char;
    I : integer;
  begin
    case Note[2] of
      'T' : TaktDauer := round(TaktDauer * FreQuote);
      't' : TaktDauer := round(TaktDauer / FreQuote);
      'O' : for C := '1' to '7' do Frequenz[C] := Frequenz[C] + Frequenz[C];
      'o' : for C := '1' to '7' do Frequenz[C] := Frequenz[C] * 0.5;
      '#' : for C := '1' to '7' do Frequenz[C] := Frequenz[C] * FreQuote;
      'b' : for C := '1' to '7' do Frequenz[C] := Frequenz[C] / FreQuote;
      'B' : Bindebogen := true;
      'F' : Fermate := true;
 '1'..'9' : val(Note[2],TaktZahl,I)
      else Help_Lied
    end
  end;

  function DateiAuf(DateiName : RowString) : boolean;
  var
    G : text;
  begin
    assign(G,DateiName);
    {$I-}reset(G);{$I+}
    if ioresult = 0 then DateiAuf := true else
    begin
      writeln('Eine neue Datei !');
      {$I-}rewrite(G);{$I+}
      if ioresult = 0 then DateiAuf := true else
      begin
        writeln(#7,'Die Datei ist nicht zu erffnen !');
        DateiAuf := false
      end
    end
  end;

  procedure Waehlen_Lied;
  var
    DosInfo : searchrec;
    LiedFile : RowString;
  begin
    findfirst('*.LID',archive,DosInfo);
    while doserror = 0 do
    begin
      write(DosInfo.Name:16);
      findnext(DosInfo)
    end;
    writeln;
    repeat
      writeln;
      write('Geben Sie bitte den Dateinamen ein : ');
      readln(LiedFile);
      if LiedFile = '' then halt;
    until DateiAuf(LiedFile);
    if LiedDatei <> '' then close(F);
    LiedDatei := LiedFile;
    assign(F,LiedDatei);
    reset(F)
  end;

  procedure Para_Lied;
  var
    I : byte;
    Parameter : RowString;
  begin
    LiedDatei := '';
    for I := 1 to paramcount do
    begin
      Parameter := paramstr(I);
      case Parameter[1] of
        '/' : Kommando(Parameter);
        '-' : PreKey := Parameter[2]
        else LiedDatei := Parameter
      end
    end;
    if (LiedDatei = '') or not DateiAuf(LiedDatei)
      then Waehlen_Lied else assign(F,LiedDatei)
  end;

  procedure Key_Lied;
  begin
    writeln;
    writeln('[L]ist    [S]ingen    [N]otation    [P]rint    [R]ewrite');
    writeln('      [H]ilfe     [W]hlen      [/]ndern  [Esc]');
    writeln;
    write('Was wollen Sie mit ',LiedDatei,' machen ? ');
    if PreKey = #0 then
    begin
      repeat until keypressed;
      FuncKey := upcase(readkey)
    end else
    begin
      FuncKey := upcase(PreKey);
      PreKey := #0
    end;
    writeln(FuncKey);
    writeln
  end;

  procedure NoteAnalyse(Note:NoteString;var Fre:integer;var Dauer:integer);
  var
    FreReal, DauerReal : real;
    Stern, I : integer;
  begin
    Stern := pos('*',Note);
    FreReal := Ruhe;
    for I := pred(Stern) downto 1 do
    case Note[I] of
      '1'..'7' : FreReal := Frequenz[Note[I]];
      '#' : FreReal := FreReal * FreQuote;
      'b' : FreReal := FreReal / FreQuote;
      '+' : FreReal := FreReal + FreReal;
      '-' : FreReal := FreReal * 0.5
    end;
    Fre := round(FreReal);
    val(copy(Note,succ(Stern),length(Note)-Stern),DauerReal,I);
    if I = 0 then Dauer := round(DauerReal*TaktDauer) else Dauer := 0
  end;

  procedure Singen_Lied;
  var
    NoteZeile : RowString;
    Leer : byte;
    Note : NoteString;
    NoteFre, NoteDauer : integer;
    Brechen : boolean;
  begin
    reset(F);
    Brechen := false;
    while not eof(F) and not Brechen do
    begin
      readln(F,NoteZeile);
      repeat
        Leer := pos(' ',NoteZeile);
        if Leer = 0 then Leer := succ(length(NoteZeile));
        Note := copy(NoteZeile,1,pred(Leer));
        if (Note[1] = '/') and (length(Note) = 2) then
        begin
          Kommando(Note);
          if Fermate then
          begin
            delay(TaktDauer * pred(TaktZahl));
            sound(Ruhe);
            delay(TaktDauer);
            Fermate := false
          end
        end else
        begin
          NoteAnalyse(Note,NoteFre,NoteDauer);
          if NoteDauer = 0 then write(Note,' ') else
          begin
            if not Bindebogen then sound(Ruhe) else Bindebogen := false;
            delay(TaktDauer shr 3);
            sound(NoteFre);
            delay(NoteDauer - TaktDauer shr 3)
          end
        end;
        delete(NoteZeile,1,Leer);
        if keypressed then
        begin
          Note := readkey;
          NoteZeile := '';
          Brechen := true
        end
      until length(NoteZeile) = 0;
      writeln
    end;
    nosound
  end;

  procedure Notation_Lied;
  var
    NoteZeile : RowString;
    NotaZeile : array[-2..1] of RowString;
    Sitz : byte;
    Leer, Stern : byte;
    Note : NoteString;
    Dauer, I : integer;
    Absatz, Gesetzt : boolean;
    DauerReal : real;
    O : text;

  procedure ResetNota;
  var
    I : integer;
  begin
    writeln;
    Absatz := false;
    fillchar(NotaZeile,sizeof(NotaZeile),' ');
    for I := -2 to 1 do NotaZeile[I][0] := #79;
    Sitz := 3;
  end;

  begin
    if FuncKey = 'P' then
    begin
      assign(O,'PRN');
      rewrite(O);
      writeln(O,#28#69#1#28#86#1#27#65#6)
    end else
    begin
      assign(O,'CON');
      rewrite(O)
    end;
    reset(F);
    readln(F,NoteZeile);
    writeln(O,NoteZeile);
    ResetNota;
    while not eof(F) do
    begin
      readln(F,NoteZeile);
      if (NoteZeile = '') and Absatz then
      begin
        for I := -1 to 1 do NotaZeile[I][1] := '';
        for I := -2 to 1 do writeln(O,NotaZeile[I]);
        ResetNota
      end
      else
      repeat
        Leer := pos(' ',NoteZeile);
        if Leer = 0 then Leer := succ(length(NoteZeile));
        Note := copy(NoteZeile,1,pred(Leer));
        Stern := pos('*',Note);
        if (Note[1] = '/') and (length(Note) = 2) then
        case Note[2] of
          'B' : begin
                  NotaZeile[-2][Sitz-2] := '';
                  NotaZeile[-2][Sitz-1] := ''
                end;
          'F' : NotaZeile[-2][Sitz-3] := '^'
        end else
        if Stern > 0 then
        begin
          Absatz := true;
          for I := pred(Stern) downto 1 do
          case Note[I] of
            '0'..'7' : NotaZeile[0][Sitz] := Note[I];
            '#','b'  : NotaZeile[-1][Sitz-1] := Note[I];
            '+' : if NotaZeile[-1][Sitz] = '' then NotaZeile[-1][Sitz] := ':'
                                               else NotaZeile[-1][Sitz] := '';
            '-' : if NotaZeile[0][Sitz] = '' then NotaZeile[0][Sitz] := ':' else
                  begin
                    NotaZeile[-1][Sitz] := NotaZeile[0][Sitz];
                    NotaZeile[0][Sitz] := ''
                  end
          end;
          val(copy(Note,succ(Stern),length(Note)-Stern),DauerReal,I);
          if I = 0 then Dauer := round(DauerReal*4) else Dauer := 0;
          Gesetzt := false;
          if Dauer div 4 > 0 then
          begin
            for I := 2 to Dauer div 4 do
            begin
              inc(Sitz);
              NotaZeile[0][Sitz] := '-'
            end;
            Gesetzt := true;
            Dauer := Dauer mod 4
          end;
          if Dauer div 2 = 1 then
          begin
            if Gesetzt then
            begin
              inc(Sitz);
              NotaZeile[0][Sitz] := '-'
            end;
            NotaZeile[1][Sitz] := '';
            Gesetzt := true;
            Dauer := Dauer mod 2
          end;
          if Dauer = 1 then
          begin
            if Gesetzt then
            begin
              inc(Sitz);
              NotaZeile[0][Sitz] := '-'
            end;
            NotaZeile[1][Sitz] := ''
          end;
          inc(Sitz,3)
        end;
        delete(NoteZeile,1,Leer);
      until length(NoteZeile) = 0;
      if Absatz then
      begin
        dec(Sitz);
        for I := -1 to 1 do NotaZeile[I][Sitz] := '';
        if Sitz < 78 then inc(Sitz,2)
      end
    end;
    if FuncKey = 'P' then writeln(O,#28#69#0#28#86#0);
    close(O)
  end;

  procedure List_Lied;
  var
    NoteZeile : RowString;
  begin
    reset(F);
    while not eof(F) do
    begin
      readln(F,NoteZeile);
      writeln(NoteZeile)
    end
  end;

  procedure Rewrite_Lied;
  var
    Fertig : boolean;
    NoteZeile : RowString;
  begin
    writeln('(Formel : Name1*Takt1 Name2*Takt2 ..... )');
    writeln('(  Z.B. : b--7*.25 #1*.5 3*1 +4*1.5 0*2 )');
    writeln('(  Z.B. : -6*.75 /B -7*.25 1*1 -6*2 /F )');
    writeln('                  B : Bindebogen     F : Fermate');
    writeln('(mit * am Anfang der letzten Zeile !)');
    writeln(' Geben Sie bitte die Noten ein :');
    writeln;
    rewrite(F);
    repeat
      readln(NoteZeile);
      Fertig := NoteZeile[1] = '*';
      if not Fertig then writeln(F,NoteZeile);
    until Fertig
  end;

  procedure Aendern_Lied;
  begin
    writeln('Oktave 6 #b   Taktdauer   Bindebogen   Fermate');
    writeln(Frequenz['6']:9:3,Taktdauer:12,ord(Bindebogen):13,ord(Fermate):10);
    writeln;
    write('Geben Sie direkt den Faktor ein : ');
    repeat until keypressed;
    FuncKey := readkey;
    writeln(FuncKey);
    Kommando('/'+FuncKey)
  end;

  procedure Quit_Lied;
  begin
    reset(F);
    textmode(c80);
    chdir('C:\PROGRAM\PASPRO');
    close(F)
  end;

begin
  Set_Lied;
  Head_Lied;
  Para_Lied;
  repeat
    Key_Lied;
    case FuncKey of
      'H' : Help_Lied;
      'W' : Waehlen_Lied;
      'S' : Singen_Lied;
      'N','P' : Notation_Lied;
      'L' : List_Lied;
      'R' : Rewrite_Lied;
      '/' : Aendern_Lied;
      #27 : Quit_Lied
    end
  until FuncKey = #27
end.
