unit Intrs;
interface

procedure Beep(F:word);
function PrinterOK:boolean;
procedure Cursor(Onff : boolean);
function ETLoad:boolean;
function ChineseMode : boolean;
procedure ReleaseET;
procedure ShowET;
function MouseInstalled : boolean;
procedure Mouse(Onff:boolean);
procedure GotoMouse(X,Y:integer);
function MousePressing:boolean;
function MousePressed:boolean;
procedure MouseMaxY(Y:byte);
procedure MouseSpeed(X,Y:byte);
procedure MouseColor(BackM,ColorM:word);
function MouseX:byte;
function MouseY:byte;
procedure TextModeVGAplus;
procedure Wwindow(X1,Y1,X2,Y2:byte);

implementation
uses dos,crt;
var Regs : registers;

procedure Beep(F : word);
const Onff : boolean = true;
begin
  if F = 0 then Onff := false;
  if Onff then
  begin
    sound(F);
    delay(32);
    nosound
  end
end;

function PrinterOK:boolean;
begin
  regs.ah := $02;
  regs.dx := 0;
  intr($17,regs);
  PrinterOK := regs.ah and 41 = 0
end;

function ETLoad : boolean;
begin
  Regs.ax := $9100;
  intr($10,Regs);
  ETLoad := Regs.ax <> $9100
end;

procedure Cursor(Onff : boolean);
begin
  Regs.ah := $01;
  if Onff then Regs.cx := $0708 else Regs.cx := $2000;
  intr($10,Regs)
end;

procedure ReleaseET;
begin
  Regs.ah := $80;
  Regs.al := $51;
  intr($10,Regs)
end;

procedure ShowET;
begin
  Regs.ah := $80;
  Regs.al := $41;
  intr($10,Regs);
  Regs.ah := $80;
  Regs.al := $61;
  intr($10,Regs)
end;

function ChineseMode : boolean;
begin
  Regs.ax := $9100;
  intr($10,Regs);
  ChineseMode := (Regs.ax <> $9100) and not odd(Regs.dx shr 15)
end;

function MouseInstalled : boolean;
begin
  Regs.ax := 0;
  intr($33,Regs);
  if Regs.ax = 65535 then MouseInstalled := true else MouseInstalled := false
end;

procedure Mouse(Onff:boolean);
begin
  if Onff then Regs.ax := $0001 else Regs.ax := $0002;
  intr($33,Regs)
end;

procedure MouseMaxY(Y:byte);
begin
  Regs.ax := 8;
  Regs.cx := 0;
  Regs.dx := Y*8-1;
  intr($33,Regs)
end;

procedure MouseSpeed(X,Y:byte);
begin
  Regs.ax := $F;
  Regs.cx := X;
  Regs.dx := Y;
  intr($33,Regs)
end;

procedure MouseColor(BackM,ColorM:word);
begin
  Regs.ax := $A;
  Regs.bx := 0;
  Regs.cx := BackM;
  Regs.dx := ColorM;
  intr($33,Regs)
end;

procedure GotoMouse(X,Y:integer);
begin
  Regs.ax := 4;
  Regs.cx := X*8;
  Regs.dx := Y*8;
  intr($33,Regs)
end;

function MousePressing:boolean;
begin
  Regs.ax := 3;
  Regs.bx := 0;
  intr($33,Regs);
  MousePressing := Regs.bx > 0
end;

function MousePressed:boolean;
var I : byte;
begin
  MousePressed := false;
  for I := 0 to 2 do
  begin
    Regs.ax := 5;
    Regs.bx := I;
    intr($33,Regs);
    if Regs.bx > 0 then MousePressed := true
  end
end;

function MouseX:byte;
begin
  Regs.ax := 3;
  Regs.cx := 0;
  intr($33,Regs);
  MouseX := Regs.cx div 8
end;

function MouseY:byte;
begin
  Regs.ax := 3;
  Regs.dx := 0;
  intr($33,Regs);
  MouseY := Regs.dx div 8
end;

procedure TextModeVGAplus;
begin
  Regs.ah := 0;
  Regs.al := $26;
  intr($10,Regs)
end;

procedure Wwindow(X1,Y1,X2,Y2:byte);
begin
  windmin := (X1-1) + (Y1-1) * 256;
  windmax := (X2-1) + (Y2-1) * 256;
  gotoxy(1,1);
end;

end.
