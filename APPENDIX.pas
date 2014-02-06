program Appendix;
uses crt, dos;
const Fchar : array[1..11] of byte
	    = ($A1,$A2,$A3,$C6,$C8,$F9,$FA,$FB,$FC,$FD,$FE);
var
  F, K : char;
  I, J : byte;
  A, B, C, D : word;
  Regs : registers;
begin
  clrscr;
  repeat
    window(1,1,80,25);
    textbackground(0);
    textcolor(7);
    write('(Esc-Exit  1-KeyValue  2-Color  3-ASCII  4-Intr  5-BIG5) : ');
    F := readkey;
    write(F);
    window(1,2,80,25);
    clrscr;
    I := 0;
    case F of
      '1' : repeat
	      gotoxy(I mod 5*16+1,wherey);
	      repeat until keypressed;
	      K := readkey;
	      if K = chr(0) then
	      begin
		K := readkey;
		write('0 and ')
	      end;
	      J := wherex;
	      write(K);
	      gotoxy(J+2,wherey);
	      write(ord(K));
	      inc(I);
	      if I mod 5 = 0 then writeln
	    until K = #27;
      '2' : for I := 0 to 15 do for J := 0 to 7 do
	    begin
	      window(I*5+1,J*3+2,I*5+5,J*3+4);
	      textbackground(J);
	      textcolor(I);
	      clrscr;
	      writeln;
	      write('B',J,'C',I)
	    end;
      '3' : for I := 0 to 255 do
	    begin
	      gotoxy(I mod 12*6+1,I div 12+2);
	      write(chr(I),#32);
	      gotoxy(I mod 12*6+3,I div 12+2);
	      write(I)
	    end;
      '4' : repeat
	      write('INTR AX BX CX DX = ');
	      readln(I,A,B,C,D);
	      J := wherey;
	      if I > 0 then
	      begin
		Regs.ax := A;
		Regs.bx := B;
		Regs.cx := C;
		Regs.dx := D;
		intr(I,Regs);
		gotoxy(6,J);
		with Regs do
		  writeln('AH=',ah,' AL=',al,' BH=',bh,' BL=',bl,' CH=',ch,' CL=',cl,' DH=',dh,' DL=',dl)
	      end
	    until I = 0;
      '5' : begin
	      window(1,2,80,25);
	      for I := 1 to 11 do
	      begin
		B := Fchar[I];
		writeln(B,' *256 + (4..7 or $A..$F) * 16 + ');
		for J := 0 to 15 do
		begin
		  gotoxy(J*4+10,wherey);
		  write(J)
		end;
		writeln;
                for C := 4 to 7 do for D := 0 to 15 do
		begin
		  gotoxy(D*4+10,wherey);
		  write(chr(B),chr(C*16+D));
		  if D = 15 then writeln
		end;
		for C := $A to $F do for D := 0 to 15 do
		begin
		  gotoxy(D*4+10,wherey);
		  write(chr(B),chr(C*16+D));
		  if (D = 15) and (odd(I) or (C < $F)) then writeln
		end;
		if not odd(I) then
		begin
		  K := readkey;
		  clrscr
		end
	      end;
            end;
    end
  until F = #27
end.