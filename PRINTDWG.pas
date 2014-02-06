program printdwg;  uses printer;

{ This Turbo Pascal 4.0 program dumps the rotated contents of a Hercules-    }
{ compatible monochrome graphics screen to a dot-matrix printer at 120 dots  }
{ per inch.  It is adapted from a procedure "HardCopy" contributed to        }
{ Compuserve by Antonio Rivera.                                              }

   const
esc = #27;              {escape char}
LF = #10;               {line feed}
FF = #12;               {form feed}
null = #0;
xmax = 719; ymax = 347; {max pixel coords}
mult = 2;               {no. of print dots per pixel}
margin = 65;            {left margin setting}
bits: array [0..7] of byte = (128, 64, 32, 16, 8, 4, 2, 1);
page0base = $B000;      {start of graphics screen RAM}

   var
pbyte: byte;            {byte to be sent to printer}
numdots: integer;       {dots per row}
low, high: char;        {constituent bytes of numdots}
row, col, i: integer;   {loop counters}
co: integer;

begin
write (lst, LF);  {top margin}
write (lst, esc, 'A', #8);  {set 8/72" LF}
numdots := (ymax + 1 + margin) * mult;
low := chr(lo(numdots)); high := chr(hi(numdots));
for col := 0 to (xmax + 1) div 8 - 1 do
   begin
   write (lst, esc, 'L', low, high);  {set 120 dpi}
   for i := 1 to margin * mult do
      write (lst, null);  {left margin}
   for row := ymax downto 0 do
      {build and send the next pbyte}
      begin
      pbyte := 0; co := col shl 3;
      for i := 0 to 7 do
         if (mem[page0base:(row and 3) shl 13 + 90*(row shr 2) +
              ((co+i) shr 3)] and (128 shr ((co+i) and 7))) <> 0 then
            pbyte := pbyte or bits[i];
      for i := 1 to mult do
         write (lst, chr(pbyte))
      end;
   writeln (lst)
   end;
write (lst, esc, 'A', #12);  {set 12/72" LF}
write (lst, FF)  {eject page}
end .
