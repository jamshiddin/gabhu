unit sqlsupport;

{$IFDEF FPC}
{$MODE Delphi}
{$H+}
{$ELSE}
  {$IFNDEF LINUX}
  {$DEFINE WIN32}
  {$ENDIF}
{$ENDIF}

interface

uses {$IFDEF WIN32}Windows, {$ENDIF} Classes, SysUtils;
//{$IFDEF FPC}, LCLIntf{$ENDIF};

type TDBType = (dbDefault, dbMySQL, dbSQLite, dbAnsi, dbSqlite3, dbSqlite3W);


const

  DblQuote: Char    = '"';
  SngQuote: Char    = #39;
  Crlf: String      = #13#10;
  Tab: Char         = #9;

  function FloatToMySQL (Value:Extended):String;
  function DateTimeToMySQL (Value:TDateTime):String;
  function MySQLToDateTime (Value:String):TDateTime;

  function Pas2SQLiteStr(const PasString: string): string;
  function SQLite2PasStr(const SQLString: string): string;
  function AddQuote(const s: string; QuoteChar: Char = #39): string;
  function UnQuote(const s: string; QuoteChar: Char = #39): string;

  function SystemErrorMsg(ErrNo: Integer = -1): String;
  function Escape(Value: String): String;
  function UnEscape(Value: String): String;

  function QuoteEscape (Value:String; qt:TDBType):String;


implementation

//Support functions
function FloatToMySQL (Value:Extended):String;
begin
  Result := StringReplace(FloatToStr(Value), ',', '.', []);
end;

function DateTimeToMySQL (Value:TDateTime):String;
begin
  Result := FormatDateTime ('yyyymmddhhnnss', Value);
end;

function MySQLToDateTime (Value:String):TDateTime;
begin
  ///todo//// did that once before, lets look.///
end;



function Pas2SQLiteStr(const PasString: string): string;
var
  n: integer;
begin
  Result := SQLite2PasStr(PasString);
  n := Length(Result);
  while n > 0 do
  begin
    if Result[n] = SngQuote then
      Insert(SngQuote, Result, n);
    dec(n);
  end;
  Result := AddQuote(Result);
end;

function SQLite2PasStr(const SQLString: string): string;
const
  DblSngQuote: String = #39#39;
var
  p: integer;
begin
  Result := SQLString;
  p := pos(DblSngQuote, Result);
  while p > 0 do
  begin
    Delete(Result, p, 1);
    p := pos(DblSngQuote, Result);
  end;
  Result := UnQuote(Result);
end;

function SystemErrorMsg(ErrNo: Integer = -1): String;
var
  buf: PChar;
  size: Integer;
  MsgLen: Integer;
begin
  {$IFDEF WIN32}
  size := 256;
  GetMem(buf, size);
  If ErrNo = - 1 then
    ErrNo := GetLastError;
  MsgLen := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrNo, 0, buf, size, nil);
  if MsgLen = 0 then
    Result := 'ERROR'
  else
    Result := buf;
  {$ELSE}
  Result := ''; //unknown
  {$ENDIF}
end;


function AddQuote(const s: string; QuoteChar: Char = #39): string;
begin
  Result := Concat(QuoteChar, s, QuoteChar);
end;

function UnQuote(const s: string; QuoteChar: Char = #39): string;
begin
  Result := s;
  if length(Result) > 1 then
  begin
    if Result[1] = QuoteChar then
      Delete(Result, 1, 1);
    if Result[Length(Result)] = QuoteChar then
      Delete(Result, Length(Result), 1);
  end;
end;




function Escape(Value: String): String;
var i:Integer;
begin
  for i:=length (Value) downto 1 do
    if Value[i] in ['\', '''', '"', #0] then
      begin
        if Value[i]=#0 then
          Value[i]:='0';
        //optionally tabs, backspaces, nl etc:
        //if Value[i]=#9 then
        //Value[i]='t';
        //etc

        Insert ('\', Value, i);
      end;
  Result := Value;
end;

function UnEscape(Value: String): String;
var i:Integer;
begin
  for i:=1 to length(Value)-1 do
    if Value[i]='\' then
      begin
        if Value[i+1]='0' then
          Value[i+1]:=#0;
        Delete (Value,i,1);
      end;
  Result := Value;
end;

function QuoteEscape (Value:String; qt:TDBType):String;
begin
  case qt of
    dbMySQL :
      begin
        //mysql finds escaping with backslash sufficient to ignore the next quote
        Value := AddQuote(Escape (Value));
      end;
    dbSQLite :
      begin
        //escape binary chars
        Value := Escape (Value);
        //replace string quotes with double quotes - sqlite needs this apperently
        Value := StringReplace (Value, '''', '''''', [rfReplaceAll]);
        Value := AddQuote (Value);
      end;
  end;
  Result := Value;
end;


end.
