UNIT PlayIt;
(*****************************************************)
(* Copyright (c) 1988 by Neil J. Rubenking           *)
(* Demonstrates how to play a PIANOMAN MUZ file from *)
(* Turbo Pascal version 4.0.  You may freely include *)
(* and distribute this Unit in your programs.        *)
(*                                                   *)
(* To use the Unit, first create a MUZ file using    *)
(* PIANOMAN.  Then call on the BINOBJ utility that   *)
(* comes with TP4 to turn the MUZ file into an OBJ   *)
(* file.  Finally, declare a TP4 Procedure as an     *)
(* EXTERNAL using that OBJ file.  Now you can call   *)
(* the Procedure PlayOBJ in this Unit.               *)
(*                                                   *)
(* See PLAYDEMO.PAS for demonstration.               *)
(*****************************************************)

(**********************)
(**)   INTERFACE    (**)
(**********************)
Uses CRT;
PROCEDURE PlayOBJ(
         P : Pointer; {Pointer to "fake External" procedure containing tune}
   KeyStop : Boolean; {If true, tune will stop when key is pressed.}
    VAR CH : char);   {^Returns pressed key if stopped.}

(**********************)
(**) IMPLEMENTATION (**)
(**********************)
TYPE
  FiledNote = RECORD
                O, NS : Byte;
                D : Word;
              END;
  NotePt = ^FiledNote;
VAR
  Oct_Val : ARRAY[0..8] OF Real;
  Freq_Val : ARRAY[1..12] OF Real;

  PROCEDURE Set_Frequencies;
  VAR N : Byte;
  BEGIN
    Freq_Val[1] := 1;
    Freq_Val[2] := 1.0594630944;
    FOR N := 3 TO 12 DO
      Freq_Val[N] := Freq_Val[N - 1] * Freq_Val[2];
    Oct_Val[0] := 32.70319566;
    FOR N := 1 TO 8 DO
      Oct_Val[N] := Oct_Val[N - 1] * 2;
  END;


  PROCEDURE PlayOne(Octave, NoteStaccato : Byte; Duration : Integer);
  CONST
    factor : ARRAY[0..10] OF Real = (0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0);
  VAR
    Frequency : Real;
    Note, Staccato : Byte;   (*!*)
  BEGIN
    Note := NoteStaccato SHR 4;
    Staccato := NoteStaccato AND $F;
    IF Staccato > 10 THEN Staccato := 10;
    IF Staccato < 0 THEN Staccato := 0;
    IF Octave > 8 THEN Octave := 8;
    IF Octave < 1 THEN Octave := 1;
    CASE Note OF
      1..12 : BEGIN
                Frequency := Oct_Val[Octave] * Freq_Val[Note];
                Sound(Round(Frequency));
                Delay(Round(Duration * factor[10 - Staccato]));
                IF Duration > 0 THEN NoSound;
                Delay(Round(Duration * factor[Staccato]));
              END;
      13 : BEGIN NoSound; Delay(Duration); END;
    END;                     {case}
  END;

  PROCEDURE PlayOBJ(P : Pointer; KeyStop : Boolean; VAR CH : char);
  VAR T : NotePt;
    N, Num : Word;
  BEGIN
    T := NotePt(P);
    Inc(LongInt(T), SizeOf(FiledNote) * 5);
    Num := LongInt(T^) AND $FFFF;
    Inc(LongInt(T), SizeOf(FiledNote) * 4);
    FOR N := 1 TO Num DO
      BEGIN
        WITH T^ DO
          PlayOne(O, NS, D);
        Inc(LongInt(T), SizeOf(FiledNote));
        IF KeyStop AND KeyPressed THEN
          BEGIN
            CH := ReadKey;
            Exit;
          END;
      END;
  END;

(**********************)
(*   INITIALIZATION   *)
(**********************)
BEGIN
  Set_Frequencies;
END.
