procedure SaveFile(Name : PathStr);
{ save a file }
var
  SaveOK : boolean;
  OutFile : text;
  i : integer;
begin
  assign(OutFile,Name); { open file if exist or make one }
  rewrite(OutFile);
  if IOResult = 0 then  { if no error }
    SaveOK := True      { continue }
  else
    SaveOK := False;    { if error, then abort }
  if SaveOK then begin
    write(Outfile,MaxPage,' '); { write amount of pages }
    if FirstVar^.Next <> nil then
      FirstVar^.Next^.SaveAll(OutFile);
    writeln(OutFile);
    for i := 1 to MaxPage do begin
      FirstNode[i]^.SaveAll(OutFile); { save nodes }
      writeln(OutFile);
    end;
  end;
  if IOResult <> 0 then SaveOK := False; { if error abort }
  close(OutFile); { close file }
  if not(SaveOK) then SaveError; { display error if any }
end;

procedure FVariable.SaveAll(var OutFile : text);
{ Save entire list of variables }
begin
  Save(OutFile);  { Save one variable }
  writeln(OutFile);
  if Next <> nil then Next^.SaveAll(OutFile);  { Save remainder of list }
end;  { of procedure FVariable.SaveAll }

procedure FVariable.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
var
  i : integer;
  S : string;
begin
  write(OutFile,VarType,' ');
  S := leftjust(Name,12);
  write(OutFile,S);
end;  { of procedure FVariable.Save }

procedure FNumVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,Value);
end;  { of procedure FNumVar.Save }

procedure FStringVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,Value);
end;  { of procedure FStringVar.Save }

procedure FTabVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,TabWidth);
end;  { of procedure FTabVar.Save }

procedure FTerm.Save(var OutFile : text);
begin
  if Term^.Name <> #0 then begin			{ if variable, write -1 and name }
    write(OutFile,-1,' ');
    write(OutFile,LeftJust(Term^.Name,12));
  end
  else begin													{ otherwise save entire variable }
    Term^.Save(OutFile);
    writeln(OutFile);
  end;
  if Next <> nil then begin						{ write operator }
    write(OutFile,Operator);
    Next^.Save(OutFile);
  end
  else
    writeln(OutFile,#0);							{ or end of list character }
end;

procedure FNode.SaveAll(var OutFile : text);
{ save entire list of nodes }
begin
  Save(OutFile);
  writeln(OutFile);
  if Next <> nil then Next^.SaveAll(OutFile);
end;

procedure FNode.Save(var OutFile : text);
{ save one node; each descendant will redefine }
var
  S : string;
begin
  write(OutFile,NodeType,' ');
  write(OutFile,XPos,' ');
  write(OutFile,YPos,' ');
  S := leftjust(Comment,52);
  write(OutFile,S);
  if CNext = nil then begin
    write(Outfile,0,' ');
    write(Outfile,0,' ');
    write(Outfile,0,' ');
  end
  else begin
    write(OutFile,CNext^.XPos,' ');
    write(OutFile,CNext^.YPos,' ');
    write(OutFile,CNext^.NodePage,' ');
  end;
end;

procedure FEquationNode.Save(var OutFile : text);
{ save one node; each descendant will redefine }
begin
  FNode.Save(OutFile);			{ save ancestor's data }
  if Variable <> nil then
    write(OutFile,LeftJust(Variable^.Name,12))
  else
    write(OutFile,LeftJust(#0,12));
  if Value <> nil then begin
    write(OutFile,' ');
    Value^.Save(OutFile);
  end
  else
    write(OutFile,#0);
  write(OutFile,LeftJust(Symbol,2));
end;

procedure FDecisionNode.Save(var OutFile : text);
{ save one node; each descendant will redefine }
begin
  FEquationNode.Save(OutFile);			{ save ancestor's data }
  if FNext = nil then begin
   write(OutFile,0,' ');
   write(OutFile,0,' ');
   write(OutFile,0,' ');
  end
  else begin
    write(OutFile,FNext^.XPos,' ');
    write(OutFile,FNext^.YPos,' ');
    write(OutFile,FNext^.NodePage,' ');
  end;
end;

procedure FInputNode.Save(var OutFile : text);
{ save one node; each descendant will redefine }
begin
  FNode.Save(OutFile);			{ save ancestor's data }
  if Variable <> nil then
    write(OutFile,Variable^.Name)
  else
    write(OutFile,#0);
end;

procedure FOutputNode.Save(var OutFile : text);
{ save one node; each descendant will redefine }
begin
  FEquationNode.Save(OutFile);			{ save ancestor's data }
  write(OutFile,XCursor,' ');
  write(OutFile,YCursor,' ');
  write(OutFile,BackColour,' ');
  write(OutFile,ForeColour,' ');
end;

procedure FControlNode.Save(var Outfile : Text);
{ save one node; each descendant will redefine }
begin
  FNode.Save(OutFile);			{ save ancestor's data }
  if OutNode = nil then begin
   write(OutFile,0,' ');
   write(OutFile,0,' ');
   write(OutFile,0,' ');
  end
  else begin
    write(OutFile,OutNode^.XPos,' ');
    write(OutFile,OutNode^.YPos,' ');
    write(OutFile,OutNode^.NodePage,' ');
  end;
  write(OutFile,Identifier);
end;

function LoadVariables(var InFile : text) : boolean;
{ load the variables from a file }
var
  N : integer;
  C : char;
  NVar,
  OVar : PVariable;
  LoadOK : boolean;
begin
  LoadVariables := False; { set variables }
  OVar := FirstVar;
  NVar := nil;
  read(InFile,C);
  if C <> ' ' then exit;
  while not(Eoln(InFile)) do begin
    read(InFile,N);   { read type of variable }
    if IOResult <> 0 then exit;  { if error, abort }
    case N of         { assign proper type of variable }
      0 : NVar := new(PVariable,Init);  { NL, tab, etc }
      1 : NVar := new(PStringVar,Init); { string }
      2 : NVar := new(PNumVar,Init);    { numeric }
      else exit;
    end;
    LoadOK := NVar^.Load(InFile); { set the specifications for the variable }
    if not(LoadOK) then exit; { check error }
    OVar^.Next := NVar; {set last and next pointers }
    NVar^.Last := OVar;
    OVar := NVar;
  end;
  LoadVariables := True;  { return no errors }
end;

function LoadNodes(var InFile : text) : boolean;
{ load the nodes }
var
  N : integer;
  ONode,
  NNode : PNode;
  LoadOK : boolean;
begin
  LoadNodes := False;  { set variables }
  if not(Eoln(InFile)) then exit;
  dispose(FirstNode[1],Done);
  for i := 1 to MaxPage do begin
    ONode := nil;
    NNode := nil;
    readln(InFile);
    while not(Eoln(InFile)) do begin
      read(InFile,N); { read in type }
      if IOResult <> 0 then exit; { error, then abort }
      case N of { deternime what type of node }
        Start      : NNode := new(PStartNode,Init);
        Stop       : NNode := new(PStopNode,Init);
        Input      : NNode := new(PInputNode,Init);
        Output     : NNode := new(POutputNode,Init);
        Assignment : NNode := new(PAssignmentNode,Init);
        Decision   : NNode := new(PDecisionNode,Init);
        Control    : NNode := new(PControlNode,Init);
        ControlOut : NNode := new(PControlOutNode,Init);
        else exit;
      end;
      LoadOK := NNode^.Load(InFile); { set specifications for node }
      if not(LoadOK) then exit; { if error then abort }
      if ONode = nil then begin { if this is first node on page ... }
        FirstNode[i] := NNode;  { set pointer }
        ONode := FirstNode[i];
      end
      else begin                { otherwise }
        ONode^.Next := NNode;   { set next }
        ONode := NNode;
      end;
    end;
  end;
  LoadNodes := True; { no error }
end;

procedure LoadFile;
{ load a file }
var
  Name : PathStr;
  InFile : text;
  N : integer;
  OVar,
  NVar : PVariable;
  ONode,
  NNode : PNode;
  Cancel,
  LoadOK : boolean;
begin
  Name := MGetFile('*.FLO','File to Open...',Cancel); { get filename }
  if not(Cancel) then begin { if not canceled }
    {$I-} { turn I/O checking off }
    NewFile; { reset programme nodes, variables, etc. }
    ProgramName := Name; { set variables }
    LoadOK := True;
    assign(InFile,Name); { open name }
    reset(InFile);
    if IOResult <> 0 then LoadOK := False; { if no error ... }
    if LoadOK then begin
      read(InFile,MaxPage);  { read number of pages }
      if IOResult <> 0 then LoadOK := False; { if error, abort }
    end;
    if LoadOK then LoadOK := LoadVariables(InFile); { load variables }
    if LoadOK then LoadOK := LoadNodes(InFile);  { load nodes }
    if LoadOK then begin
      readln(InFile);
      if not(Eof(InFile)) then LoadOK := False;{ if not at end of file abort }
    end;
    close(InFile); { close file }
    {$I-} { turn I/O checking off }
    for i := 1 to MaxPage do
      if LoadOK then LoadOK := FirstNode[i]^.ConnectAll; { connect nodes }
    if not(LoadOK) then
      LoadError { if error occured then display it }
    else begin
      PageCheck; { otherwise, redraw screen }
    end;
  end;
end;

function FVariable.LoadBase(var InFile : text) : boolean;
{ Load portion of variable which never changes }
var
  C : char;
  Nm : string[12];
begin
  LoadBase := False;
  if Eoln(InFile) then exit;  { Error occurred }
  read(InFile,C);
  if (C <> ' ') or Eoln(InFile) then exit;  { Error occured }
  read(InFile,Nm);
  Name := NoRSpace(Nm);
  LoadBase := True;
end;  { of function FVariable.LoadBase }

function FVariable.Load(var InFile : text) : boolean;
{ Load one variable; each descendant will redefine }
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;  { of function FVariable.Load }

function FNumVar.Load(var InFile : text) : boolean;
{ Load one variable; each descendant will redefine }
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,Value);
  if (IOResult <> 0) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;  { of function FNumVar.Load }

function FStringVar.Load(var InFile : text) : boolean;
{ Load one variable; each descendant will redefine }
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,Value);
  if not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;  { of function FStringVar.Load }

function FTabVar.Load(var InFile : text) : boolean;
{ Load one variable; each descendant will redefine }
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOk := LoadBase(InFile);
  if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,TabWidth);
  if (IOResult <> 0) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;  { of function FTabVar.Load }

function FTerm.Load(var InFile : text) : boolean;
var
  LoadOk : boolean;
  N : integer;
  Nm : string[12];
  S : string;
  C : char;
begin
  LoadOK := False;
  if Eoln(InFile) then exit;  { Error occurred }
  read(InFile,N);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  if N = -1 then begin			{ if -1, get pointer to variable in list }
    read(InFile,C);
    if (C <> ' ') or Eoln(InFile) then exit;  { Error occurred }
    read(InFile,Nm);
    S := NoRSpace(Nm);
    Term := FirstVar^.Find(S,0);
    if (Term = nil) or not(Eoln(InFile)) then exit;  { Error occurred }
  end
  else begin								{ otherwise create constant }
    case N of
      0      : Term := new(PVariable,Init);
      StrVar : Term := new(PStringVar,Init);
      NumVar : Term := new(PNumVar,Init);
      TabVar : Term := new(PTabVar,Init);
      NLVar  : Term := new(PNLVar,Init);
      else exit;  { Error occurred }
    end;
    LoadOK := Term^.Load(InFile);
    if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  end;
  read(InFile,C);
  Operator := C;
  if C <> #0 then begin
    Next := new(PTerm,init);
    Next^.Last := @Self;
    LoadOK := Next^.Load(InFile);
    if not(LoadOK) then exit;  { Error occurred }
  end
  else begin
    if not(Eoln(Infile)) then exit;  { Error occurred }
    readln(InFile);
  end;
  Load := True;
end;

function FNode.LoadBase(var InFile : text) : boolean;
var
  S : String[52];
  C : char;
begin
  LoadBase := False;
  if Eoln(InFile) then exit;  { Error occurred }
  read(InFile,XPos);
  if (IOResult <> 0) or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,YPos);
  if (IOResult <> 0) or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,C);
  if (C <> ' ') or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,S);
  Comment := NoRSpace(S);
  if Eoln(InFile) then exit;  { Error occurred }
  read(InFile,CNextX);
  if (IOResult <> 0) or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,CNextY);
  if (IOResult <> 0) or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,CNextPage);
  if (IOResult <> 0) or (Eoln(InFile)) then exit;  { Error occurred }
  read(InFile,C);
  if C <> ' ' then exit;  { Error occurred }
  LoadBase := True;
end;

function FNode.Load(var InFile : text) : boolean;
var
  LoadOk : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if (LoadOK = False) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;

function FEquationNode.LoadBase(var InFile : text) : boolean;
var
  LoadOK : boolean;
  Nm : string[12];
  S : string;
  C : char;
  Symb : string[2];
begin
  LoadBase := False;
  LoadOK := FNode.LoadBase(InFile);
  if (not(LoadOk)) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,Nm);
  S := NoRSpace(Nm);
  if S <> #0 then begin
    Variable := FirstVar^.Find(S,0);
    if (Variable = nil) or Eoln(InFile) then exit;  { Error occurred }
  end;
  read(InFile,C);
  if C <> #0 then begin
    Value := new(PTerm,Init);
    LoadOk := Value^.Load(InFile);
    if not(LoadOK) then exit;  { Error occurred }
  end;
  if Eoln(InFile) then exit;  { Error occurred }
  read(InFile,Symb);
  Symbol := NoRSpace(Symb);
  if not((Symbol[1] in ['=','<','>']) and
    ((Length(Symbol) = 1) or (Symbol[2] in ['=','>']))) then exit;  { Error occurred }
  LoadBase := True;
end;

function FEquationNode.Load(var InFile : text) : boolean;
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;

function FDecisionNode.Load(var InFile : text) : boolean;
var
  LoadOK : boolean;
  Nm : string[12];
  S : string;
  C : char;
begin
  Load := True;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,FNextX);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,FNextY);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,FNextPage);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,C);
  if (C <> ' ') or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;

function FInputNode.Load(var InFile : text) : boolean;
var
  LoadOK : boolean;
  Nm : string[12];
  S : string;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) then exit;  { Error occurred }
  read(InFile,Nm);
  S := NoRSpace(Nm);
  Variable := FirstVar^.Find(S,0);
  if (Variable = nil) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;

function FOutputNode.Load(var InFile : text) : boolean;
var
  LoadOk : boolean;
  N : integer;
  C : char;
begin
  Load := False;
  LoadOk := LoadBase(InFile);
  if not(LoadOK) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,XCursor);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,YCursor);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,BackColour);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,ForeColour);
  if (IOResult <> 0) or Eoln(InFile) then exit;  { Error occurred }
  read(InFile,C);
  if (C <> ' ') or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;

function FControlNode.Load(var InFile : Text) : boolean;
var
  LoadOK : boolean;
begin
  Load := False;
  LoadOK := LoadBase(InFile);
  if not(LoadOK) then exit;  { Error occurred }
  read(InFile,OutNodeX);
  if (IOResult <> 0) and Eoln(InFile) then exit;  { Error occurred }
  read(InFile,OutNodeY);
  if (IOResult <> 0) and Eoln(InFile) then exit;  { Error occurred }
  read(InFile,OutNodePage);
  if (IOResult <> 0) and Eoln(InFile) then exit;  { Error occurred }
  read(InFile,Identifier);
  if (IOResult <> 0) or not(Eoln(InFile)) then exit;  { Error occurred }
  readln(InFile);
  Load := True;
end;
