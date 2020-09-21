{****************************************************************************}
{*                               MOUSE TOOLS                                *}
{*                       Version 1.2, April 30, 1990                        *}
{*                                                                          *}
{*    Written by:                   Copyright (C) 1989 by Nels Anderson     *}
{*    Nels Anderson                 All Rights Reserved                     *}
{*    92 Bishop Drive                                                       *}
{*    Framingham, MA 01701          Source code for use by registered       *}
{*                                  owner only.  Not to be distributed      *}
{*                                  without express consent of the writer.  *}
{*                                                                          *}
{****************************************************************************}

{ Mouse handler unit

This unit provides all the capabilities needed to add a mouse interface to
a program.  The routines included are:

MReset...........Reset the mouse (used once to start it up)
MPut.............Put the mouse at some specific coordinates
MStatus..........Read the button positions and x,y coordinates
MLimit...........Set the limits of the mouse coordinates
MouseCursor......Move the mouse cursor (used each time mouse moves)
MouseCursorOn....Draw mouse cursor at start of program
MouseCursorOff...Turn off mouse cursor
MouseLocate......Determine what the mouse is pointing to

To use the mouse in a program, it is necessary first to enable it (which
also checks to see if a mouse even exists on the system), set the limits
(usually equal to the number of pixels on the screen minus the size of
the mouse cursor), put the mouse somewhere (0,0), reserve memory in the
heap to save the screen that's under the mouse cursor, and finally turn
the mouse cursor on.  The following code fragment is an example of the
code needed to start up the mouse:

begin {Main Routine
  Initialize;				{start up BGI graphics
  if MReset = -1 then begin		{start up mouse, if there is one
    MLimit(0,632,0,342);		{set mouse limits
    MPut(0,0);				{reset mouse coordinates
  end;
  Mx := 0; My := 0;			{set last known mouse coordinates
  Button := 0;				{set last known button position
  GetMem(MCurs,ImageSize(0,0,MW,MH));	{reserve memory for GetImage/PutImage
  MouseCursorOn(0,0,1);			{show mouse cursor type 1 at 0,0
          .
          .
          .

Somewhere in the body of the program the mouse status must be checked and
the cursor updated.  If the coordinates have changed, MouseCursor is called
with both the new and old coordinates as arguments.  If a button is pushed,
MouseLocate is called with the current coordinates as arguments.  It will
return the location in the table of the screen item that the mouse is now
pointing to.  This result can be used in a case statement to call the
desired function:

  MStatus(NewButton,NewX,NewY);		{get mouse status
  if (NewX <> Mx) or (NewY <> My) then	{if mouse has moved...
    MouseCursor(NewX,NewY,Mx,My,1);	{...move the mouse cursor
  Mx := NewX; My := NewY;		{remember new location
  if NewButton <> Button then begin	{if button changed...
    if NewButton > 0 then begin		{...and if button now down...
      case MouseLocate(Mx,My,size,@mt) of  {find where mouse is pointed...
        1: FirstFunction;       	{...and do a command
        2: SecondFunction;
                .
                .
                .
        else ErrorFunction;		{if MouseLocate didn't find anything
      end; {case
    end; {if NewButton > 0
    Button := NewButton;		{remember new button setting
  end; {if NewButton <> Button

}

unit Mouse;

{$F+}

interface

uses Variable;

function MReset:  INTEGER;
procedure MPut(x,y:  INTEGER);
procedure MStatus(var button,xpos,ypos:  INTEGER);
procedure MLimit(xmin,xmax,ymin,ymax:  INTEGER);
procedure MouseCursor(x,y,Oldx,Oldy,Num:  INTEGER);
procedure MouseCursorOn(x,y,Num:  INTEGER);
procedure MouseCursorOff(Oldx,Oldy:  INTEGER);
function MouseLocate(x,y,size:  INTEGER; mt:  mtptr):  INTEGER;

implementation

uses
  Crt,Dos,Graph;

{****************************************************************************}
{*                                                                          *}
{*  Routine: MReset                                                         *}
{*  Arguments: none                                                         *}
{*  Function: initializes the mouse                                         *}
{*  Results: status is -1 for mouse installed, 0 otherwise                  *}
{*                                                                          *}
{*  Note: on some DOS 2.x systems the $33 interrupt doesn't even exist, so  *}
{*  its presence must be checked for before calling it.                     *}
{****************************************************************************}

function MReset:  INTEGER;
var
  Regs: Registers;
  result: INTEGER;
begin
  if MemW[0000:$0066] <> 0 then begin	{if mouse interrupt exists...}
    Regs.AX := 0;			{select function}
    Intr(51,Regs);			{call the mouse driver}
    result := Regs.AX;			{return status (BX=number of buttons)}
    MReset := result;
    if result = -1 then
      MouseFound := TRUE		{a mouse was found}
    else
      MouseFound := FALSE;
  end;
end; {MReset function}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MPut(mx,my)                                                    *}
{*  Arguments: mx = column of desired mouse position                        *}
{*             my = row of desired mouse position                           *}
{*  Function: sets the mouse coordinates to the specified x,y position      *}
{*  Results: nothing returned to caller                                     *}
{*                                                                          *}
{****************************************************************************}

procedure MPut(x,y:  INTEGER);
var
  Regs: Registers;
begin
  if MouseFound then begin
    Regs.AX := 4;		{select driver function}
    Regs.CX := x;		{select column}
    Regs.DX := y;		{select row}
    Intr(51,Regs);		{call the mouse driver}
    Mx := X;
    My := Y;
  end;
end; {MPut procedure}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MStatus(button,xpos,ypos)                                      *}
{*  Arguments: button = buttons pressed status                              *}
{*             xpos = column                                                *}
{*             ypos = row                                                   *}
{*  Function: reports current mouse status                                  *}
{*  Results: button indicates which buttons pressed                         *}
{*           xpos,ypos indicate current mouse position                      *}
{*                                                                          *}
{****************************************************************************}

procedure MStatus(var button,xpos,ypos:  INTEGER);
var
  Regs: Registers;
begin
  if MouseFound then begin
    Regs.AX := 3;		{select mouse driver function}
    Intr(51,Regs);		{call the mouse driver}
    button := Regs.BX;		{get button status}
    xpos := Regs.CX;		{get the column}
    ypos := Regs.DX;		{get the row}
  end
  else begin
    case cmd of
      '2' : Dec(My,1);
      '4' : Dec(Mx,1);
      '6' : Inc(My,1);
      '8' : Inc(Mx,1);
      '@' : Dec(My,5);
      '$' : Dec(Mx,5);
      '^' : Inc(My,5);
      '*' : Inc(Mx,5);
    end;
  end;

end; {MStatus procedure}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MLimit(xmin,xmax,ymin,ymax)                                    *}
{*  Arguments: xmin = minimum mouse column                                  *}
{*             xmax = maximum mouse column                                  *}
{*             ymin = minimum mouse row                                     *}
{*             ymax = maximum mouse row                                     *}
{*  Function: sets mouse row and column limits                              *}
{*  Results: nothing returned to caller                                     *}
{*                                                                          *}
{****************************************************************************}

procedure MLimit(xmin,xmax,ymin,ymax:  INTEGER);
var
  Regs: Registers;
begin    
  if MouseFound then begin
    Regs.AX := 7;		{select mouse driver function}
    Regs.CX := xmin;		{set minimum column}
    Regs.DX := xmax;		{set maximum column}
    Intr(51,Regs);		{set column limits}

    Regs.AX := 8;		{select mouse driver function}
    Regs.CX := ymin;		{set minimum row}
    Regs.DX := ymax;		{set maximum row}
    Intr(51,Regs);		{set row limits}
  end;
end; {MLimit procedure}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MouseLocate(x,y,size,mt)                                       *}
{*  Arguments: x = current mouse column                                     *}
{*             y = current mouse row                                        *}
{*             size = size of table                                         *}
{*             mt = pointer to table                                        *}
{*  Function: returns what mouse is now pointing to                         *}
{*  Results: position in mouse "button" table                               *}
{*                                                                          *}
{****************************************************************************}

function MouseLocate(x,y,size:  INTEGER; mt:  mtptr):  INTEGER;
{ translate mouse coordinates to table entry }
{
  Requires a table mt[x1,x2,y1,y2] with <size> entries where for
  each entry x1 and x2 define the limits in the x direction and y1
  and y2 define the limits in the y direction for the item in that
  position of the table.
}
var
  i:  INTEGER;
begin
  for i := 1 to size do begin		{check each table entry...}
    if (x >= mt^[i,1]) and (x <= mt^[i,2]) and
    (y >= mt^[i,3]) and (y <= mt^[i,4]) then begin
      MouseLocate := i;			{position matches}
      exit;				{return entry number}
    end; {if}
  end; {for i}
  MouseLocate := 0;			{no match found}
end; {MouseLocate function}

{ Mouse Cursor Shapes }

const
  Cursor: array[1..9,0..255] of BYTE = (		{hand}
( 00,00,00,08,08,08,08,08,00,00,00,00,00,00,00,00,	{MW=10,MH=15}
  00,00,08,15,08,15,08,15,08,00,00,00,00,00,00,00,
  00,00,08,07,08,07,08,07,08,08,00,00,00,00,00,00,
  00,00,08,15,08,15,08,15,08,15,08,00,00,00,00,00,
  00,00,08,07,08,07,08,07,08,07,08,00,00,00,00,00,
  00,08,08,15,08,15,08,15,08,15,08,00,00,00,00,00,
  08,15,08,07,08,07,08,07,08,07,08,00,00,00,00,00,
  08,07,08,15,15,07,15,15,15,07,08,00,00,00,00,00,
  08,07,08,08,07,07,07,07,07,07,08,00,00,00,00,00,
  08,07,07,15,15,07,07,07,15,07,08,00,00,00,00,00,
  08,07,07,07,15,15,15,15,15,07,08,00,00,00,00,00,
  00,08,07,07,07,15,08,15,07,07,08,00,00,00,00,00,
  00,00,08,07,07,07,08,07,07,08,00,00,00,00,00,00,
  00,00,00,08,08,08,08,07,08,08,00,00,00,00,00,00,
  00,00,08,07,15,15,15,15,15,15,00,00,00,00,00,00,
  00,00,00,08,08,08,08,08,08,08,00,00,00,00,00,00),

( 08,08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,	{pointing finger}
  08,15,08,00,00,00,00,00,00,00,00,00,00,00,00,00,	{MW=11,MH=15}
  08,15,15,08,00,00,00,00,00,00,00,00,00,00,00,00,
  00,08,15,15,08,00,00,00,00,00,00,00,00,00,00,00,
  00,00,08,15,15,08,00,00,00,00,00,00,00,00,00,00,
  00,00,08,08,15,15,08,00,00,00,00,00,00,00,00,00,
  00,08,15,15,08,15,15,08,00,00,00,00,00,00,00,00,
  08,15,07,15,01,15,15,15,08,00,00,00,00,00,00,00,
  08,08,08,07,01,15,15,15,15,08,00,00,00,00,00,00,
  08,15,15,01,15,15,07,07,15,08,00,00,00,00,00,00,
  00,08,15,15,15,07,07,07,07,07,08,00,00,00,00,00,
  00,00,08,07,07,07,07,07,07,07,01,08,00,00,00,00,
  00,00,00,08,08,07,07,07,07,01,01,08,00,00,00,00,
  00,00,00,00,00,08,08,08,08,01,01,08,00,00,00,00,
  00,00,00,00,00,00,08,08,07,07,08,00,00,00,00,00,
  00,00,00,00,00,00,00,08,08,08,00,00,00,00,00,00),

( 08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,	{arrow}
  08,08,00,00,00,00,00,00,00,00,00,00,00,00,00,00,	{MW=7,MH=15}
  08,15,08,00,00,00,00,00,00,00,00,00,00,00,00,00,
  08,15,15,08,00,00,00,00,00,00,00,00,00,00,00,00,
  08,15,15,15,08,00,00,00,00,00,00,00,00,00,00,00,
  08,15,15,15,15,08,00,00,00,00,00,00,00,00,00,00,
  08,15,15,15,15,15,08,00,00,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,08,00,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  08,15,15,08,15,15,08,08,08,00,00,00,00,00,00,00,
  08,15,08,08,15,15,08,00,00,00,00,00,00,00,00,00,
  08,08,00,00,08,15,15,08,00,00,00,00,00,00,00,00,
  00,00,00,00,08,15,15,08,00,00,00,00,00,00,00,00,
  00,00,00,00,00,08,08,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00),

( 00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00,	{watch}
  00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00,
  00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00,
  00,00,00,00,08,08,08,08,08,08,08,00,00,00,00,00,
  00,00,00,08,15,15,15,15,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,08,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,08,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,08,15,15,15,08,00,00,00,00,
  00,00,00,08,15,08,08,08,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,15,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,15,15,15,15,08,00,00,00,00,
  00,00,00,08,15,15,15,15,15,15,15,08,00,00,00,00,
  00,00,00,00,08,08,08,08,08,08,08,00,00,00,00,00,
  00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00,
  00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00,
  00,00,00,00,00,08,08,08,08,08,00,00,00,00,00,00),

( 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,	{L-Arrow}
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,08,08,00,00,00,00,00,00,00,00,00,00,
  00,00,00,08,15,08,00,00,00,00,00,00,00,00,00,00,
  00,00,08,15,15,08,08,08,08,00,00,00,00,00,00,00,
  00,08,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  00,08,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  00,00,08,15,15,08,08,08,08,00,00,00,00,00,00,00,
  00,00,00,08,15,08,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,08,08,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00),

( 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,	{R-Arrow}
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,08,08,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,08,15,08,00,00,00,00,00,00,00,00,00,00,
  08,08,08,08,15,15,08,00,00,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,08,00,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,08,00,00,00,00,00,00,00,00,
  08,08,08,08,15,15,08,00,00,00,00,00,00,00,00,00,
  00,00,00,08,15,08,00,00,00,00,00,00,00,00,00,00,
  00,00,00,08,08,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00),

( 00,00,08,08,08,08,08,00,00,00,00,00,00,00,00,00,	{D-Arrow}
  00,00,08,15,15,15,08,00,00,00,00,00,00,00,00,00,
  00,00,08,15,15,15,08,00,00,00,00,00,00,00,00,00,
  08,08,08,15,15,15,08,08,08,00,00,00,00,00,00,00,
  08,15,15,15,15,15,15,15,08,00,00,00,00,00,00,00,
  08,08,15,15,15,15,15,08,08,00,00,00,00,00,00,00,
  00,00,08,15,15,15,08,00,00,00,00,00,00,00,00,00,
  00,00,00,08,15,08,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,08,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00),

( 00,00,00,00,00,00,00,08,00,00,00,00,00,00,00,00,	{Compass}
	00,00,00,00,00,00,08,15,08,00,00,00,00,00,00,00,
	00,00,00,00,00,08,15,15,15,08,00,00,00,00,00,00,
	00,00,00,00,08,15,15,15,15,15,08,00,00,00,00,00,
	00,00,00,08,00,08,08,15,08,08,00,08,00,00,00,00,
	00,00,08,15,08,00,08,15,08,00,08,15,08,00,00,00,
	00,08,15,15,08,08,08,15,08,08,08,15,15,08,00,00,
	08,15,15,15,15,15,15,15,15,15,15,15,15,15,08,00,
	00,08,15,15,08,08,08,15,08,08,08,15,15,08,00,00,
	00,00,08,15,08,00,08,15,08,00,08,15,08,00,00,00,
	00,00,00,08,00,08,08,15,08,08,00,08,00,00,00,00,
	00,00,00,00,08,15,15,15,15,15,08,00,00,00,00,00,
	00,00,00,00,00,08,15,15,15,08,00,00,00,00,00,00,
	00,00,00,00,00,00,08,15,08,00,00,00,00,00,00,00,
	00,00,00,00,00,00,00,08,00,00,00,00,00,00,00,00,
	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00),

( 08,08,08,00,00,00,00,08,08,08,00,00,00,00,00,00,	{XCursor}
  08,15,15,08,00,00,08,15,15,08,00,00,00,00,00,00,
  08,08,15,15,08,08,15,15,08,08,00,00,00,00,00,00,
  00,00,08,15,15,15,15,08,00,00,00,00,00,00,00,00,
  00,00,00,08,15,15,08,00,00,00,00,00,00,00,00,00,
  00,00,08,15,15,15,15,08,00,00,00,00,00,00,00,00,
  08,08,15,15,08,08,15,15,08,08,00,00,00,00,00,00,
  08,15,15,08,00,00,08,15,15,08,00,00,00,00,00,00,
  08,08,08,00,00,00,08,08,08,08,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00) );

{****************************************************************************}
{*                                                                          *}
{*  Routine: MouseCursor(x,y,Oldx,Oldy,Num)                                 *}
{*  Arguments: x = current mouse column                                     *}
{*             y = current mouse row                                        *}
{*             Oldx = previous mouse column                                 *}
{*             Oldy = previous mouse row                                    *}
{*             Num = selected cursor number                                 *}
{*  Function: moves mouse cursor                                            *}
{*  Results: nothing returned to caller                                     *}
{*                                                                          *}
{****************************************************************************}

procedure MouseCursor(x,y,Oldx,Oldy,Num:  INTEGER);
{ move mouse cursor }
var
  i,j,k:  INTEGER;
begin
  PutImage(Oldx,Oldy,MCurs^,NormalPut);   	{erase old cursor}
  GetImage(x,y,x+MW,y+MH,MCurs^);  		{save beneath new one}
  for i := 0 to MH do begin
    k := i * 16;
    for j := 0 to MW do
      if Cursor[Num,k+j] > 0 then begin
        if (Cursor[num,k+j] <> 08) and ((Num <> 1) or (Num <> 4)) then
          PutPixel(x+j,y+i,Cursor[Num,k+j])
        else
          PutPixel(x+j,y+i,00);
      end;
  end; {for i}
end;

procedure MouseCursorOn(x,y,Num:  INTEGER);
{ draw mouse cursor }
var
  i,j,k:  INTEGER;
begin
  GetImage(x,y,x+MW,y+MH,MCurs^);  		{save beneath new one}
  for i := 0 to MH do begin
    k := i * 16;
    for j := 0 to MW do
      if Cursor[Num,k+j] > 0 then begin
        if (Cursor[num,k+j] <> 08) and ((Num <> 1) or (Num <> 4)) then
          PutPixel(x+j,y+i,Cursor[Num,k+j])
        else
          PutPixel(x+j,y+i,00);
      end;
  end; {for i}
  MOn := TRUE;
end;

procedure MouseCursorOff(Oldx,Oldy:  INTEGER);
{ remove mouse cursor }
begin
  PutImage(Oldx,Oldy,MCurs^,NormalPut);	{erase old cursor}
  MOn := FALSE;
end;

begin
  MOn := FALSE;
  MouseFound := FALSE;
end.
