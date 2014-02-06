program MDBset;
uses crt, graph, Hercules;
var
  H0,H1,H2,I,J,K,L,H,Col,Ps : integer;
  Acent,Bcent,Wid,Ascale,Bscale,Amin,Bmax,A,B,X,Y,Xnew : real;
  Overflow : boolean;
begin
  write('a-center  b-center  width : ');
  readln(Acent,Bcent,Wid);
  write('color cutoff points(h0=10 <h1=20 <h2=60)');
  readln(H0,H1,H2);
  write('pox-size(1,2,4,5 or 8)');
  readln(Ps);
  Ascale := Ps * Wid / 719;
  Bscale := 1.18 * Ascale;
  Amin := Acent - 719 / 2*Ascale / Ps;
  Bmax := Bcent + 348 / 2*Bscale / Ps;

  Set_Herc;
    for I := 0 to MaxX div Ps-1 do
    begin
      A := Amin + I * Ascale;
      for J := 0 to MaxY div Ps-1 do
      begin
        B := Bmax-J*bscale;
        X := 0;
        Y := 0;
        repeat
        begin
          Xnew := X*X-Y*Y+A;
          Y := 2*X*Y+B;
          X := Xnew;
          Overflow := X*X + Y*Y > MaxY;
          if Overflow then
          begin
            if H<H0 then Col := 1 else if H<H1 then Col := 0 else Col := 0;
            for K := 0 to Ps-1 do for L := 0 to Ps-1 do putpixel(I*Ps+K,J*Ps+L,Col);
            H := H2
          end;
          inc(H);
        until (H = H2) or Overflow;
      end;
    end;
    writeln('Center = ',Acent,' ',Bcent,'),Width = ',Wid);
    writeln('H = (',H0:3,H1:3,H2:3,')');
    repeat until keypressed;
  closeGraph
end.


