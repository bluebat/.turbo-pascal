program Singen;
uses crt, dos, Intrs;
const

type

var
  FuncKey : char;

  procedure Para_ ;
  var Syntax : boolean;
      I : byte;
      Parameter : RowString;
  begin
    LoadFile := 'LEBEN.LIF';
    Syntax := true;
    for I := 1 to paramcount do
    begin
      Parameter := paramstr(I);
      if Parameter[1] <> '/' then LoadFile := Parameter else
      case upcase(Parameter[2]) of
        ' ' : ;
        else Syntax := false
      end
    end;
    assign(F,LoadFile);
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

  procedure Set_;
  begin

  end;

  procedure Head_;
  begin

  end;

  procedure Clear_;
  begin

  end;

  procedure Key_;
  begin
    FuncKey := ;
  end;

  procedure Help_;
  begin

  end;

  procedure Quit_;
  begin

  end;

begin
  Para_ ;
  Set_ ;
  Head_ ;
  Clear_ ;
  repeat
    Key_ ;
    case FuncKey of
      'H' : Help_ ;
    {  'N' : Name_ ;
      'S' : Save_ ;
  'L','X' : Load_ ;
      'E' : Explain_ ;
      'O' : Output_ ;
      'C' : Clear_ ;
'^','V','<','>':Shift_ ;
      'M' : Mirrow_ ;
      'R' : Rotate_ ;
  'G','P' : Memory_ ;
      'A' : Auto_ ;
      'D' : Delete_ ;
      #8  : Look_ ;
      #0  : Move_ ;
   #9,#13 : Grow_ ;
      #32 : Toggle_ ;  }
      #27 : Quit_
    end
  until FuncKey = #27
end.
