unit Init;

{$O+}
{$F+}

interface

implementation

uses
  Crt,Graph,Variable,InitOver,Convert,Mouse,Util,Menu;

var
  GraphMode,
  GraphDriver,
  InitResult,
  i : integer;

begin

  Randomize;

  { Initialize Graphics }

  if RegisterBGIDriver(@EGAVGADriverProc) < 0 then begin
    writeln(#13,'A problem occured while loading Visual Programming.');
    writeln('Re-install and try again.');
    Halt(1);                               { load EGA/VGA graphics driver }
  end;
  if not (IsEgaVga) then begin
    WriteLn(#13,#13,'This program requires EGA graphics or better');
    Halt(1);
  end;
	Writeln(#13,'Visual Programming  Ver 1.01, Guelph University Software Development Contest');
  delay(1500);
  DispInit;                                   { Get video RAM address }
  GetMem(BufPtr, SizeOf(VBuf) );                    { Allocate buffer }
  SaveScreen( BufPtr );                       { Store screen contents }
  SavedRow := WhereY;                        { Get current screen row }
  SavedColumn := WhereX;                  { Get current screen column }
  GraphDriver := EGA;                                { force EGA graphics }
  GraphMode := EGAHi;
  InitGraph(GraphDriver,GraphMode,'');     { attempt to activate graphics }
  InitResult := GraphResult;
  if InitResult <> grOk then begin     { if graphics could not initialize }
    WriteLn('Cannot initialize graphics, error #',InitResult:2);
    WriteLn(GraphErrorMsg(i));
    FreeMem(BufPtr, SizeOf(VBuf) );
    RestoreScreen( BufPtr );
    GotoXY(SavedColumn,SavedRow);
    Halt(1);                        { print error message and end program }
  end;
  SetActivePage(0);                       { set graphics pages to default }
  SetVisualPage(0);
  setfillstyle(solidfill,0);                      { initialize fill style }

  { Initialize Mouse }

  if MReset = -1 then begin                     { check for mouse present }
    MLimit(0,639-MW,0,349-MH);               { set limits of mouse cursor }
    MPut(0,0);                    { put mouse cursor in upper left corner }
    Button := 0;
    getmem(MCurs,ImageSize(0,0,MW,MH)); { reserve memory for screen beneath }
		Mx := 0;                                        { reset mouse variables }
 		My := 0;
		NewX := 0;
		NewY := 0;
  end  { of if statement }
  else begin                                     { no mouse }
    RestoreCrtMode;                              { restore character mode }
    writeln(#13,'No mouse driver detected.');    { show error }
    halt(1);                                     { end programme with error }
  end;

  { Initialize variables }

  for i:=1 to 6 do begin
    LXY[i+3,1] := LXY[3,1]+13;             { top corners of major areas - X }
    LXY[i+3,2] := i*11+i*Unt+LXY[3,2]-13;                               { Y }
  end;
  for i := 1 to 6 do begin
    Psx[i,1] := LXY[1,1] + (i-1) * 74 + 2; { Place Symbol X -- creates }
    Psx[i,2] := LXY[1,1] + (i*74) + 2;     { grid for finding where the }
    Psx[i,3] := LXY[1,2] + 14;             { sybol is placed }
    Psx[i,4] := LXY[1,2] + 249;
  end;
  for i := 1 to 5 do begin
    PSy[i,1] := LXY[1,1] + 1;              { Place Symbol Y }
    PSy[i,2] := LXY[1,1] + 445;
    PSy[i,3] := LXY[1,2] + (i-1) * 47 + 15;
    PSy[i,4] := LXY[1,2] + i*47 + 14;
  end;

  for i:=1 to 6 do begin
		Getmem(SymbBack[i],ImageSize(0,0,(2*Unt)-1,unt-1));{ reserve memory for }
	end;                                                 { moving symbols }
  InitNodes;                                          { Initialize the nodes }
  DrawScreen;                                         { Draw the Screen }
end. { Unit Init }
