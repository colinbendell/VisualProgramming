unit Misc;

{$O+}
{$F+}

interface

function TestName(S : string) : boolean;
function NewNode(NodeType : integer; X,Y : word) : boolean;
procedure FileAreaCursor;
procedure SymbolAreaCursor;
function PlaceSymbol(symbnum : integer) : boolean;
procedure MoveNode(GridX,GridY : word);
procedure MoveSymbol;
procedure PageIcon;
procedure TurnPage(Dir : boolean);
procedure DeletePage(P : byte);
procedure FileArea;

implementation

uses
  Crt,Dos,Graph,OOP,Mouse,MouseRs2,Util,Variable,Menu;

function TestName(S : string) : boolean;
{ test a variable name to see if valid }
var
  i : integer;
begin
  TestName := True;  { set test to true }
  if (length(S) < 1) or (length(S) > 12) then TestName := False;
            { if longer or shorter than it should be, abort }
  if   (((S[1] < 'a') or (S[1] > 'z')) { if first char not valid }
    and ((S[1] < 'A') or (S[1] > 'Z'))) then
      TestName := False;               { abort test }
  for i:=2 to length(S) do             { test the rest }
    if    ((S[i] < '0') or (S[i] > '9')) { if not valid }
      and ((S[i] < 'A') or (S[i] > 'Z'))
      and ((S[i] < 'a') or (S[i] > 'z'))
      and  (S[i] <> '_') then
        TestName := False;  { abort }
end;  { of function TestName }

function NewNode(NodeType : integer; X,Y : word) : boolean;
{ create a new node }
const
  NNode : PNode = nil;
  NodeOK : boolean = False;
begin
  case NodeType of { create the apropriate node }
    1 : NNode := new(PStopNode,Init);
    2 : NNode := new(PAssignmentNode,Init);
    3 : NNode := new(PDecisionNode,Init);
    4 : NNode := new(PInputNode,Init);
    5 : NNode := new(POutputNode,Init);
    6 : NNode := new(PControlNode,Init);
    8 : NNode := new(PControlOutNode,Init);
  end;
  if FirstNode[Page] = nil then { if first on page }
    FirstNode[Page] := NNode { set firstnode }
  else                          { otherwise }
    FirstNode[Page]^.Add(NNode); { tack on to end of list }
  NodeOK := NNode^.SetNode(X,Y); { set the node }
  if NodeOK = False then { check to see if canceled }
    dispose(NNode,Delete); {if so delete it from list }
  NewNode := NodeOK;
end;

procedure FileAreaCursor;
{ place appropriate mouse cursor on screen }
var
  GridX,GridY,MouseStart,i : integer;
  SNode : PNode;
  SType : integer;
  FMt : array [1..3,1..4] of integer;
begin
  If Mon then MouseCursorOff(Mx,My); { mouse cursor on, turn off }
  GridX := MouseLocate(NewX,NewY,6,@PsX); { find out where on grid }
  GridY := MouseLocate(NewX,NewY,5,@PsY); { the mouse is }
	if ViewOn and ViewVis and ((GridX = 0) or (GridY = 0)) then begin
    { if out of grid, clear the view box }
    OldGridX := 0;
    OldGridY := 0;
    clear(LXY[2,1]+2,LXY[2,2]+14,LXY[1,1]+442,LXY[1,2]+242,lightblue);
  end;
  if (NewX > LXY[1,1]+18) and (NewX < LXY[1,1]+411) and
     (NewY < LXY[1,2]+14) then
     { if Mouse cursor on the space on the top bar }
    MouseCursorOn(NewX,NewY,Hand) { show a hand }
  else { otherwise }
    if (NewX in [LXY[2,1]..LXY[2,1]+18]) and
	     (NewY in [LXY[2,2]..LXY[2,2]+14]) then
       { if mouse cursor on top of view box }
	    MouseCursorOn(NewX,NewY,Arrow) { show arrow }
    else begin { otherwise }
      FMt[1,1] := PSX[GridX,1]+3;           { Left Box }
      FMt[1,2] := PSX[GridX,1]+21;          { init variables }
      FMt[1,3] := PSY[GridY,3]+12;
      FMt[1,4] := PSY[GridY,3]+21;
      FMt[2,1] := PSX[GridX,1]+55;          { Right Box }
      FMt[2,2] := PSX[GridX,1]+73;
      FMt[2,3] := PSY[GridY,3]+12;
      FMt[2,4] := PSY[GridY,3]+21;
      FMt[3,1] := PSX[GridX,1]+29;          { Bottom Box }
      FMt[3,2] := PSX[GridX,1]+47;
      FMt[3,3] := PSY[GridY,3]+29;
	    FMt[3,4] := PSY[GridY,3]+38;
	    MouseStart := MouseLocate(Newx,Newy,3,@Fmt);
        { see in what section on the grid it is }
	    SNode := FirstNode[Page]^.Find(GridX,GridY);
      { get pointer to symbol is on grid square? }
	    SType := SNode^.NodeType;               { get type of symbol }
			if ViewOn and ViewVis and               { if viewBox visible }
				 ((OldGridX <> GridX) or (OldGridY <> GridY)) then begin
				OldGridX := GridX;
				OldGridY := GridY;
		    clear(LXY[2,1]+2,LXY[2,2]+14,LXY[1,1]+442,LXY[1,2]+242,
          lightblue);
        { clear box }
		    if SNode <> nil then
			    SNode^.Show; { show comment }
	    end;
	    if SNode <> nil then { if something on grid square }
		    case SType of { put proper mouse cursor on }
			    decision : case MouseStart of
									     1 : MouseCursorOn(NewX,NewY,LArrow);
									     2 : MouseCursorOn(NewX,NewY,RArrow);
									     else MouseCursorOn(NewX,NewY,Compass);
								     end;
			    stop,control : MouseCursorOn(NewX,NewY,Compass);
			    else case MouseStart of
						     3 : MouseCursorOn(NewX,NewY,DArrow);
						     else MouseCursorOn(NewX,NewY,Compass);
					     end;
		    end
	    else
		    MouseCursorOn(NewX,NewY,Arrow);
    end;
end;

procedure SymbolAreaCursor;
{ show what type of symbol the mouse cursor is on in the symbols box }
var
  symbs : array[1..6,1..4] of integer;
  Symbol : 0..6;
begin
  for i := 1 to 6 do begin { set variables }
    symbs[i,1] := LXY[i+3,1];
    symbs[i,2] := LXY[i+3,1] + (2 * unt)-1;
    symbs[i,3] := LXY[i+3,2];
    symbs[i,4] := LXY[i+3,2] + unt-1;
  end;
  Symbol := MouseLocate(NewX,NewY,6,@symbs);  { where is mouse }
  if ViewOn and ViewVis and (Symbol <> OldSymbol) then begin
    { show the appropriate symbol }
    clear(LXY[2,1]+2,LXY[2,2]+14,LXY[1,1]+442,LXY[1,2]+242,lightblue);
    OldSymbol := Symbol;
    if Symbol <> 0 then begin
      case Symbol of
        1 : printXY(LXY[2,1]+12,LXY[2,2]+16,'STOP NODE',yellow);
        2 : printXY(LXY[2,1]+12,LXY[2,2]+16,'ASSIGNMENT NODE',yellow);
        3 : printXY(LXY[2,1]+12,LXY[2,2]+16,'DECISION NODE',yellow);
        4 : printxy(LXY[2,1]+12,LXY[2,2]+16,'INPUT NODE',yellow);
        5 : printXY(LXY[2,1]+12,LXY[2,2]+16,'OUTPUT NODE',yellow);
        6 : printXY(LXY[2,1]+12,LXY[2,2]+16,'CONTROL NODE',yellow);
      end;
    end;
  end;
  if Symbol = 0 then { if mouse cursor not on symbol }
    MouseCursorOn(NewX,NewY,Hand) { display hand }
  else                            { otherwise }
    MouseCursorOn(NewX,NewY,Compass); { display compass }
end;

function PlaceSymbol(symbnum : integer) : boolean;
{ place the symbol on file area grid }
var
  GridX,GridY,x,y : integer;
begin
  NewX := Mx;
  NewY := My;
  GridX := MouseLocate(Mx,My,6,@PsX);
  GridY := MouseLocate(Mx,My,5,@PsY);
  X := PsX[GridX,1] + 10;
  Y := PsY[GridY,3] + 10;
  If (GridX = 0) or (GridY = 0) then begin
    PutImage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,NormalPut);
    PlaceSymbol := False;
  end
  else begin
    PutImage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,NormalPut);
    clear(X,Y,X+(2*unt)-1,Y+unt-1,lightblue);
		PlaceSymbol := NewNode(SymbNum,GridX,GridY);
    PageCheck;
  end;
end;

procedure MoveNode(GridX,GridY : word);
var
  MoveOK : boolean;
  Node,BackupNode : PNode;
  x,y,
  symbnum : integer;
  NewGridX,NewGridY : integer;
begin
  Node := FirstNode[Page]^.Find(GridX,GridY);
  if Node <> nil then begin
    if ViewOn then ClearViewBox;
    symbnum := Node^.NodeType;
    if symbnum <> Start then begin
      MouseCursorOff(NewX,Newy);
      Button := NewButton;
      MLimit(unt,640-unt,unt div 2,349-(unt div 2));
      MPut(PsX[GridX,1]+unt+10,PsY[GridY,3]+(unt div 2)+10);
      NewX := Mx;
      NewY := My;
      repeat
        repeat
          MStatus(NewButton,NewX,NewY);
        until (Button<>NewButton) or (Mx<>NewX) or (My<>NewY);
        if (Mx <> NewX) or (My <> NewY) then begin
          putimage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,Normalput);
          Mx := NewX;
          My := NewY;
          GetImage(Mx-unt,My-(unt div 2),Mx+unt-1,My+(unt div 2),
            SymbBack[symbnum]^);
          DrawSymbol(Mx-unt,My-(unt div 2),symbnum,0);
        end;
      until newButton=0;
      Mx := NewX;
      My := NewY;
      NewGridX := MouseLocate(Mx,My,6,@PsX);
      NewGridY := MouseLocate(Mx,My,5,@PsY);
      X := PsX[NewGridX,1] + 10;
      Y := PsY[NewGridY,3] + 10;
      If (NewGridX = 0) or (NewGridY = 0) then begin
        PutImage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,NormalPut);
        dispose(Node,Delete);
      end
      else begin
        PutImage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,NormalPut);
        clear(X,Y,X+(2*unt)-1,Y+unt-1,lightblue);
        MLimit(0,639-MW,0,349-MH);
        case symbnum of
          Stop       : BackupNode := new(PStopNode,Init);
          Assignment : BackupNode := new(PAssignmentNode,Init);
          Decision   : BackupNode := new(PDecisionNode,Init);
          Input      : BackupNode := new(PInputNode,Init);
          Output     : BackupNode := new(POutputNode,Init);
          Control    : BackupNode := new(PControlNode,Init);
          ControlOut : BackupNode := new(PControlOutNode,Init);
        end;
        BackupNode^.Copy(Node);
        MoveOK := Node^.ChangeNode(NewGridX,NewGridY);
        if MoveOK = False then Node^.Copy(BackupNode);
        dispose(BackupNode,Done);
	    end;
      setsymbols;
      PageCheck;
		  MLimit(0,639-MW,0,349-MH);
    end
    else begin
      BackupNode := new(PStartNode,Init);
      BackupNode^.Copy(Node);
      MoveOK := Node^.ChangeNode(GridX,GridY);
      if MoveOK = False then Node^.Copy(BackupNode);
      dispose(BackupNode,Done);
    end;
    if ViewOn then ViewBox;
    FileAreaCursor;
  end;
end;

procedure MoveSymbol;
var
  symbs : array[1..6,1..4] of integer;
  i,symbnum,x,y : integer;
begin
  for i := 1 to 6 do begin
    symbs[i,1] := LXY[i+3,1];
    symbs[i,2] := LXY[i+3,1] + (2 * unt)-1;
    symbs[i,3] := LXY[i+3,2];
    symbs[i,4] := LXY[i+3,2] + unt-1;
  end;
  if MouseLocate(NewX,NewY,6,@symbs) <> 0 then begin;
    symbnum := MouseLocate(NewX,NewY,6,@symbs);
    MouseCursorOff(NewX,Newy);
    if ViewOn then ClearViewBox;
    Button := NewButton;
    MLimit(unt,640-unt,unt div 2,349-(unt div 2));
    MPut(symbs[symbnum,1]+unt,symbs[symbnum,3]+(unt div 2));
    NewX := Mx;
    NewY := My;
    repeat
      repeat
        MStatus(NewButton,NewX,NewY);
      until (Button<>NewButton) or (Mx<>NewX) or (My<>NewY);
      if (Mx <> NewX) or (My <> NewY) then begin
        putimage(Mx-unt,My-(unt div 2),SymbBack[symbnum]^,Normalput);
        Mx := NewX;
        My := NewY;
        GetImage(Mx-unt,My-(unt div 2),Mx+unt-1,My+(unt div 2),
          SymbBack[symbnum]^);
        DrawSymbol(Mx-unt,My-(unt div 2),symbnum,0);
      end;
    until newButton=0;
    Dummy := PlaceSymbol(symbnum);
    setsymbols;
		if ViewOn then ViewBox;
    MLimit(0,639-MW,0,349-MH);
    MouseCursorOn(Mx,My,Arrow);
		FileAreaCursor;
	end;
end;

procedure PageIcon;
var
  NewPage : string;
  Dummy : integer;
  Cancel : boolean;
begin
  if MaxPage <> 1 then begin
    GetFileType := 2;
    NewPage := MGetFile('0','Page',Cancel);
    if not(Cancel) then
      val(NewPage,Page,Dummy);
    PageCheck;
  end;
end;

procedure TurnPage(Dir : boolean);
var
  NewPage : integer;
begin
  case Dir of
    True : NewPage := Page - 1;
    False : NewPage := Page + 1;
  end;
  if NewPage in [1..MaxPage] then begin
    Page := NewPage;
    PageCheck;
  end;
end;

procedure DeletePage(P : byte);
var
  i : byte;
begin
  for i := P+1 to MaxPage do
    FirstNode[i-1] := FirstNode[i];
  FirstNode[P] := nil;
  MaxPage := MaxPage - 1;
  if Page > MaxPage then Page := MaxPage;
end;

procedure FileArea;
{ find out what symbol to connect to }
var
  GridX,GridY,NewGridX,NewGridY,MouseStart : integer;
  FMt : array[1..3,1..4] of integer;
  SNode,ENode : PNode;
  SType : integer;
begin
  MouseCursorOff(Mx,My); { turn mouse off }
  if (Mx > LXY[2,1]) and { is mouse cursor on top corner of view box }
     (Mx < LXY[2,1]+18) and
     (My > LXY[2,2]) and
     (My < LXY[2,2]+14) then
    If ViewOn then begin { if view box on, turn off }
      ClearViewBox;
      ViewOn := False;
    end                  { otherwise }
    else begin           { turn viewbox on }
      ViewOn := True;
      ViewBox;
    end
  else       { if not on corner }
    if (Mx > LXY[1,1]+410) and (My < LXY[1,2]+14) then
      { if top bar clicked on }
      case Mx-LXY[1,1] of
        411..421 : PageIcon; { page icon }
        424..430 : TurnPage(True); { turn page down }
        437..443 : TurnPage(False); { turn page up }
      end
    else
      if (Mx < LXY[1,1]+18) and (My < LXY[1,2]+14) then
      { if on top corner of viewbox }
        NewFile; { reset programme }
  GridX := MouseLocate(Mx,My,6,@PsX); { set variables }
  GridY := MouseLocate(Mx,My,5,@PsY);
	FMt[1,1] := PSX[GridX,1]+3;                   { Left box }
	FMt[1,2] := PSX[GridX,1]+21;
	FMt[1,3] := PSY[GridY,3]+12;
	FMt[1,4] := PSY[GridY,3]+21;
	FMt[2,1] := PSX[GridX,1]+55;                  { Right box }
	FMt[2,2] := PSX[GridX,1]+73;
	FMt[2,3] := PSY[GridY,3]+12;
	FMt[2,4] := PSY[GridY,3]+21;
	FMt[3,1] := PSX[GridX,1]+29;                  { Bottom box }
	FMt[3,2] := PSX[GridX,1]+47;
  FMt[3,3] := PSY[GridY,3]+29;
  FMt[3,4] := PSY[GridY,3]+38;
  MouseStart := MouseLocate(Mx,My,3,@Fmt);  { find out where clicked }
	SNode := FirstNode[Page]^.Find(GridX,GridY); { get pointer }
  if SNode <> nil then begin { it not clicked on nothing }
    SType := SNode^.NodeType; { find out what type }
		If ((SType = decision) and ((MouseStart = 1 ) or (MouseStart = 2))) or
			 ((Stype in [Assignment,Input,Output,Start,ControlOut])
				 and (MouseStart = 3)) then begin
			if ViewOn then ClearViewBox; { turn view box off }
			MouseCursorOn(Mx,My,XCursor); { mouse cursor on with the 'X' }
			repeat                        { repeat until clicked again }
				MStatus(NewButton,NewX,NewY);
				If (NewX<>Mx) Or (NewY<>My) Then         { if mouse has moved }
					MouseCursor(NewX,NewY,Mx,My,XCursor);
				Mx := NewX;
				My := NewY;
			until NewButton = 0;
			Button := NewButton; { set variables }
			NewGridX := MouseLocate(Mx,My,6,@PsX);
			NewGridY := MouseLocate(Mx,My,5,@Psy);
			ENode := FirstNode[Page]^.Find(NewGridX,NewGridY);
			if (ENode <> nil) and (Enode <> SNode) then { connect to node }
				if MouseStart = 2 then
					Snode^.ConnectTo(Enode,False)
				else
					SNode^.ConnectTo(ENode,true);
      PageCheck; { redraw screed }
			If ViewOn then ViewBox; { turn viewbox on }
		end
		else
			MoveNode(GridX,GridY); { otherwise move the node }
	end
	else MouseCursorOn(Mx,My,Arrow); { mouse cursor on }
end;

end. {Unit Misc}
