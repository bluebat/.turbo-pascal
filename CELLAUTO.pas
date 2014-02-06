program	CellAuto;
uses crt, graph;
var
  N, I,	J, K, L	: integer;
  MaxX,	MaxY : integer;
  PreRow, NowRow : array[0..1024] of byte;

procedure Set_Graph;
var GraphDriver, GraphMode, ErrorCode :	integer;
    PathToBGI :	string;
begin
  PathToBGI := '';
  repeat
    GraphDriver	:= detect;
    initGraph(GraphDriver,GraphMode,PathToBGI);
    ErrorCode := graphResult;
    if ErrorCode <> grOK then
    begin
      writeln('Graphics error : ',graphErrorMsg(ErrorCode));
      if ErrorCode = grFileNotFound then
      begin
	writeln('Enter full path to BGI driver or type [^Break] to quit : ');
	readln(PathToBGI);
	writeln
      end
      else
	halt(1)
    end
  until	ErrorCode = grOk;
  MaxX := getMaxX;
  MaxY := getMaxY;
  clearDevice
end;

begin
  Set_Graph;
  fillchar(PreRow,Sizeof(PreRow),0);
  randomize;
  for J	:= 0 to	pred(MaxX) do PreRow[J]	:= random(16);
  while	not keypressed do
    begin
    for	N := 1 to pred(MaxY) do
    begin
      for J := 0 to pred(MaxX) do
      begin
	I := (pred(J) +	MaxX) mod MaxX;
	K := succ(J) mod MaxX;
	L := succ(K) mod MaxX;
	NowRow[J] := PreRow[I] xor PreRow[K]  ;
	putpixel(J,N,NowRow[J])
      end;
      PreRow :=	NowRow
    end
  end;
  closeGraph
end.


