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

{ Mouse response unit for CGA/EGA/MCGA screens

This unit provides a number of ways to get responses from the mouse.  The
routines included are:

MGetFile.........Returns a file name that the user has selected
MGetFileDef......Returns a file name that the user has selected, or default
MouseYN..........Returns a Yes/No response
MouseMsg.........Displays one line message and an OK box
MouseQuestion....Uses a table to ask a multiple response question
MouseReadKey.....Returns a single character or coordinates of mouse click
KeyOrClick.......Wait for a key hit or mouse click

To use these routines the mouse must have been activated as shown in the
MOUSE.PAS unit.

}

Unit MouseRs2;

{$F+}

interface

uses Variable;

procedure Click;
function MGetFile(FileSpec,Heading:  STRING; var Cancel : BOOLEAN): STRING;
function MGetFileDef(FileSpec,DefFile,Heading:  STRING;
  var Cancel : BOOLEAN): STRING;
function MouseYN(x,y: INTEGER; Heading:  STRING):  BOOLEAN;
procedure MouseMsg(x,y: INTEGER; Msg:  STRING);
function MouseQuestion(Size,Default: INTEGER;Heading: STRING;Ques: QTable): INTEGER;
function MouseReadKey(Heading: STRING; CS : CharSet): CHAR;
procedure KeyOrClick(Num:  WORD);
procedure InputIt(x,y: integer; var temp: STRING; MaxLen : byte;
  Min : pointer);

implementation

uses
  Crt,Dos,Graph,OOP,Box,Convert,Mouse,Util;

procedure Click;
{ click the speaker }
var
  b:  BYTE;
begin
  if SoundOn then begin			{if sound allowed...}
    b := Port[$61] and $FC;		{read sound port}
    Port[$61] := b;			{speaker in}
    Delay(4);
    Port[$61] := b or $02;		{speaker out}
  end;
end; {Click procedure}

procedure GetPageList(var PageList : dir_Files; var Num : integer);
var
  i : integer;
begin
  for i := 1 to MaxPage do
    PageList[i] := ItoS(i);
  if NewPageRequest = False then
    Num := MaxPage
  else begin
    Num := MaxPage + 1;
    PageList[Num] := 'New Page';
  end;
end;

procedure getVarList(Var VarList : dir_Files; var counter : integer;
	var EndPtr: PVariable; VarType : integer);
  { finds and counts the amount of the specified variables }
var
  I : integer;

begin
  EndPtr := FirstVar^.Next;  { start at the begining }
  Counter := 0;              { initialize variables }
  for i := 1 to 200 do
    VarList[i] := #0;
  For I := 1 to 200 do
    If EndPtr = nil then begin { if last variable }
      Counter := I-1;          { find the count and exit }
      Exit;
    end
    else begin                 { if not last variable}
      while (VarType <> 0) and (EndPtr^.VarType <> VarType) and
        (EndPtr <> nil) do
          EndPtr := EndPtr^.Next;
      if EndPtr <> nil then begin { if variable is of the specified }
        Varlist[i] := EndPtr^.Name; { add to list }
        EndPtr := EndPtr^.Next;
      end;
    end;
end;

procedure DirList(mask_in : STRING;
                  Var Name_list : Dir_Files;
                  Var File_Counter: integer;
                  FileAttr: integer);

var
  regs      : registers;
  i         : byte;
  DTAseg,
  DTAofs    : integer;
  FileName  : string[20];

begin
  Fillchar(regs,SizeOf(regs),0);
  file_counter:= 0;
  regs.AH := $2F;			{find memory address where file}
  MSDos(regs);                          {  names will be}
  DTAseg := regs.ES;			{save that address}
  DTAofs := regs.BX;

  FillChar(regs,SizeOf(regs),0);
  mask_in := mask_in + #0;		{terminate file spec}
  with regs do begin
    AH := $4E;				{find first matching file task}
    DS := Seg(Mask_in);			{point to ASCIIZ string to match}
    DX := Ofs(Mask_in)+1;
    CL := FileAttr;			{file attributes, $10=directories}
  end;
  MSDos(regs);				{find first file that matches spec}
  if regs.AL <> 0 then exit;		{exit if no matches at all}
  file_counter := 0;			{initialize number of matching files}
  if (FileAttr = 0) or ((Mem[DTAseg:DTAofs+21] and FileAttr) > 0) then begin
    i:= 1;
    repeat				{copy file name into variable}
      FileName[i] := Chr(Mem[DTAseg:DTAofs+29+i]);
      i := i+1;
    until (FileName[i-1] < chr(32)) or (i > 12);

    FileName[0] := Chr(i-1);		{set string length}
    file_counter := file_counter + 1;	{initialize number of matching files}
    name_list[File_Counter] := FileName;{copy this file into array}
  end;

  repeat
    FillChar(regs,SizeOf(regs),0);
    with regs do begin
      AH := $4F;
      CL := $00;
    end;
    MSDos(regs);			{find next file that matches spec}

    if regs.AL = 0 then begin		{unless no more files that match...}
      if (FileAttr=0) or ((Mem[DTAseg:DTAofs+21] and FileAttr)<>0) then begin
        file_counter := file_counter+1;	{increment number of matching files}
        i := 1;
        repeat				{copy file name into variable}
          FileName[i] := Chr(Mem[DTAseg:DTAofs+29+i]);
          i := i+1;
        until (FileName[i-1] < chr(32)) or (i > 12);

        FileName[0] := Chr(i-1);	{set string length}
        name_list[file_counter] := FileName;  {copy this file into array}
      end; {if file attributes match}
    end; {if file spec match}
  until regs.AL <> 0;  {until no more matching files}
end;

procedure ClearDir;
{ part of MGetFile }
begin
  MouseCursorOff(Mx,My);
  PutImage(FileX,FileY,FileWindow^,NormalPut);
  MouseCursorOn(Mx,My,HAND);
  FreeMem(FileWindow,ImageSize(100,90,356,280));
end;

procedure ShowFiles;
{ show 10 files }
var
  FillColor,
  i,j:  INTEGER;
begin
  FillColor := LightGray;
  MouseCursorOff(Mx,My);
  SetFillStyle(SolidFill,FillColor);
  Bar(FileX+24,FileY+50,FileX+128,FileY+150);	{clear old list}
  Bar(FileX+146,FileY+51,FileX+158,FileY+149);	{clear old scroll bar}
  if NowRoot then begin			{if now at root...}
    for i := 1 to NumDrives do		{display drive names}
      if i < 11 then			{only room for 10 drives}
        OutTextXY(FileX+32,FileY+50+i*10,Chr(i+64)+':');
  end
  else begin				{else, if displaying files...}    
    if NumFiles+NumDirs > 0 then begin
      i := (100*DirOff) div (NumFiles+NumDirs);
      j := 1000 div (NumFiles+NumDirs);
      if j > 100 then j := 100;
      SetFillStyle(9,FillColor);	{draw new scroll bar}
      Bar3D(FileX+146,FileY+50+i,FileX+158,FileY+50+i+j,0,TopOff);
    end;
    i := 1;
    while (i < 11) and (i+DirOff <= NumDirs) do begin
      MoveTo(FileX+24,FileY+48+yofs+i*10);
      LineRel(3,-3);
      LineRel(-3,-3);
      LineRel(0,6);
      OutTextXY(FileX+32,FileY+50+i*10,Dirs[i+DirOff]);
      i := i + 1;
    end;
    while (i < 11) and (i+DirOff <= NumFiles+NumDirs) do begin
      OutTextXY(FileX+32,FileY+50+i*10,Files[i+DirOff-NumDirs]);
      i := i + 1;
    end;
  end; {if displaying files}
  MouseCursorOn(Mx,My,FINGER);
end;

procedure ScrollBar;
{ use the scroll bar to select a group of files }
var
  SaveOff:  WORD;
begin
  SaveOff := DirOff;
  DirOff := ((NumFiles + NumDirs - 10) * (My - (FileY+45))) div 100;
  if (DirOff < 0)
  or (DirOff > (NumFiles + NumDirs) - 10) then
    DirOff := SaveOff;			{prevent going too far}
  ShowFiles;
end;

procedure GoUp;
{ part of MGetFile: scroll the file list up by one }
begin
  if DirOff > 0 then begin
    DirOff := DirOff - 1;		{decrement offset into file array}
    ShowFiles;				{list current 10 files}
  end
  else begin
    Sound(440);
    Delay(250);
    NoSound;
  end;
end;

procedure GoDown;
{ part of MGetFile:  scroll the file list down by one }
begin
  if DirOff < (NumFiles + NumDirs) - 10 then begin
    DirOff := DirOff + 1;		{increment offset into file array}
    ShowFiles;				{list current 10 files}
  end
  else begin
    Sound(440);
    Delay(250);
    NoSound;
  end;
end;

function GetCurDir:  STRING;
{ return current directory name }
var
  regs:  REGISTERS;
  DirName:  STRING;
  i:  INTEGER;
begin
  FillChar(regs,SizeOf(regs),0);	
  with regs Do
    begin
    AH := $47;				{get directory function}
    DS := Seg(DirName);			{point to where name goes}
    SI := Ofs(DirName)+1;
    DL := DriveNo + 1;			{set current drive number}
  end;
  MsDos(regs);				{do it}
  i := 1;
  repeat				{get length of directory name}
    i := i + 1;
  until DirName[i-1] < chr(32);
  DirName[0] := Chr(i-1);		{set length within string variable}
  GetCurDir := DirName;
end;

function SelectIt(var Cancel: BOOLEAN):  BOOLEAN;
{ The current file has been selected.  If it is actually a file, just
  return TRUE.  If it's actually a directory, change to that directory,
  gather file names, and return FALSE.}
var
  FillColor:  INTEGER;
  regs:  REGISTERS;
  DirName:  STRING;
begin
  FillColor := LightBlue;
  if NowRoot then begin			{if it's a disk name...}
    MouseCursor(Mx,My,Mx,My,HAND);
    DriveNo := Ord(UpCase(FileName[1]))-65;
    with regs do begin			{find number of drives}
      AH := $0E;			{requires using select drive function}
      DL := DriveNo;			{select new current drive}
    end;
    MsDos(regs);			{do it}
    FileName := '\'+#00;		{set default file name}
    NowRoot := FALSE;			{no longer at root}
    NowDir := TRUE;			{but at a directory}
  end; {if it's a disk name}
  if NowDir then begin			{if it's a directory name...}
    MouseCursor(Mx,My,Mx,My,HAND);
    FillChar(regs,SizeOf(regs),0);	{change to new directory}
    with regs do begin
      AH := $3B;			{CHDIR function}
      DS := Seg(FileName);		{pointer to directory name}
      DX := Ofs(FileName)+1;
    end;
    MsDos(regs);			{do CHDIR}
    DirList('*.*',Dirs,NumDirs,$10);	{get list of directories}
    DirList(FileLimit,Files,NumFiles,$00);	{get list of files}
    SelectIt := FALSE;
    DirOff := 0;			{reset offset}
    SetFillStyle(SolidFill,FillColor);
    MouseCursorOff(Mx,My);
    Bar(FileX+16,FileY+27,FileX+240,FileY+35); {clear old directory name}
    DirName := GetCurDir;		{find current directory name}
    OutTextXY(FileX+16,FileY+35,Chr(DriveNo+65));	{show drive}
    OutTextXY(FileX+24,FileY+35,':\'+Copy(DirName,1,25));{show directory name}
    SetFillStyle(SolidFill,FillColor);
    Bar(FileX+64,FileY+170,FileX+240,FileY+180);	{erase old file name}
    MouseCursorOn(Mx,My,HAND);
    FileName := '';			{no current file name now}
    ShowFiles;				{show new list of files}
  end
  else begin				{it's just a file name}
    if FileName = '' then		{if name is blank...}
      Cancel := TRUE;		{set cancel code}
    SelectIt := TRUE;
  end;
end; {SelectIt function}

procedure CloseDir(var Cancel : BOOLEAN);
{ close the current directory, and move up a level}
var
  x:  BOOLEAN;
  regs:  REGISTERS;
  FillColor:  INTEGER;
begin
  FileName := Dirs[2];			{get '..' for filename}
  NowDir := TRUE;			{the filename is a directory}
  if FileName[1] = '.' then		{if not at root...}
    x := SelectIt(Cancel)			{select next level}
  else begin				{else, if already at root...}
    with regs do begin			{find number of drives}
      AH := $0E;			{requires using select drive function}
      DL := DriveNo;			{select current drive}
    end;
    MsDos(regs);			{do it}
    NumDrives := regs.AL - 1;		{get number of drives}
    DirOff := 0;
    NowRoot := TRUE;			{indicate now at root}
    NowDir := FALSE;			{and not at a directory}
    FillColor := LightGray;
    SetFillStyle(SolidFill,FillColor);
    Bar(FileX+16,FileY+27,FileX+240,FileY+35);{clear old directory name}
    OutTextXY(FileX+16,FileY+35,'Drives:');	{label replaces directory}
    FileName := '';
    ShowFiles;				{show list of disks}
  end;
end;

function SetFile(var Cancel: BOOLEAN):  BOOLEAN;
{ part of MGetFile, return TRUE if file selected is same as last selection }
var
  OldName:  STRING;
  FillColor,
  Num:  INTEGER;
begin
  FillColor := LightBlue;
  OldName := FileName;
  Num := (My-(FileY+50)) div 10;	{calculate file being pointed to}
  if NowRoot then			{if now at root...}
    if Num <= NumDrives then
      FileName := Chr(Num+65)+':'	{filename is disk name}
    else
      FileName := ''
  else begin				{if not at root...}
    if Num+1+DirOff <=  NumDirs then begin{set new name to directory or file}
      FileName := Dirs[1+DirOff+Num];
      NowDir := TRUE;			{indicate this is a directory}
    end
    else begin
      if 1+DirOff+Num-NumDirs > NumFiles then
        FileName := ''			{no file this far down}
      else
        FileName := Files[1+DirOff+Num-NumDirs];
      NowDir := FALSE;			{indicate this is not a directory}
    end;
  end; {if not at root}
  SetFillStyle(SolidFill,FillColor);
  Bar(FileX+64,FileY+170,FileX+240,FileY+180);
  OutTextXY(FileX+64,FileY+180,FileName);
  SetFile := FALSE;
  if (FileName=OldName) and (FileName<>'') then {if name clicked on twice...}
    SetFile := SelectIt(Cancel);
end; {SetFile procedure}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MGetFileDef(FileSpec,DefFile,Heading:  STRING): STRING;        *}
{*  Arguments: FileSpec = allowable file names (using wildcards)            *}
{*             DefFile = default file name                                  *}
{*             Heading = heading to prompt user                             *}
{*  Function: returns name of file selected by user                         *}
{*  Results: file name string, string[1] = #255 if cancel                   *}
{*                                                                          *}
{****************************************************************************}

function MGetFileDef(FileSpec,DefFile,Heading:  STRING;
  var Cancel : BOOLEAN): STRING;
{ return a file name; FileSpec should be something along the lines of
  '*.*' or '*.txt' or whatever is appropriate }

var
  DirName:  STRING;
  Back,Fore,
	i,vartype:  INTEGER;
  regs:  REGISTERS;
  CurStyle:  TextSettingsType;
  flag:  BOOLEAN;
  EndPtr : PVariable;
begin
  Cancel := False;
	Dimall;
	GetTextSettings(CurStyle);		{detect text style}
	if CurStyle.Font > 0 then		{if not default font...}
		yofs := 2				{vertical positions need an offset}
	else
		yofs := 0;
		mtd := mtdwide;				{set parameters}
		mtynd := mtyndwide;
		FileX := 100;
		FileY := 90;
	NowRoot := FALSE;
	NowDir := FALSE;
	FileLimit := FileSpec;		{copy file spec for other routines}
  regs.AH := $19;			{find what current drive is}
  MsDos(regs);
  if GetFileType > 0 then begin
    DriveNo := 0;
    DirName := '';
  end
  else begin
    DriveNo := regs.AL;
    DirName := GetCurDir;			{find current directory name}
  end;
  MouseCursorOff(Mx,My);
  FileName := DefFile;
  GetMem(FileWindow,ImageSize(100,90,356,280));
  GetImage(FileX,FileY,FileX+256,FileY+190,FileWindow^);
  case GetFileType of
    0 : begin
		      DirList('*.*',Dirs,NumDirs,$10);		{get list of directories}
		      DirList(FileSpec,Files,NumFiles,$00);		{get list of files}
	      end;
    1 : begin
      		NumDirs := 0;
      		if filespec = '1' then
            vartype :=  1
      		else
            if filespec = '2' then
              vartype := 2
      		  else
              vartype := 0;
      		GetVarList(Files,NumFiles,EndPtr,VarType);
      	end;
    2 : begin
          NumDirs := 0;
          GetPageList(Files,NumFiles);
        end;
  end;
	Back := LightBlue;
	Fore := White;
	Boxit(FileX,FileY,FileX+256,FileY+190,White,Heading);	{main box}
	SetColor(Black);
	SetTextJustify(CenterText,CenterText);
	Rectangle(FileX+16,FileY+40,FileX+160,FileY+160);	{file name box}
	Line(FileX+144,FileY+40,FileX+144,FileY+160);		{slider boxes}
	Line(FileX+144,FileY+50,FileX+160,FileY+50);
	Line(FileX+144,FileY+150,FileX+160,FileY+150);
	SetColor(yellow);
	Rectangle(FileX+176,FileY+101,FileX+240,FileY+115);	{OK box}
	OutTextXY(FileX+208,FileY+109-yofs,'OK');
	SetColor(DarkGray);
	if GetFileType = 0 then begin
		Rectangle(FileX+176,FileY+121,FileX+240,FileY+135);	{Close box}
		OutTextXY(FileX+208,FileY+129-yofs,'Close');
	end;
	Rectangle(FileX+176,FileY+141,FileX+240,FileY+155);	{Cancel box}
	OutTextXY(FileX+208,FileY+149-yofs,'Cancel');
	SetColor(Blue);
	SetTextJustify(LeftText,BottomText);
	OutTextXY(FileX+16,FileY+180,'Name:');
	if Length(FileName) > 0 then
		OutTextXY(FileX+64,FileY+180,FileName);
	Line(FileX+64,FileY+182,FileX+240,FileY+182);	{underline name field}
	OutTextXY(FileX+149,FileY+50,Chr(24));	{up arrow}
	OutTextXY(FileX+149,FileY+160,Chr(25));	{down arrow}
	SetColor(Blue);
	if GetFileType = 0 then begin
		OutTextXY(FileX+16,FileY+35,Chr(DriveNo+65));		{show drive}
		OutTextXY(FileX+24,FileY+35,':\'+Copy(DirName,1,25));	{show directory name}
	end;
	DirOff := 0;					{offset into directory array}
	MouseCursorOn(Mx,My,Arrow);
	ShowFiles;					{list first 10 files}
	repeat
		repeat					{use mouse until key hit...}
			MStatus(NewButton,NewX,NewY);		{get mouse status}
			if (NewX <> Mx) or (NewY <> My) then	{mouse cursor moved!}
				MouseCursor(NewX,NewY,Mx,My,Arrow);
			Mx := NewX; My := NewY;			{remember new location}
			if NewButton <> Button then begin		{if button changed...}
				if NewButton > 0 then begin		{if button now down...}
					Click;
					case MouseLocate(Mx,My,7,@mtd) of	{do a command}
						1:  if SelectIt(Cancel) then begin
									ClearDir;
									MGetFileDef:=FileName;
                  BrightAll;
									exit;
								end;
						2:  if GetFileType = 0 then CloseDir(Cancel);
						3:  begin
									ClearDir;
									Cancel := TRUE;
									MGetFileDef:=FileName;
                  BrightAll;
									exit;
								end;
						4:  GoUp;
						5:  GoDown;
						6:  begin
									if SetFile(Cancel) then begin
										ClearDir;
										MGetFileDef:=FileName;
                    BrightAll;
										exit;
									end;
								end;
						7:  ScrollBar;
					else Delay(1);
					end; {case}
				end; {if button now down}
				Button := NewButton;			{remember new button setting}
			end; {if button changed}
		until KeyPressed;
		c := ReadKey;
		if c = #00 then begin			{function key hit}
			c := ReadKey;				{read rest of keystroke}
			case c of
				#72:  GoUp;				{up arrow: scroll files up}
				#73:  CloseDir(Cancel);				{PgUp: close directory}
				#80:  GoDown;				{down arrow: scroll down}
			end;
			c := #00;
		end; {if function key}
		if c = #27 then begin			{if ESC hit...}
			ClearDir;					{clear directory}
			Cancel := TRUE;			{return abort flag}
			MGetFileDef := FileName;
      Brightall;
			exit;					{abort}
		end;
		if c <> Chr(13) then begin			{if not a c/r...}
			if c = Chr(08) then begin			{if backspace...}
				if Length(FileName) > 0 then begin
					FileName := Copy(FileName,1,Length(FileName)-1); {remove last char.}
					SetFillStyle(SolidFill,Back);
					Bar(FileX+64+(8*Length(FileName)),FileY+170,FileX+72+(8*Length(FileName)),FileY+180);
				end;
			end
			else if c in [#33..#127] then begin	{if normal character...}
				if Length(FileName) >= 12 then begin	{if string too long...}
					Sound(440);				{beep!}
					Delay(250);
					NoSound;
				end
				else begin
					FileName := FileName + c;		{add character to result}
					OutTextXY(FileX+56+(8*Length(FileName)),FileY+180,c);
				end;
			end; {if not a backspace}
		end {if not a c/r}
		else begin					{else, if cr hit...}
			if GetFileType = 0 then
				if FileName[Length(FileName)] = '\' then begin	{if dir change...}
					if Length(FileName) > 1 then
						FileName[Length(FileName)] := #00
					else
						FileName := '\' + #00;
					NowDir := TRUE;
					flag := SelectIt(Cancel);			{select new directory}
					c := #255;
				end
				else if FileName[Length(FileName)] = ':' then begin {if drive change...}
					NowRoot := TRUE;
					flag := SelectIt(Cancel);			{select new drive}
					c := #255;
				end
			else begin
				ClearDir;
				MGetFileDef:=FileName;
        BrightAll;
				exit;
			end;
		end; {if drive or dir change}
	until c = #13;
	if Length(FileName) = 0 then			{if nothing entered, }
		Cancel := TRUE;			{treat as an abort}
	MGetFileDef := FileName;			{return file name}
	ClearDir;
  SetTextJustify(0,2);
	BrightAll;
end; {MGetFileDef function}

procedure MouseYNClear(x,y:  INTEGER);
{ clear MouseYN or MouseMsg message }
begin
  MouseCursorOff(Mx,My);
  PutImage(x,y,FileWindow^,NormalPut);
  MouseCursorOn(Mx,My,HAND);
  FreeMem(FileWindow,ImageSize(200,200,400,250));
end;

{****************************************************************************}
{*                                                                          *}
{*  Routine: MGetFile(FileSpec,Heading:  STRING): STRING;                   *}
{*  Arguments: FileSpec = allowable file names (using wildcards)            *}
{*             Heading = heading to prompt user                             *}
{*  Function: returns name of file selected by user                         *}
{*  Results: file name string, string[1] = #255 if cancel                   *}
{*                                                                          *}
{****************************************************************************}

function MGetFile(FileSpec,Heading: STRING; var Cancel : BOOLEAN): STRING;
var
  temp:  STRING;
begin
  temp := MGetFileDef(FileSpec,'',Heading,Cancel);
  MGetFile := temp;
end; {MGetFile function}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MouseYN(x,y: INTEGER; Heading:  STRING):  BOOLEAN;             *}
{*  Arguments: Heading = question to ask user                               *}
{*             x,y = screen position for message box                        *}
{*  Function: prompts for and gets yes or no response                       *}
{*  Results: returns TRUE is user selected Yes, FALSE otherwise             *}
{*                                                                          *}
{****************************************************************************}

function MouseYN(x,y: INTEGER; Heading:  STRING):  BOOLEAN;
{ get a yes or no response using mouse }
var
  Fore,
  Back:  INTEGER;
  CurStyle:  TextSettingsType;
begin
  GetTextSettings(CurStyle);		{detect text style}
  if CurStyle.Font > 0 then		{if not default font...}
    yofs := 2				{vertical positions need an offset}
  else
    yofs := 0;
  MouseCursorOff(Mx,My);
  GetMem(FileWindow,ImageSize(200,200,400,250));
  GetImage(x,y,x+200,y+50,FileWindow^);
  mtynd := mtyndwide;
  Fore := White;
  Back := LightCyan;
  OutlineBox(x,y,x+200,y+50,Back,Fore);
  SetColor(Black);
  SetTextJustify(LeftText,BottomText);		{draw response box}
  OutTextXY(x+16,y+15,Heading);			{add the heading}
  SetColor(LightGray);
  Rectangle(x+25,y+26,x+90,y+40);		{Yes box}
  SetTextJustify(CenterText,CenterText);	{draw response box}
  OutTextXY(x+57,y+34-yofs,'YES');
  Rectangle(x+110,y+26,x+175,y+40);		{No box}
  OutTextXY(x+142,y+34-yofs,'NO');
  SetTextJustify(LeftText,BottomText);		{draw response box}
  Mx := x+100;
  My := y+25;
  MPut(Mx,My);
  MouseCursorOn(Mx,My,Arrow);
  for i := 1 to 2 do begin			{set button locations array}
    for j := 1 to 2 do
      mtyn[i,j] := mtynd[i,j] + x;
    for j := 3 to 4 do
      mtyn[i,j] := mtynd[i,j] + y;
  end;
  repeat					{use mouse until key hit...}
    MStatus(NewButton,NewX,NewY);		{get mouse status}
    if (NewX <> Mx) or (NewY <> My) then	{mouse cursor moved!}
      MouseCursor(NewX,NewY,Mx,My,Arrow);
    Mx := NewX; My := NewY;			{remember new location}
    if NewButton <> Button then begin		{if button changed...}
      if NewButton > 0 then begin		{if button now down...}
        Click;
        case MouseLocate(Mx,My,2,@mtyn) of	{do a command}
          1: begin MouseYNClear(x,y);MouseYN := TRUE;exit;end;
          2: begin MouseYNClear(x,y);MouseYN := FALSE;exit;end;
        else Delay(1);
        end; {case}
      end; {if button now down}
      Button := NewButton;			{remember new button setting}
    end; {if button changed}
  until KeyPressed;
  c := ReadKey;
  if (UpCase(c) = 'Y') or (c = #13) then
    MouseYN := TRUE
  else
    MouseYN := FALSE;
  MouseYNClear(x,y);
  SetTextJustify(0,2);
end; {MouseYN function}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MouseMsg(x,y: INTEGER; Msg:  STRING);                          *}
{*  Arguments: Msg = message to display to user                             *}
{*             x,y = screen position for message box                        *}
{*  Function: displays one line message and waits for mouse click           *}
{*  Results: returns nothing                                                *}
{*                                                                          *}
{****************************************************************************}

procedure MouseMsg(x,y: INTEGER; Msg:  STRING);
{ display a one line message }
var
  Fore,
  Back:  INTEGER;
  CurStyle:  TextSettingsType;
begin
  GetTextSettings(CurStyle);		{detect text style}
  if CurStyle.Font > 0 then		{if not default font...}
    yofs := 2				{vertical positions need an offset}
  else
    yofs := 0;
  MouseCursorOff(Mx,My);
  GetMem(FileWindow,ImageSize(200,200,414,250));
  GetImage(x,y-14,x+200,y+50,FileWindow^);
  mtynd := mtyndwide;
  Fore := white;
  Back := lightcyan;
  OutlineBox(x,y,x+200,y+50,Back,Fore);
  setfillstyle(solidfill,fore);
  bar(x,y-14,x+200,y);
  SetColor(black);
  SetTextJustify(CenterText,CenterText);	{draw response box}
  OutTextXY(x+100,y+15,Msg);			{add the message}
  Rectangle(x+80,y+26,x+120,y+40);		{OK box}
  OutTextXY(x+100,y+34-yofs,'OK');
  SetTextJustify(LeftText,BottomText);
  Mx := x+100;
  My := y+34;
  MPut(Mx,My);
  MouseCursorOn(Mx,My,Arrow);
  repeat
    MStatus(NewButton,NewX,NewY);
  until (NewButton = 0) or (not MouseFound); {wait for button release}
  repeat					{use mouse until key hit...}
    MStatus(NewButton,NewX,NewY);		{get mouse status}
    if (NewX <> Mx) or (NewY <> My) then	{mouse cursor moved!}
      MouseCursor(NewX,NewY,Mx,My,Arrow);
    Mx := NewX; My := NewY;			{remember new location}
    if NewButton <> Button then begin		{if button changed...}
      if NewButton > 0 then begin		{if button now down...}
        Click;
      end; {if button now down}
    end; {if button changed}
  until KeyPressed or (NewButton > 0);
  if KeyPressed then
    c := ReadKey;
  MouseYNClear(x,y-14);
  repeat
    MStatus(NewButton,NewX,NewY);
  until (NewButton = 0) or (not MouseFound); {wait for button release}
  SetTextJustify(0,2);
  MouseCursorOff(Mx,My);
end; {MouseMsg procedure}

procedure MouseQClear(x1,x2,y1,y2:  INTEGER);
{ clear MouseQuestion message }
begin
  MouseCursorOff(Mx,My);
  PutImage(x1,y1,FileWindow^,NormalPut);
  FreeMem(FileWindow,ImageSize(x1,y1,x2,y2));
end;

{****************************************************************************}
{*                                                                          *}
{*Routine: MouseQuestion(Size,Default: INTEGER;Heading: STRING;Ques: QTable)*}
{*  Arguments: Size = number of answers                                     *}
{*             Default = default answer (where mouse cursor is placed)      *}
{*             Heading = question to be answered                            *}
{*             Ques = table of answers                                      *}
{*  Function: asks question and returns answer selected                     *}
{*  Results: returns integer value corresponding to selected answer         *}
{*                                                                          *}
{****************************************************************************}

{ General Purpose Mouse Question and Answer Box }

{ This routine puts up a correctly sized box on the screen, including the
  desired header and any number of answers that can be select by the mouse
  or from the keyboard.  Each answer is given a response button that the
  user can click on and the routine will exit and pass back the number of
  the button.  If a key is hit, its number is passed back also.

  The parameters passed are:

  Size:  number of answers
  Heading:  a string that is put at the top of the box
  Ques:  the address of a table of strings that are used as answers
}

function MouseQuestion(Size,Default: INTEGER;Heading: STRING; Ques: QTable)
  : INTEGER;
{ get a multiple choice response from the mouse }
var
  i,j,
  x1,x2,
  y1,y2,
  Temp :  INTEGER;
  mtq: array[1..16,1..4] of INTEGER;		{buttons for questions}
begin
  temp := 0;
  MouseCursorOff(Mx,My);
  y1 := 160 - 10 * Size;			{establish window size}
  y2 := 190 + 10 * Size;
  j := Length(Heading);
  for i := 1 to size do				{find longest string}
    if j < Length(Ques^[i]) + 4 then
      j := Length(Ques^[i]) + 4;
  x1 := 304 - 4 * j;
  x2 := 336 + 4 * j;
  GetMem(FileWindow,ImageSize(x1,y1,x2,y2));
  GetImage(x1,y1,x2,y2,FileWindow^);
  SetTextJustify(0,2);
  Boxit(x1,y1,x2,y2,white,Heading);
  SetTextJustify(LeftText,BottomText);
  SetColor(lightgray);
  for i := 1 to Size do begin			{print the answers}
    Circle(x1+17,y1+16+(i*20),7);
    OutTextXY(x1+32,y1+21+(i*20),ItoS(i)+'. '+Ques^[i]);
    mtq[i,1] := x1 + 9;				{mouse array position}
    mtq[i,2] := x1 + 25;			{  for this button}
    mtq[i,3] := y1 + 9 + (i * 20);
    mtq[i,4] := y1 + 23 + (i * 20);
  end;
  mtq[size+1,1] := x1;        { Cancel box }
  mtq[size+1,2] := x1+17;
  mtq[Size+1,3] := y1;
  mtq[Size+1,4] := y1+14;
  repeat
    MStatus(Button,NewX,NewY);
  until (Button = 0) or (not MouseFound); {wait for button release}
  Mx := x1+17;
  My := y1+16+(Default*20);
  MPut(Mx,My);					{put cursor on default answer}
  MouseCursorOn(Mx,My,Arrow);
  repeat					{use mouse until key hit...}
    MStatus(NewButton,NewX,NewY);		{get mouse status}
    if (NewX <> Mx) or (NewY <> My) then	{mouse cursor moved!}
      MouseCursor(NewX,NewY,Mx,My,Arrow);
    Mx := NewX; My := NewY;			{remember new location}
    if NewButton <> Button then begin		{if button changed...}
      if NewButton > 0 then begin		{if button now down...}
        Click;
        i := MouseLocate(Mx,My,Size+1,@mtq);
        if i > 0 then begin
          Temp := i;
        end;
      end; {if button now down}
      Button := NewButton;			{remember new button setting}
    end; {if button changed}
    if KeyPressed then begin
      c := ReadKey;
      Temp := Ord(c) - 48;
    end;
  until (Temp >= 1) and (Temp <= Size+1);
  MouseQuestion := Temp;
  MouseQClear(x1,x2,y1,y2);
  SetTextJustify(0,2);
end; {MouseQuestion function}

{****************************************************************************}
{*                                                                          *}
{*  Routine: MouseReadKey(Heading: STRING): CHAR;                           *}
{*  Arguments: Heading = question to be answered                            *}
{*  Function: asks question and waits for mouse click or single key entry;  *}
{*            if Heading is empty, just wait for click or key hit           *}
{*  Results: returns value of key hit or 0 if mouse clicked                 *}
{*                                                                          *}
{****************************************************************************}

function MouseReadKey(Heading: STRING; CS : CharSet): CHAR;
{ Read a key or wait for a mouse click }
var
  c:  CHAR;
  y1,y2,
  x1,x2:  INTEGER;
begin
  if Length(Heading) > 0 then begin		{put up question box if }
    MouseCursorOff(Mx,My);			{  a heading was passed}
    x1 := 204 - 4 * Length(Heading);
    x2 := 236 + 4 * Length(Heading);
    y1 := 250;
    y2 := 300;
    GetMem(FileWindow,ImageSize(x1,y1,x2,y2));
    GetImage(x1,y1,x2,y2,FileWindow^);
      OutlineBox(x1,y1,x2,y2,LightGray,Magenta);
    OutTextXY(x1+16,y1+30,Heading);
    MouseCursorOn(Mx,My,Arrow);
  end; {if Heading}
  C := #0;
  MStatus(NewButton,NewX,NewY);
  repeat					{use mouse until key hit...}
    Button := NewButton;			{remember new button setting}
    MStatus(NewButton,NewX,NewY);		{get mouse status}
    if (NewX <> Mx) or (NewY <> My) then	{mouse cursor moved!}
      MouseCursor(NewX,NewY,Mx,My,Arrow);
    Mx := NewX;
    My := NewY;
    If Keypressed then begin
      C := Readkey;
      If not (UpCase(C) in CS) then C := #0
    end;
  until (C <> #0) or ((NewButton <> Button) and (NewButton > 0));
  if C = #0 then Click;
  Button := NewButton;
	MouseReadKey := c;
  if Length(Heading) > 0 then begin		{remove box if one was used}
    MouseCursorOff(Mx,My);
    PutImage(x1,y1,FileWindow^,NormalPut);
    MouseCursorOn(Mx,My,Arrow);
    FreeMem(FileWindow,ImageSize(x1,y1,x2,y2));
  end; {if Heading}
end; {MouseReadKey function}

{****************************************************************************}
{*                                                                          *}
{*  Routine: KeyOrClick;                                                    *}
{*  Arguments: desired mouse cursor or 0 for none                           *}
{*  Function: waits for mouse to be clicked or any key to be hit            *}
{*  Results: nothing                                                        *}
{*                                                                          *}
{****************************************************************************}

procedure KeyOrClick(Num:  WORD);
{ Read a key or wait for a mouse click }
var
  c:  CHAR;
begin
  while KeyPressed do				{clear keyboard buffer}
    c := ReadKey;
  if MouseFound then begin
    repeat					{wait for release}
      MStatus(NewButton,NewX,NewY);		{get mouse status}
    until NewButton = 0;
  end;
  repeat					{use mouse until key hit...}
    Button := NewButton;			{remember new button setting}
    MStatus(NewButton,NewX,NewY);		{get mouse status}
    if (Num > 0)
    and ((NewX <> Mx) or (NewY <> My)) then	{mouse cursor moved!}
      MouseCursor(NewX,NewY,Mx,My,Num);
    Mx := NewX; My := NewY;			{remember new location}
  until KeyPressed or ((NewButton <> Button) and (NewButton > 0));
  if KeyPressed then				{if key was hit...}
    c := ReadKey				{clear keyboard buffer}
  else
    Click;
end; {KeyOrClick procedure}

procedure InputIt(x,y: integer; var temp: STRING; MaxLen : byte;
  Min: pointer);
{ input a string and echo it using current font }
var
  x1,y1: INTEGER;
  c:  CHAR;
  color,
  bkcolor:  WORD;
begin
  MoveTo(x,y);
  temp := '';  					{clear answer length}
  bkcolor := GetPixel(GetX,GetY);
  color := GetColor;
  repeat
    Line(GetX,GetY+7,GetX+7,GetY+7);		{draw cursor}
    MouseCursorOn(Mx,My,Arrow);
    c := MouseReadKey('',[#1..#255]);
    MouseCursorOff(Mx,My);
    if (c = #0) and (MouseLocate(Mx,My,1,Min) = 1) then { Mouse button in }
      c := #27;                                     { Cancel area }
    if c = #27 then begin			{if ESC hit...}
      temp := #27;				{abort input}
      exit;
    end;
    if (c <> #13) and (c <> #0) then begin			{if not a c/r...}
      if c = Chr(08) then begin			{if backspace...}
        if Length(temp) > 0 then begin
          temp := Copy(temp,1,Length(temp)-1);	{remove last character}
          SetFillStyle(SolidFill,bkcolor);
          Bar(GetX-8,GetY,GetX+7,GetY+11);	{clear it from screen}
          MoveTo(GetX-8,GetY);			{back up the cursor}
        end;
      end
      else begin				{if normal character...}
        if Length(temp) >= MaxLen then begin	{if string too long...}
          Sound(440);				{beep!}
          Delay(250);
          NoSound;
        end
        else begin
          temp := temp + c;			{add character to result}
          SetColor(bkcolor);
          Line(GetX,GetY+7,GetX+7,GetY+7);	{clear cursor}
          SetColor(color);
          OutText(c);
        end;
      end;
    end;
  until c = Chr(13);
  SetColor(bkcolor);
  Line(GetX,GetY+7,GetX+7,GetY+7);			{erase cursor}
  SetColor(color);
end; {InputIt procedure}

begin
  SoundOn := TRUE;				{initially allow sound}
end.
