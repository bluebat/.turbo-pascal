unit SinoFont;

interface

uses dos,graph;
procedure Get_Font(High,Low,X,Y,Color : integer;F : char);
function ETLoad : boolean;

implementation

procedure Get_Font(High,Low,X,Y,Color : integer;F : char);
var
  Data : file of byte;
  Font_File : string;
  Font : byte;
  Pixs : array[0..575] of boolean;
  I, J, Ii : integer;
  Number1, Number2, Big5 : longint;
begin
  if High >= 164 then
  begin
    Number1 := 157 * (High - 164);
    Font_File := 'STDFONT.24';
    if upcase(F) in ['K','L'] then Font_File := Font_File + F
  end else
  begin
    Number1 := 157 * (High - 161);
    Font_File := 'SPCFONT.24'
  end;

  if Low < 127 then Number2 := Low - 64 else Number2 := Low - 98;
  Big5 := Number1 + Number2;
  assign(Data,Font_File);
  Reset(Data);
  Big5 := Big5 * 72;
  seek(Data,Big5);
  for I := 0 to 71 do
  begin
    read(Data,Font);
    Ii := I shl 3;
    for J := 7 downto 0 do
    begin
      Pixs[Ii + J] := odd(Font);
      Font := Font shr 1
    end
  end;
  close(Data);
  for I := 0 to 23 do for J := 0 to 23 do
    if Pixs[I * 24 + J] then putpixel(X + J,Y + I,Color);
end;

function ETLoad : boolean;
var
  Regs : registers;
begin
  Regs.ax := $9100;
  intr($10,Regs);
  ETLoad := Regs.ax <> $9100
end;

end.