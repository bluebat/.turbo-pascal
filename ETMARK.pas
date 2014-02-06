program ETMark;
uses
  crt,graph;
var
  GraphDriver, GraphMode : integer;
  Mark : pointer;
begin
  if paramcount > 0 then
  begin
    GraphDriver := att400;
    GraphMode := att400Hi;
    initGraph(GraphDriver,GraphMode,'d:\turbo');
    if graphResult <> grOK then halt(1);
    directvideo := false;
    write(#27,'FKT24,580,350,4,1,S;',paramstr(1));
    getmem(Mark,imagesize(580,350,639,375));
    getimage(580,350,639,375,Mark^);
    write(#27,'T24,580,350,4,1,X;',paramstr(1),#27,'FMT16;');
    putimage(580,377,Mark^,normalput);
    closegraph
  end
  else
    write(#7,'Can not find a parameter string !!')
end.
