unit Menu;

{$O+}
{$F+}

interface

uses Variable,Dos;

procedure ResetPulldowns;
function GetMenuItem(select:MnuArray; hl:MtdArray; num:integer;
  heading:string) : integer;
procedure hilightit(s,col:integer; t:mtptr);
procedure NewFile;
procedure SaveFile(Name : PathStr);
procedure LoadFile;
procedure ShowVariables;
procedure RunProgramme;
function FileMenu : integer;
function ProgramMenu : integer;
function quitmenu :integer;
procedure mainmenu;
function moveit(Num:integer) : integer;

implementation

uses
  Crt,Graph,OOP,Box,Convert,Mouse,MouseRS2,Util;

procedure ResetPulldowns;
{ redraw the menu bar }
begin
  SetTextJustify(0,2); { set text justify }
  setcolor(black);     { set color }
  outtextxy(32,17,' File    Program    Quit!  '); { print out in plain color }
  setcolor(red);
  outtextxy(32,17,' F'); { print out hilights in red }
  outtextxy(32+TextWidth(' File    '),17,'P'); {104}
  outtextxy(32+TextWidth(' File    Program    '),17,'Q'); {168}
  Mt[2,1] := 24;         { reset mouse areas for menu bar }
  Mt[2,2] := 31+TextWidth(' File  ');
  Mt[3,1] := 32+TextWidth(' File  ');
  mt[3,2] := 31+TextWidth(' File    Program  ');
  mt[4,1] := 32+TextWidth(' File    Program  ');
  mt[4,2] := 31+TextWidth(' File    Program    Quit!  ');
  mt[5,1] := 32+TextWidth(' File    Program    Options  ');

  { -- from here on no longer valid; not excluded because of lack of time -- }

  mt[5,2] := 31+TextWidth(' File    Program    Options    Display  ');
  mt[6,1] := 32+TextWidth(' File    Program    Options    Display  ');
  mt[6,2] := 31+TextWidth(' File    Program    Options    Display    Help  ');
end;  { of procedure ResetPulldowns }

function GetMenuItem(select:MnuArray; hl:MtdArray;
                      num:integer; heading:string) : integer;
{ General menu utility which creates a menu for almost any occasion }

var
  X1,Y1,X2,Y2,i,ii,s,olds : integer;
  GMt : array [1..8,1..4] of integer;
  cmd : char;
  go : boolean;

const
  MBackground : pointer = nil;

begin
  if Mon then MouseCursorOff(Mx,My); { turn mouse off }
  CenterXY(num*112+20,58,X1,x2,Y1,Y2); { center menu box }
  if num = 6 then CenterXY(num*104+20-6,58,X1,x2,Y1,Y2);{ make the exception }
  if ViewOn and ViewVis then ClearViewBox; { turn view box off }
  GetMem(MBackground,ImageSize(X1,Y1,X2,Y2)); { reserve background memory }
  GetImage(X1,Y1,X2,Y2,MBackground^); { get screen image }
  DimAll; { dim major boxes }
  Boxit(X1,Y1,X2,Y2,white,heading); { draw box }
  for i:= 1 to 7 do                               { set mouse variables }
    For ii := 1 to 4 do
      Gmt[i,ii] := 0;
  if Num <>6 then For i := 0 to num-1 do begin
    Gmt[i+1,1] := X1+18+(i*96)+(i*16);
    Gmt[i+1,2] := X1+18+(i*96)+96+(i*16);
  end
  else For i := 0 to num-1 do begin
    Gmt[i+1,1] := X1+18+(i*88)+(i*15);
    Gmt[i+1,2] := X1+18+(i*88)+88+(i*15);
  end;
  For i := 1 to num do begin
    Gmt[i,3] := Y1+24;
    Gmt[i,4] := Y1+42;
  end;
  Gmt[7,1] := x1;
  Gmt[7,2] := x1+17;
  Gmt[7,3] := y1;
  Gmt[7,4] := y1+14;
  ShadowBox(Gmt[1,1],Gmt[1,3],Gmt[1,2],true,select[1]);    { draw menu keys }
  For i := 2 to num do
    ShadowBox(Gmt[i,1],Gmt[i,3],Gmt[i,2],false,select[i]);
  Set_Hilights(@hl);                                       { draw hilights }
  MouseCursorOn(Mx,My,Arrow);  { mouse on }
  MStatus(NewButton,NewX,NewY);
  Button:=NewButton;
  Cmd:=#0;
  S:=1;
  Go:=false;
  Repeat
    cmd := MouseReadKey('',[Upcase(Chr(hl[1,3])),Upcase(Chr(hl[2,3])),
                            Upcase(Chr(hl[3,3])),Upcase(Chr(hl[4,3])),
                            Upcase(chr(hl[5,3])),Upcase(Chr(hl[6,3])),
                            Upcase(Chr(hl[7,3])),#75,#77,#27,#13]);
                          { wait until key or mouse pressed / clicked }
    If Mon then MouseCursorOff(Mx,My); { mouse off }
    if cmd = #0 then begin
      if s <> 0 then Olds := s;
      s:=mouseLocate(NewX,NewY,7,@Gmt);
      if s <> 0 then begin
        If Mon then MouseCursorOff(Mx,My); { mouse cursor off }
        { reset menu keys }
        ShadowBox(Gmt[olds,1],Gmt[olds,3],Gmt[olds,2],false,Select[olds]);
        Set_Hilights(@hl); { reset hilights }
        if s = 7 then s := num;
      end;
    end
    else begin
      { move menu botton according to key pressed }
      If Mon then MouseCursorOff(Mx,My);
      if s = 0 then s := olds;
      ShadowBox(Gmt[s,1],Gmt[s,3],Gmt[s,2],false,Select[s]);
      Set_Hilights(@hl);
      case cmd of
        #75:begin { left }
              dec(s);
              if s = 0 then s := num;
            end;
        #77:begin { right }
              inc(s);
              if s = num+1 then s := 1;
            end;
        #27:begin { esc }
              s := 12;
              cmd := #13;
            end;
        else begin  { find out what hot key was pressed }
               olds := s;
               s := 0;
               repeat
                 inc(s);
               until (upcase(chr(hl[s,3])) = upcase(cmd)) or (s = num+1);
               if s = num +1 then s := olds
               else cmd := #13;
             end;
      end;
		end;
    if s <> 0 then ShadowBox(Gmt[s,1],Gmt[s,3],Gmt[s,2],true,Select[s]);
    MouseCursorOn(Mx,My,Arrow); { mouse on }
    if (cmd = #0) or (cmd=#13) then begin   { if esc or enter hit }
      click;
      if s <> 0 then begin
        MouseCursorOff(Mx,My);
        UnShadowBox(Gmt[s,1],Gmt[s,3],Gmt[s,2],Select[s]);
        Set_Hilights(@hl);
        MouseCursorOn(Mx,My,Arrow);
        go := true;   { exit }
      end;
    end;
  until go;
  MouseCursorOff(Mx,My);
  BrightAll; { bright all the major boxes }
  PutImage(X1,Y1,MBackground^,NormalPut); { resotre screen }
  FreeMem(MBackground,ImageSize(X1,Y1,X2,Y2)); { free reserved memory }
  Mbackground := nil;
  if ViewOn and ViewVis then ViewBox;
  MouseCursorOn(Mx,My,Arrow);
  GetMenuItem := s; { return the key pressed }
end;

function moveit(Num:integer) : integer;
{ move the menu boxes, when they are opened }
var temp : integer;
begin
  repeat
		temp := Num;
		case temp of
      2 : Num := FileMenu + 1;
      3 : Num := ProgramMenu + 1;
			4 : Num := quitmenu + 1;
		end;
		ResetPullDowns; { reset hilights }
		If Num > 4 then Num := 2;
		If Num < 2 then Num := 4;
	until temp = Num; { until esc }
	moveit := num;
end;

procedure hilightit(s,col:integer; t:mtptr);
{ show which menu item is currently selected ( top menu ) }
var ss,col2:integer;
begin
  case col of { reverse colour }
    white:col2:=black;
    black:col2:=white;
  end;
  mouseCursorOff(Mx,My); { mouse cursor off }
  ResetPulldowns; { reset pull down menu }
  ss := s + 1;
  clear(t^[ss,1],t^[ss,3],t^[ss,2],t^[ss,4],col); { clear selected one }
  setcolor(col2);
  case ss of { write the text in hilighted one }
    2: outtextxy(32,17,' File');
    3: outtextxy(32+TextWidth(' File    '),17,'Program');
    4: outtextxy(32+TextWidth(' File    Program    '),17,'Quit!');
  end;
  BottomHelp(s,0);
  MouseCursorOn(Mx,My,Arrow);
end;

procedure setup_select(num:Integer; l:SelectPtr);
{ draw the menu for pull down menus }
var
  x1,y1,x2,y2,longest,hight,i,ii:Integer;
  Name:String;
begin
  { which one }
  case num of
    1:begin
        Longest := 14;
				Hight := 8;
				Name := 'File';
			end;
		2:begin
				Longest := 10;
				Hight := 5;
				Name := 'Program';
			end;
	end;
	{ draw menu }
	x1:=mt[num+1,1];
	y1:=mt[num+1,4]+1;
	x2:=x1+32+(8*longest);
	y2:=y1+(hight*14);
	clear(mt[num+1,1],mt[num+1,3],mt[num+1,2],mt[num+1,4],black);
  shadow(x1,y1,x2,y2);
  clear(x1,y1,x2,y2,white);
  setcolor(black);
  rectangle(x1,y1,x2,y2);
  rectangle(x1+1,y1+1,x2-1,y2-1);
  setcolor(white);
  { write all the selections and hilights and searating lines }
  case Name[1] of
    'F': begin { file  menu }
           outtextxy(32,18,' File');
           for i:=1 to Hight-2 do begin
             setcolor(black);
             if l^[i] <> '-' then
               outtextxy(35,y1+i*14+5,l^[i])
             else
               rectangle(x1+16,y1+i*14+7,x2-16,y1+i*14+7);
           end;
         end;
    'P': begin { programme menu }
           outtextxy(Mt[3,1],18,'  Program');
           for i:=1 to Hight-2 do begin
             setcolor(black);
             if l^[i] <> '-' then
               outtextxy(MT[3,1]+11,y1+i*14+5,l^[i])
             else
               rectangle(x1+16,y1+i*14+7,x2-16,y1+i*14+7);
           end;
         end;
  end;
end;

procedure selection(MenuNum,SelectNum : integer; Select : selectptr;
  On : Boolean);
  { hilight selection in the menu }
var
  x,y,lng : integer;
begin
  x := mt[MenuNum+1,1] + 11; { set variables }
  y := SelectNum * 14 + 33;
  case MenuNum of            { determine which menu }
    1 : lng := 119;
    2 : lng := 87;
  end;
  case on of                 { is this one selected? }
    True : begin             { yes, make background black }
             clear(x,y-3,x+lng,y+10,black);
             printxy(x,y,Select^[SelectNum],white);
             bottomhelp(MenuNum,SelectNum);
           end;
    False : begin            { no, make bakground normal (white) }
              clear(x,y-3,x+lng,y+10,white);
              printxy(x,y,Select^[SelectNum],black);
            end;
  end;
end;

procedure NewFile;
{ reset program }
var
	i : byte;
begin
	for i := 1 to MaxPage do  { delete all of the nodes }
		if FirstNode[i] <> nil then dispose(FirstNode[i],Done);
	dispose(FirstVar,Done);
  ProgramName := 'NONAME.FLO'; { reset variables }
	InitNodes;
  pagecheck;
end;

procedure LoadError;
 { Display error in loading a file }
begin
  MouseMsg(200,200,'Error loading flowchart.'); { display error }
  NewFile; { reset nodes that were loaded }
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

procedure SaveError;
{ display save error }
begin
  MouseMsg(200,200,'Error saving file.'); { display save error }
end;

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

procedure SaveFileAs;
{ save file as a different name }
var
  Name : PathStr;
  Cancel : boolean;
begin
  Name := MGetFile('*.FLO','Save File As...',Cancel); { get new name }
  if not(Cancel) then SaveFile(Name); { save file }
end;

procedure RunProgramme; { run programme }
begin
  MouseCursorOff(Mx,My); { mouse off }
  RestoreCRTMode; { go to text mode }
  FirstNode[1]^.Run;  { start run sequence }
  SetGraphMode(GetGraphMode); { go to graphics mode }
  DrawScreen; { redraw screen }
end;

procedure ShowVariables;
{ display the variables }
Var
  temp : integer;
  Cancel,
  Finished : Boolean;
  VarName : string;
const
  ButtonNames : MnuArray = (   { menu buttons }
    'String Var',
    'Numeric Var',
    'All Var',
    'OK',
    '',
    '',
    '');
  Hl : mtdarray = (       { hilights for buttons }
    (105,173,Ord('S'),0),
    (213,173,Ord('N'),0),
    (341,173,Ord('A'),0),
    (473,173,Ord('O'),0),
    (0,0,255,0),
    (0,0,255,0),
    (0,0,255,0));

begin
  if FirstVar^.Next = nil then begin { if mo variables, }
    MouseMsg(200,200,'No variables!'); { display message }
    exit;
  end;
  GetFileType := 1; { set variables }
  MLimit(0,639-MW,0,349-MH);
  Finished := False;
  repeat
    temp := GetMenuItem(ButtonNames,hl,4,'Variables'); { menu }
    if MOn then
      MouseCursorOff(Mx,My);
    case temp of { do menu options }
      1 : VarName := MGetFile('1','String Variables',Cancel); { show strings }
      2 : VarName := MGetFile('2','Numeric Variables',Cancel); { show nums }
      3 : VarName := MGetFile('0','Variables',Cancel); { show all }
      4 : Finished := true; { OK }
    end;
  until Finished;
  GetFileType := 0;
end;

function FileMenu : integer;
{ file menu }
var
  Cmd:Char;
  ff,OldS,S,ML:Integer;
  Go:Boolean;
	fileback:Pointer;
const
  select: array[1..6] of string = ( { selections }
    ' New',
    ' Load...',
    ' Save',
    ' Save As...',
    '-',
    ' Exit');

  hl:array[1..9,1..4] of Integer = (  { hilights }
    (35,47,Ord('N'),0),
    (35,61,Ord('L'),0),
    (35,75,Ord('S'),0),
    (75,89,Ord('A'),0),
    (0,349,0,0),
    (43,117,Ord('x'),0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0));

  fmt:array[1..6,1..4] of Integer = ( { file mouse areas }
    (35,123,44,57),
    (35,123,58,71),
    (35,123,72,85),
    (35,123,86,99),
    (0,0,0,0),
    (35,123,114,127));

begin
	MouseCursorOff(Mx,My);                       { setup menu }
	Getmem(fileback,Imagesize(19,14,176,204)); { save fileback }
	Getimage(19,14,176,204,fileback^);
  Setup_Select(1,@select);
  Set_Hilights(@hl);
  MouseCursorOn(Mx,My,Arrow);
  If (Button <=0) or (MouseFound=False) then
    Selection(1,1,@Select,True);
  Delay(200);
  MStatus(NewButton,NewX,NewY);
  Button:=NewButton;
  Cmd:=#0;
  S:=1;
  Go:=false;
  ff:=1;
  Repeat     { evaluate keystrokes loop }
    Repeat   { evaluate mouse movements loop }
      MStatus(NewButton,NewX,NewY);
      if (Newx<>Mx) or (NewY<>My) or (Button<>NewButton) then begin
       { if mouse moved }
        ML := mouseLocate(NewX,NewY,6,@fmt);
        If (ML<>S) and (Newbutton > 0) then begin { if mouse clicked }
          MouseCursorOff(Mx,My);
          if s<>0 then selection(1,s,@select,False);
          case ML of
            0 : begin
                  if MouseLocate(NewX,NewY,7,@mt) in [3..7] then
                    NewButton := 0;
                  s:=0;
                end;
            5 : s := 0; { skip line }
            else s := ML;
          end;
          set_Hilights(@hl); { set hilights }
          if s<>0 then selection(1,s,@select,True);
          MouseCursorOn(Mx,My,Arrow);
        end;
        MouseCursor(NewX,NewY,Mx,My,Arrow);
        Mx:=NewX;
        My:=NewY;
      end;
    until (keypressed) or (Button<>NewButton) or (go);
    if keypressed then begin { if mouse pressed }
      cmd:=readkey;
      if cmd=#0 then begin
        cmd:=readkey;
        case cmd of
          #75:begin { left }
                go:=true;
                FF:=3;
              end;
          #77:begin { right }
                go:=true;
                ff:=2;
              end;
          #72:begin { up }
              MouseCursorOff(Mx,My);
              selection(1,s,@select,False);
              Set_Hilights(@hl);
              case s of
                1 : s := 6;
                2 : s := 1;
                3 : s := 2;
                4 : s := 3;
                6 : s := 4;
              end;
              selection(1,s,@select,True);
              MouseCursorOn(Mx,My,Arrow);
            end;
          #80:begin { down }
              MouseCursorOff(Mx,My);
              selection(1,s,@select,False);
              Set_Hilights(@hl);
              case s of
                1 : s := 2;
                2 : s := 3;
                3 : s := 4;
                4 : s := 6;
                6 : s := 1;
              end;
              selection(1,s,@select,True);
              MouseCursorOn(Mx,My,Arrow);
            end;
        end;
      end
      else begin
        if upcase(cmd) = #27 then { esc }
          go := true
        else
          if upcase(cmd) in ['N','L','S','A','X'] then begin { hilights }
            MouseCursorOff(Mx,My);
            selection(1,s,@select,False);
            Set_Hilights(@hl);
            case upcase(cmd) of
              'N' : s := 1;
              'L' : s := 2;
              'S' : s := 3;
              'A' : s := 4;
              'X' : s := 6;
            end;
            cmd := #13;
            selection(1,s,@select,True);
            MouseCursorOn(Mx,My,Arrow);
          end
          else delay(1);
      end;
    end;
    if (Button<>NewButton) or (cmd=#13) then begin {execute command}
      click;
      if s = 0 then begin
        case MouseLocate(Mx,My,7,@mt) of
          1:MyExitProc; {exit }
          3:begin
							ff :=2;   { Programme }
							go := true;
						end;
					4:begin
							ff := 3;  { Quit }
							go := true;
						end;
          5:;
          6:;
          7:;
          else go:=true;
        end;
        Button := NewButton;
      end
      else
        go := True;
    end;
  until go; { until enter or esc }
  MouseCursorOff(Mx,My);
	DelShadow(mt[2,1],mt[2,4]+1,mt[2,1]+144,mt[2,4]+113{155});
	Putimage(19,14,fileback^,NormalPut);
	Freemem(fileback,imagesize(19,14,176,204));
  MouseCursorOn(Mx,My,Arrow);
  if (cmd = #13) or (Button <> NewButton) then { evaluate execution }
    case s of
      1 : NewFile;   { new file }
      2 : LoadFile;  { load file }
      3 : SaveFile(ProgramName); { savefile }
      4 : SaveFileAs; { save file as }
      6 : MyExitProc; { quit }
    end;
  if NewButton = 0 then Button := NewButton;
  FileMenu:=FF;
  BottomHelp(0,0);
end;

function ProgramMenu : integer;
{ file pull down menu }
var
  Cmd:Char;
  ff,OldS,S,ML:Integer;
  Go:Boolean;
  Background:Pointer;
const
  select: array[1..3] of string = ( { menu selections }
    ' Variables',
    '-',
    ' Run');

  hl:array[1..9,1..4] of Integer = ( { hilights }
    (99,47,Ord('V'),0),
    (0,0,0,0),
    (99,75,Ord('R'),0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0));

  fmt:array[1..3,1..4] of Integer = ( { mouse area }
    (99,140,44,57),
    (0,0,0,0),
    (99,140,72,85));

begin
  MouseCursorOff(Mx,My); { mouse off }
  Getmem(Background,Imagesize(mt[3,1],14,mt[3,1]+112,mt[3,4]+71)); { save }
  Getimage(Mt[3,1],14,Mt[3,1]+112,mt[3,4]+71,Background^);   { background }
  Setup_Select(2,@select);      { setup selection }
  Set_Hilights(@hl);   { set hilights }
  MouseCursorOn(Mx,My,Arrow); { mouse on }
  If (Button <=0) then Selection(2,1,@Select,True);
  Delay(200);
  MStatus(NewButton,NewX,NewY);
  Button:=NewButton;
  Cmd:=#0;
  S:=1;
  Go:=false;
  ff:=2;
  Repeat
    Repeat
      MStatus(NewButton,NewX,NewY);
      if (Newx<>Mx) or (NewY<>My) or (Button<>NewButton) then begin
        ML:=mouseLocate(NewX,NewY,3,@fmt);
        If (ML<>S) and (Newbutton > 0) then begin
          MouseCursorOff(Mx,My);
          if s<>0 then selection(2,s,@select,False);
          case ML of
            0 : begin
                  if MouseLocate(NewX,NewY,7,@mt) in [3..7] then
                    NewButton := 0;
                  s:=0;
                end;
            2 : s := 0;
            else s := ML;
          end;
          set_Hilights(@hl);
          if s<>0 then selection(2,s,@select,True);
          MouseCursorOn(Mx,My,Arrow);
        end;
        MouseCursor(NewX,NewY,Mx,My,Arrow);
        Mx:=NewX;
        My:=NewY;
      end;
    until keypressed or (Button<>NewButton) or go;
    if keypressed then begin
      cmd:=readkey;
      if cmd=#0 then begin
        cmd:=readkey;
        case cmd of
          #75 : begin
                  go:=true;
                  FF:=1;
                end;
          #77 : begin
                  go:=true;
                  ff:=3;
                end;
          #72,
          #80 : begin
                  MouseCursorOff(Mx,My);
                  selection(2,s,@select,False);
                  Set_Hilights(@hl);
                  case s of
                    1 : s := 3;
                    3 : s := 1;
                  end;
                  selection(2,s,@select,True);
                  MouseCursorOn(Mx,My,Arrow);
                end;
        end;
      end
      else begin
        if upcase(cmd) = #27 then
          go := true
        else
          if upcase(cmd) in ['V','R'] then begin
            MouseCursorOff(Mx,My);
            selection(2,s,@select,False);
            Set_Hilights(@hl);
            case upcase(Cmd) of
              'V' : s := 1;
              'R' : s := 3;
            end;
            cmd:=#13;
            selection(2,s,@select,True);
            MouseCursorOn(Mx,My,Arrow);
          end
          else
            delay(1);
      end;
    end;
    if (Button<>NewButton) or (cmd=#13) then begin
      click;
      if s = 0 then begin
        case MouseLocate(Mx,My,7,@mt) of
          1 : MyExitProc;
					2 : begin
							  ff := 1;
							  go := true;
						  end;
					4 : begin
							  ff := 3;
							  go := true;
						  end;
          5:;
          6:;
          7:;
          else go:=true;
        end;
        Button := NewButton;
      end
      else
        go := true;
    end;
  until go;
  MouseCursorOff(Mx,My);
  DelShadow(mt[3,1],mt[3,4]+1,mt[3,1]+112,mt[3,4]+71);
  Putimage(Mt[3,1],14,background^,NormalPut);
  Freemem(Background,imagesize(Mt[3,1],14,Mt[3,1]+112,mt[3,4]+71));
  MouseCursorOn(Mx,My,Arrow);
  if (cmd = #13) or (Button <> NewButton) then
    case s of
      1 : ShowVariables;
      3 : RunProgramme;
    end;
  if NewButton = 0 then Button := NewButton;
  ProgramMenu:=FF;
  BottomHelp(0,0);
end;

function quitmenu :integer;
{ quit pull down menu }
begin
	hilightit(3,black,@mt);
	cmd := MousereadKey('',[#13,#75,#77,#27,'F','P']);
	hilightit(3,white,@mt);
	case cmd of
		#13 : myexitproc;
		#0 : case MouseLocate(Mx,My,8,@mt) of
					 1 : myexitproc;
					 2 : quitmenu := 1;
					 3 : quitmenu := 2;
					 4 : myexitproc;
				 end;
		#75 : quitmenu := 2;
		#77 : quitmenu := 1;
		#27 : quitmenu := 3;
		'F' : quitmenu := 1;
		'P' : quitmenu := 2;
	end;
end;

{-------------------------}

procedure mainmenu;
{ main menu }
var
  s,ss:integer;
  go,find:boolean;
  a:char;
begin
  ss:=0;
  s:=1;
  find:=false;
  go:=false;
  repeat
    if ss<>s then begin
      hilightit(s,black,@mt);
      ss:=s;
    end;
		repeat
			MStatus(NewButton,NewX,NewY);
			if (Mx<>NewX) or (My<>NewY) then begin
				MouseCursor(NewX,NewY,Mx,My,Arrow);
				Mx:=NewX;
				My:=NewY;
			end;
		until (keypressed) or (Button<>NewButton);
		hilightit(s,white,@mt);
		ResetPullDowns;
		if keypressed then begin
			a:=readkey;
			if a=#0 then begin
				a:=readkey;
				case a of
					#80:s := moveit(s+1);
					#75:dec(s);
					#77:inc(s);
					else go:=true;
				end;
				if s>3 then s:=1;
				if s<1 then s:=3;
			end
			else begin
				case upcase(a) of
					'F':s := moveit(2);
					'P':s := moveit(3);
					'Q':s := moveit(4);
					else go:=true;
				end;
      end;
    end;
  until (go=true) or (Button<>NewButton);
  BottomHelp(0,0);
end;

end. { of unit menu }