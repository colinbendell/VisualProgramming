unit InitOver;

{$F+}

interface

function IsEgaVga : boolean;
procedure DispInit;
procedure EgaVgaDriverProc;

implementation

uses Overlay,OverXMS,Dos,Variable;

{**********************************************************************
*  IsEgaVga : Determines whether an EGA or a VGA card is installed.   *
**-------------------------------------------------------------------**
*  Input   : None                                                     *
*  Output  : Boolean --> Yes or No                                    *
**********************************************************************}

function IsEgaVga : boolean;

var Regs : Registers;        { Processor registers for interrupt call }

begin
  Regs.AX := $1a00;                { Function 1AH applies to VGA only }
  Intr( $10, Regs );
  if ( Regs.AL = $1a ) then              { Is the function available? }
    case Regs.BL of                               { Yes --> Pass code }
         4 : IsEgaVga := true;                    { EGA COLOR }
         5 : IsEgaVga := true;                    { EGA MONO }
         7 : IsEgaVga := true;                    { VGA MONO }
         8 : IsEgaVga := true;                    { VGA COLOR }
      else IsEgaVga := False;                     { None }
    end
  else                              { Not a VGA, but it may be an EGA }
    begin
      Regs.ah := $12;                            { Call function 12H, }
      Regs.bl := $10;                            { sub-function 10H   }
      intr($10, Regs);                              { Call video BIOS }
      if ( Regs.bl <> $10 ) then                          { EGA card? }
        IsEgaVga := true                { Yes --> Pass True }
      else IsEgaVga := False;           { No --> Pass False }
    end;
end;

{*********************************************************************}
{* DispInit: Creates a pointer to video RAM.                         *}
{* Input   : None                                                    *}
{* Output  : None                                                    *}
{*********************************************************************}

procedure DispInit;

var Regs: Registers;                  { Store the processor registers }

begin
  Regs.ah := $0f;               { Funct. no. 15 = Read the video mode }
  Intr($10, Regs);                    { Call the BIOS video interrupt }
  if Regs.al=7 then                          { Monochrome video card? }
    VioPtr := @MBuf     { Yes --> Set pointer to monochrome video RAM }
  else                                 { Handle it as EGA, VGA or CGA }
    VioPtr := @CBuf;                 { Set pointer to color video RAM }
end;

procedure EgaVgaDriverProc; external;
{$L EGAVGA.OBJ }
{ Taken from BGIDRIV.PAS -
  Copyright (c) 1985, 1990 by Borland International, Inc. }

begin
  OvrInit('VP.OVR');    { initialize overlay }
  case ovrResult of     { if error }
    OvrNotFound : begin { write error }
                    writeln('Missing file VP.OVR.');
                    halt(1);
                  end;
    OvrError : begin
                 writeln('Overlay manager error.');
                 halt(1);
               end;
    OvrOK    : OvrInitXMS;
  end;
  If OvrResult <> OvrOK then begin
    Writeln(#13,'Error Using XMS -- Switching to EMS');  {Display Error}
    OvrInitEMS;           { overlay in EMS memory }
    if OvrResult <> OvrOK then
      halt(1);
  end;
end. { of unit InitOver }