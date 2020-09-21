uses
  Overlay,InitOver,Crt,Dos,Graph,Variable,Init,Mouse,MouseRS2,OOP,
  Box,Convert,Util,Misc,Menu;

{$F+}
{$O Dos}
{$O Init}
{$O Box}
{$O Convert}
{$O Util}
{$O Misc}
{$O Menu}

var sel : integer;

procedure PollMouse;
begin
    MStatus(NewButton,NewX,NewY);
    If (NewX<>Mx) Or (NewY<>My) Then begin            { if mouse has moved }
      Case MouseLocate(NewX,NewY,8,@mt) of
				0 : MouseCursor(NewX,NewY,Mx,My,Hand);       { set cursor type for }
				7 : begin
 							MouseCursorOff(Mx,My);
							SymbolAreaCursor;
						end;
				8 : begin
 							MouseCursorOff(Mx,My);
							FileAreaCursor;
						end;
        Else MouseCursor(NewX,NewY,Mx,My,Arrow);            { new location }
      end;  { of case statement }
    end;
    Mx := NewX;
    My := NewY;
    If NewButton <> Button Then begin       { if button status has changed }
      If NewButton >= 1 Then begin             {if button has been pressed }
        Click;
        J := MouseLocate(Mx,My,8,@mt);
        Case J Of
          1 : MyExitProc;                                    { control box }
					2..4 : sel := Moveit(J);                              { menu bar }
          7 : MoveSymbol;                               { flowchart symbol }
          8 : FileArea;
          Else Delay(1);                   { if button status is unchanged }
        end;  { of case statement }
      end; { of if statement }
      Button := NewButton;
    end; { of if statement }
end;  { of procedure PollMouse }

{Main Programme}
begin
  Repeat
    If keypressed then begin
      Cmd := ReadKey;
      If Cmd = #0 Then begin       { check for extended keyboard scan code }
        Cmd := ReadKey;
        Case Cmd Of
					#33 : sel := Moveit (2);         { Alt-F }
					#25 : sel := Moveit (3);         { Alt-P }
					#16 : sel := Moveit (4);         { Alt-Q }
					#45 : MyExitProc;                { Alt-X }
          #47 : begin
                  MouseCursorOff(Mx,My);
                  If ViewOn then begin
                    ClearViewBox;
                    ViewOn := False;
                  end
                  else begin
                    ViewOn := True;
                    ViewBox;
                  end;
                  MouseCursorOn(Mx,My,Arrow);
                end;
          #60 : SaveFile(ProgramName);       { F2 }
          #61 : LoadFile;                    { F3 }
          #62 : NewFile;                     { F4 }
          #63 : RunProgramme;                { F5 }
          #64 : ShowVariables;               { F6 }
          #68 : MainMenu;                    { F10 }
          Else Delay(1);
        end;  { of case statement }
      end  { of if statement }
      else
        case upcase(Cmd) of
          'R' : DrawScreen;
        end;
    end;
    Pollmouse;
  Until False;  { endless loop; program halted by MyExitProc }
end.
