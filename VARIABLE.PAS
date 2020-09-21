unit Variable;

interface

uses Dos;

type
  SelectType = array [1..1] of STRING;
  SelectPtr = ^SelectType;
  mttype = array[1..1,1..4] of INTEGER;	{table used for MouseLocate}
  mtptr = ^mttype;			{pointer to these tables}
  dir_files = array[1..200] of STRING[13];
  QArray = array[1..99] of STRING;	{array of question string}
  QTable = ^QArray;			{pointer to these arrays}
  mtdarray = array[1..7,1..4] of INTEGER;
  mtynarray = array[1..2,1..4] of INTEGER;
  charset = set of char;
  MnuArray = array[1..7] of string;
  VBuf   = array[1..25, 1..80] of word;     { Describes the screen }
  VPtr   = ^VBuf;                     { Pointer to a screen buffer }

const
  ProgramName : DirStr = 'NONAME.FLO';  { programme name }
	Page : byte = 1; { page }
	MaxPage : byte = 1; { maximum page }
  MaxId : word = 1;
  ViewOn : Boolean = True; { view screen }
  ViewVis : Boolean = True; { view box visible }
  SwapLoc : array[Boolean] of String[7] = ('on disk', 'in EMS');
  GetFileType : 0..2 = 0;
  NewPageRequest : Boolean = False;
	Unt = 27; { unit for symbols }
  HAND = 1;			{cursor types}
  FINGER = 2;
  ARROW = 3;
  WATCH = 4;
  LArrow = 5;
  RArrow = 6;
  DArrow = 7;
  Compass = 8;
	XCursor = 9;
	OldGridX : word = 0; { grid types }
	OldGridY : word = 0;
  OldSymbol : 0..6 = 0;
  MW = 14;			{mouse cursor width -1}
  MH = 15;			{mouse cursor height -1}
  { constants for wide screen type, i.e., EGA/VGA }
  mtdwide: mtdarray = (			{buttons for directory screen}
    (276,340,190,205),			{OK button}
    (276,340,210,225),		        {Close button}
    (276,340,230,245),		        {Cancel button}
    (244,260,130,140),		        {Up Arrow}
    (244,260,240,250),		        {Down Arrow}
    (132,228,140,240),		        {File}
    (244,260,140,240) );	        {Scroll Bar}
  mtyndwide: mtynarray = (		{buttons for yes/no screen}
    (25,90,26,40),			{Yes button}
    (110,175,26,40) );			{No button}
  { constants for thin screen type, i.e., CGA }
  mtdthin: mtdarray = (			{buttons for directory screen}
    (226,290,100,115),			{OK button}
    (226,290,120,135),			{Close button}
    (226,290,140,155),			{Cancel button}
    (194,210,040,050),			{Up Arrow}
    (194,210,150,160),			{Down Arrow}
    (082,178,050,150),			{File}
    (194,210,050,150) );		{Scroll Bar}
  mtyndthin: mtynarray = (		{buttons for yes/no screen}
    (25,90,26,40),			{Yes button}
    (110,175,26,40) );			{No button}
  LXY : array[1..9,1..2] of integer = (  { top corners for major boxes }
    (31,53),
    (36,259),
    (520,52),
    (0,0),
    (0,0),
    (0,0),
    (0,0),
    (0,0),
    (0,0));
  mt : array[1..8,1..4] of integer = ( { mouse areas }
    (0,18,0,13),
    (32,87,14,27),
    (88,151,14,27),
    (152,247,14,27),
    (248,337,14,27),
    (338,441,14,27),
		(520,620,34,287),
    (31,480,53,302));

var
  MouseFound,			{TRUE if mouse driver exists, and has been
  				 initialized with MReset}
  MOn:  BOOLEAN; { mouse on }
  Button,        { mouse variables }
  NewButton,
  Mx,My,
  NewX,NewY:  INTEGER;
  MCurs:  POINTER;		{pointer to mouse cursor image}
  FileX,				{upper left corner of files box}
  FileY,
  yofs,					{vertical offset for various fonts}
  mqx,mqy:  INTEGER;			{upper left corner of question box}
  FileWindow:  POINTER;
  FileLimit,
  FileName:  STRING;
  Dirs,
  Files:  dir_files;
  c:  CHAR;
  NumDrives,
  DriveNo,
  DirOff,
  NumDirs,
  NumFiles,
  i,j:  INTEGER;
  SoundOn,				{set if sound (clicks) allowed}
  NowRoot,
  NowDir:  BOOLEAN;
  mtyn: array[1..2,1..4] of INTEGER;	{buttons for yes/no screen}
  mtd: mtdarray;			{buttons for directory screen}
  mtynd: mtynarray;			{buttons for yes/no screen}
  f : integer;
  Cmd : char;
  dshadow: array[1..2] of pointer;
  ViewBack : pointer;
  DeskFilex: 0..639;
  DeskFiley: 28..335;
  Symbx: 0..639;
  Symby: 28..335;
  PsX: Array [1..6,1..4] of integer;
  PsY: array [1..5,1..4] of integer;
	SymbBack: array[1..8] of pointer;
  Dummy : boolean;
  outputsbackground : pointer;
  topY : integer;
  MBuf   : VBuf absolute $B000:0000;         { Monochrome video RAM }
  CBuf   : Vbuf absolute $B800:0000;              { Color video RAM }
  VioPtr : VPtr;                         { Pointer to the video RAM }
  BufPtr : VPtr;           { Stores pointer to the allocated blocks }
  SavedColumn,                          { The current screen column }
  SavedRow  : byte;                      { The current screen row }

implementation

end. {of Unit Var}
