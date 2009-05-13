unit passql;

{$IFDEF FPC}
{$MODE Delphi}
{$H+}
{ELSE}
  {$IFNDEF LINUX}
  {$DEFINE WIN32}
  {$ENDIF}
{$ENDIF}

interface

uses Classes, SysUtils, sqlsupport, syncobjs;

//Enable on older versions of delphi, bcb or freepascal to disable modern syntax
//{$DEFINE NONBLOATED}

//TObject or TComponent behaviour:
{$DEFINE ASCOMPONENT}

{$IFNDEF NONBLOATED}
const
  NaN = {$IFNDEF FPC}0.0 / 0.0{$ELSE}nil{$ENDIF}; //Not A Number; a special float.
{$ENDIF}

type
  //used for dump table/database and showcreatetable functions

  TDumpTarget = (dtTestOnly, dtString, dtFile, dtStream, dtStrings);

  TDumpTargets = set of TDumpTarget;

  TSQLDB = class;

  TResultCell = class (TObject)
  protected
    FValue:String;
    FIsNull:Boolean;
    function GetInteger:Int64;
    function GetFloat:Extended;
    function GetBoolean:Boolean;
  public
    property IsNull:Boolean read FIsNull;
    property AsString:String read FValue;
    property AsInteger:Int64 read GetInteger;
    property AsBoolean:Boolean read GetBoolean;
    property AsFloat:Extended read GetFloat;
//    property AsVariant:Variant read FValue;
  end;

  TResultRow = class (TStringList)
  protected
  public //i'd prefer to have this private or protected, but thats impossible right now...
    FNulls:TList;
    FResultCell:TResultCell;
    FFields:TStrings;
    FNameValue:TStrings;
    function GetString (i:Integer):String;
    function GetResultCell (i:Integer):TResultCell;
    function GetIsNull (i:Integer):Boolean;
    function GetByField (Value: String):TResultCell;
    function GetAsNameValue:TStrings;
//public
    constructor Create;
    destructor  Destroy; override;
    //override Strings property to customize behavior
    //note:
    //property Strings isn't listed, because it doesn't need to be overriden. but it can do so.
    property Columns[Index:Integer]:String read GetString; default;
    property Format[Index:Integer]:TResultCell read GetResultCell;
    property IsNull[i:Integer]:Boolean read GetIsNull;
    property ByField[Value:String]:TResultCell read GetByField;
    property Fields:TStrings read FFields;
    property AsNameValue:TStrings read GetAsNameValue;
  end;

  TFieldDesc = class
    name: String;
    table: String;
    def: String; //database specific
    datatype: Byte; //database specific
//    length: Integer; MySQL per-cell based info, ignore...
    max_length: Integer;
    flags: Integer; //database specific
    decimals: Integer; //database specific
  end;

  TResultSet = class (TObject) //TPersistant?
    Owner: TSQLDB;
    FRowCount: Integer;
    FColCount: Integer;
    FLastInsertID:Int64;
    FRowsAffected: Int64;
    FRowList: TList;
    FFields: TStringList;
    FDataBase: String;
    FNilRow : TResultRow;
    FSQL: String;
    FQuerySize:Integer;
    FCallbackOnly:Boolean;
    FLastError:Integer;
    FHasResult:Boolean;
    FLastErrorText:String;
    FResultAsStrings: TStrings;
    constructor Create;// override;
    destructor Destroy; override;
    procedure Refresh;
  end;



  TOnFetchRow = procedure (Sender: TObject; Row:TResultRow) of Object;
  TOnBeforeQuery = procedure (Sender: TObject; var SQL:String) of Object;

  //base class for sql interfaces
  TSQLDB = class (TComponent)
  private
    FSQL: String;
    function GetLastError: Integer;
  //({$IFDEF ASCOMPONENT}TComponent{$ELSE}TObject{$ENDIF})
  protected
    //may or may not be used for specific DB engines, it's common anyhow
    FActive:Boolean;
    FActivateOnLoad:Boolean;
    FHost:String;
    FPort:Integer;
    FUser:String;
    FPass:String;
//    FThreaded: Boolean;
    //typical behaviour for all DB:

    FDataBase: String;
    FCurrentSet: TResultSet;
    FResultSets: TStringList;

//    FResults: TStringList;
//    FSQL: String;
//    FLastError: Integer;
    FCallBackOnly: Boolean;

    //The events
    FOnFetchRow:TOnFetchRow;
    FOnQueryComplete:TNotifyEvent;
    FOnError:TNotifyEvent;
    FOnBeforeQuery:TOnBeforeQuery;
    FOnSuccess:TNotifyEvent;
    FOnOpen:TNotifyEvent;
    FOnClose:TNotifyEvent;
    FDummyString:String;
    FDummyBool:Boolean;
    FFetchRowLimit:Integer;
    FFetchMemoryLimit:Integer;
    FDllLoaded:Boolean;
    FDataBaseType: TDBType;
    FCSLock: TCriticalSection;
    FErrorLog: TFileName;
//    FMaxQuerySize:Integer;
    procedure DoQuery (SQL:String);

    procedure DumpInit;
    procedure DumpWrite (Line:String);
    procedure DumpFinal;

    procedure LogError;
  public
    (*  Only virtual procedures may be database specific
        for some functions prototypes exists that does not need overriden*)

    FVersion:String;
    FEncoding:String;

    FDumpTargets : TDumpTargets;
    FDumpType:TDBType;
    FDumpString: String;
    FDumpFile: TFileName;
    FDumpStream: TStream;
    FDumpFileStream:TStream;
    FDumpStrings: TStrings;

    PrimaryKey: String;

    function Query (SQL:String):Boolean; virtual; abstract; //must override;

    procedure Lock; virtual;
    procedure Unlock; virtual;


    function Connect (Host, User, Pass:String; DataBase:String=''):Boolean; virtual; abstract;
    procedure Close; virtual;
    function Use (Database:String):Boolean; virtual;
    procedure StartTransaction; virtual;
    procedure Commit; virtual;
    procedure Rollback; virtual;
    function GetErrorMessage:String; virtual;

    //typical mysql
    procedure SetDataBase (Database:String); virtual;
    procedure SetPort (Port:Integer); virtual;

    //all these functions call query or operate on a Query result set.
    function  QueryOne (SQL:String):String;
    //comment this out if not supported by compiler:
    function  FormatQuery (Value: string; const Args: array of const):Boolean;
    procedure Clear; //clean up results

    function  GetField (I:Integer):String;
    function GetFieldCount:Integer;
    function  GetOneResult:String;
    function  GetResult(I:Integer):TResultRow;
    function GetResultFromColumnName(Field: String): TResultRow;
    function QueryStrings (SQL:String; Strings:TStrings):Boolean;
    procedure SetActive (DBActive:Boolean);

    //Additional support routines to get result in specific format
    function GetResultAsText:String; //Tab-seperated
    function GetResultAsHTML:String; //HTML table
    function GetResultAsCS:String; //Comma seperated
    function GetResultAsStrings:TStrings; //TStrings, one row per line, tab seperated
//      function GetOneColumnAsStrings:TStrings; //First column as strings
//      function GetOneRowAsStrings:TStrings; //First row as strings, with fieldnames

    //support functions, database specific:
    //please, remember to set FDumpTargets and optionally FDumpType first.
    function ExplainTable (Table:String): Boolean; virtual; abstract;
    function ShowCreateTable (Table:String): Boolean; virtual; abstract;
    function DumpTable (Table:String): Boolean; virtual; abstract;
    function DumpDatabase (Table:String): Boolean; virtual; abstract;

    function GetRowsAffected: Int64;
    function GetRowCount: Integer;
    function GetLastInsertID: Int64;
    function GetCurrentResult: TResultSet;

    //Selects, adds if necessary
    function UseResultSet (Name: String): TResultSet;

    //add if not exist:
    function AddResultSet (Name: String): TResultSet;

    //if exists, returns set else nil
    function ExistResultSet (Name: String): TResultSet;


    {$IFDEF ASCOMPONENT}
    procedure Loaded; override;
    {$ENDIF}
    constructor Create (AOwner:TComponent); override;
    destructor  Destroy; override;

    property Results[Index: Integer]:TResultRow read GetResult; default;
    property Column [Field: String]: TResultRow read GetResultFromColumnName;
    property Fields [Index:Integer]:String read GetField;
    property LastError:Integer read GetLastError;
    property ErrorMessage:String read GetErrorMessage;
  published
    //result set based:
    property CurrentResult: TResultSet read GetCurrentResult;
//    property RowsAffected:Int64 read FRowsAffected;
//    property RowCount:Integer read FRowCount;
//    property LastInsertID:Int64 read FLastInsertID;
    property RowsAffected:Int64 read GetRowsAffected;
    property RowCount:Integer read GetRowCount;
    property LastInsertID:Int64 read GetLastInsertID;

    property Active:Boolean read FActive write SetActive;
    property DllLoaded:Boolean read FDLLLoaded write FDummyBool;
    property DataBase:String read FDataBase write SetDataBase;
    property SQL:String read FSQL write DoQuery;
//    property SQL:String read FSQL write FSQL;
    property Host:String read FHost write FHost;
    property Port:Integer read FPort write SetPort;
    property User:String read FUser write FUser;
    property Password:String read FPass write FPass;

    property Result:String read GetOneResult;
//    property Threaded:Boolean read FThreaded write FThreaded; //Use to fill remaining time with processmessages

    property ColCount:Integer read GetFieldCount;
    property FieldCount:Integer read GetFieldCount;
//    property MaxQuerySize:Integer read FMaxQuerySize write FMaxQuerySize;
    property CallBackOnly:Boolean read FCallBackOnly write FCallBackOnly;

    property FetchRowLimit:Integer read FFetchRowLimit write FFetchRowLimit default 0;
    property FetchMemoryLimit:Integer read FFetchMemoryLimit write FFetchMemoryLimit default 0; //2*1024*1024; //2Mb       //Events:

    property ServerVersion:String read FVersion write FDummyString;
    property ServerEncoding:String read FEncoding write FDummyString;

    property ResultAsText:String read GetResultAsText; //Tab-seperated
    property ResultAsHTML:String read GetResultAsHTML; //HTML table
    property ResultAsCommaSeperated:String read GetResultAsCS; //Comma seperated
//  property ResultAsStrings:TStrings read GetResultAsStrings; //TStrings, one row per line, tab seperated

    property ErrorLog: TFileName read FErrorLog write FErrorLog;

    property OnFetchRow:TOnFetchRow read FOnFetchRow write FOnFetchRow;
    property OnQueryComplete:TNotifyEvent read FOnQueryComplete write FOnQueryComplete;
    property OnError:TNotifyEvent read FOnError write FOnError;
    property OnBeforeQuery:TOnBeforeQuery read FOnBeforeQuery write FOnBeforeQuery;
    property OnOpen:TNotifyEvent read FOnOpen write FOnOpen;
    property OnClose:TNotifyEvent read FOnClose write FOnClose;
    property OnSuccess:TNotifyEvent read FOnSuccess write FOnSuccess;
  end;

implementation

function TResultCell.GetInteger: Int64;
begin
  Result := StrToIntDef (FValue, 0);
end;

function TResultCell.GetFloat: Extended;
begin
  try
    Result := StrToFloat (FValue);
  except
    Result := 0;
  end;
end;

function TResultCell.GetBoolean: Boolean;
begin
  Result := (not FIsNull) and
            (FValue<>'') and
            (
                (
                  (FValue<>'0') and
                  (lowercase(FValue)<>'false') and
                  (lowercase(FValue)<>'N')
                )
              or
               (lowercase(FValue)='true')
            );
end;

constructor TResultRow.Create;
begin
  inherited;
  FResultCell := TResultCell.Create;
  FNulls := TList.Create;
  FNameValue := TStringList.Create;
end;

destructor TResultRow.Destroy;
begin
  FResultCell.Free;
  FNulls.Free;
  FNameValue.Free;
  inherited;
end;

function TResultRow.GetResultCell(i: Integer): TResultCell;
begin
  with FResultCell do
    begin
      if (i>=0) and (i<count) then
        begin
          FValue := Strings[i];
          FIsNull := Integer(FNulls[i])<>0;
        end
      else
        begin
          FValue := '';
          FIsNull := True;
        end;
    end;
  Result := FResultCell;
end;

function TResultRow.GetString(i: Integer): String;
begin
  if (i>=0) and (i<Count) then
    Result := Strings[i]
  else
    Result := '';
end;

function TResultRow.GetByField(Value: String): TResultCell;
begin
  Result := GetResultCell (FFields.IndexOf (Value) );
end;

function TResultRow.GetIsNull(i: Integer): Boolean;
begin
  if (i>=0) and (i<FNulls.Count) then
    Result := Integer(FNulls[i])=0
  else
    Result := True;
end;

function TResultRow.GetAsNameValue: TStrings;
var i:Integer;
begin
  Result := FNameValue;
  Result.Clear;
  if FFields.Count<>Count then
    exit; //this will be an empty set (nilrow)
  for i:=0 to Count - 1 do
    Result.Add(FFields[i]+'='+Strings[i])
end;

procedure TSQLDB.DoQuery;  //procedure needed for SQL property
begin
  if not (csLoading in ComponentState) then
    Query (SQL);
end;

function TSQLDB.GetOneResult: String;
begin
  if (FCurrentSet.FRowCount >=1) and (FCurrentSet.FColCount >= 1) then
    Result := Results[0][0]
  else
    Result := '';
end;

function TSQLDB.QueryOne(SQL: String): String;
begin
  if Query (SQL) then
    Result := GetOneResult
  else
    Result := '';
end;

function TSQLDB.FormatQuery (Value: string; const Args: array of const):Boolean;

var i,j:Integer;
    c:char;
    sql, p:String;
begin
  //we could call the format function,
  //but we need to escape non-numerical values anyhow
  //open arrays are fun since they involve some compiler magic :)
  Result := False;
  sql:='';

  //We need to clear the result set!
  Query (''); //empty result set

  with FCurrentSet do
    begin
      //this function succeeds if some string contains a '%%'.. fixed
      FLastErrorText := 'Invalid format';
      FLastError := -1;
    end;
  for i:=0 to high(Args) do
    begin
      j:=pos('%', Value);
      while copy (Value, j+1, 1)='%' do //skip this occurence
        begin
          sql:=sql+copy(Value,1,j+1);
          Value := copy (Value, j+2, maxint);
          j:=pos('%', Value);
        end;

      if j<length(Value) then
        c:=upcase(Value[j+1])
      else
        c:=#0; //exit;
      sql:=sql+copy(Value,1,j-1);
      Value:=copy(Value, j+2, maxint);

      p := '';

      with Args[i] do
          case VType of
            vtBoolean:
              begin
                if c in ['B', 'Q', 'A'] then
                  p := IntToStr(Integer(VBoolean))
                else
                  exit; //illegal format
              end;
            vtInteger:
              begin
                if c in ['D', 'Q', 'A'] then
                  p := IntToStr(VInteger)
                else
                  exit; //illegal format
              end;
            vtString:
              begin
                if c in ['S', 'Q', 'Z', 'X', 'A'] then
                  p :=  String(VString^)
                else
                  exit; //illegal format
              end;
            vtChar:
              begin
                if c in ['S', 'Q', 'Z', 'X', 'A'] then
                  p := VChar
                else
                  exit; //illegal format
              end;
            vtExtended:
              begin
                if c in ['F', 'Q', 'A'] then
                  p := FloatToStr(Extended(VExtended^))
                else
                  exit; //illegal format
              end;
            vtInt64:
              begin
                if c in ['I', 'D', 'Q', 'A'] then
                  p := IntToStr(VInt64^)
                else
                  exit; //illegal format
              end;
            vtAnsiString:
              begin
                if c in ['S', 'Q', 'Z', 'U', 'X', 'A'] then
                  p := String(VAnsiString)
                else
                  exit; //illegal format
              end;
            vtVariant:
              begin
                if c in ['S', 'Q', 'Z', 'A'] then
                  p := String(VVariant^)
                else
                  exit; //illegal format
              end;
            vtCurrency:
              begin
                if c in ['S', 'Q', 'Z'] then
                  p := CurrToStr(VCurrency^)
                else
                  exit; //illegal format
              end;
            else
              exit;
          end; //case

        //rules:
        // d - decimal, not quoted
        // b - boolean, not quoted
        // i - int64, 'd' also allowed
        // s - string, variant, currency, autoquoted
        // f - float
        // z - binary safe (Zero-safe + quotes escaped), many types
        // q - any type quoted; force quote, all types
        // u - do not quote string types
        // x - binary safe but not quoted, string types
        // a - any type unquoted

        //other way round:
        // strings: S Q Z X A
        // integers: D Q A
        // int64: D I Q A
        // float: F Q A
        // Boolean: B Q A

        //table
        //      quoted binary datatype
        // S      yes    no   strings, char, array of char, variants (casted as string)
        // U      no     no   String types
        // D,I    no     no   Integers, ordinal types
        // F      no     no   floating point (any type)
        // Z      yes    yes  Binary data as string
        // X      no     yes  Binary data, not quoted (recommended only to use if you quote the data yourself)
        // A      no     no   Any type not quoted
        // Q      yes    no   Any type quoted

        // char, char array, variant and currency types: see string types

        //last note about floats: for sqlite i'm not too sure at the moment
        //how decimal seperator is threated, weather it is locally or not
        //mysql uses a dot everywhere ... have to check this out.

        if (c='X') then //make this string binary:
          p := Escape (p); //we just assume same syntax is valid on both mydb and litedb databases

        if (c='S') or (c='Z') then //quote string
          p:= QuoteEscape (p, FDataBaseType);

        if (c='Q') then p := AddQuote (p);

        sql := sql + p;
    end;

  //in case it was nicely formatted, but out of arguments:
  Value := StringReplace (Value, '%%', '%', [rfReplaceAll]);

  sql := sql+Value;
  Result := Query (sql);
{
const
  BoolChars: array[Boolean] of Char = ('F', 'T');
var
  I: Integer;
  R,s:String;
begin
  R := '';
  query('');
  for I := 0 to High(Args) do
    begin
      r:='';
      s:=s+r;
      with Args[I] do
        case VType of
//          vtBoolean:    r := r + BoolChars[VBoolean];
          vtInteger:    r := r + IntToStr(VInteger);

          vtChar:       begin
                          if r<>'' then
                            ;
                          r := r + VChar;
                        end;
          vtExtended:   r := r + FloatToStr(VExtended^);

          vtString:     r := r + VString^;
//          vtPChar:      r := r + VPChar;
          vtObject:     r := r + VObject.ClassName;
  //        vtClass:      r := r + VClass.ClassName;
  //        vtAnsiString: r := r + string(VAnsiString);
          vtCurrency:   r := r + CurrToStr(VCurrency^);
          vtVariant:    r := r + string(VVariant^);
          vtInt64:      r := r + IntToStr(VInt64^);
        else
          r:=r+'';
      end;
    end;
  Result := R<>'';
  query(r);
}
end;

function TSQLDB.GetField(i: Integer): String;
begin
  if (i>=0) and (i<FCurrentSet.FFields.Count) then
    Result := FCurrentSet.FFields[i]
  else
    Result := '';
end;

function TSQLDB.GetResult(i: Integer): TResultRow;
begin
  if (i>=0) and (i<FCurrentSet.FRowList.Count) then
    Result := TResultRow (FCurrentSet.FRowList[i])
  else
    Result := FCurrentSet.FNilRow;  //give back a valid pointer to an empty row
end;

function TSQLDB.QueryStrings(SQL: String; Strings: TStrings): Boolean;
var i:Integer;
begin
  Strings.Clear;
  Result := Query (SQL);
  if Result then
    begin
      for i:=0 to FCurrentSet.FRowCount-1 do
        Strings.Add(Results[i][0]);
    end;
end;

{$IFDEF ASCOMPONENT}
// Loaded is implemented to allow 'component style' db activation (Actice is published property)
procedure TSQLDB.Loaded;
begin
  inherited;
  if FActivateOnLoad then
    SetActive(True);
end;

procedure TSQLDB.SetActive;
begin

  if (csLoading in ComponentState) and
     not (csDesigning in ComponentState) then
    begin
      FActivateOnLoad:=DBActive;
      exit;
    end;
  if DBActive and not FActive then
    Connect(FHost, FUser, FPass, FDataBase);
  if FActive and not DBActive then
    Close;
end;
{$ENDIF}

//Some virtual prototypes
function TSQLDB.Use (DataBase:String):Boolean;
begin
  Result := Query ('USE '+DataBase);
end;

function TSQLDB.GetErrorMessage: String;
begin
  if FCurrentSet.FLastErrorText <> '' then
    Result := FCurrentSet.FLastErrorText
  else
    Result := IntToStr (FCurrentSet.FLastError);
end;

procedure TSQLDB.StartTransaction;
begin
  Lock;
  Query ('BEGIN'); //start transaction
end;

procedure TSQLDB.Commit;
begin
  Query ('COMMIT');
  Unlock;
end;

procedure TSQLDB.Rollback;
begin
  Query ('ROLLBACK');
  Unlock;
end;

procedure TSQLDB.SetDataBase(Database: String);
begin
  FDataBase := DataBase;
  if not (csLoading in ComponentState) then
    Use (DataBase);
end;

procedure TSQLDB.Close;
begin
  //Virtual
  FActive := False;
end;

//Additional output-generating functions:
function TSQLDB.GetResultAsText: String; //TAB-seperated
var i,j:Integer;
begin
  if FCurrentSet.FHasResult then
    begin
      Result:='';
      for i:=0 to RowCount - 1 do
        begin
          Result:=Result+Results[i][0];
          for j:=1 to FieldCount - 1 do
            Result:=Result+#9+Results[i][j];
          Result:=Result+{$IFNDEF LINUX}#13+{$ENDIF}#10;
        end;
    end
  else
    Result := '';
end;

function TSQLDB.GetResultAsHTML: String; //TAB-seperated
var i,j:Integer;
begin
  if FCurrentSet.FHasResult then
    begin
      Result:='<TABLE>';
      for i:=0 to RowCount - 1 do
        begin
          Result:=Result+'<TR>'+Results[i][0];
          for j:=1 to FieldCount - 1 do
            begin
              Result:=Result+'<TD>'+Results[i][j]+'</TD>';
            end;
          Result:=Result+#13+#10;
        end;
      Result:=Result+'</TABLE>'+#13+#10;
    end
  else
    Result := '<!-- no result -->';
end;

function TSQLDB.GetResultAsCS: String;
var i,j:Integer;
begin
  if FCurrentSet.FHasResult then
    begin
      Result:='';
      for i:=0 to RowCount - 1 do
        begin
          Result:=Result+'"'+Results[i][0]+'"';

          for j:=1 to FieldCount - 1 do
            Result:=Result+', "'+Results[i][j]+'"';
          Result:=Result+{$IFNDEF LINUX}#13+{$ENDIF}#10;
        end;
    end
  else
    Result := '';
end;

function TSQLDB.GetResultAsStrings: TStrings;
var i{,j}:Integer;
begin
  with FCurrentSet do
    begin
      if not Assigned (FResultAsStrings) then
        FResultAsStrings := TStringList.Create;
      FResultAsStrings.Clear;
      if FHasResult then
        begin
          for i := 0 to RowCount - 1 do
            FResultAsStrings.Add (Results[i][0]);
        end;
      Result := FResultAsStrings;
    end;
end;

procedure TSQLDB.SetPort(Port: Integer);
begin
  FPort := Port;
end;

procedure TSQLDB.Clear;
var i:Integer;
begin
  with FCurrentSet do
    begin
      for i:=0 to FRowList.Count - 1 do
        TResultRow (FRowList[i]).Free;
      for i:=0 to FFields.Count - 1 do
        FFields.Objects [i].Free;
      FRowList.Clear;
      FFields.Clear;
      FRowCount := 0;
      FColCount := 0;
      FRowsAffected:=-1;
      FLastInsertID:=-1;
      FHasResult:=False;
    end;
end;

constructor TSQLDB.Create(AOwner: TComponent);
begin
  inherited;
  FResultSets := TStringList.Create;
  FCurrentSet := UseResultSet ('default');


//  FThreaded := True; //assume operation in thread by default
                     //client could set it off when in main thread
                     //to optimize for busy calls
  FFetchMemoryLimit := 16*1024*1024; //16MB
  FCSLock := TCriticalSection.Create;
end;

destructor TSQLDB.Destroy;
begin
  Active := False;
  Clear;
  FResultSets.Free;
  FCSLock.Free;
  inherited;
end;



function TSQLDB.GetFieldCount: Integer;
begin
  if FCurrentSet.FHasResult then
    Result := FCurrentSet.FFields.Count
  else
    Result := 0;
end;

procedure TSQLDB.DumpInit;
begin
  //clear results:
  FDumpString := '';
  FDumpFileStream := nil;
  if not Assigned (FDumpStrings) then
    FDumpStrings := TStringList.Create;
  FDumpStrings.Clear;
  if dtFile in FDumpTargets then
    try
      FDumpFileStream := TFileStream.Create (FDumpFile, fmOpenWrite or fmCreate);
    except
      FDumpFileStream := nil;
      FDumpTargets := FDumpTargets - [dtFile];
    end;
  if dtStream in FDumpTargets then
    //actually do nothing
    if not Assigned (FDumpStream) or
       not (FDumpStream is TStream) then
      FDumpTargets := FDumpTargets - [dtStream];
end;

procedure TSQLDB.DumpWrite(Line: String);
begin
  if dtStrings in FDumpTargets then
    FDumpStrings.Add (Line);
  Line := Line + #13#10; //Line now always is <> ''
  if dtString in FDumpTargets then
    FDumpString := FDumpString + Line;
  if dtFile in FDumpTargets then
    try
      FDumpFileStream.Write (Line[1], Length (Line));
    except end;
  if dtStream in FDumpTargets then
    try
      FDumpStream.Write (Line[1], Length(Line));
    except end;
end;

procedure TSQLDB.DumpFinal;
begin
  if dtFile in FDumpTargets then
    try  //allways be carefull with streams:
      FreeAndNil (FDumpFileStream);
    except end;
end;


procedure TSQLDB.Lock;
begin
  FCSLock.Enter;
end;

procedure TSQLDB.Unlock;
begin
  FCSLock.Leave;
end;

procedure TSQLDB.LogError;
var f: TextFile;
begin
  if FErrorLog='' then
    exit;
  if LastError=0 then
    exit;
  {$I-}
  AssignFile (f, FErrorLog);
  if FileExists (FErrorLog) then
    Append (f)
  else
    Rewrite (f);
  writeln (f, 'Error on query '+SQL);  
  writeln (f, IntToStr(FCurrentSet.FLastError)+' '+FCurrentSet.FLastErrorText);

  CloseFile(f);
  {$I+}
end;

function TSQLDB.GetResultFromColumnName(Field: String): TResultRow;
begin
  Result := GetResult (FCurrentSet.FFields.IndexOf(Field));
end;

function TSQLDB.AddResultSet(Name: String): TResultSet;
var i: Integer;
begin
  Result := ExistResultSet(Name);
  if not Assigned(Result) then
    begin
      i := FResultSets.AddObject (Name, TResultSet.Create);
      Result := TResultSet(FResultSets.Objects[i]);
    end;
end;

function TSQLDB.ExistResultSet(Name: String): TResultSet;
var i:Integer;
begin
  Result := nil;
  i := FResultSets.IndexOf (Name);
  if i>=0 then
    Result := TResultSet(FResultSets.Objects[i]);
end;

function TSQLDB.GetCurrentResult: TResultSet;
begin
  Result := FCurrentSet;
end;

function TSQLDB.GetLastError: Integer;
begin
  Result := FCurrentSet.FLastError;
end;

function TSQLDB.GetLastInsertID: Int64;
begin
  Result := FCurrentSet.FLastInsertID;
end;

function TSQLDB.GetRowCount: Integer;
begin
  Result := FCurrentSet.FRowCount;
end;

function TSQLDB.GetRowsAffected: Int64;
begin
  Result := FCurrentSet.FRowsAffected;
end;

function TSQLDB.UseResultSet(Name: String): TResultSet;
begin
  //just an alias
  Result := AddResultSet(Name);
end;

{ TResultSet }

constructor TResultSet.Create;
begin
  FRowList := TList.Create;
  FFields  := TStringList.Create;
  FNilRow  := TResultRow.Create;
  FNilRow.FFields := FFields;
end;

destructor TResultSet.Destroy;
begin
//  Clear;
  FRowList.Free;
  FNilRow.Free;
  FFields.Free;
  inherited;
end;

procedure TResultSet.Refresh;
begin
  Owner.Query (FSQL);
end;

end.
