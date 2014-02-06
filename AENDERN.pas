program Aendern;
type
  AtomPtr = ^Atom;
  Atom = record
           Zeichen : string[7];
           Link, Recht : AtomPtr
         end;
var
  Wurzel : AtomPtr;
  GanzSatz : string;
  Erfolg, Abschluss : boolean;

procedure Eingeben;
var
  Laenge : byte;
begin
  new(Wurzel);
  if not Erfolg then writeln(' ':20,'Please use the correct form !');
  Erfolg := true;
  writeln;
  write('':10,'INORDER : ');
  readln(GanzSatz);
  Laenge := length(GanzSatz);
  Abschluss := Laenge = 0;
  while Laenge > 0 do
  begin
    if GanzSatz[Laenge] = ' ' then delete(GanzSatz,Laenge,1);
    dec(Laenge)
  end
end;

procedure BaumBauen(Satz : string;Knoten : AtomPtr);
type
  TypVonSatz = (Falsch, Einfach, Schwer);
var
  Laenge, Punkt : byte;
  RechtsSatz, LinksSatz : string;
  SatzTyp : TypVonSatz;

  procedure SuchenPunkt;
  type
    TypVonZeichen = (Keine, Sex, Nummer, Funker);
  var
    Wortslage, Lage : byte;
    ZeichenTyp : TypVonZeichen;
    Haben : boolean;

    function Klammern(Lage : byte) : byte;
    var
      Gesucht : boolean;
    begin
      Gesucht := false;
      repeat
        inc(Lage);
        case Satz[Lage] of
          ')' : Gesucht := true;
          '(' : Lage := Klammern(Lage)
        end
      until Gesucht or (Lage = Laenge);
      Klammern := Lage;
      if not Gesucht then SatzTyp := Falsch
    end;

  begin
    ZeichenTyp := Keine;
    Punkt := 0;
    Haben := false;
    Laenge := length(Satz);
    SatzTyp := Einfach;
    Lage := 0;
    Wortslage := 1;
    while (SatzTyp = Einfach) and (Wortslage <= Laenge) do
    begin
      case Satz[Wortslage] of
        '(' : begin
                Lage := Klammern(Wortslage);
                if (Lage = Laenge) and (Wortslage = 1) then
                begin
                  delete(Satz,Laenge,1);
                  delete(Satz,1,1);
                  dec(Laenge,2);
                  Wortslage := 0
                end else
                begin
                  Wortslage := Lage;
                  ZeichenTyp := Nummer
                end
              end;
        '0'..'9' : ZeichenTyp := Nummer;
        '+','-' : case ZeichenTyp of
                    Nummer : begin
                               ZeichenTyp := Funker;
                               Punkt := Wortslage;
                               Haben := true
                             end;
                    Keine  : ZeichenTyp := Sex
                    else SatzTyp := Falsch
                  end;
        '*','/' : if ZeichenTyp = Nummer then
                  begin
                    ZeichenTyp := Funker;
                    if not Haben then Punkt := Wortslage
                  end
                  else SatzTyp := Falsch
        else SatzTyp := Falsch
      end;
      inc(Wortslage)
    end;
    if ZeichenTyp <> Nummer then SatzTyp := Falsch;
    if (SatzTyp = Einfach) and (Punkt > 0) then SatzTyp := Schwer
  end;

  procedure Trennen;
  begin
    Knoten^.Zeichen := Satz[Punkt];
    new(Knoten^.Link);
    new(Knoten^.Recht);
    LinksSatz := copy(Satz,1,Punkt - 1);
    RechtsSatz := copy(Satz,Punkt + 1,Laenge - Punkt)
  end;

begin
  SuchenPunkt;
  case SatzTyp of
    Einfach : begin
                Knoten^.Zeichen := Satz;
                Knoten^.Link := nil;
                Knoten^.Recht := nil
              end;
    Schwer : begin
               Trennen;
               BaumBauen(LinksSatz,Knoten^.Link);
               BaumBauen(RechtsSatz,Knoten^.Recht)
             end;
    Falsch : Erfolg := false
  end
end;

procedure Ausgeben;

  procedure PreAusgeben(Knoten : AtomPtr);
  begin
    if Knoten <> nil then
    begin
      write(Knoten^.Zeichen,' ');
      PreAusgeben(Knoten^.Link);
      PreAusgeben(Knoten^.Recht)
    end
  end;

  procedure PostAusgeben(Knoten : AtomPtr);
  begin
    if Knoten <> nil then
    begin
      PostAusgeben(Knoten^.Link);
      PostAusgeben(Knoten^.Recht);
      write(Knoten^.Zeichen,' ')
    end
  end;

begin
  write(' ':9,'PREORDER : ');
  PreAusgeben(Wurzel);
  writeln;
  write(' ':8,'POSTORDER : ');
  PostAusgeben(Wurzel);
  writeln;
  dispose(Wurzel)
end;


begin
  repeat
    repeat
      Eingeben;
      BaumBauen(GanzSatz,Wurzel);
    until Erfolg or Abschluss;
    if not Abschluss then Ausgeben
  until Abschluss
end.


