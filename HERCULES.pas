unit Hercules;

interface

uses dos, graph, printer;
var MaxX, MaxY : integer;
procedure Set_Herc;
procedure HardCopy;

implementation

procedure Set_Herc;
var GraphDriver, GraphMode, ErrorCode : integer;
    PathToBGI : string;
begin
  GraphDriver := hercMono;
  GraphMode := hercMonoHi;
  PathToBGI := '';
  repeat
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
  until ErrorCode = grOk;
  MaxX := getMaxX;
  MaxY := getMaxY;
  clearDevice
end;

procedure HardCopy;
type
  ScanPage = record
               PinByte : array[0..86,0..29,0..2] of char;
               Unused : array[0..361] of char
             end;
var
  Scan : array[0..3] of ScanPage absolute $B000:$0000;
  L, C, P, B : integer;
begin
  write(lst,#27#51#24);
  for C := 0 to 29 do
  begin
    write(lst,#27#42#38#92#1);
    for L := 86 downto 0 do for P := 3 downto 0 do for B := 0 to 2 do
      write(lst,Scan[P].PinByte[L,C,B]);
    writeln(lst)
  end
end;

END.


