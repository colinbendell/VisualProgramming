unit Util;

interface

{$O+}
{$F+}

uses Variable;

procedure InitNodes;
procedure PrintXY(X,Y:Integer; S:String; Col:Integer);
procedure Clear(X1,Y1,X2,Y2,Col:Integer);
procedure XBox(X,Y,Col:Integer);
procedure Boxit(X1,Y1,X2,Y2,Num:Integer; Def:string);
procedure DrawTriangle(basex,basey,direct:integer);
procedure ShadowBox(X1,Y1,x2:integer; Active:boolean; s:string);
procedure UnShadowBox(X1,Y1,x2:integer; s:string);
procedure Shadow(X1,Y1,X2,Y2:Integer);
procedure DelShadow(x1,y1,x2,y2:Integer);
procedure DelShadowMem(x1,y1,x2,y2:Integer);
procedure DrawSymbol(X,Y,num:integer; Identifier : word);
procedure DrawNode(GridX,GridY,Num : integer; Identifier : word);
procedure setsymbols;
procedure BottomHelp(a,b:integer);
procedure DimAll;
procedure BrightAll;
procedure CenterXY(Width,Height : integer; var XMin, XMax, YMin, YMax : integer);
Function NextX(XL,YL,First,Second,FDef,SDef:integer) : integer;
Function NextY(XL,YL,First,Second,FDef,SDef:integer) : integer;
procedure Set_Hilights(T:MtPtr);
procedure PageCheck;
procedure ViewBox;
procedure ClearViewBox;
procedure DrawScreen;
procedure SaveScreen( SPtr : VPtr );
procedure RestoreScreen( BPtr : VPtr );
procedure MyExitProc;

implementation

uses
  Crt,Dos,Graph,OOP,Box,Convert,Mouse,MouseRs2,Menu;

procedure InitNodes;
{ initialize the nodes }
var
	i : byte;
	Dummy : boolean;
begin
  Page := 1; { set global variables }
  MaxPage := 1;
  MaxId := 1;
  for i := 1 to 200 do { set pointers to nil }
		FirstNode[i] := nil;
	FirstVar := new(PVariable,Init); { create a new node }
	FirstNode[1] := new(PStartNode,Init);
	Dummy := FirstNode[1]^.SetNode(3,1); { create start node }
end;

procedure PrintXY(X,Y:Integer; S:String; Col:Integer);
{ print something on screen in colour }
begin
  SetTextStyle(0,HorizDir,1); { set style }
  SetColor(Col); { set colour }
  OutTextXY(X,Y,S); { write the text }
end;

procedure Clear(X1,Y1,X2,Y2,Col:Integer);
{ clear a portion of the screen in colour }
begin
  SetFillStyle(SolidFill,Col); { set colour }
  Bar(x1,y1,x2,y2); { clear the area }
end;

procedure XBox(X,Y,Col:Integer);
{ draw the little box on the top of boxes [-] }
begin
  clear(X,Y,X+17,Y+13,black); { clear the background }
  SetColor(Col); { change colour }
  Rectangle(X,Y,X+17,Y+13); { draw box around }
  Rectangle(X+4,Y+7-1,X+13,Y+8-1); { draw the line inside }
  SetColor(Black);
  Rectangle(X+18,Y,X+18,Y+13);
end;

procedure Boxit(X1,Y1,X2,Y2,Num:Integer; Def:string);
{ create a standard dialog box }
begin
  SetTextJustify(0,2); { set justification }
  OutLineBox(X1,Y1,X2,Y2,LightBlue,White); { draw outline }
  Clear(X1,Y1,X2,Y1+13,White); { clear top bar }
  PrintXY(X1+RtoI((X2-(X1-17)+1)/2)-RtoI((Length(Def)*8-1)/2),Y1+3,Def,1);
   { print in the center, the name }
  xbox(x1,y1,white); { draw little box on top of the box [-] }
end;

procedure DrawTriangle(basex,basey,direct:integer);
{ draw triangles for selected menu option }
{ for use with node seting }
var
  Triangle : array[1..3] of PointType;
begin
  setcolor(blue); { set colour to blue }
  case direct of { which way to point }
    1 : begin { point right }
          Triangle[1].x := basex+1; { set variables }
          Triangle[1].y := basey+2;
          Triangle[2].x := basex+6;
          Triangle[2].y := basey+7;
          Triangle[3].x := basex+1;
          Triangle[3].y := basey+12;
        end;
    2 : begin { point left }
          Triangle[1].x := basex+7; { set variables }
          Triangle[1].y := basey+2;
          Triangle[2].x := basex+2;
          Triangle[2].y := basey+7;
          Triangle[3].x := basex+7;
          Triangle[3].y := basey+12;
        end;
  end;
  fillPoly(SizeOf(Triangle) div           { draw the triangle }
           SizeOf(PointType), Triangle);
end;

procedure ShadowBox(X1,Y1,x2:integer; Active:boolean; s:string);
{ shadowed menu selection }
var
  col,y2:integer;
begin
  y2 := y1+14; { set variables }
  if active then col := white else col := lightgray;
  clear(x1,y1,x2,y2,col); { clear the area }
  OutLineBox(x1,y1,x2,y2,col,col);
  clear(x1+8,y2+1,x2+8,y2+8,black); { creat shadow }
  Clear(x2+1,y1+8,x2+8,y2+8,black);
  if Active then begin     { if active }
    DrawTriangle(x1,y1,1); { draw triangles }
    DrawTriangle(x2-8,y1,2);
  end;
  settextjustify(CenterText,CenterText); { print the option in center }
  SetColor(Blue);
  Outtextxy(x1+((x2-x1) div 2),y1+7,s);
  settextjustify(0,2); { set default justification }
end;

procedure UnShadowBox(X1,Y1,x2:integer; s:string);
{ unshadow a menu option when selected }
begin
  shadowbox(x1,y1,x2,true,s); { select button but }
  clear(x1+8,y1+15,x2+8,y1+22,lightblue); { erase the shadow }
  Clear(x2+1,y1+8,x2+8,y1+22,lightblue);
end;

procedure Shadow(X1,Y1,X2,Y2:Integer);
{ shadow any box and save the background }
begin
  GetMem(DShadow[1],ImageSize(x1+8,y2+1,x2+8,y2+8)); { save screen }
  GetImage(x1+8,y2+1,x2+08,y2+08,DShadow[1]^);
  Clear(x1+08,y2+1,x2+08,y2+08,black);               { put side shadow on }
  GetMem(DShadow[2],ImageSize(x2+1,y1+8,x2+10,y2+08)); { save screen }
  GetImage(x2+1,y1+8,x2+10,y2+08,DShadow[2]^);
  clear(x2+1,y1+08,x2+10,y2+08,black);               { put bottom shadow on }
end;

procedure DelShadow(x1,y1,x2,y2:Integer);
{ delete the shadowed area }
begin
  PutImage(x2+1,y1+8,DShadow[2]^,NormalPut); { resore bottom bar and }
  FreeMem(DShadow[2],ImageSize(x2+1,y1+8,x2+10,y2+8)); { free memory }
  PutImage(x1+8,y2+1,DShadow[1]^,NormalPut); { restore side bar and }
  FreeMem(DShadow[1],ImageSize(x1+8,y2+1,x2+8,y2+8)); { free memory }
end;

procedure DelShadowMem(x1,y1,x2,y2:Integer);
{ free shadow memory but do not restore screen }
begin
  FreeMem(DShadow[2],ImageSize(x2+1,y1+8,x2+10,y2+8)); { botton }
  FreeMem(DShadow[1],ImageSize(x1+8,y2+1,x2+8,y2+8)); { side }
end;

procedure DrawSymbol(X,Y,num:integer;Identifier:word);
{ draw the node symbol }
begin
  SetTextJustify(CenterText,CenterText); { set justification }
  setcolor(lightgray); { set colour }
  case num of { draw the symbol }
    Stop : begin
             { stop, two ovals, and lines to connect them }
             arc(x+(unt div 2)+3,y+(unt div 2),90,270,unt div 2+3);
             arc(x+(2*unt)-(unt div 2)-4,y+(unt div 2),270,90,unt div 2+3);
             line(x+(unt div 2)+3,y,x+(2*unt)-(unt div 2)-4,y);
             line(x+(unt div 2)+3,y+unt-1,x+(2*unt)-(unt div 2)-4,y+unt-1);
             printxy(x+unt,y+(unt div 2),'STOP',lightgray);
           end;
    Assignment : rectangle(X,Y,X+(2*unt)-1,Y+unt-1); { assignment, a box }
    Decision : begin { decision, a diamond }
                 line(x,y+(unt div 2),x+unt,y);
                 line(x+unt,y,x+2*unt-1,y+(unt div 2));
                 line(x+2*unt-1,y+(unt div 2),x+unt,y+unt-1);
                 line(x+unt,y+unt-1,x,y+(unt div 2));
                 printxy(x+4,y+(unt div 4),'Y',lightgray);
                 printxy(x+2*unt-4,y+(unt div 4),'N',lightgray);
               end;
    Input : begin { input, box with top left corner cut off }
              line(x,y+unt-1,x+(2*unt)-1,y+unt-1);
              line(x+10,y,x+(2*unt)-1,y);
              line(x,y+10,x,y+unt-1);
              line(x+(2*unt)-1,y,x+(2*unt)-1,y+unt-1);
              line(x+10,y,x,y+10);
            end;
    Output : begin { output, box with a piece missing at bottom right }
               line(x,y,x+(2*unt)-1,y);
               line(x,y,x,y+unt-1);
               line(x,y+unt-1,x+(unt*2)-31,y+unt-1);
               line(x+(unt*2)-31,y+unt-1,x+(unt*2)-21,y+unt-11);
               line(x+(unt*2)-21,y+unt-11,x+(2*unt)-1,y+unt-11);
               line(x+(2*unt)-1,y+unt-11,x+(2*unt)-1,y);
             end;
    Control : begin { control, single circle }
                circle(x+unt,y+(unt div 2),unt div 2);
                if Identifier <> 0 then
                  Printxy(x+unt,y+(unt div 2),ItoS(Identifier),lightgray);
              end;
    Start : begin { start, same as stop }
              arc(x+(unt div 2)+3,y+(unt div 2),90,270,unt div 2+3);
              arc(x+(2*unt)-(unt div 2)-4,y+(unt div 2),270,90,unt div 2+3);
              line(x+(unt div 2)+3,y,x+(2*unt)-(unt div 2)-4,y);
              line(x+(unt div 2)+3,y+unt-1,x+(2*unt)-(unt div 2)-4,y+unt-1);
              printxy(x+unt,y+(unt div 2),'START',lightgray);
						end;
    ControlOut : begin { control out, two circles }
                   circle(x+unt,y+(unt div 2),unt div 2);
                   circle(x+unt,y+(unt div 2),unt div 2 + 4);
                   if Identifier <> 0 then
                     Printxy(x+unt,y+(unt div 2),ItoS(Identifier),lightgray);
                 end;
  end;
  SetTextJustify(0,2); { reset justification }
end;

procedure DrawNode(GridX,GridY,Num: integer; Identifier : word);
{ draw node symbol on grid locations }
const
  X : integer = 0;
  Y : integer = 0;
begin
  X := PsX[GridX,1] + 10; { get pixel locations }
  Y := PsY[GridY,3] + 10;
  DrawSymbol(X,Y,Num,Identifier); { draw symbol }
end;

procedure setsymbols;
{ draw symbols box }
var
  i,ii,iii,x,y:integer;
begin
  for i := Stop to Control do begin { for every symbol on box... }
    x := LXY[i + 3,1];
    y := LXY[i + 3,2];
    clear(x,y,x+(2*unt)-1,y+unt-1,lightblue); { clear the background }
    setcolor(lightgray); { set light grey }
    getImage(X,Y,X+(2*Unt)-1,Y+unt-1,SymbBack[i]^); { save background }
    DrawSymbol(X,Y,i,0); { draw the symbol }
	end;
	SymbBack[ControlOut] := SymbBack[Control];
end;

procedure BottomHelp(a,b:integer);
{ bottom help bar for top menu selections }
begin
  clear(0,335,639,349,white); { clear the bar }
  setcolor(black);
  case a of
    0 : begin { default status bar }
          setcolor(White);
          outtextxy(72,339,'лллллл');
          setcolor(black);
          outtextxy(8,339,'   Save     Load     New     Run     Variable'+
            '      Menu        Exit');
          setcolor(red);
          outtextxy(8,339,'F2       F3       F4      F5      F6         '+
            '  F10       Alt-X');
        end;
    1 : case b of { help for file menu }
          0 : outtextxy(8,339,'File management commands (New, Load, '+
                               'Save, etc.)');
          1 : outtextxy(8,339,'Removes current work file from memory');
          2 : outtextxy(8,339,'Load a new file into memory to work on');
          3 : outtextxy(8,339,'Save current work file');
          4 : outtextxy(8,339,'Save current work file with a'+
                               ' specified name');
          6 : outtextxy(8,339,'Exit Visual Programming');
        end;
    2 : case b of { help for programme menu }
          0 : outtextxy(8,339,'View program variables or run program');
          1 : outtextxy(8,339,'Execute the program');
          3 : outtextxy(8,339,'View the list of variables');
        end;
    3 : outtextxy(8,339,'Exit Visual Programming'); { help for quit }
  end;
end;

procedure DimAll;
{ dim all the major boxes ( file area, symbols, top bar, etc }
var X1,Y1,X2,Y2 : integer;
	ffile :string;
	N : namestr;
	D : dirstr;
	E : extstr;
begin
	FSplit(ProgramName,D,N,E);
	fFile := N + E + '        '; { show filename }
	if getpixel(LXY[1,1]+20,LXY[1,2]+14) = white then begin
		SetTextJustify(0,2);
		X1 := LXY[3,1];
		Y1 := Lxy[3,2];
		X2 := Lxy[3,1]+79;
		Y2 := LXY[3,2]+253;
		PrintXY(X1+RtoI((X2-(X1-17)+1)/2)-RtoI((Length('Symbols')*8-1)/2),Y1+3,
			'Symbols',1);
		xbox(x1,y1,white);
		X1 := LXY[1,1];
		Y1 := LXY[1,2];
		X2 := LXY[1,1]+449;
		Y2 := LXY[1,2]+249;
		Clear(X1,Y1,X2,Y1+13,LightGray); { file area dim }
		PrintXY(X1+RtoI((X2-(X1-17)+1)/2)-RtoI((Length(fFile)*8-1)/2),Y1+3,fFile,1);
		xbox(x1,y1,white);
	end;
	Clear(0,14,639,27,LightGray);  { dim top menu bar }
	ResetPullDowns; { reset the menu pulldowns }
end;

procedure BrightAll;
{ bright all the major boxes after it has been dimmed }
var X1,Y1,X2,Y2 : integer;
	ffile :string;
	N : namestr;
	D : dirstr;
	E : extstr;
begin
	FSplit(ProgramName,D,N,E);
	fFile := N + E + '        '; { show filename }
	if getpixel(LXY[1,1]+20,LXY[1,2]+14) = lightgray then
	begin
		SetTextJustify(0,2);
		X1 := LXY[3,1];
		Y1 := Lxy[3,2];
		X2 := Lxy[3,1]+79;
		Y2 := LXY[3,2]+253;
		Clear(X1,Y1,X2,Y1+13,White); { bright symbol area }
		PrintXY(X1+RtoI((X2-(X1-17)+1)/2)-RtoI((Length('Symbols')*8-1)/2),Y1+3,'Symbols',1);
		xbox(x1,y1,white);
		X1 := LXY[1,1];
		Y1 := LXY[1,2];
		X2 := LXY[1,1]+449;
		Y2 := LXY[1,2]+249;
		Clear(X1,Y1,X2,Y1+13,White); { bright file area }
		PrintXY(X1+RtoI((X2-(X1-17)+1)/2)-RtoI((Length(fFile)*8-1)/2),Y1+3,fFile,1);
		xbox(x1,y1,white);
	end;
	Clear(0,14,639,27,White); { bright top menu bar }
	ResetPullDowns; { reset pull down menu }
end;

procedure CenterXY(Width,Height : integer;
                   var XMin, XMax, YMin, YMax : integer);
{ center a string or box in the center of the screen }
begin
  XMin := RtoI((640-Width)/2);
  XMax := XMin + Width;
  YMin := RtoI((350-Height)/2);
  YMax := YMin + Height;
end;

Function NextX(XL,YL,First,Second,FDef,SDef:integer) : integer;
{ find the next possible place to draw a line (x) }
{ for use with the connect line }
var temp,tempXL :integer;
begin
  temp := first;
  tempXL := XL;
  repeat          { find a free pixel }
    Inc(tempXL,temp);
    if tempXL = Fdef then begin
      temp := second;
      tempXL := XL;
    end;
  until (GetPixel(tempXL, YL) = lightblue) or (tempXL = Sdef);
  { if none available go in center }
  NextX := tempXL;
end;

Function NextY(XL,YL,First,Second,FDef,SDef:integer) : integer;
{ find the next possile place to draw a line (y) }
{ for ise with the connect line }
var temp,tempYL : integer;
begin
  temp := first;
  tempYL := YL;
  repeat  { find a free pixel }
    Inc(tempYL,temp);
    if tempYL = Fdef then begin
      temp := second;
      tempYL := YL;
    end;
  until (GetPixel(XL, tempYL) = lightblue) or (tempYL = SDef);
  NextY := TempYL;
end;

procedure Set_Hilights(T:MtPtr);
{ display the appropriate hilights }
Var i:Integer;
begin
  SetColor(Red);
  For I:=1 To 9 Do
    OutTextXY(T^[i,1]+8,T^[i,2],Chr(T^[i,3])); { print the hilights in red }
end;

procedure PageCheck;
{ redraw the screen for the current page }
var
  FileTitle : string;
  D : DirStr;
  N : NameStr;
	E : ExtStr;

begin
  If Mon then begin  { turn mouse off if it was on, and remember }
    MouseCursorOff(Mx,My);
    Mon := True;
  end;
  FSplit(ProgramName,D,N,E);
  FileTitle := N + E + '        '; { show filename }
  Boxit(LXY[1,1],LXY[1,2],LXY[1,1]+449,LXY[1,2]+249,1,FileTitle);
   { draw file area box }
   { draw page flipping icon as appropriate }
  if Page <> MaxPage then
    DrawTriangle(LXY[1,1]+437,LXY[1,2],1);
  if Page <> 1 then
    DrawTriangle(LXY[1,1]+424,LXY[1,2],2);
  { draw page icon }
  Line(LxY[1,1]+411,LxY[1,2]+2,Lxy[1,1]+411,LXY[1,2]+12);
  Line(Lxy[1,1]+411,LXY[1,2]+12,LXY[1,1]+421,LXY[1,2]+12);
  Line(LXY[1,1]+421,LXY[1,2]+12,LXY[1,1]+421,LXY[1,2]+5);
  Line(LXY[1,1]+421,LXY[1,2]+5,LXY[1,1]+417,LxY[1,2]+2);
  Line(LXY[1,1]+417,LxY[1,2]+2,Lxy[1,1]+411,LXY[1,2]+2);
  Line(LXY[1,1]+417,LxY[1,2]+2,LXY[1,1]+417,LXY[1,2]+5);
  Line(LXY[1,1]+417,LxY[1,2]+5,LXY[1,1]+421,LXY[1,2]+5);
  PrintXY(LXY[1,1]+383,LXY[1,2]+4,ITOFS(Page,3,'0'),1); { print page }
  if FirstNode[Page] <> nil then
    FirstNode[Page]^.DrawAll; { draw the symbols }
  if ViewOn and ViewVis then
    boxit(LXY[2,1],LXY[2,2],LXY[1,1]+444,Lxy[1,2]+244,1,'View'); { view box }
  If Mon then MouseCursorOn(Mx,My,Arrow); { turn mouse on }
end;

procedure ViewBox;
{ turn view box on }
begin
  ViewVis := True;
  PageCheck;
end;

procedure ClearViewBox;
{ turn view box off }
begin
  ViewVis := False;
  PageCheck;
end;

procedure DrawScreen;
{ draw the entire screen }
{ used in initializing and after running }
begin
  clear(0,0,639,349,darkgray); { clear the screen }
  clear(0,0,639,13,lightblue); { clear top bar }
  clear(0,335,639,349,white); { clear bottom bar }
  xbox(0,0,white);  { close icon [-] }
  setcolor(15);
	outtextxy(rtoi(259.5),3,'Visual Programming'); { print name }
	Boxit(LXY[3,1],Lxy[3,2],Lxy[3,1]+79,LXY[3,2]+253,1,'Symbols');
    { symbols box }
	Clear(0,14,639,27,White);
	ResetPullDowns;
  XBox(0,0,White);
  Shadow(LXY[1,1],LXY[1,2],LXY[1,1]+449,LXY[1,2]+249); { shadow file box }
  DelShadowMem(LXY[1,1],LXY[1,2],LXY[1,1]+449,LXY[1,2]+249); { del shad mem }
  shadow(LXY[3,1],LXY[3,2],LXY[3,1]+79,LXY[3,2]+253); { shadow symbols box }
  DelShadowMem(LXY[3,1],LXY[3,2],LXY[3,1]+79,LXY[3,2]+253); { del shadow mem}
	setsymbols; { draw symbols }
  BottomHelp(0,0); { set default status bar }
	MouseCursorOn(Mx,My,Arrow); { turn mouse on }
  PageCheck; { draw the file area }
end;

procedure SaveScreen( SPtr : VPtr );
{ save text screen }
var scrow,                                              { Current row }
    column : byte;                                   { Current column }

begin
  for scrow:=1 to 25 do                  { Execute the 25 screen rows }
    for column:=1 to 80 do            { Execute the 80 screen columns }
      SPtr^[scrow, column] := VioPtr^[scrow, column];   { Store char. }
                                                        { & attribute }
end;
                                                                        
procedure RestoreScreen( BPtr : VPtr );
{ restore text screen }
var scrow,                                          { The current row }
    column : byte;                               { The current column }
                                                                        
begin
  for scrow:=1 to 25 do                  { Execute the 25 screen rows }
    for column:=1 to 80 do            { Execute the 80 screen columns }
      VioPtr^[scrow, column] := BPtr^[scrow, column];   { Store char. }
                                                        { & attribute }
end;

procedure MyExitProc;
{ exit procedure }
var
  i : byte;
begin
  for i := 1 to MaxPage do
    dispose(FirstNode[i],Done);
  MouseCursorOff(Mx,My);
  CloseGraph;         { Close graphics mode }
  RestoreCRTmode;       { Restore mode used before program began }
  RestoreScreen( BufPtr );
  FreeMem( BufPtr, SizeOf(VBuf) );         { Release allocated buffer }
  GotoXY(SavedColumn,SavedRow);
  Halt(0);             { End program }
end;  { of procedure MyExitProc }

end. { of Util unit }
