unit OOP;

{$F+}

interface

uses Dos,Variable;

const

{ Node Types }
  Stop = 1;
  Assignment = 2;
  Decision = 3;
  Input = 4;
  Output = 5;
  Control = 6;
  Start = 7;
  ControlOut = 8;

{ Variable Types }
  StrVar = 1;
  NumVar = 2;
  TabVar = 3;
  NLVar  = 4;

type

{ Variables }

  PVariable = ^FVariable;
  FVariable = object  { Abstract object }
    Name : string[13];
    VarType : 0..4;
    Next : PVariable;
    Last : PVariable;
    constructor Init;
    procedure SetVar(VarName : string; LastVar : PVariable);
    procedure List(ListType : byte; X,Y : byte);
    function Find(VarName : string; FindType : byte) : PVariable;
    procedure SaveAll(var OutFile : text); virtual;
    procedure Save(var OutFile : text); virtual;
    procedure Show; virtual;
    function LoadBase(var InFile : text) : boolean;
    function Load(var InFile : text) : boolean; virtual;
    destructor Done; virtual;
  end;  { of object FVariable }

  PNumVar = ^FNumVar;
  FNumVar = object(FVariable)
    Value : real;
    constructor Init;
    procedure SetVar(VarName : string; LastVar : PVariable; N : real);
    procedure Show; virtual;
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
  end;  { of object FNumVar }

  PStringVar = ^FStringVar;
  FStringVar = object(FVariable)
    value : string;
    constructor Init;
    procedure SetVar(VarName : string; LastVar : PVariable; S : string);
    procedure Save(var OutFile : text); virtual;
    procedure Show; virtual;
    function Load(var InFile : text) : boolean; virtual;
  end;  { of object FStringVar }

  PTabVar = ^FTabVar;
  FTabVar = object(FVariable)
    { Used only as a constant }
    TabWidth : integer;
    constructor Init;
    procedure SetVar(VarName : string; LastVar : PVariable; N : integer);
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
    procedure Show; virtual;
  end;  { of object FTabVar }

  PNLVar = ^FNLVar;
  FNLVar = object(FVariable)
    { Used only as a constant }
    constructor Init;
    procedure Show; virtual;
  end;  { of object FNLVar }

{ Equations }

  PTerm = ^FTerm;
  FTerm = object
    { Linked list of variables or constants used in equations }
    Next : PTerm;
    Last : PTerm;
    Operator : char;
    Term : PVariable;
    constructor Init;
    procedure SetTerm(TermType : byte);
    procedure GetStringTerm;
    procedure GetNumTerm;
    procedure GetVarTerm(VarType : byte);
    procedure GetTab;
    procedure GetNewLine;
    procedure GetOperator;
    procedure Show;
    procedure CalcTerms(var TempTerm : PTerm);
    procedure CalcPowers;
    procedure CalcMultDiv;
    procedure CalcAddSub;
    function GetNumValue : real;
    function GetStrValue : string;
    procedure Save(var OutFile : text);
    function Load(Var InFile : text) : boolean;
    destructor Delete;
    destructor Done;
  end;  { of object FTerm }

{ Nodes }

  PNode = ^FNode;
  FNode = object  { Abstract object }
    NodeType : 0..ControlOut;
    NodePage : byte;
    XPos, YPos : byte;
    Comment : string;
    Next : PNode;
    CNext : PNode;
    { Temporary fields used in loading }
    CNextX,CNextY,CNextPage : byte;
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    function ChangeNode(X,Y : word) : boolean; virtual;
    procedure GetComment;
    function Find(X,Y : word) : PNode;
    function FindLast(X,Y : word) : PNode;
    function FindCLast(X,Y : word) : PNode;
    function FindFLast(X,Y : word) : PNode; virtual;
    procedure Add(Node : PNode);
    procedure ConnectTo(Node : PNode; side: Boolean); virtual;
    procedure Copy(Node : PNode);
    procedure NewPos(X,Y : word);
    procedure Show; virtual;
    procedure DrawAll; virtual;
    procedure Draw; virtual;
    procedure DrawLine(Side : boolean); virtual;
    procedure run; virtual;
    procedure SaveAll(var OutFile : text);
    procedure Save(var OutFile : text); virtual;
    function LoadBase(var InFile : text) : boolean; virtual;
    function Load(var InFile : text) : boolean; virtual;
    function ConnectAll : boolean; virtual;
    destructor Delete; virtual;
    destructor Done; virtual;
  end;  { of object FNode }

  PEquationNode = ^FEquationNode;
  FEquationNode = object(FNode)  { Abstract object }
    Value : PTerm;
    Variable : PVariable;
    Symbol : string[2];
    constructor Init;
    function GetVariable : boolean;
    function GetNumValue : boolean;
    function GetStrValue : boolean;
    procedure Copy(Node : PEquationNode);
    procedure Save(var OutFile : text); virtual;
    function LoadBase(var InFile : text) : boolean; virtual;
    function Load(var InFile : text) : boolean; virtual;
    destructor Delete; virtual;
    destructor Done; virtual;
  end;  { of object FEquationNode }

  PStopNode = ^FStopNode;
  FStopNode = object(FNode)
    constructor Init;
    function ChangeNode(X,Y : word) : boolean; virtual;
    procedure Show; virtual;
    procedure Run; virtual;
  end;  { of object FStopNode }

  PAssignmentNode = ^FAssignmentnode;
  FAssignmentNode = object(FEquationNode)
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    procedure Show; virtual;
    procedure Run; virtual;
  end;  { of object FAssignmentNode }

  PDecisionNode = ^FDecisionNode;
  FDecisionNode = object(FEquationNode)
    FNext : PNode;
    { Temporary fields used in loading }
    FNextX,FNextY,FNextPage : byte;
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    function GetVariable : boolean;
    procedure GetSymbol;
    procedure Copy(Node : PDecisionNode);
    procedure ConnectTo(Node : PNode; side: Boolean); virtual;
    function FindFLast(X,Y : word) : PNode; virtual;
    procedure Show; virtual;
    procedure DrawAll; virtual;
    procedure DrawLine(Side : boolean); virtual;
    procedure run; virtual;
    function RunNum : boolean;
    function RunStr : boolean;
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
    function ConnectAll : boolean; virtual;
  end;  { of object FDecisionNode }

  PInputNode = ^FInputNode;
  FInputNode = object(FNode)
    Variable : PVariable;
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    function GetVariable : boolean;
    procedure Copy(Node : PInputNode);
    procedure Show; virtual;
    procedure run; virtual;
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
  end;  { of object FInputNode }

  POutputNode = ^FOutputNode;
  FOutputNode = object(FEquationNode)
    XCursor : shortint;
    YCursor : shortint;
    BackColour : shortint;
    ForeColour : shortint;
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    procedure Getposition;
    procedure GetColours;
    procedure GetXCursor;
    procedure GetYCursor;
    procedure Copy(Node : POutputNode);
    procedure Show; virtual;
    procedure run; virtual;
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
  end;  { of object FOutputNode }

  PControlOutNode = ^FControlOutNode;
  PControlNode = ^FControlNode;
  FControlNode = object(FNode)
    OutNode : PControlOutNode;
    Identifier : word;
    { Temporary fields used in loading and SetNode }
    OutNodeX,OutNodeY,OutNodePage : byte;
    constructor Init;
    function SetNode(X,Y : word) : boolean; virtual;
    function ChangeNode(X,Y : word) : boolean; virtual;
    function GetOutLoc : boolean;
    function GetOutPage : boolean;
    function GetIdentifier : boolean;
    procedure Copy(Node : PControlNode);
    procedure Show; virtual;
    procedure Draw; virtual;
    procedure Run; virtual;
    procedure Save(var OutFile : text); virtual;
    function Load(var InFile : text) : boolean; virtual;
    function ConnectAll : boolean; virtual;
    destructor Delete; virtual;
  end;  { of object FControlNode }

  PStartNode = ^FStartNode;
  FStartNode = object(FNode)
    constructor Init;
    function ChangeNode(X,Y : word) : boolean; virtual;
    procedure Show; virtual;
  end;  { of object FStartNode }

  FControlOutNode = object(FNode)
    InNode : PControlNode;
    constructor Init;
    function ChangeNode(X,Y : word) : boolean; virtual;
    procedure Copy(Node : PControlOutNode);
    procedure Show; virtual;
    procedure Draw; virtual;
    destructor Delete; virtual;
  end;  { of object FControlOutNode }

var
  FirstVar : PVariable;
  FirstNode : array[1..200] of PNode;

implementation

uses
  Crt,Graph,Box,Convert,Mouse,MouseRS2,Util,Init,Misc,Menu;

{ Variables }

constructor FVariable.Init;
begin
  Name := #0;
  VarType := 0;
  Next := nil;
  Last := nil;
end;  { of constructor FVariable.Init }

procedure FVariable.SetVar(VarName : string; LastVar : PVariable);
begin
  Name := VarName;
  if LastVar <> nil then begin			{ Insert into list }
    Next := LastVar^.Next;
    Last := LastVar;
    LastVar^.Next := @Self;
  end;  { of if statement }
end;  { of procedure FVariable.SetVar }

function FVariable.Find(VarName : string; FindType : byte) : PVariable;
var
  TempVar : PVariable;
begin
  if     ((Name = VarName) or (VarName = #0))    { Name matches or is blank }
     and ((VarType = FindType) or (FindType = 0)) then  { Type matches or }
    TempVar := @Self                                    { no type necessary }
  else
    if Next <> nil then
      TempVar := Next^.Find(VarName,FindType)    { Keep searching list }
    else
      TempVar := nil;                            { Variable not found }
  Find := TempVar;
end;  { of function FVariable.Find }

procedure FVariable.List(ListType : byte; X,Y : byte);
begin
  if (VarType = ListType) or (ListType = 0) then begin  { Type matched or }
    outtextXY(X,Y,Name);                                { no type necessary }
    Y := Y + 14;
  end;  { of if statement }
  if Next <> nil then Next^.List(ListType,X,Y);   { Write remainder of list }
end;  { of procedure FVariable.List }

procedure FVariable.Show;
var
  tempbackground : pointer;
begin
  if Name <> #0 then begin
    if getx+(length(name)*8) > 631 then begin  { If at edge of screen, }
      if gety >= 118 then begin                          { enlarge box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
        dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
        boxit(0,topy,639,139,white,'');
        putimage(0,topy,tempbackground^,normalput);
        freemem(tempbackground,imagesize(0,topy+14,639,139));
        clear(3,124,637,125,lightblue);
				moveto(9,gety-14);
			end;  { of if statement }
      moveto(9,gety+14);
    end;  { of if statement }
    outtext(Name+' ');               { Write name }
  end;  { of if statement }
end;  { of procedure FVariable.Show }

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

destructor FVariable.Done;
{ Dispose of entire list }
begin
  if Next <> nil then dispose(Next,Done);
end;  { of procedure FVariable.Done }

constructor FNumVar.Init;
begin
  FVariable.Init;
  VarType := NumVar;
  Value := 0;
end;  { of constructor FNumVar.Init }

procedure FNumVar.SetVar(VarName : string; LastVar : PVariable; N : real);
begin
  FVariable.SetVar(VarName,LastVar);
  Value := N;
end;  { of procedure FNumVar.SetVar }

procedure FNumVar.Show;
var
  tempbackground : pointer;
begin
  FVariable.Show;					{ if variable has name, write it }
  if Name = #0 then begin
    if getx+(length(RtoS(Value,10,10)+' ')*8) > 631 then begin
      if gety >= 118 then begin		{ if at edge of screen, enlarge box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
				dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
				boxit(0,topy,639,139,white,'');
				putimage(0,topy,tempbackground^,normalput);
				freemem(tempbackground,imagesize(0,topy+14,639,139));
				clear(3,124,637,125,lightblue);
				moveto(9,gety-14);
			end;  { of if statement }
      moveto(9,gety+14);
    end;  { of if statement }
    outtext(RtoS(Value,10,10)+' ');
  end;  { of if statement }
end;  { of procedure FNumVar.Show }

procedure FNumVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,Value);
end;  { of procedure FNumVar.Save }

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

constructor FStringVar.Init;
begin
  FVariable.Init;
  Vartype := StrVar;
  Value := #0;
end;  { of constructor FStringVar.Init }

procedure FStringVar.SetVar(VarName : string; LastVar : PVariable;
  S : string);
begin
  FVariable.SetVar(VarName,LastVar);
  Value := S;
end;  { of procedure FStringVar.SetVar }

procedure FStringVar.Show;
var
  tempbackground : pointer;
begin
  FVariable.Show;
  if Name = #0 then begin		{ if variable has name, write it }
    if getx+(length('"'+Value+'" ')*8) > 631 then begin
      if gety >= 118 then begin					{ if at edge of screen, enlarge box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
        dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
        boxit(0,topy,639,139,white,'');
        putimage(0,topy,tempbackground^,normalput);
        freemem(tempbackground,imagesize(0,topy+14,639,139));
        clear(3,124,637,125,lightblue);
        moveto(9,gety-14);
      end;  { of if statement }
      moveto(9,gety+14);
    end;  { of if statement }
    outtext('"'+Value+'" ');
  end;  { of if statement }
end;  { of procedure FStringVar.Show }

procedure FStringVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,Value);
end;  { of procedure FStringVar.Save }

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

constructor FTabVar.Init;
begin
  FVariable.Init;
  TabWidth := 0;
  vartype := TabVar;
end;  { of constructor FTabVar.Init }

procedure FTabVar.SetVar(VarName : string; LastVar : PVariable; N : integer);
begin
  FVariable.SetVar(VarName,LastVar);
  TabWidth := N;
end;  { of procedure FTabVar.SetVar }

procedure FTabVar.Show;
var
  tempbackground : pointer;
begin
  FVariable.Show;
  if Name = #0 then begin					{ if variable has name, write it }
    if getx+(length('Tab('+ItoS(tabwidth)+') ')*8) > 631 then begin
      if gety >= 118 then begin					{ if at edge of screen, enlarge box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
        dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
        boxit(0,topy,639,139,white,'');
        putimage(0,topy,tempbackground^,normalput);
        freemem(tempbackground,imagesize(0,topy+14,639,139));
        clear(3,124,637,125,lightblue);
        moveto(9,gety-14);
      end;  { of if statement }
      moveto(9,gety+14);
    end;  { of if statement }
    outtext('Tab('+ItoS(TabWidth)+') ');
  end;  { of if statement }
end;  { of procedure FTabVar.Show }

procedure FTabVar.Save(var OutFile : text);
{ Save one variable; each variable type redefines this procedure }
begin
  FVariable.Save(OutFile);
  write(OutFile,TabWidth);
end;  { of procedure FTabVar.Save }

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

constructor FNLVar.Init;
begin
  FVariable.Init;
  VarType := NLVar;
end;  { of constructor FNLVar.Init }

procedure FNLVar.Show;
var
  tempbackground : pointer;
begin
  FVariable.Show;
  if Name = #0 then begin								{ if variable has name, write it }
    if getx+(length('NL ')*8) > 631 then begin
      if gety >= 118 then begin					{ if at edge of screen, enlarge box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
        dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
        boxit(0,topy,639,139,white,'');
        putimage(0,topy,tempbackground^,normalput);
        freemem(tempbackground,imagesize(0,topy+14,639,139));
        clear(3,124,637,125,lightblue);
        moveto(9,gety-14);
      end;  { of if statement }
      moveto(9,gety+14);
    end;  { of if statement }
    outtext('NL ');
  end;  { of if statement }
end;  { of procedure FNLVar.Show }

{ Equations }

constructor FTerm.Init;
begin
	Next := nil;
	Last := nil;
	Operator := #0;
	Term := nil;
end;

procedure FTerm.SetTerm(TermType : byte);
  { TermType : 1 - String Constant,
               2 - Numeric Constant,
               3 - String Variable,
               4 - Numeric Variable,
               5 - Untyped Variable,
               6 - Tab,
               7 - New Line }
var
  Cancel : boolean;
begin
  case TermType of
    1 : GetStringTerm;
    2 : GetNumTerm;
    3 : GetVarTerm(StrVar);
    4 : GetVarTerm(NumVar);
		5 : GetVarTerm(0);
		6 : GetTab;
		7 : GetNewLine;
 	end;
end;

procedure FTerm.GetStringTerm;
const
  Temp : PStringVar = nil;
  S : string = #0;
  Background : pointer = nil;
  CancelBox : array[1..1,1..4] of integer = ((8,25,197,210));
begin
  Button := NewButton;
  GetMem(Background,ImageSize(0,197,639,244));	{ save window background }
  GetImage(0,197,639,244,Background^);
  boxit(8,197,631,244,white,'String : ');       { open window }
  SetColor(lightgray);
  InputIt(17,223,s,75,@CancelBox);						{ read string from kbd }
  PutImage(0,197,Background^,NormalPut);			  { close window }
  Freemem(Background,ImageSize(0,197,639,244));
  if s = '' then s := #27;                      { check for cancel }
  if s <> #27 then begin                     { if not cancel then }
    Temp := new(PStringVar,Init);              { create variable }
    Temp^.SetVar(#0,nil,S);
    Term := Temp;
  end;
end;

procedure Fterm.GetTab;
var
  Background : pointer;
  temp : string;
  go : boolean;
  tempterm : Ptabvar;
  Column,
  Code : integer;
const
  CancelBox : array[1..1,1..4] of integer = ((249,262,155,172));
begin
  Button := NewButton;
  GetMem(Background,ImageSize(249,155,391,195));  { save window background }
  GetImage(249,155,391,195,Background^);
  temp := '';
  repeat
    go := false;
    boxit(249,155,391,195,white,'Column');          { open window }
    PrintXY(258,174,'New column > ',yellow);
    SetColor(lightgray);
    InputIt(361,174,temp,2,@CancelBox);         { read tab width from kbd }
    If Mon then MouseCursorOff(Mx,My);
    if temp = '' then temp := #27;                { check for cancel }
    if temp <> #27 then begin
      val(temp,column,code);
      if (column < 1) or (column > 80) or (code <> 0) then
        MouseMsg(200,200,'Invalid column!')   { check if within bounds }
      else
        go := True;
    end;
  until go or (temp = #27);       { repeat until valid response or cancel }
  PutImage(249,155,Background^,NormalPut);        { close window }
  Freemem(Background,ImageSize(249,155,391,195));
  if temp <> #27 then begin                      { if not cancel then }
    Tempterm := new(PtabVar,Init);                  { create new variable }
    Tempterm^.SetVar(#0,nil,RtoI(GetVal(temp)));
    term := Tempterm;
  end;
end;

procedure FTerm.GetNewLine;
begin
  Term := new(PNLVar,Init);
end;

procedure FTerm.GetNumTerm;
var
  TempNumVar : PNumVar;
  temp : string;
  N : real;
  go : boolean;
  Code : integer;
  background : pointer;
const
  CancelBox : array[1..1,1..4] of integer = ((201,214,155,172));
begin
  Button := NewButton;
  MouseCursorOff(Mx,My);
  GetMem(Background,ImageSize(201,155,439,195));  { save window background }
  GetImage(201,155,439,195,Background^);
  temp := '';
  repeat
    go := false;
    boxit(201,155,439,195,white,'Number');         { open window }
    PrintXY(210,174,'Enter a number > ',yellow);
    SetColor(lightgray);
    InputIt(348,174,temp,10,@CancelBox);       { read number from keyboard }
    if temp = '' then temp := #27;               { check for cancel }
    if temp <> #27 then begin
      val(temp,N,Code);
      if Code <> 0 then                     { check for valid response }
        MouseMsg(200,200,'Invalid number!')
      else
        go := true;
    end;
  until go or (temp = #27);
  MouseCursorOff(Mx,My);
  PutImage(201,155,Background^,NormalPut);     { close window }
  Freemem(Background,ImageSize(201,155,439,195));
  MouseCursorOn(Mx,My,Arrow);
  if temp <> #27 then begin                 { if not cancel then }
    TempNumVar := new(PNumVar,Init);        { create new variable }
    TempNumVar^.SetVar(#0,nil,N);
    Term := TempNumVar;
  end;
end;

procedure FTerm.GetVarTerm(VarType : byte);
var
  VarName : string;
  Cancel : boolean;
begin
  repeat
    GetFileType := 1;							{ Pick variable from list }
		VarName := MGetFile(ItoS(VarType),'Variable Name',Cancel);
		GetFileType := 0;
		term := FirstVar^.Find(VarName,VarType);  { Get pointer to variable }
		if (term = nil) and not(Cancel) then
      mousemsg(200,200,'Invalid Variable');
	until (term <> nil) or Cancel;
end;

procedure FTerm.GetOperator;
var
  temp : string[1];
const
  opset : array [1..6] of string = ('+','-','*','/','^',#0);
begin
  Temp := OpSet[MouseQuestion(5,1,'Operator:',@Opset)];
  Operator := Temp[1];
end;

procedure FTerm.Show;
var tempbackground : pointer;
begin
  if Term <> nil then Term^.Show;  { show variable or constant }
  if Operator <> #0 then begin
    if getx+(length(operator+'  ')*8) > 631 then begin
      if gety >= 118 then begin      { if at edge of screen then expand box }
        getmem(tempbackground,imagesize(0,topy,639,139));
        getimage(0,topy,639,139,tempbackground^);
        putimage(0,topy,outputsbackground^,normalput);
        freemem(outputsbackground,imagesize(0,topy,639,139));
        dec(topy,14);
				getmem(outputsbackground,imagesize(0,topy,639,139));
				getimage(0,topy,639,139,outputsbackground^);
        boxit(0,topy,639,139,white,'');
        putimage(0,topy,tempbackground^,normalput);
        freemem(tempbackground,imagesize(0,topy+14,639,139));
        clear(3,124,637,125,lightblue);
        moveto(9,gety-14);
      end;
      moveto(9,gety+14);
    end;
    outtext(Operator+' ');        { show operator }
    if next <> nil then Next^.Show;   { show rest of terms }
  end;
end;

procedure FTerm.CalcTerms(var TempTerm : PTerm);
{ replace actual list of terms with temporary list, replacing all variable
  references with constants having the same value }
var
  Temp : PVariable;
begin
  TempTerm^.Operator := Operator;         { copy operator to new list }
  TempTerm^.Term := new(PNumVar,Init);    { create constant in new list }
  Temp := TempTerm^.Term;                 { copy value of constant or var }
  PNumVar(Temp)^.Value := PNumVar(Term)^.Value;  { to new list }
  if Next = nil then
    TempTerm^.Next := nil         				{ end new list }
  else begin
    TempTerm^.Next := new(PTerm,Init);		{ create new term in new list }
    Next^.CalcTerms(TempTerm^.Next);
  end;
end;

procedure FTerm.CalcPowers;
{ calculate all powers in list of terms, replacing each pair of terms with
  a single term containing the result of the operation }
var
  Finished : boolean;
  Temp : PVariable;
  TempNext : PTerm;
begin
  Finished := False;
  repeat
    case Operator of
      '^' : begin   { calculate result and put it in replacement term }
              Temp := Next^.Term;
              PNumVar(Term)^.Value :=
                Pwr( PNumVar(Term)^.Value, RtoI( PNumVar(Temp)^.Value ) );
              Operator := Next^.Operator;
              TempNext := Next^.Next;
              dispose(Next,Delete);
              Next := TempNext;
              if Next <> nil then
                Next^.Last := @Self;
            end;
      #0  : exit;      { end of list }
      else Finished := True;  { next term is not a power }
    end;
  until Finished;     { repeat until term that isn't power is reached }
  Next^.CalcPowers;    { continue until another sequence of powers is hit }
end;

procedure FTerm.CalcMultDiv;
{ calculate all mult. and div. in list of terms, replacing each pair of terms
  with a single term containing the result of the operation }
var
  Finished : boolean;
  Temp : PVariable;
  TempNext : PTerm;
begin
  Finished := False;
  repeat
    case Operator of
      '*' : begin   { calculate result and put it in replacement term }
              Temp := Next^.Term;
              PNumVar(Term)^.Value := PNumVar(Term)^.Value *
                PNumVar(Temp)^.Value;
              Operator := Next^.Operator;
              TempNext := Next^.Next;
              dispose(Next,Delete);
              Next := TempNext;
              if Next <> nil then
                Next^.Last := @Self;
            end;
      '/' : begin   { calculate result and put it in replacement term }
              Temp := Next^.Term;
              if PNumVar(Temp)^.Value = 0 then begin
                writeln('Error : Division by Zero');
                halt(1);
              end
              else begin
                PNumVar(Term)^.Value := PNumVar(Term)^.Value /
                  PNumVar(Temp)^.Value;
                Operator := Next^.Operator;
                TempNext := Next^.Next;
                dispose(Next,Delete);
                Next := TempNext;
                if Next <> nil then
                  Next^.Last := @Self;
              end;
            end;
      #0  : exit;		{ end of list }
      else Finished := True;
    end;
  until Finished;		{ repeat until term that isn't mult or div is reached }
  Next^.CalcMultDiv;  { continue until next mult or div term is reached }
end;

procedure FTerm.CalcAddSub;
{ calculate all add. and sub. in list of terms, replacing each pair of terms
  with a single term containing the result of the operation }
var
  Finished : boolean;
  TempNext : PTerm;
  Temp : PVariable;
begin
  Finished := False;
  repeat
    case Operator of
      '+' : begin   { calculate result and put it in replacement term }
              Temp := Next^.Term;
              PNumVar(Term)^.Value := PNumVar(Term)^.Value +
                PNumVar(Temp)^.Value;
              Operator := Next^.Operator;
              TempNext := Next^.Next;
              dispose(Next,Delete);
              Next := TempNext;
              if Next <> nil then
                Next^.Last := @Self;
            end;
      '-' : begin   { calculate result and put it in replacement term }
              Temp := Next^.Term;
              PNumVar(Term)^.Value := PNumVar(Term)^.Value -
                PNumVar(Temp)^.Value;
              Operator := Next^.Operator;
              TempNext := Next^.Next;
              dispose(Next,Delete);
              Next := TempNext;
              if Next <> nil then
                Next^.Last := @Self;
            end;
      #0  : exit;		{ end of list }
      else Finished := True;
    end;
  until Finished;		{ repeat until term that isn't add or subt is reached }
  Next^.CalcPowers;		{ continue until next add or subt is reached }
end;

function FTerm.GetNumValue : real;
{ find result of numeric equation, using standard order of operations }
var
  TempTerm : PTerm;
  TempVal : PVariable;
begin
  TempTerm := new(PTerm,Init);  { create temporary list }
  CalcTerms(TempTerm); 					{ copy terms into temporary list }
  TempTerm^.CalcPowers;         { take all powers out of list }
  TempTerm^.CalcMultDiv;        { take all mult. and div. out of list }
  TempTerm^.CalcAddSub;         { take all add. and subt. out of list }
  TempVal := TempTerm^.Term;    { remaining term is value }
  GetNumValue := PNumVar(TempVal)^.Value;
  dispose(TempTerm,Done);				{ dispose of temporary list }
end;

function FTerm.GetStrValue : string;
{ find result of string equation }
var
  Temp : string;
begin
  Temp := '';
  with Term^ do
    case VarType of			{ add current term to string }
      StrVar : Temp := Temp + PStringVar(Term)^.Value;
      NumVar : Temp := Temp + RtoS(PNumVar(Term)^.Value,10,10);
      3 : Temp := Temp + StringOf(PTabVar(Term)^.TabWidth,' ');
      4 : Temp := Temp + #10 + #13;
    end;
  if Operator <> #0 then Temp := Temp + Next^.GetStrValue;
  GetStrValue := Temp;            { add result of rest of terms to string }
end;

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

destructor FTerm.Delete;
{ Delete term from list }
begin
  if (Term <> nil) and (Term^.Name = #0) then dispose(Term,Done);
end;

destructor FTerm.Done;
{ Dispose of entire list }
begin
  if (Term <> nil) and (Term^.Name = #0) then dispose(Term,Done);
  if Next <> nil then dispose(Next,Done);
end;

{ Nodes }

constructor FNode.Init;
begin
  XPos := 0;
  YPos := 0;
  Comment := #0;
  NodeType:= 0;
  NodePage := Page;
  Next := nil;
  CNext := nil;
  CNextX := 0;
  CNextY := 0;
  CNextPage := 0;
end;

function FNode.SetNode(X,Y : word) : boolean;
begin
  if FirstNode[NodePage]^.Find(X,Y) = nil then begin
    XPos := X;
    YPos := Y;
    SetNode := True;
  end
  else
    SetNode := False;
end;

function FNode.ChangeNode(X,Y : word) : boolean;
{ Most nodes simply call their SetNode routine again when they are moved;
  some may override this, however }
begin
  ChangeNode := SetNode(X,Y);
end;

procedure FNode.GetComment;
var
  Background : pointer;
  temp : string;
  CancelBox : array[1..1,1..4] of integer;
begin
  Button := NewButton;
  GetMem(Background,ImageSize(LXY[2,1],197,LXY[1,1]+444,244)); {open window}
  GetImage(LXY[2,1],197,LXY[1,1]+444,244,Background^);
  boxit(LXY[2,1],197,LXY[1,1]+444,244,white,'Enter Your Comment');
  CancelBox[1,1] := LXY[2,1];														{ set up cancel box }
  CancelBox[1,2] := LXY[2,1] + 13;
  CancelBox[1,3] := 197;
  CancelBox[1,4] := 210;
  SetColor(lightgray);
  InputIt(LXY[2,1]+9,223,Temp,52,@CancelBox);				{ read comment from kbd }
  If (temp <> #27) and (temp <> '') then Comment := Temp; { cancel }
  PutImage(LXY[2,1],197,Background^,NormalPut);				{ close window }
  Freemem(Background,ImageSize(LXY[2,1],197,LXY[1,1]+444,244));
end;

function FNode.Find(X,Y : word) : PNode;
begin
  if (XPos = X) and (YPos = Y) then
    Find := @Self
  else
    if Next = nil then
      Find := nil
    else
      Find := Next^.Find(X,Y);
end;

function FNode.FindLast(X,Y : word) : PNode;
{ find last node in list }
begin
  if Next = nil then
    FindLast := nil
  else
    if (Next^.XPos = X) and (Next^.YPos = Y) then
      FindLast := @Self
    else
      FindLast := Next^.FindLast(X,Y);
end;

function FNode.FindCLast(X,Y : word) : PNode;
{ find first node in list which is connected to current node }
begin
  if (CNext <> nil) and (CNext^.XPos = X) and  (CNext^.YPos = Y) then
    FindCLast := @Self
  else
    if Next = nil then
      FindCLast := nil
    else
      FindCLast := Next^.FindCLast(X,Y);
end;

function FNode.FindFLast(X,Y : word) : PNode;
{ find first decision node which is connect through FNext to current node }
begin
  if Next = nil then
    FindFLast := nil
  else
    FindFLast := Next^.FindFLast(X,Y);
end;

procedure FNode.Add(Node : PNode);
{ add node to list }
begin
  Node^.Next := Next;
  Next := Node;
end;

procedure FNode.ConnectTo(Node : PNode; Side : Boolean);
begin
  CNext := Node;
end;

procedure FNode.Copy(Node : PNode);
{ create an exact copy of a node }
begin
  NodeType := Node^.NodeType;
  NodePage := Node^.NodePage;
  XPos := Node^.XPos;
  YPos := Node^.YPos;
  Comment := Node^.Comment;
end;

procedure FNode.NewPos(X,Y : word);
{ put a node in a new position }
begin
  if FirstNode[Page]^.Find(X,Y) = nil then begin
    XPos := X;
    YPos := Y;
	end;
end;

procedure FNode.Show;
{ show node info in view box }
begin
	PrintXY(LXY[2,1]+12,LXY[2,2]+24,Comment,white);
end;

procedure FNode.Run;
{ execute a node }
begin
  if CNext = nil then begin
    writeln('Error: Node not connected.');
    writeln('Hit any key to continue.');
    repeat until keypressed;
  end
  else
    CNext^.Run;
end;

procedure FNode.DrawAll;
{ draw entire flowchart }
begin
	Draw;
	if CNext <> nil then DrawLine(True);
	if Next <> nil then Next^.DrawAll;
end;

procedure FNode.Draw;
{ draw current node }
begin
  DrawNode(XPos,YPos,NodeType,0);
end;

procedure FNode.DrawLine(Side : boolean);
{ draw line between current node and CNext }
{ Side is used only in FDecisionNode }
var
 XL,YL,temp,GoL,OldX,OldY :integer;
 go : boolean;
begin
  SetColor(LightGray);
  XL := PSX[XPos,1]+37;
  YL := PSY[YPos,4]+2;
  YL := NextY(XL,PSY[YPos,4]+2,-2,2,YL-12,YL+10);
  Line(PSX[XPos,1]+37,PSY[YPos,4]-10,PSX[XPos,1]+37,YL);
  if XPos > CNext^.XPos then
    GoL := -37
  else
    if XPos < CNext^.XPos then
      GoL := 37
    else
      if YPos+1 = Cnext^.Ypos then
        GoL := 0
      else
        if YPos > Cnext^.YPos then
          GOL := 37
        else
          GOL := -37;

  if GoL = -37 then temp := 2
  else if GoL = 37 then temp := -2
  else temp := 0;
  repeat
		go := false;
		if (Xpos-1 = Cnext^.Xpos) or (Xpos+1 = Cnext^.Xpos) then
			case GoL of
				-37 : if XL - 74 <= PSX[CNext^.XPos,2]+37 then go := true;
				 37 : if XL + 74 >= PSX[CNext^.XPos,1]+37 then go := true;
					0 : go := true;
			end
		else
			case GoL of
				-37 : if XL - 74 <= PSX[CNext^.XPos,1]+37 then go := true;
				 37 : if XL + 74 >= PSX[CNext^.XPos,2]+37 then go := true;
					0 : go := true;
			end;
		if not(go) then begin
      if (GetPixel(XL+GoL,YL+1) <> lightblue)
        or (GetPixel (XL+GoL,YL-1) <> lightblue) then begin
          Arc(XL+GoL,YL,0,180,2);
          Line(XL,YL,XL+GoL+temp,yl);
      end
      else if GetPixel(XL,YL) = lightblue then
        Line(XL+3,YL,XL+GoL,YL)
      else
        line(XL,YL,xL+GoL,YL);
      inc(XL,GoL);
    end;
  until go;
  OldX := XL;
  OldY := YL;
	If (GoL = 0) and (YPos+1 = CNext^.YPos) then
		GoL := -37;
	if YPos+1 = Cnext^.Ypos then
		XL := PSX[CNext^.Xpos,1]+37
  else
		if (XPos+1 = Cnext^.XPos) or (XPos-1 = Cnext^.Xpos) then
			Case GoL of
			  -37 : begin
							  XL := PSX[CNext^.XPos,2]+1;
							  XL := NextX(XL,YL,2,-2,XL+12,XL-10);
						  end;
			   37 : begin
							  XL := PSX[CNext^.XPos,1]-1;
							  XL := NextX(XL,YL,-2,2,XL-12,XL+10);
						  end;
		  end
	  else
		  Case GoL of
			   37 : begin
							  XL := PSX[CNext^.XPos,2]+1;
							  XL := NextX(XL,YL,2,-2,XL+12,XL-10);
						  end;
			  -37 : begin
							  XL := PSX[CNext^.XPos,1]-1;
							  XL := NextX(XL,YL,-2,2,XL-12,XL+10);
						  end;
		  end;
	Line(OldX,OldY,XL,Yl);
	if YPos+1 > CNext^.YPos then GoL := -47
	else if YPos+1 < CNext^.YPos then GoL := 47
  else GoL := 0;
  if GoL = -47 then temp := 2
  else if GoL = 47 then temp := -2
  else GoL := 0;
  repeat
    go := false;
    case GoL of
      -47 : if YL - 47 <= PSY[CNext^.YPos,3]-1 then go := true;
       47 : if YL + 47 >= PSY[CNext^.YPos,3]-1 then go  := true;
        0 : go := true;
    end;
    if not(go) then begin
      if (GetPixel(XL+1,YL+GoL) <> lightblue)
        or (GetPixel (XL-1,YL+GoL) <> lightblue) then begin
          Arc(XL+GoL,YL,90,270,2);
          Line(XL,YL+goL+temp,XL,yl);
      end
      else if GetPixel(XL,YL) = lightblue then
        Line(XL,YL+3,XL,YL+GoL)
      else
        line(XL,YL,xL,YL+goL);

      inc(YL,GoL);
    end;
  until go;
  OldY := YL;
  if GoL <> 0 then begin
    YL := PSY[CNext^.YPos,3]-1;
    Line(XL,OldY,XL,YL);
  end;
  OldX := XL;
  OldY := YL;
  if (CNext^.XPos <> XPos) or (YPos <> CNext^.YPos) then begin
    Line(XL,YL,PSX[CNext^.XPos,1]+37,YL);
    OldX := PSX[CNext^.XPos,1]+37;
  end;
  Line(OldX,OldY,PSX[CNext^.XPos,1]+37,PSY[CNext^.YPos,3]+10);
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

function FNode.ConnectAll : boolean;
{ connect all nodes in flowchart after loading }
begin
  ConnectAll := False;
  if (CNextX <> 0) and (CNextY <> 0) and (CNextPage <> 0) then begin
    if (CNextX = 0) or (CNextY = 0) or (CNextPage = 0) then exit;  { Error occurred }
    CNext := FirstNode[CNextPage]^.Find(CNextX,CNextY);
    if CNext = nil then exit;  { Error occurred }
  end;
  if Next = nil then
    ConnectAll := True
  else
    ConnectAll := Next^.ConnectAll;
end;

destructor FNode.Delete;
{ Delete node from list }
var
  LastNode : PNode;
begin
  while FirstNode[NodePage]^.FindCLast(XPos,YPos) <> nil do begin
    LastNode := FirstNode[NodePage]^.FindCLast(XPos,YPos);
    LastNode^.ConnectTo(nil,True);    { remove all connections from CNext }
  end;
  while FirstNode[NodePage]^.FindFLast(XPos,YPos) <> nil do begin
    LastNode := FirstNode[NodePage]^.FindFLast(XPos,YPos);
    LastNode^.ConnectTo(nil,False);   { remove all connections from FNext }
  end;
  LastNode := FirstNode[NodePage]^.FindLast(XPos,YPos);
  if LastNode <> nil then
    LastNode^.Next := Next            { take node out of list }
  else
    if Next <> nil then
      FirstNode[NodePage] := Next     { make next node first in list }
    else
      DeletePage(NodePage);
end;

destructor FNode.Done;
{ Dispose of entire list }
begin
  if Next <> nil then dispose(Next,Done);
end;

constructor FEquationNode.Init;
begin
  FNode.Init;
  Variable := nil;
  Value := nil;
  Symbol := '=';
end;

function FEquationNode.GetVariable : boolean;
var
  VarName : string;
  VarType : integer;
  Replace,
  Cancel,
  Finished : boolean;
  NewVar : PVariable;
Const
  Table : array[1..2] of String = ('String','Numeric');
begin
  Finished := False;
  repeat
    GetFileType := 1;
		VarName := MGetFile('0','Variable Name',Cancel);
    GetFileType := 0;
    if TestName(VarName) then Finished := True;
    if not(Cancel) and Finished then begin
      NewVar := FirstVar^.Find(VarName,0);
      if NewVar = nil then begin
        VarType := MouseQuestion(2,1,'New Variable Type',@table);
        case VarType of
          StrVar : NewVar := new(PStringVar,Init);
          NumVar : NewVar := new(PNumVar,Init);
        end;
        NewVar^.SetVar(VarName,FirstVar);
      end;
      if (Variable <> nil) and (Value <> nil) and
        (Variable^.VarType <> NewVar^.VarType) then begin
        Replace := MouseYN(200,200,     				{ new var and value would be }
          'Different type-Replace?');   				{ different types }
        if Replace then begin
          dispose(Value,Done);
          Value := nil;
          Variable := NewVar;
        end
        else
          Finished := False;
      end
      else
        Variable := NewVar;
    end;
  until Finished or Cancel;
  if Variable = nil then
    GetVariable := false
  else
    GetVariable := True;
end;

function FEquationNode.GetNumValue : boolean;
Var
	temp : integer;
  Cancel,
	Finished : Boolean;
  OldValue,
  Term : PTerm;
  TermType : shortint;
const
  ButtonNames : MnuArray = (
		'Number',
    'Variable',
		'Operator',
		'Ok',
		'Cancel',
    '',
		'');
	Hl : mtdarray = (
		(65,173,Ord('N'),0),
    (169,173,Ord('V'),0),
		(289,173,Ord('p'),0),
		(417,173,Ord('O'),0),
		(521,173,Ord('a'),0),
    (0,0,255,0),
		(0,0,255,0));
begin
  OldValue := Value;
  Value := new(Pterm,Init);
  Term := Value;
	MLimit(0,639-MW,0,349-MH);
	Finished := False;
  Cancel := False;
  repeat
    boxit(0,TopY,639,139,white,'Equation :');
    MoveTo(9,TopY+26);
    If Variable <> nil then Variable^.show;
    OutText(Symbol+' ');
    if Value <> nil then Value^.Show;
    temp := GetMenuItem(ButtonNames,hl,5,'Equation');
	  if MOn then
      MouseCursorOff(Mx,My);
    TermType := 0;
	  case temp of
      1 : Term^.SetTerm(2);
		  2 : if FirstVar^.Next = nil then
            mousemsg(200,200,'No variables!')
          else
            Term^.SetTerm(4);
		  3 : if Term^.Term = nil then
            MouseMsg(200,200,'Get a term first!')
          else begin
            Term^.GetOperator;
            if Term^.Operator <> #0 then begin
              Term^.Next := new(PTerm,Init);
              Term^.Next^.Last := Term;
              Term := Term^.next;
            end;
          end;
		  4 : MouseMsg(200,200,'Enter at least one term.');
      5 : Cancel := True;
	  end;
  until Cancel or (Term^.Term <> nil);
  if not(Cancel) then
    repeat
      boxit(0,TopY,639,139,white,'Equation :');
      MoveTo(9,TopY+26);
      if Variable <> nil then begin
        Variable^.show;
        OutText(Symbol+' ');
      end;
      If Value <> nil then Value^.Show;
      temp := GetMenuItem(ButtonNames,hl,5,'Equation');
	    if MOn then
        MouseCursorOff(Mx,My);
      TermType := 0;
	    case temp of
		    1 : Term^.SetTerm(2);
		    2 : if FirstVar^.Next = nil then
              mousemsg(200,200,'No variables!')
            else
              Term^.SetTerm(4);
		    3 : if term^.term = nil then
              term^.Last^.GetOperator
            else begin
              term^.GetOperator;
              term^.next := new(PTerm,Init);
              term^.next^.last := term;
              term := term^.next;
            end;
		    4 : begin
              if Term^.Term = nil then begin
                Term^.Last^.Operator := #0;
                Term^.Last^.Next := nil;
                dispose(Term,Done);
              end;
              Finished := true;
            end;
        5 : begin
              Cancel := true;
              Finished := True;
            end;
			end;
			if topy <= lxy[1,2] then begin
				if Term^.Term = nil then begin
					Term^.Last^.Operator := #0;
					Term^.Last^.Next := nil;
					dispose(Term,Done);
				end;
				Finished := true;
				MouseMsg(200,200,'Too Many Lines')
			end;
		until Finished;
  if Cancel then begin
    if Value <> nil then dispose(Value,Done);
    Value := OldValue;
    GetNumValue := False;
  end
  else begin
    if oldValue <> nil then dispose(OldValue,Done);
    GetNumValue := True;
	end;
	brightall;
end;

function FEquationNode.GetStrValue : boolean;
Var
	temp : integer;
  Cancel,
	Finished : Boolean;
  OldValue,
  term : PTerm;
  TermType : shortint;
const
  ButtonNames : MnuArray = (
		'Text',
		'Variable',
		'New Col.',
		'New Line',
		'Ok',
    'Cancel',
		'');
	Hl : mtdarray = (
		(40,173,Ord('T'),0),
		(127,173,Ord('V'),0),
		(262,173,Ord('C'),0),
		(365,173,Ord('L'),0),
		(460,173,Ord('O'),0),
    (555,173,Ord('a'),0),
		(0,0,255,0));
begin
  OldValue := Value;
  Value := new(Pterm,Init);
  Term := Value;
	MLimit(0,639-MW,0,349-MH);
	Finished := False;
  Cancel := False;
  repeat
    boxit(0,TopY,639,139,white,'Equation :');
    MoveTo(9,TopY+26);
    if Variable <> nil then begin
      Variable^.Show;
      Outtext(Symbol+' ');
    end;
    if Value <> nil then Value^.Show;
    temp := GetMenuItem(ButtonNames,hl,6,'Equation');
	  if MOn then
      MouseCursorOff(Mx,My);
    TermType := 0;
	  case temp of
		  1 : Term^.SetTerm(1);
		  2 : if FirstVar^.Next = nil then
            mousemsg(200,200,'No variables!')
          else
            Term^.SetTerm(5);
		  3 : Term^.SetTerm(6);
		  4 : Term^.SetTerm(7);
		  5 : MouseMsg(200,200,'Enter at least one term.');
      6 : Cancel := True;
	  end;
  until (Term^.Term <> nil) or Cancel;
  if not Cancel then begin
    Term^.Operator := '+';
    Term^.Next := new(PTerm,Init);
    Term^.Next^.Last := Term;
    Term := Term^.Next;
    repeat
      TermType := 0;
      repeat
        boxit(0,TopY,639,139,white,'Equation :');
        MoveTo(9,TopY+26);
        if Variable <> nil then begin
          Variable^.Show;
          Outtext(Symbol+' ');
        end;
        if Value <> nil then Value^.Show;
        temp := GetMenuItem(ButtonNames,hl,6,'Equation');
	      if MOn then
          MouseCursorOff(Mx,My);
	      case temp of
		      1 : Term^.SetTerm(1);
		      2 : if FirstVar^.Next = nil then
                mousemsg(200,200,'No variables!')
              else
                Term^.SetTerm(5);
		      3 : Term^.SetTerm(6);
		      4 : Term^.SetTerm(7);
		      5 : begin
                if Term^.Term = nil then begin
                  Term^.Last^.Operator := #0;
                  Term^.Last^.Next := nil;
                  dispose(Term,Done);
                end;
                Finished := true;
              end;
          6 : begin
                Finished := True;
                Cancel := True;
              end;
				end;
				if topy <= lxy[1,2] then begin
					if Term^.Term = nil then begin
						Term^.Last^.Operator := #0;
						Term^.Last^.Next := nil;
						dispose(Term,Done);
					end;
					Finished := true;
					MouseMsg(200,200,'Too Many Lines');
				end;
			until (Term^.Term <> nil) or Finished;
      if not(Finished) then begin
        Term^.Operator := '+';
        Term^.Next := new(PTerm,Init);
        Term^.Next^.Last := Term;
        Term := Term^.Next;
      end;
    until Finished;
  end;
  if Cancel then begin
    if Value <> nil then dispose(Value,Done);
    Value := OldValue;
    GetStrValue := False;
  end
  else begin
    if OldValue <> nil then dispose(OldValue,Done);
    GetStrValue := True;
	end;
	brightall;
end;

procedure FEquationNode.Copy(Node : PEquationNode);
begin
  FNode.Copy(Node);
  Variable := Node^.Variable;
  Value := Node^.Value;
  Symbol := Node^.Symbol;
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

destructor FEquationNode.Delete;
{ Delete node from list }
begin
  if Value <> nil then dispose(Value,Done);
	FNode.Delete;
end;

destructor FEquationNode.Done;
{ Dispose of entire list }
begin
  if Value <> nil then dispose(Value,Done);
  FNode.Done;
end;

constructor FStopNode.Init;
begin
  FNode.Init;
  NodeType := Stop;
end;

function FStopNode.ChangeNode(X,Y : word) : boolean;
Var
	temp : integer;
	NodeOk,
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '',
    '');
  Hl : mtdarray = (
    (173,173,Ord('C'),0),
    (305,173,Ord('O'),0),
    (409,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
	if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
		XPos := X;
		YPos := Y;
    MLimit(0,639-MW,0,349-MH);
	  Finished := False;
    repeat
			temp := GetMenuItem(ButtonNames,hl,3,'Stop');
			MouseCursorOff(Mx,My);
      case temp of
				1 : GetComment;
				2 : begin
							NodeOk := True;
							Finished := True;
						end;
				3 : begin
							NodeOk := False;
							Finished := True;
						end;
			end;
		until Finished;
	end
	else
		NodeOK := False;
	ChangeNode := NodeOK;
end;

procedure FStopNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'STOP NODE',yellow);
	FNode.Show;
end;

procedure FStopNode.Run;
begin
  writeln;
  writeln('Hit any key to return to Visual Programming...');
  repeat until keypressed;
end;

constructor FAssignmentNode.Init;
begin
  FEquationNode.Init;
  NodeType := Assignment;
end;

function FassignmentNode.SetNode(X,Y : word) : boolean;
Var
	temp : integer;
	VarOk,
	ValueOk,
	NodeOk,
	Finished : Boolean;
const
  ButtonNames : MnuArray = (
    'Variable',
    'Equation',
    'Comment',
    'Ok',
    'Cancel',
    '',
    '');
  Hl : mtdarray = (
    (57,173,Ord('V'),0),
    (169,173,Ord('E'),0),
    (285,173,Ord('C'),0),
    (417,173,Ord('O'),0),
    (521,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0));

begin
	if ((X = XPos) and (Y = YPos)) or
    (FirstNode[page]^.Find(X,Y) = nil) then begin
		XPos := X;
		YPos := Y;
    GetMem(OutputsBackground,ImageSize(0,92,639,139));
    GetImage(0,92,639,139,OutputsBackground^);
    TopY := 92;
  	MLimit(0,639-MW,0,349-MH);
  	Finished := False;
    if Variable <> nil then
      VarOK := true
    else
      VarOK := false;
    if Value <> nil then
      ValueOk := true
    else
      ValueOk := false;
		repeat
      boxit(0,TopY,639,139,white,'Equation :');
      MoveTo(9,TopY+26);
      if Variable <> nil then begin          { Display equation }
        Variable^.show;
        OutText('= ');
      end;
      If Value <> nil then Value^.Show;
			temp := GetMenuItem(ButtonNames,hl,5,'Assignment');
			if MOn then MouseCursorOff(Mx,My);
      case temp of
        1 : VarOK := GetVariable;
				2 : If VarOk then
              case Variable^.vartype of
                StrVar : ValueOk := GetStrValue;
                NumVar : ValueOK := GetNumValue;
              end
            else
              MouseMsg(200,200,'Get a Variable first!');
				3 : GetComment;
				4 : if VarOK and ValueOK then begin
							Finished := True;
							NodeOK := True;
						end
						else
							MouseMsg(200,200,'Enter all fields first!');
				5 : begin
							NodeOk := False;
							Finished := True;
						end;
			end;
		until Finished;
    PutImage(0,TopY,OutputsBackground^,NormalPut);
    Freemem(OutputsBackground,ImageSize(0,TopY,639,139));
	end
  else
    NodeOK := False;
	SetNode := NodeOK;
end;

procedure FAssignmentNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'ASSIGNMENT NODE',yellow);
	FNode.Show;
end;

procedure FAssignmentNode.Run;
const
  dummystr : string = #255;
  dummynum : real = 2.9e-39;
begin
  case Variable^.VarType of
    StrVar : PStringVar(Variable)^.Value := Value^.GetStrValue;
    NumVar : PNumVar(Variable)^.Value := Value^.GetNumValue;
  end;
  FNode.Run;
end;

constructor FDecisionNode.Init;
begin
  FEquationNode.Init;
  NodeType := Decision;
  FNext := nil;
  FNextX := 0;
  FNextY := 0;
  FNextPage := 0;
end;

function FDecisionNode.SetNode(X,Y : word) : boolean;
Var
	temp : integer;
	VarOK,
	ValueOK,
	NodeOK,
	Finished : boolean;
const
  ButtonNames : MnuArray = (
    'Variable',
    'Symbol',
    'Equation',
    'Comment',
    'Ok',
    'Cancel',
    '');
  Hl : mtdarray = (
		(24,173,Ord('V'),0),
		(135,173,Ord('S'),0),
		(230,173,Ord('E'),0),
		(337,173,Ord('C'),0),
		(460,173,Ord('O'),0),
		(555,173,Ord('a'),0),
		(0,0,255,0));

begin
	if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then
    if FirstVar^.Next = nil then begin
      MouseMsg(200,200,'No variables.');
      NodeOK := False;
    end
    else begin
		  XPos := X;
		  YPos := Y;
      GetMem(OutputsBackground,ImageSize(0,92,639,139));
      GetImage(0,92,639,139,OutputsBackground^);
      TopY := 92;
	    MLimit(0,639-MW,0,349-MH);
	    Finished := False;
		  repeat
        If Variable <> nil then
          VarOk := true
        else
          VarOk := false;
        if Value <> nil then
          ValueOK := true
        else
          ValueOk := false;
        boxit(0,TopY,639,139,white,'Equation :');
        MoveTo(9,TopY+26);
        if Variable <> nil then begin           { Display Equation }
          Variable^.show;
          OutText(symbol+' ');
        end;
        If Value <> nil then Value^.Show;
			  temp := GetMenuItem(ButtonNames,hl,6,'Decision');
			  MouseCursorOff(Mx,My);
        case temp of
				  1 : VarOK := GetVariable;
				  2 : GetSymbol;
				  3 : If VarOk then
                case Variable^.vartype of
                  StrVar : ValueOk := GetStrValue;
                  NumVar : ValueOK := GetNumValue;
                end
              else
                MouseMsg(200,200,'Get a Variable first!');
				  4 : GetComment;
				  5 : if VarOK and ValueOK then begin
							  NodeOK := True;
							  Finished := True;
						  end
						  else
							  MouseMsg(200,200,'Enter all fields first!');
				  6 : begin
							  NodeOK := False;
							  Finished := True;
						  end;
			  end;
		  until Finished;
      PutImage(0,TopY,OutputsBackground^,NormalPut);
      Freemem(OutputsBackground,ImageSize(0,TopY,639,139));
	  end
  else
    NodeOK := False;
  SetNode := NodeOK;
end;

function FDecisionNode.GetVariable : boolean;
var
  VarName : string;
  VarType : integer;
  Replace,
  Cancel,
  Finished : boolean;
  NewVar : PVariable;
Const
  Table : array[1..2] of String = ('String','Numeric');
begin
  Finished := False;
  repeat
    GetFileType := 1;
		VarName := MGetFile('0','Variable Name',Cancel);
    GetFileType := 0;
    if TestName(VarName) then Finished := True;
    if not(Cancel) and Finished then begin
      NewVar := FirstVar^.Find(VarName,0);
      if (Variable <> nil) and  (Value <> nil) and
        (Variable^.VarType <> NewVar^.VarType) then begin
        Replace := MouseYN(200,200,
          'Different type-Replace?');
        if Replace then begin
          dispose(Value,Done);
          Value := nil;
          Variable := NewVar;
        end
        else
          Finished := False;
      end
      else
        Variable := NewVar;
    end;
  until Finished or Cancel;
  if Variable = nil then
    GetVariable := false
  else
    GetVariable := True;
end;

procedure FDecisionNode.GetSymbol;
Const
  Table : array[1..6] of string = ('=','<','>','>=','<=','<>');
var
	Response : integer;
begin
  Response := MouseQuestion(6,1,'Symbol',@table);
	case Response of
		1 : Symbol := '=';
		2 : Symbol := '<';
		3 : Symbol := '>';
		4 : Symbol := '>=';
		5 : Symbol := '<=';
		6 : Symbol := '<>';
	end;
end;

procedure FDecisionNode.Copy(Node : PDecisionNode);
begin
  FEquationNode.Copy(Node);
  FNext := Node^.FNext;
end;

function FDecisionNode.FindFLast(X,Y : word) : PNode;
begin
  if (FNext^.XPos = X) and (FNext^.YPos = Y) then
    FindFLast := @Self
  else
    if Next = nil then
      FindFLast := nil
    else
      FindFLast := Next^.FindFLast(X,Y);
end;

procedure FDecisionNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'DECISION NODE',yellow);
	FNode.Show;
end;

procedure FDecisionNode.Run;
var
  temp : real;
  tempstr : string;
  Outcome : boolean;
begin
  case Variable^.VarType of
    StrVar : OutCome := RunStr;
    NumVar : OutCome := RunNum;
  end;
  if OutCome then
    FNode.Run
  else
    if FNext = nil then
      write('Error: Node not connected.')
    else
      FNext^.run;
end;

function FDecisionNode.RunNum;
var
  a,b : char;
  OutCome : boolean;
  Temp : real;
begin
  OutCome := False;
  a := Symbol[1];
  if Length(Symbol) = 1 then
    b := #0
  else
    b := Symbol[2];
  case a of
    '=' : if PNumVar(Variable)^.Value = Value^.GetNumValue then
		        OutCome := True;
    '<' : case b of
		        #0  : if PNumVar(Variable)^.Value < Value^.GetNumValue then
		                OutCome := True;
            '=' : if PNumVar(Variable)^.Value <= Value^.GetNumValue then
		                OutCome := True;
            '>' : if PNumVar(Variable)^.Value <> Value^.GetNumValue then
		                OutCome := True;
          end;
    '>' : case b of
		        #0  : if PNumVar(Variable)^.Value > Value^.GetNumValue then
		                OutCome := True;
            '=' : if PNumVar(Variable)^.Value >= Value^.GetNumValue then
		                OutCome := True;
          end;
  end;
  RunNum := OutCome;
end;

function FDecisionNode.RunStr;
var
  a,b : char;
  OutCome : boolean;
begin
  OutCome := False;
  a := Symbol[1];
  if Length(Symbol) = 1 then
    b := #0
  else
    b := Symbol[2];
  case a of
    '=' : if PStringVar(Variable)^.Value = Value^.GetStrValue then
		        OutCome := True;
    '<' : case b of
		        #0  : if PStringVar(Variable)^.Value < Value^.GetStrValue then
		                OutCome := True;
            '=' : if PStringVar(Variable)^.Value <= Value^.GetStrValue then
		                OutCome := True;
            '>' : if PStringVar(Variable)^.Value <> Value^.GetStrValue then
		                OutCome := True;
          end;
    '>' : case b of
		        #0  : if PStringVar(Variable)^.Value > Value^.GetStrValue then
		                OutCome := True;
            '=' : if PStringVar(Variable)^.Value >= Value^.GetStrValue then
		                OutCome := True;
          end;
  end;
  RunStr := OutCome;
end;

procedure FDecisionNode.ConnectTo(Node : PNode; Side:boolean);
begin
  if Side = true then CNext := Node
  else FNext := Node;
end;

procedure FDecisionNode.DrawAll;
begin
	if FNext <> nil then DrawLine(False);
	FNode.DrawAll;
end;

procedure FDecisionNode.DrawLine(Side : boolean);
var
 OldX,OldY,XL,YL,temp,GoL :integer;
 go : boolean;
 TNext : PNode;
begin
  SetColor(LightGray);
  YL := PSY[YPos,3]+23;
	If Side = True {False} then begin
    XL := PsX[XPos,1]-1;
    XL := NextX(XL,YL,+2,-2,XL+12,XL-10);
    Line(PSX[XPos,1]+10,YL,XL,YL);
		TNext := CNext;
	end
	else begin
		XL := PSX[XPos,2]+1;
		XL := NextX(XL,YL,-2,+2,XL-12,XL+10);
		Line(PSX[XPos,2]-10,YL,XL,YL);
		TNext := FNext;
  end;
  OldX := XL;
  OldY := YL;
	if YPos >= TNext^.YPos then
		YL := NextY(XL,YL-24,2,YL-24-2,12,YL-24-10)
	else
		YL := NextY(XL,YL+24,-2,2,YL+24-12,YL+24+10);
	Line(OldX,OldY,XL,YL);
	OldX := XL;
	OldY := YL;
	if ((side <> false) and (TNext^.XPos <> XPos+1)) and
		((side <> true) and (TNext^.XPos <> XPos-1)) then
		if side = false then
			if XPos < TNext^.XPos then
				XL := PSX[XPos+1,1]+37
			else
				XL := PSX[XPos,1]+37
		else
			if XPos > TNext^.XPos then
				XL := PSX[XPos+1,1]+37
			else
				XL := PSX[XPos,1]+37;
  Line(OldX,OldY,XL,YL);
  if ((side = false) and (TNext^.XPos = XPos-1)) or
    ((side = true) and (TNext^.XPos = XPos+1)) then GOL := 0
  else if XPos > TNext^.XPos then GoL := -37
  else if XPos < TNext^.XPos then GoL := 37
  else GoL := 0;
  if GoL = -37 then temp := 2
  else if GoL = 37 then temp := -2
  else temp := 0;
  repeat
		go := false;
		if ((Xpos-1 = Tnext^.Xpos) or (Xpos+1 = Tnext^.Xpos) and
			 ((Ypos+1 = Tnext^.Ypos) or (YPos = Tnext^.Ypos))) or
			 (YPos+1 = Tnext^.Ypos) or (YPos = TNext^.Ypos) then
			case GoL of
				-37 : if XL - 37 <= PSX[TNext^.XPos,2]+37 then go := true;
				 37 : if XL + 74 >= PSX[TNext^.XPos,1]+37 then go := true;
					0 : go := true;
			end
		else
			case GoL of
				-37 : if XL - 37 <= PSX[TNext^.XPos,1]+37 then go := true;
				 37 : if XL + 74 >= PSX[TNext^.XPos,2]+37 then go := true;
					0 : go := true;
			end;
		if not(go) then begin
			if (GetPixel(XL+GoL,YL+1) <> lightblue)
        or (GetPixel (XL+GoL,YL-1) <> lightblue) then begin
          Arc(XL+GoL,YL,0,180,2);
          Line(XL,YL,XL+GoL+temp,yl);
      end
      else if GetPixel(XL,YL) = lightblue then
        Line(XL+3,YL,XL+GoL,YL)
      else
        line(XL,YL,xL+GoL,YL);
      inc(XL,GoL);
    end;
  until go;
  OldX := XL;
  OldY := YL;
	If (GoL = 0) and (YPos+1 = TNext^.YPos) and (((side = false) and
		(TNext^.XPos <> XPos-1)) or
		((side = true) and
		(TNext^.XPos <> XPos+1))) then
		GoL := -37;

	if (Tnext^.Ypos <> YPos+1) and (Tnext^.Ypos <> Ypos) then
		Case GoL of
			37 : begin
							XL := PSX[TNext^.XPos,2]+1;
							XL := NextX(XL,YL,2,-2,XL+12,XL-10);
						end;
			-37 : begin
							XL := PSX[TNext^.XPos,1]-1;
							XL := NextX(XL,YL,-2,2,XL-12,XL+10);
						end;
		end
	else
		XL := PSX[TNext^.Xpos,1]+37;
	Line(OldX,OldY,XL,Yl);
	if YPos+1 > TNext^.YPos then
		GoL := -47
	else
		if YPos+1 < TNext^.YPos then
			GoL := 47
		else
			GoL := 0;
	if GoL = -47 then
		temp := 2
	else
		if GoL = 47 then
			temp := -2
		else
			GoL := 0;
	repeat
		go := false;
		case GoL of
      -47 : if YL - 47 <= PSY[TNext^.YPos,3]-1 then go := true;
       47 : if YL + 47 >= PSY[TNext^.YPos,3]-1 then go  := true;
        0 : go := true;
    end;
    if not(go) then begin
      if (GetPixel(XL+1,YL+GoL) <> lightblue)
        or (GetPixel (XL-1,YL+GoL) <> lightblue) then begin
          Arc(XL+GoL,YL,90,270,2);
          Line(XL,YL+goL+temp,XL,yl);
      end
      else if GetPixel(XL,YL) = lightblue then
        Line(XL,YL+3,XL,YL+GoL)
      else
        line(XL,YL,xL,YL+goL);

      inc(YL,GoL);
    end;
  until go;
  OldY := YL;
  YL := PSY[TNext^.YPos,3]+1;
  Line(XL,OldY,XL,YL);
  OldX := XL;
  OldY := YL;
  Line(XL,YL,PSX[TNext^.XPos,1]+37,YL);
  OldX := PSX[TNext^.XPos,1]+37;
	Line(OldX,OldY,PSX[TNext^.XPos,1]+37,PSY[TNext^.YPos,3]+10);
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

function FDecisionNode.ConnectAll : boolean;
begin
  ConnectAll := False;
  if (FNextX <> 0) and (FNextY <> 0) and (FNextPage <> 0) then begin
    if (FNextX = 0) or (FNextY = 0) or (FNextPage = 0) then exit;  { Error occurred }
    FNext := FirstNode[FNextPage]^.Find(FNextX,FNextY);
    if FNext = nil then exit;  { Error occurred }
  end;
  ConnectAll := FNode.ConnectAll;
end;

constructor FInputNode.Init;
begin
  FNode.Init;
  NodeType := Input;
  Variable := nil;
end;

function FInputNode.SetNode(X,Y : word) : boolean;
Var
	temp : integer;
	VarOk,
	NodeOk,
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Variable',
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '');
  Hl : mtdarray = (
    (113,173,Ord('V'),0),
    (229,173,Ord('C'),0),
    (361,173,Ord('O'),0),
    (466,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
  if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
    if Variable <> nil then
      VarOk := true
    else
      VarOk := false;
    Finished := False;
		XPos := X;
		YPos := Y;
    MLimit(0,639-MW,0,349-MH);
		repeat
			temp := GetMenuItem(ButtonNames,hl,4,'Input');
			MouseCursorOff(Mx,My);
      case temp of
				1 : VarOK := GetVariable;
				2 : GetComment;
				3 : if VarOk then begin
							NodeOk := True;
							Finished := True;
						end;
				4 : begin
							NodeOk := False;
							Finished := True;
						end;
			end;
		until Finished;
	end
  else
    NodeOK := False;
	SetNode := NodeOK;
end;

procedure FInputNode.Copy(Node : PInputNode);
begin
  FNode.Copy(Node);
  Variable := Node^.Variable;
end;

procedure FInputNode.Show;
begin
	printxy(LXY[2,1]+12,LXY[2,2]+16,'INPUT NODE',yellow);
	FNode.Show;
end;

procedure FinputNode.Run;
var
  Result : integer;
begin
  case variable^.vartype of
    StrVar : readln(PStringVar(variable)^.value);
    NumVar : begin
               {$I-}
               repeat
   		           readln(PNumVar(variable)^.value);
                 Result := IOResult;
                 if Result <> 0 then writeln('Please type a number.');
               until Result = 0;
               {$I+}
             end;
  end;
  FNode.Run;
end;

function FInputNode.GetVariable : boolean;
Const
  Table : array[1..2] of String = ('String','Numeric');
  Y : byte = 0;
  X : byte = 0;
var
  VarName : string;
  VarType : integer;
  Cancel : boolean;
begin
  repeat
    GetFileType := 1;
			VarName := MGetFile('0','Variable Name',Cancel);
    GetFileType := 0;
    if not(Cancel) and TestName(VarName) then begin
      Variable := FirstVar^.Find(VarName,0);
      if Variable = nil then begin
        VarType := MouseQuestion(2,1,'New Variable Type',@table);
        case VarType of
          StrVar : Variable := new(PStringVar,Init);
          NumVar : Variable := new(PNumVar,Init);
        end;
        Variable^.SetVar(VarName,FirstVar);
      end;
    end;
  until TestName(VarName) or Cancel;
  if Cancel then
    GetVariable := false
  else
    GetVariable := True;
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

constructor FOutputNode.Init;
begin
  FEquationNode.Init;
  NodeType := Output;
  XCursor := 0;
  YCursor := 0;
  backcolour := 0;
  forecolour := 7;
end;

function FOutputNode.SetNode(X,Y : word) : boolean;

Var
	temp : integer;
  NodeOk,
  OutputOK,
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
		'Position',
		'Colour',
		'Output',
		'Comment',
		'Ok',
		'Cancel',
		'');
	Hl : mtdarray = (
		(24,173,Ord('P'),173),
		(151,173,Ord('l'),173),
		(246,173,Ord('u'),173),
		(337,173,Ord('C'),0),
		(460,173,Ord('O'),0),
		(555,173,Ord('a'),0),
		(0,0,255,0));

begin
  if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
		XPos := X;
		YPos := Y;
    GetMem(OutputsBackground,ImageSize(0,92,639,139));
    GetImage(0,92,639,139,OutputsBackground^);
    TopY := 92;
	  MLimit(0,639-MW,0,349-MH);
	  Finished := False;
    If Value <> nil then
      OutputOk := true
    else
      OutputOk := false;
		repeat
      boxit(0,TopY,639,139,white,'Outputs :');
      MoveTo(9,TopY+26);
      if Value <> nil then Value^.Show;              { Display outputs }
			temp := GetMenuItem(ButtonNames,hl,6,'Output Menu');
			if MOn then
        MouseCursorOff(Mx,My);
			case temp of
				1 : GetPosition;
				2 : GetColours;
				3 : OutputOk := GetStrValue;
				4 : GetComment;
				5 : if OutputOK then begin
							Finished := True;
							NodeOK := True;
						end
            else
              MouseMsg(200,200,'Enter all fields first!');
				6 : begin
							NodeOk := False;
							Finished := True;
						end;
			end;
		until Finished;
    PutImage(0,TopY,OutputsBackground^,NormalPut);
    Freemem(OutputsBackground,ImageSize(0,TopY,639,139));
	end
  else
    NodeOk := False;
	SetNode := NodeOK;
end;

procedure FOutputNode.GetPosition;
Var
	temp,OldRow,OldCol : integer;
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
		'Column',
		'Row',
		'Ok',
    'Cancel',
		'',
		'',
		'');
	Hl : mtdarray = (
		(121,173,Ord('C'),0),
		(245,173,Ord('R'),0),
		(361,173,Ord('O'),0),
    (465,173,Ord('a'),0),
		(0,0,255,0),
		(0,0,255,0),
		(0,0,255,0));

begin
	MLimit(0,639-MW,0,349-MH);
	Finished := False;
  OldRow := XCursor;
  OldCol := YCursor;
	repeat
		temp := GetMenuItem(ButtonNames,hl,4,'Cursor Position');
		if MOn then
      MouseCursorOff(Mx,My);
		case temp of
			1 : GetYCursor;
			2 : GetXCursor;
			3 : Finished := True;
      4 : begin
            XCursor := OldRow;
            YCursor := OldCol;
            Finished := True;
          end;
		end;
	until Finished;
end;

procedure FOutputNode.GetXcursor;
var
  Background : pointer;
  temp : string;
  go : boolean;
  Row,
  Code : integer;
const
  CancelBox : array[1..1,1..4] of integer = ((213,226,155,172));
begin
  Button := NewButton;
  GetMem(Background,ImageSize(213,155,427,195));
  GetImage(213,155,427,195,Background^);
  temp := '';
  repeat
    go := false;
    boxit(213,155,427,195,white,'Row');
    PrintXY(213+9,174,'Row cursor location > ',yellow);
    SetColor(lightgray);
    InputIt(394,174,temp,2,@CancelBox);
    if temp = '' then temp := #27;
    if temp <> #27 then begin
      val(Temp,Row,Code);
      if (Row < 0) or (Row > 25) or (Code <> 0) then
        MouseMsg(200,200,'Invalid row!')
      else
        go := true;
    end
    else
      go := true;
    If Mon then MouseCursorOff(Mx,My);
  until go;
  PutImage(213,155,Background^,NormalPut);
  Freemem(Background,ImageSize(213,155,427,195));
  if temp <> #27 then
    XCursor := Row;
end;

procedure FOutputNode.GetYCursor;
var
  Background : pointer;
  temp : string;
  go : boolean;
  Col,
  Code : integer;
const
  CancelBox : array[1..1,1..4] of integer = ((201,214,155,172));
begin
  Button := NewButton;
  GetMem(Background,ImageSize(201,155,439,195));
  GetImage(201,155,439,195,Background^);
  temp := '';
  PrintXY(210+9,174,'Column cursor location > ',yellow);
  repeat
    go := false;
    boxit(201,155,439,195,white,'Column');
    PrintXY(210,174,'Column cursor location > ',yellow);
    SetColor(lightgray);
    InputIt(406,174,temp,2,@CancelBox);
    if temp <> #27 then begin
      val(Temp,Col,Code);
      if (Col < 0) or (Col > 80) or (Code <> 0) then
        MouseMsg(200,200,'Invalid column!')
      else
        go := True;
    end
    else
      go := true;
    If Mon then MouseCursorOff(Mx,My);
  until go;
  PutImage(201,155,Background^,NormalPut);
  Freemem(Background,ImageSize(201,155,439,195));
  if temp <> #27 then
    YCursor := Col;
end;

procedure FOutputNode.GetColours;
Var
	temp,OldBack,OldFore : integer;
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
		'Background',
		'Foreground',
		'Ok',
		'Cancel',
		'',
		'',
		'');
	Hl : mtdarray = (
		(105,173,Ord('B'),0),
		(217,173,Ord('F'),0),
		(361,173,Ord('O'),0),
    (465,173,Ord('a'),0),
		(0,0,255,0),
		(0,0,255,0),
		(0,0,255,0));

  Backtable : array[1..8] of string = (
    'Black',
    'Blue',
    'Green',
    'Cyan',
    'Red',
    'Magenta',
    'Brown',
    'Light Gray');

  Foretable : array[1..16] of string = (
    'Black',
    'Blue',
    'Green',
    'Cyan',
    'Red',
    'Magenta',
    'Brown',
    'Light Gray',
    'Dark Gray',
    'Light Blue',
    'Light Green',
    'Light Cyan',
    'Light Red',
    'Light Magenta',
    'Yellow',
    'White');

begin
	MLimit(0,639-MW,0,349-MH);
	Finished := False;
  OldBack := BackColour;
  OldFore := ForeColour;
	repeat
		temp := GetMenuItem(ButtonNames,hl,4,'Colours');
		if MOn then
      MouseCursorOff(Mx,My);
		case temp of
			1 : backcolour := MouseQuestion(8,1,'Background Colour',@backtable)-1;
			2 : forecolour := MouseQuestion(16,1,'Foreground Colour',@foretable)-1;
			3 : Finished := true;
      4 : begin
            backcolour := oldback;
            forecolour := oldfore;
            Finished := true;
          end;
		end;
	until Finished;
end;

procedure FOutputNode.Copy(Node : POutputNode);
begin
  FEquationNode.Copy(Node);
  XCursor := Node^.XCursor;
  YCursor := Node^.YCursor;
  BackColour := Node^.BackColour;
  ForeColour := Node^.ForeColour;
end;

procedure FOutputNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'OUTPUT NODE',yellow);
	FNode.Show;
end;

procedure FOutputNode.Run;
var x,y:integer;
tempterm : pterm;
begin
  textcolor(forecolour);
  textbackground(backcolour);
  if xcursor = 0 then
    x := whereX
  else
    x := xcursor;
  if ycursor = 0 then
    y := whereY
  else
    Y := ycursor;
  gotoxy(x,y);
  tempterm := Value;
  repeat
    case tempterm^.term^.vartype of
      StrVar : write (pstringvar(tempterm^.term)^.value);
      NumVar : write (pnumvar(tempterm^.term)^.value);
      TabVar : gotoxy(wherex+ptabvar(tempterm^.term)^.tabwidth,wherey);
      NLVar : writeln;
    end;
    tempterm := tempterm^.next;
  until tempterm = nil;
  FNode.Run;
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

constructor FControlNode.Init;
begin
  FNode.Init;
  NodeType := Control;
  OutNode := nil;
  Identifier := 0;
  OutNodeX := 0;
  OutNodeY := 0;
  OutNodePage := 0;
end;

function FControlNode.SetNode(X,Y : word) : boolean;
Var
  temp : integer;
  NodeOk,
  PageOk,
  Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Page',
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '');
  Hl : mtdarray = (
    (129,173,Ord('P'),0),
    (229,173,Ord('C'),0),
    (361,173,Ord('O'),0),
    (465,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin

  if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
    XPos := X;
    YPos := Y;
    MLimit(0,639-MW,0,349-MH);
    Finished := False;
    PageOK := True;
    OutNodePage := Page;
    NodeOK := GetIdentifier;
    if NodeOK then
      repeat
        temp := GetMenuItem(ButtonNames,hl,4,'Control : In');
        MouseCursorOff(Mx,My);
        case temp of
          1 : PageOK := GetOutPage;
          2 : GetComment;
          3 : begin
                NodeOk := True;
                Finished := True;
              end;
          4 : begin
                NodeOk := False;
                Finished := True;
              end;
        end;
      until Finished;
    if NodeOK then NodeOK := GetOutLoc;
    OutNodePage := 0;
  end
  else
    NodeOK := False;
  SetNode := NodeOK;
end;

function FControlNode.ChangeNode(X,Y : word) : boolean;
Var
  temp : integer;
  NodeOk,
  Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '',
    '');
  Hl : mtdarray = (
    (173,173,Ord('C'),0),
    (305,173,Ord('O'),0),
    (409,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
  if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
    XPos := X;
    YPos := Y;
    MLimit(0,639-MW,0,349-MH);
    Finished := False;
    repeat
      temp := GetMenuItem(ButtonNames,hl,3,'Control : In');
      MouseCursorOff(Mx,My);
      case temp of
        1 : GetComment;
        2 : begin
              NodeOk := True;
              Finished := True;
            end;
        3 : begin
              NodeOk := False;
              Finished := True;
            end;
      end;
    until Finished;
  end
  else
    NodeOK := False;
  ChangeNode := NodeOK;
end;

function FControlNode.GetOutPage : boolean;
var
  NewPage : string;
  Dummy : integer;
  OldPage : 1..200;
  Cancel : boolean;
begin
  OldPage := OutNodePage;
  GetFileType := 2;
  NewPageRequest := True;
  NewPage := MGetFile('0','Page',Cancel);
  NewPageRequest := False;
  GetFileType := 0;
  if not(Cancel) then
    if NewPage = 'New Page' then begin
      OutNodePage := MaxPage + 1;
      MaxPage := OutNodePage;
    end
    else
      val(NewPage,OutNodePage,Dummy);
  if (OldPage <> OutNodePage) and (FirstNode[OldPage] = nil) then begin
    DeletePage(OldPage);
    if OutNodePage > MaxPage then OutNodePage := MaxPage;
  end;
end;

function FControlNode.GetOutLoc : boolean;
var
  x,y : integer;
  Node : PNode;
  LocOK : boolean;
begin
  MouseCursorOff(NewX,NewY);
  MLimit(unt,640-unt,unt div 2,349-(unt div 2));
  MPut(PsX[XPos,1]+unt+10,PsY[YPos,3]+(unt div 2)+10);
  Page := OutNodePage;
  PageCheck;
  Delay(200);
  MStatus(Button,Mx,My);
  GetImage(Mx-unt,My-(unt div 2),Mx+unt-1,My+(unt div 2),
  SymbBack[ControlOut]^);
  DrawSymbol(Mx-unt,My-(unt div 2),ControlOut,0);
  repeat                           { Move symbol }
    repeat
      MStatus(NewButton,NewX,NewY);
    until (Button<>NewButton) or (Mx<>NewX) or (My<>NewY);
    if button=NewButton then begin
      putimage(Mx-unt,My-(unt div 2),SymbBack[ControlOut]^,Normalput);
      Mx := NewX;
      My := NewY;
      GetImage(Mx-unt,My-(unt div 2),Mx+unt-1,My+(unt div 2),
      SymbBack[ControlOut]^);
      DrawSymbol(Mx-unt,My-(unt div 2),ControlOut,0);
    end;
  until newButton > 0;        { until button is pressed }
  Button := NewButton;
  repeat                      { keep moving symbol }
    repeat
      MStatus(NewButton,NewX,NewY);
    until (Button<>NewButton) or (Mx<>NewX) or (My<>NewY);
    if button=NewButton then begin
      putimage(Mx-unt,My-(unt div 2),SymbBack[ControlOut]^,Normalput);
      Mx := NewX;
      My := NewY;
      GetImage(Mx-unt,My-(unt div 2),Mx+unt-1,My+(unt div 2),
      SymbBack[ControlOut]^);
      DrawSymbol(Mx-unt,My-(unt div 2),ControlOut,0);
    end;
  until NewButton = 0;          { until button is released }
  Button := NewButton;
  LocOK := PlaceSymbol(ControlOut);   { attempt to create new node }
  setsymbols;
  if ViewOn then ViewBox;
  MLimit(0,639-MW,0,349-MH);
  if LocOK = True then begin
    X := MouseLocate(Mx,My,6,@PsX);
    Y := MouseLocate(Mx,My,5,@PsY);
    Node := FirstNode[Page]^.Find(X,Y);     { return pointer to new node }
    OutNode := PControlOutNode(Node);       { set pointer to OutNode }
    PControlOutNode(Node)^.InNode := @Self; { set pointer to InNode }
  end;
  GetOutLoc := LocOK;
  if FirstNode[Page] = nil then DeletePage(Page);
end;

function FControlNode.GetIdentifier : boolean;
begin
  if MaxId = 200 then begin
    mousemsg(200,200,'Too many control nodes.');
    GetIdentifier := False;
  end
  else begin
    Identifier := MaxId;
    MaxId := MaxId + 1;
    GetIdentifier := True;
  end;
end;

procedure FControlNode.Copy(Node : PControlNode);
begin
  FNode.Copy(Node);
  OutNode := Node^.OutNode;
  Identifier := Node^.Identifier;
end;

procedure FControlNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'CONTROL NODE #'+ItoS(Identifier)+' : In',
	  yellow);
	FNode.Show;
end;

procedure FControlNode.Draw;
begin
  DrawNode(XPos,YPos,NodeType,Identifier);
end;

procedure FControlNode.Run;
begin
  OutNode^.Run;
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

function FControlNode.ConnectAll : boolean;
begin
  ConnectAll := False;
  if (OutNodeX <> 0) and (OutNodeY <> 0) and (OutNodePage <> 0) then begin
    if (OutNodeX = 0) or (OutNodeY = 0) or (OutNodePage = 0) then exit;
    OutNode := PControlOutNode(FirstNode[OutNodePage]^.
      Find(OutNodeX,OutNodeY));                        { Find Out node }
    if OutNode = nil then
      exit     { error occurred }
    else
      OutNode^.InNode := @Self;
  end;
  ConnectAll := FNode.ConnectAll;
end;

destructor FControlNode.Delete;
{ Delete node from list }
var
  Temp : PNode;
  P : byte;
begin
  for P := 1 to MaxPage do begin  { Check all pages }
    Temp := FirstNode[P];
    repeat               { decrement identifiers of all other control nodes }
      while (Temp^.NodeType <> Control) and (Temp^.Next <> nil) do
        Temp := Temp^.Next;
      if (Temp^.NodeType = Control) and
         (PControlNode(Temp)^.Identifier > Identifier) then
        dec(PControlNode(Temp)^.Identifier);  { Decrement Identifier }
      if Temp^.Next <> nil then Temp := Temp^.Next;
    until Temp^.Next = nil;
  end;
  MaxId := MaxId - 1;                         { decrement MaxId }
  FNode.Delete;
  if OutNode <> nil then begin                { dispose of Control Out node }
    OutNode^.InNode := nil;
    dispose(OutNode,Delete);
  end;
end;

constructor FStartNode.Init;
begin
  FNode.Init;
  NodeType := Start;
end;

function FStartNode.ChangeNode(X,Y : word) : boolean;
Var
	temp : integer;
	NodeOk,
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '',
    '');
  Hl : mtdarray = (
    (173,173,Ord('C'),0),
    (305,173,Ord('O'),0),
    (409,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
	if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
		XPos := X;
		YPos := Y;
	  MLimit(0,639-MW,0,349-MH);
	  Finished := False;
    repeat
			temp := GetMenuItem(ButtonNames,hl,3,'Start');
			MouseCursorOff(Mx,My);
      case temp of
				1 : GetComment;
				2 : begin
							NodeOk := True;
							Finished := True;
						end;
				3 : begin
							NodeOk := False;
							Finished := True;
						end;
			end;
		until Finished;
	end
	else
		NodeOK := False;
	ChangeNode := NodeOK;
end;

procedure FStartNode.Show;
begin
	printXY(LXY[2,1]+12,LXY[2,2]+16,'START NODE',yellow);
	FNode.Show;
end;

constructor FControlOutNode.Init;
begin
  FNode.Init;
  NodeType := ControlOut;
  InNode := nil;
end;

function FControlOutNode.ChangeNode(X,Y : word) : boolean;
Var
	temp : integer;
	NodeOk,
	Finished : Boolean;

const
  ButtonNames : MnuArray = (
    'Comment',
    'Ok',
    'Cancel',
    '',
    '',
    '',
    '');
  Hl : mtdarray = (
    (173,173,Ord('C'),0),
    (305,173,Ord('O'),0),
    (409,173,Ord('a'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
  if ((X = XPos) and (Y = YPos)) or
     (FirstNode[Page]^.Find(X,Y) = nil) then begin
    XPos := X;
    YPos := Y;
    MLimit(0,639-MW,0,349-MH);
    Finished := False;
    repeat
      temp := GetMenuItem(ButtonNames,hl,3,'Control : Out');
      MouseCursorOff(Mx,My);
      case temp of
        1 : GetComment;
        2 : begin
              NodeOk := True;
              Finished := True;
            end;
        3 : begin
              NodeOk := False;
              Finished := True;
            end;
      end;
    until Finished;
  end
  else
    NodeOK := False;
  ChangeNode := NodeOK;
end;

procedure FControlOutNode.Copy(Node : PControlOutNode);
begin
  FNode.Copy(Node);
  InNode := Node^.InNode;
end;

procedure FControlOutNode.Show;
begin
  printXY(LXY[2,1]+12,LXY[2,2]+16,'CONTROL NODE #'+ItoS(InNode^.Identifier)+
    ' : Out',yellow);
  FNode.Show;
end;

procedure FControlOutNode.Draw;
begin
  DrawNode(XPos,YPos,NodeType,InNode^.Identifier);
end;

destructor FControlOutNode.Delete;
{ Delete node from list }
begin
  FNode.Delete;
  if InNode <> nil then begin  { dispose of Control In node }
    InNode^.OutNode := nil;
    dispose(InNode,Delete);
  end;
end;

end. {Unit OOP}
