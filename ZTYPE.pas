unit Ztype;

interface
type Complex = record
                 RePart,ImPart :real
               end;
     Complexp = ^Complex;

function Zabs(Z:Complex):real;
function Arg(Z:Complex):real;
function Hsin(Angle:real):real;
function Hcos(Angle:real):real;
function Zadd(Z1,Z2:Complex):Complexp;
function Zsub(Z1,Z2:Complex):Complexp;
function Zmulti(Z1,Z2:Complex):Complexp;
function Zdiv(Z1,Z2:Complex):Complexp;
function Zsin(Z:Complex):Complexp;
function Zcos(Z:Complex):Complexp;
function Zpower(Z:Complex;Power:real):Complexp;
function Zexp(Z:Complex):Complexp;
function Zln(Z:Complex):Complexp;
function ZpowerZ(Z,PowerZ:Complex):Complexp;

implementation

var Zptr : Complexp;

function Zabs(Z:Complex):real;
begin
  Zabs := sqrt(sqr(Z.RePart) + sqr(Z.ImPart))
end;

function Arg(Z:Complex):real;
begin
  if Z.RePart = 0 then Arg := pi / 2 + pi * ord(Z.ImPart < 0)
    else Arg := arctan(Z.ImPart / Z.RePart) + pi * ord(Z.RePart < 0)
end;

function Hsin(Angle:real):real;
var Ex:real;
begin
  Ex := exp(Angle);
  Hsin := (Ex - 1 / Ex) / 2
end;

function Hcos(Angle:real):real;
var Ex:real;
begin
  Ex := exp(Angle);
  Hcos := (Ex + 1 / Ex) / 2
end;

function Zadd(Z1,Z2:Complex):Complexp;
begin
  Zptr^.RePart := Z1.RePart + Z2.RePart;
  Zptr^.ImPart := Z1.ImPart + Z2.ImPart;
  Zadd := Zptr
end;

function Zsub(Z1,Z2:Complex):Complexp;
begin
  Zptr^.RePart := Z1.RePart - Z2.RePart;
  Zptr^.ImPart := Z1.ImPart - Z2.ImPart;
  Zsub := Zptr
end;

function Zmulti(Z1,Z2:Complex):Complexp;
begin
  Zptr^.RePart := Z1.RePart * Z2.RePart - Z1.ImPart * Z2.ImPart;
  Zptr^.ImPart := Z1.RePart * Z2.ImPart + Z1.ImPart * Z2.Repart;
  Zmulti := Zptr
end;

function Zdiv(Z1,Z2:Complex):Complexp;
var Base:real;
begin
  Base := sqr(Z2.RePart) + sqr(Z2.ImPart);
  Zptr^.RePart := (Z1.RePart * Z2.RePart + Z1.ImPart * Z2.ImPart)/Base;
  Zptr^.ImPart := (Z1.ImPart * Z2.RePart - Z1.RePart * Z2.ImPart)/Base;
  Zdiv := Zptr
end;

function Zsin(Z:complex):Complexp;
begin
  Zptr^.RePart := sin(Z.RePart) * Hcos(Z.ImPart);
  Zptr^.RePart := Hsin(Z.ImPart) * cos(Z.RePart);
  Zsin := Zptr
end;

function Zcos(Z:Complex):Complexp;
begin
  Zptr^.RePart := cos(Z.RePart) * Hcos(Z.ImPart);
  Zptr^.ImPart := -sin(Z.RePart) * Hsin(Z.ImPart);
  Zcos := Zptr
end;

function Zpower(Z:Complex;Power:real):Complexp;
var Value,Angle:real;
begin
  if Zabs(Z) = 0 then Value := 0 else Value := exp(Power * ln(Zabs(Z)));
  Angle := Power * Arg(Z);
  Zptr^.RePart := Value * cos(Angle);
  Zptr^.ImPart := Value * sin(Angle);
  Zpower := Zptr
end;

function Zexp(Z:Complex):Complexp;
var Rexp:real;
begin
  Rexp := exp(Z.RePart);
  Zptr^.RePart := Rexp * cos(Z.ImPart);
  Zptr^.ImPart := Rexp * sin(Z.ImPart);
  Zexp := Zptr
end;

function Zln(Z:Complex):Complexp;
begin
  if Zabs(Z) = 0 then Zptr^.RePart := 0 else Zptr^.RePart := ln(Zabs(Z));
  Zptr^.ImPart := Arg(Z);
  Zln := Zptr
end;

function ZpowerZ(Z,PowerZ:Complex):Complexp;
begin
  Zptr := Zexp(Zmulti(PowerZ,Zln(Z)^)^);
  ZpowerZ := Zptr
end;

begin
  new(Zptr)
end.

