{****************************************************************************}
{*                               MOUSE TOOLS                                *}
{*                        Version 1.0, April 7, 1989                        *}
{*                                                                          *}
{*    Written by:                   Copyright (C) 1989 by Nels Anderson     *}
{*    Nels Anderson                 All Rights Reserved                     *}
{*    92 Bishop Drive                                                       *}
{*    Framingham, MA 01701          Source code for use by registered       *}
{*                                  owner only.  Not to be distributed      *}
{*                                  without express consent of the writer.  *}
{*                                                                          *}
{****************************************************************************}

{Number/string conversion routines}

unit Convert;

{$O+}
{$F+}

interface

function RtoI(number:  REAL): INTEGER;
function ItoS(number:  LONGINT): STRING;
function ItoFS(number:  LONGINT;  a:  INTEGER; fill:  CHAR): STRING;
function RtoS(number:  REAL; a,b:  INTEGER): STRING;
function NoSpace(s: STRING): STRING;
function NoZero(s:string):string;
function NoRSpace(s: STRING): STRING;
function GetVal(s: STRING): REAL;
function GetIVal(s: STRING): INTEGER;
function LeftJust(s: STRING; n: INTEGER): STRING;
function Pwr(n: REAL; m: INTEGER): REAL;
function StringOf(n: INTEGER; c: CHAR): STRING;

implementation

function RtoI(number: REAL): INTEGER;
{ convert a Real to an Integer }
var
  temp:  STRING;
  code,
  i: INTEGER;
begin
  Str(number:5:0,temp);			{temp = string version of number}
  Val(temp,i,code);  			{i = integer version of temp}
  RtoI := i;
end; {RtoI function}

function ItoS(number: LONGINT): STRING; 
{ convert any integer type to a string }
var
  s: STRING[11];
begin
  Str(number,s);
  ItoS := s;
end; {ItoS function}

function ItoFS(number:  LONGINT;  a:  INTEGER; fill:  CHAR): STRING;
{ convert any integer type to a formatted string }
var
  s: STRING[33];
  i: INTEGER;
begin
  Str(number:a,s);
  for i := 1 to Length(s) do
    if s[i] = ' ' then s[i] := fill;
  ItoFS := s;
end; {ItoFS function}

function RtoS(number: REAL; a,b: INTEGER): STRING;
{ convert a real number to a string }
var
  s: STRING[11];
begin
  Str(number:a:b,s);
  RtoS := s;
end; {RtoS function}

function NoSpace(s: STRING): STRING;
{ remove leading spaces from a string }
var
  i: INTEGER;
begin
  i := 0;
  while s[i] = ' ' do
    Inc(i);
  Delete(s,1,i-1);
  NoSpace := s;
end; {NoSpace function}

function NoZero(s:string):string;
{ deletes leading and trailing zero's }
{ adapted from NoSpace by Colin Bendell }
var i:integer;
begin
  i := length(s)+1;
  repeat
    dec(i);
  until (s[i] <> '0') and (s[i] <> '.');
  delete(s,i+1,length(s));
  i := 0;
  repeat
    inc(i);
  until (s[i] <> '0');
  delete(s,1,i-1);
  NoZero := s;
end;

function NoRSpace(s: STRING): STRING;
{ remove trailing spaces from a string }
{ adapted from NoSpace by Joe Mason }
var
  i: INTEGER;
begin
  i := Length(s);
  while s[i] = ' ' do
    Dec(i);
  Delete(s,i+1,Length(s)-i);
  NoRSpace := s;
end; {NoRSpace function}

function GetVal(s: STRING): REAL;
{ Convert a string to a real number }
var
  DecPoint,
  sign,i,j:  INTEGER;
  result:  REAL;
begin
  i := 1;				{initialize offset into string}
  while s[i] = ' ' do			{ignore leading spaces}
    i := i + 1;
  sign := 1;				{assume number is positive}
  if s[i] = '-' then begin		{but if it's negative...}
    sign := -1;				{change sign}
    i := i + 1;				{point past sign}
  end;
  DecPoint := 0;
  result := 0;
  for j := i to Length(s) do begin	{for each digit in number...}
    if s[j] <> '.' then begin		{if not a decimal point...}
      if (s[j] < '0') or (s[j] > '9') then begin
        GetVal := -32767;		{invalid digit in number}
        Exit;
      end;
      result := result * 10 + Ord(s[j]) - 48;	{add digit}
    end
    else
      DecPoint := j;			{remember position}
  end; {for each digit}
  if (DecPoint > 0) and (DecPoint < Length(s)) then
    for i := 1 to Length(s) - DecPoint do
      result := result / 10;		{adjust for decimal point}
  GetVal := result * sign;
end; {GetVal function}

function GetIVal(s: STRING): INTEGER;
{ Convert a string to an integer number }
var
  result,
  sign,i,j:  INTEGER;
begin
  i := 1;				{initialize offset into string}
  while s[i] = ' ' do			{ignore leading spaces}
    i := i + 1;
  sign := 1;				{assume number is positive}
  if s[i] = '-' then begin		{but if it's negative...}
    sign := -1;				{change sign}
    i := i + 1;				{point past sign}
  end;
  result := 0;
  for j := i to Length(s) do begin	{for each digit in number...}
    if (s[j] < '0') or (s[j] > '9') then begin
      GetIVal := -32767;		{invalid digit in number}
      Exit;
    end;
    result := result * 10 + Ord(s[j]) - 48;	{add digit}
  end; {for each digit}
  GetIVal := result * sign;
end; {GetIVal function}

function LeftJust(s: STRING; n: INTEGER): STRING;
{ Left justify a string in a field of n characters }
{ Written by Joe Mason }
var
  i : INTEGER;
  result : STRING;
begin
  result[0] := Chr(n);
  for i := 1 to n do
    if i > length(s) then
      result[i] := ' '
    else
      result[i] := s[i];
  LeftJust := result;
end;

function Pwr(n: REAL;  m: INTEGER): REAL;
{ Calculate n to the mth power }
{ Written by Joe Mason }
var
  i : integer;
  temp : real;
begin
  if m = 0 then
    temp := 1
  else begin
    temp := n;
    if m < 0 then begin
      for i := -1 downto m+1 do
        temp := temp * temp;
      temp := 1 / temp;
    end
    else
      if m > 0 then
        for i := 1 to m-1 do
          temp := temp * temp;
  end;
  Pwr := temp;
end;

function StringOf(n: INTEGER; c: CHAR): STRING;
{ Forms a string of n copies of c }
{ Written by Joe Mason }
var
  i : integer;
  temp : string;
begin
  temp := '';
  for i := 1 to n do
    temp := temp + c;
  StringOf := temp;
end;

end.
