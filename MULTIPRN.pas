program	MultiPrn;
uses printer;
const
  ReservedCount	= 48;
  ReservedWord : array[0..ReservedCount	- 1] of	string[14]
		   = ('absolute','and','array','begin','case','const','div',
		      'do','downto','else','end','external','file','for',
		      'foward','function','goto','if','implementation','in',
		      'inline','interface','interrupt','label','mod','nil',
		      'not','of','or','packed','procedure','program','record',
		      'repeat','set','shl','shr','string','then','to','type',
		      'unit','until','uses','var','while','with','xor');
  InitFont = #27#53#27#116#1#27#50;
  ResetFont = #27#120#1#27#112#0#27#107#3;
var
  F : text;
  Ch : char;

procedure Initiate;
begin
  writeln('This program will print a Pascal file in multi-font.');
  if paramCount	= 0 then
  begin
    writeln;
    writeln('You must type : C\>MULTIPRN filename [ subhead ]');
    halt
  end;
  assign(F,paramstr(1));
  reset(F)
end;

procedure Title;
begin
  writeln(lst,InitFont);
  write(lst,#27#119#1,#27#87#1,' ':10,paramstr(1),#27#87#0,#27#119#0);
  writeln(lst,' ':10,paramstr(2));
  writeln(lst)
end;

procedure Printing;
type
  TypeList = (Reserved,Routine,Identifier,Separator,Characters,Comment);
const
  TypeFont : array[TypeList] of	string[6]
	   = (#27#107#6,#27#120#0,#27#112#1#27#107#4,#27#107#3,
	      #27#107#3,#27#112#1#27#107#4);
  TokenType : TypeList = Separator;
  Token	: string[63] = '';
procedure PrintToken(ThenType :	TypeList);

function IsReserved : boolean;
var I :	integer;
begin
  I := 0;
  while	(Token <> ReservedWord[I]) and (I < ReservedCount) do inc(I);
  IsReserved :=	I < ReservedCount
end;

begin
  if (TokenType	= Routine) and IsReserved then TokenType := Reserved;
  write(lst,TypeFont[Tokentype],Token,ResetFont);
  Token	:= '';
  TokenType := ThenType
end;

begin
  while	not eof(F) do
  begin
    read(F,Ch);
    case Ch of
      'a'..'z' : if TokenType =	Separator then PrintToken(Routine);
      'A'..'Z' : if TokenType =	Separator then PrintToken(Identifier);
      '0'..'9','#','$','^','_' :
	    if TokenType = Separator then PrintToken(Routine);
      '.' : if TokenType in [Routine,Identifier] then PrintToken(Separator);
      #39 : if TokenType = Characters then
	    begin
	      Token := Token + Ch;
	      Ch := #0;
	      PrintToken(Separator)
	    end
	    else if TokenType <> Comment then PrintToken(Characters);
      '{' : if TokenType <> Characters then PrintToken(Comment);
      '}' : if TokenType <> Characters then
	    begin
	      Token := Token + Ch;
	      Ch := #0;
	      PrintToken(Separator)
	    end;
    else
      if TokenType in [Routine,Identifier] then	PrintToken(Separator);
    end;
    Token := Token + Ch;
    if eoln(F) or eof(F) then
    begin
      PrintToken(Separator);
      readln(F);
      writeln(lst)
    end
  end
end;

procedure CloseFile;
begin
  writeln(lst,InitFont);
  close(F)
end;


begin
  Initiate;
  Title;
  Printing;
  Closefile
end.




