{A collection of box drawing routines}

unit Box;

{$O+}
{$F+}

interface

procedure OutlineBox(x1,y1,x2,y2,boxcolor,rectcolor:  INTEGER);
procedure Scroll(x1,y1,x2,y2:  INTEGER);
procedure XPutPixel(x,y,color:  INTEGER);
procedure XLine(x1,y1,x2,y2,color:  INTEGER);
{procedure Input(var temp:  STRING);}

implementation

uses
  Crt,Dos,Graph;

procedure OutlineBox(x1,y1,x2,y2,boxcolor,rectcolor:  INTEGER);
{ Draw and outline a box }
begin
  SetFillStyle(SolidFill,boxcolor);	{set main color of box}
  if BoxColor<>LightGray then
    Bar(x1,y1,x2,y2);			{draw it}
  SetColor(rectcolor);			{set color for outline}
  Rectangle(x1,y1,x2,y2);
  Rectangle(x1+1,y1+1,x2-1,y2-1);
end; {OutlineBox procedure}

procedure Scroll(x1,y1,x2,y2:  INTEGER);
{ scroll a window up a line }
var
  i,x,y,yy:  INTEGER;
begin

  Port[$03CE] := 1;		{select enable set/reset register}
  Port[$03CF] := $0F;		{allow all planes to be written}
  Port[$03CE] := 8;		{select bit mask register}
  Port[$03CF] := 0;		{allow no bits to be overwritten}

  for i := 1 to 3 do begin
    for y := y1 to y2-4 do begin{row loop}
      yy := y*80;
      for x := x1 to x2 do	{column loop}
        Mem[$A000:yy+x] := Mem[$A000:yy+x+320];
    end; {for y}
  end; {for i}

  Port[$03CE] := 0;		{select set/reset register}
  Port[$03CF] := 0;
  Port[$03CE] := 1;		{select enable set/reset register}
  Port[$03CF] := 0;
  Port[$03CE] := 8;		{select bit mask register}
  Port[$03CF] := $FF;
end;

procedure XPutPixel(x,y,color:  INTEGER);
{ XOR plot a pixel at x,y }
var
  i: INTEGER;
begin
  i := GetPixel(x,y);
  PutPixel(x,y,i xor color);
end; {XPutPixel procedure}

procedure XLine(x1,y1,x2,y2,color:  INTEGER);
{ XOR draw a line from x1,y1 to x2,y2 }
var
  i: INTEGER;
  dx,dy: REAL;
begin
  if Abs(x1-x2) > Abs(y1-y2) then begin	{if x distance is greater...}
    if x1 > x2 then begin		{line must go left to right}
      i := x1; x1 := x2; x2 := i;
      i := y1; y1 := y2; y2 := i;
    end;
    dy := (y2-y1) / (x2-x1);
    for i := 0 to x2-x1 do		{draw the line}
      XPutPixel(x1+i,y1+Round(i*dy),color);
  end {if x distance is greater}
  else begin				{if y distance is greater...}
    if y1 > y2 then begin		{line must go top to bottom}
      i := x1; x1 := x2; x2 := i;
      i := y1; y1 := y2; y2 := i;
    end;
    if y2 - y1 <> 0 then
      dx := (x2-x1) / (y2-y1)
    else
      dx := 0;
    for i := 0 to y2-y1 do		{draw the line}
      XPutPixel(x1+Round(i*dx),y1+i,color);
  end;
end; {XLine procedure}

end. {Unit Box}
