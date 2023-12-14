/**
 This grammer only has limited suport for commands with multiple cases used. This is do to possible conflicts in
 identifier names and the current resoltion straegy. There are plans to adapt this by using lexer modes, but they
 are not yet implemented. For now the most common forms command names are used.

 Currentlyu there are some odd behaviors when handling character tokens defined here (e.g. '@') and trying to replace
 them with LEXECAL tokens ( e.g. INDIRECT: '@';)

 There is also an issue with the end of routine being detected correctly

 TODO:
     Timeouts
     W *
     Commands: tstart, trestart, trollback
     Add addtional special variables ($ECode, $Truth)
     Add addition functions ($Ascii,$Char,$Data, $Find, $FN, $ETRAP, $Next, $Randow, $Select, $Text, $View)
     Add Global UCI/Namespace
     Add Pattern Match codes
     Add ssvns


 Created by Jerry Goodnough
*/

grammar Mumps;

program:
    (commandLine)+ EOF;

commandLine:
    (lineStart)+ commandSeq lineEnd # normalLine
    | (entryRef)? lineStart commandSeq lineEnd  # entryline
    | (lineStart)+ ('.')+ commandSeq lineEnd # dotLine
    ;

lineStart:
 (SPACE)+
 ;
lineEnd:
 '\n'
 | '\r''\n'
 | EOF
 ;

commandSeq:
    (SPACE)* command (SPACE command)* (SPACE)*
    | COMMENT;

// NOT Implemented: a, p, t (tstart, trestart, trollback, z)
command:
  breakCommand
  | closeCommand
  | doCommand
  | elseCommand
  | forCommand
  | gotoCommand
  | hangCommand
  | haltCommand
  | ifCommand
  | jobCommand
  | killCommand
  | lockCommand
  | mergeCommand
  | newCommand
  | openCommand
  | quitCommand
  | readCommand
  | setCommand
  | useCommand
  | viewCommand
  | writeCommand
  | xecuteCommand;

postcondRef:
    ':'  boolExpr;

entryRef:
    id (actParams)?;

boolExpr:
    expr;


breakCommandId:
 'B'
 | 'b'
 | 'Break'
 | 'break'
 | 'BREAK'
 ;

breakCommand:
 breakCommandId (postcondRef)? SPACE (expr (postcondRef)?)?;

closeCommandId:
 'C'
 | 'c'
 | 'CLOSE'
 | 'close'
 | 'Close'
 ;

closeCommand:
 closeCommandId (postcondRef)? SPACE closeArg (COMMA closeArg)*;

closeArg:
    '@' expr(postcondRef)?
    | expr (postcondRef)?;

doCommandId:
  'D'
  | 'Do'
  | 'DO'
  | 'do'
  | 'dO';
//  D ( O)?;

doCommand:
   doWithOutArg
   | doWithArg
   ;

doWithArg:
    doCommandId postcondRef? SPACE doArgs;

doWithOutArg:
    doCommandId postcondRef? SPACE* ; //Hack for Do at EOL

doArgs:
   doArg (postcondRef)? ( COMMA doArg)*;

doArg:
    doIndirect
    | doDirect;

doIndirect:
    '@' expr;

doDirect:
    callRef (params)? (COMMA doDirect)*;

elseCommandId:
 'E'
 | 'e'
 | 'ELSE'
 | 'Else'
 | 'else';

 elseCommand:
  elseCommandId SPACE;

forCommandId:
   'F'
   | 'f'
   | 'FOR'
   | 'for'
   | 'For'
   ;
forCommand:
    forWithOutArgs
    | forWithArgs;

forWithOutArgs:
    forCommandId (postcondRef)? SPACE*;  //Hack for EOL

forWithArgs:
    forCommandId (postcondRef)? SPACE forArgs (COMMA forArgs)*;

forArgs:
    '@' expr
    | lvarName '=' expr (':' expr (':' expr)?)?;

gotoCommandId:
    'G'
    | 'g'
    | 'GOTO'
    | 'Goto'
    | 'goto'
    ;

gotoCommand:
    gotoCommandId (postcondRef)? SPACE gotoCall (COMMA gotoCall);

gotoCall:
    '@' expr (postcondRef)?
    | callRef (postcondRef)?;

hangCommandId:
 'H'
 | 'h'
 | 'HANG'
 | 'Hang'
 | 'hang'
 ;

hangCommand:
    hangCommandId (postcondRef)? SPACE hangCommandId (COMMA hangArg);

hangArg:
    '@' expr (postcondRef)?
    | expr (postcondRef)?;

haltCommandId:
 'H'
 | 'h'
 | 'HALT'
 | 'Halt'
 | 'halt'
 ;

haltCommand:
    haltCommandId (postcondRef) SPACE;


ifCommandId:
 'I'
 | 'i'
 | 'IF'
 | 'If'
 | 'if'
 | 'iF'
 ;

ifCommand:
 ifWithoutArg
 | ifWithArg
 ;

ifWithoutArg:
 ifCommandId SPACE
 ;

ifWithArg:
  ifCommandId SPACE ifArg
  ;

ifArg:
  '@' expr
  | boolExpr
  ;

jobCommandId:
   'J'
   | 'j'
   | 'Job'
   | 'JOB'
   | 'job'
   ;

jobCommand:
    jobCommandId (postcondRef)? SPACE jobArg  (COMMA jobArg)*
    ;
jobArg:
    '@' expr (postcondRef)?
    | jobTarget (postcondRef)?;


jobTarget:
    callRef
    ;
killCommmandId:
    'K'
    | 'k'
    | 'KILL'
    | 'Kill'
    | 'kill'
    ;

killCommand:
    killWithoutArg
    | killWithArgument;

killWithArgument:
    killCommmandId (postcondRef)? killArgument (postcondRef) (COMMA killArgument (postcondRef)?)*
    ;

killArgument:
     varRef;

killWithoutArg:
    killCommmandId (postcondRef)? SPACE;

lockCommandId:
 'L'
 | 'l'
 | 'LOCK'
 | 'Lock'
 | 'lock'
 ;

lockCommand:
    unlockAll
    | lockWithArgs
    ;

lockWithArgs:
   lockCommandId (postcondRef)? lockArg (COMMA lockArg)*;

lockArg:
    '@' expr (postcondRef)?
    |lockRef (postcondRef)?
    |lockPlusRef (postcondRef)?
    |lockMinusRef (postcondRef)?
    ;
lockRef:
  varRef;

lockPlusRef:
  '+' varRef;

lockMinusRef:
  '-' varRef;

unlockAll:
   lockCommandId(postcondRef)? SPACE;

mergeCommandId:
    'M'
    | 'm'
    | 'MERGE'
    | 'Merge'
    | 'merge'
    ;
mergeCommand:
    mergeCommandId (postcondRef)? mergeArg (postcondRef)? (COMMA mergeArg (postcondRef)?) *
    ;

mergeArg:
    varRef '=' varRef;

newCommandId:
    'N'
    | 'n'
    | 'NEW'
    | 'new'
    | 'New'
    ;
newCommand:
    newWithArg
    | newWithoutArgs
    ;


newWithoutArgs:
    newCommandId (postcondRef)? SPACE*;  //Hack for EOL


//We might have an issue here with indirection.
newWithArg:
    newCommandId (postcondRef)? SPACE newArgument+ (COMMA newArgument)*;


newArgument:
    LEFTPAREN (lvarName (COMMA lvarName)*) RIGHTPAREN  # newExcept
    | lvarName (postcondRef)? #newExplicit
    | '@' expr (postcondRef)? #newIdirect
    ;

openCommandId:
    'O'
    | 'o'
    | 'OPEN'
    | 'open'
    | 'Open'
    ;

openCommand:
    openCommandId (postcondRef)? SPACE openArgs (COMMA openArgs)*;


//TODO: Adopt a commmon style for handleing postcode arguments and Timeout
openArgs:
    '@' expr (postcondRef)?
    | expr (postcondRef)?
    ;

setCommandId:
 'Set'
 | 'S'
 | 's'
 | 'SET';

 quitCommandId:
 'Q'
 | 'q'
 | 'QUIT'
 | 'quit'
 | 'Quit'
 ;

quitCommand:
 quitWithoutArgs
 | quitWithArgs
 ;
quitWithoutArgs
:
 quitCommandId (postcondRef)? SPACE*;   //Hack for Quit at EOL

quitWithArgs:
 quitCommandId (postcondRef)? SPACE expr;

readCommandId:
 'R'
 | 'r'
 | 'READ'
 | 'read'
 | 'Read'
 ;

readCommand:
  readCommandId (postcondRef)? SPACE readArg (COMMA readArg)*;

//TODO: Add Fixed Length, and Timeout
readArg:
  lvarRef (postcondRef)?
  | '*' lvarRef (postcondRef)?
  | '@' expr;


 // Formation using Fragments - Breaks with id
 // S E T;
 // Formation in pur characters - Breaks with id
 // ('S' | 's') ( ('E' | 'e') ('T' | 't') )?;
setCommand:
  setCommandId postcondRef? SPACE setArgs;

setArgs:
   setArg (postcondRef)? ( COMMA setArg)*;

setArg:
    setTarget '=' expr
    | LEFTPAREN setTarget ( COMMA setTarget)* RIGHTPAREN;

setTarget:
    gvarRef
    | lvarRef
    | partialRef
    | '@' expr;

useCommandId:
  'U'
  | 'u'
  | 'USE'
  | 'use'
  | 'Use'
  ;

useCommand:
    useCommandId (postcondRef) SPACE useArg (COMMA useArg)*;

useArg:
    '@' expr (postcondRef)?
    | expr (postcondRef)?
    ;
viewCommandId:
 'V'
 | 'v'
 | 'VIEW'
 | 'view'
 | 'View'
 ;

viewArg:
    '@' expr (postcondRef)?
    | expr (postcondRef)?
    ;
viewCommand:
 viewCommandId (postcondRef) SPACE viewArg (COMMA viewArg)*
 ;

writeCommandId:
 'W'
 | 'w'
 | 'WRITE'
 | 'write'
 | 'Write'
 ;

//TODO: Deal with timeout, write * and other forms if any
writeArg:
 '@' expr (postcondRef)? # writeCmdIndiirect
 | '!'+ # writeNewLin
 | expr # writeExpression
 ;

writeCommand:
 writeCommandId (postcondRef)? SPACE writeArg (COMMA writeArg)*;


xecuteCommandId:
  'X'
  | 'Xecute'
  | 'x'
  | 'xecute' ;
//   ('X' | 'x')(  ('e' | 'E') ('C' | 'c') ('U' | 'u') ('T'| 't') ('E' | 'e') )?;
// X (E C U T E)?

xecuteCommand:
  xecuteCommandId (postcondRef)? expr (COMMA expr)*;

// **** Building blocks ***
callRef:
    label
    | label '^' routineName
    | '^' routineName;

routineName:
  id;

label:
  id;

actParams:
   '()'
   | '(' lvarName (COMMA lvarName)*')';

params:
   '()'
   | '(' paramref (COMMA paramref)*')';

paramref:
   '.'? lvarName
   | expr;

gvarName:
  '^' id;

gvarRef:
  gvarName ('(' subsciptList ')');

lvarName:
  id;

lvarRef:
  lvarName ('(' subsciptList ')')?;

varRef:
    lvarRef
    | gvarRef;

// **** Special Variables **
specialVariable:
 horlogVariableId
 | ioVariableId
 | jobVariableId
 | storageVariableId
 ;

horlogVariableId:
 '$H'
 | '$i'
 | '$HORLOG'
 | '$horlog'
 | '$Horlog'
 ;

ioVariableId:
 '$I'
 | '$i'
 | '$IO'
 | '$io'
 | '$Io'
 ;

jobVariableId:
 '$J'
 | '$j'
 | '$JOB'
 | '$job'
 | '$Job'
 ;

storageVariableId:
 '$S'
 | '$s'
 | '$STORAGE'
 | '$storage'
 | '$Storage'
 ;

// **** Functions ***
funtion:
 extractFunction
 | orderFunction
 | pieceFunction
 ;

extractFunctionId:
 '$E'
 | '$e'
 | '$Extract'
 | '$EXTRACT'
 | '$extract'
 ;

extractFunction:
    extractFunctionId LEFTPAREN expr (COMMA expr (COMMA expr)?)? RIGHTPAREN;

orderFunctionId:
    '$O'
    | '$o'
    | '$ORDER'
    | '$Order'
    | '$order'
    ;
orderFunction:
    orderFunctionId LEFTPAREN varRef (COMMA expr)? RIGHTPAREN;


pieceFunctionId:
 '$P'
 | '$p'
 | '$PIECE'
 | '$piece'
 | '$Piece'
 ;

pieceFunction:
 pieceFunctionId LEFTPAREN expr (COMMA expr (COMMA expr)?)? RIGHTPAREN;

partialRef:
 '@' expr '@' LEFTPAREN expr (COMMA expr)* RIGHTPAREN;

extrinFunctionCall:

   '$$' callRef (params)
    ;
subsciptList:
  expr (COMMA expr)*;

scinote:
    NUMBER ('E' | 'e') '+' NUMBER+
    | NUMBER ('E' | 'e') '-' NUMBER+;

expr:
    varRef # variable
    | LEFTPAREN expr RIGHTPAREN # paren
    | '\'' expr # not
    | '-' expr # unaryMinus
    | '+' expr # unaryPlus
    | extrinFunctionCall # extrinCall
    | expr '+' expr # addtion
    | expr '-' expr # subtraction
    | expr '*' expr # multipy
    | expr '\\' expr # intDivie
    | expr '/' expr # divide
    | expr '#' expr # modulo
    | expr '=' expr # equals
    | expr '>' expr # greatThan
    | expr '<' expr # lessThan
    | expr '\'<'expr # notLessThen
    | expr '\'>' expr # notGreaterThen
    | expr '_' expr # concat
    | expr '**' expr # exponent
    | expr '!' expr # or
    | expr '&' expr # and
    | expr '?' expr # patern // Todo: fix for patterns.
    | funtion # function
    | specialVariable # svn
    | partialRef # pRef
    | '@' varRef # indirect
    | scinote #scientifcNotation
    | NUMBER # number
    | STRING_LITERAL # stringLit
    ;

id:
    'B'
    | 'b'
    | 'Break'
    | 'break'
    | 'BREAK'
    | 'C'
    | 'c'
    | 'CLOSE'
    | 'close'
    | 'Close'
    | 'D'
    | 'Do'
    | 'DO'
    | 'do'
    | 'dO'
    | 'E'
    | 'e'
    | 'ELSE'
    | 'Else'
    | 'else'
    | 'G'
    | 'g'
    | 'GOTO'
    | 'Goto'
    | 'goto'
    | 'H'
    | 'h'
    | 'HANG'
    | 'Hang'
    | 'hang'
    | 'HALT'
    | 'Halt'
    | 'halt'
    | 'J'
    | 'j'
    | 'Job'
    | 'JOB'
    | 'job'
    | 'K'
    | 'k'
    | 'KILL'
    | 'Kill'
    | 'kill'
    | 'I'
    | 'i'
    | 'IF'
    | 'If'
    | 'if'
    | 'iF'
    | 'L'
    | 'l'
    | 'LOCK'
    | 'Lock'
    | 'lock'
    | 'M'
    | 'm'
    | 'MERGE'
    | 'Merge'
    | 'merge'
    | 'N'
    | 'n'
    | 'NEW'
    | 'new'
    | 'New'
    |'O'
    | 'o'
    | 'OPEN'
    | 'open'
    | 'Open'
    | 'Q'
    | 'q'
    | 'QUIT'
    | 'quit'
    | 'Quit'
    | 'R'
    | 'r'
    | 'READ'
    | 'read'
    | 'Read'
    | 'Set'
    | 'S'
    | 's'
    | 'SET'
    | 'V'
    | 'v'
    | 'VIEW'
    | 'view'
    | 'View'
    | 'X'
    | 'Xecute'
    | 'x'
    | 'xecute'
    | NAME;


CIRCUMFLEX:
 '^';

RIGHTPAREN:
 ')';

LEFTPAREN:
 '(';

COMMA:
 ',';

SPACE:
 ' ';

PLUS:
 '+';

NAME:
 ('a' .. 'z' | 'A' .. 'Z' | '%')  ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9')*;



STRING_LITERAL:
     '"' ('""' | ~'"')* '"';


NUMBER:
     ('0' .. '9')+ ('.' ('0' .. '9')+)?;


COMMENT
    : ';' ~[\r\n]*
    ;


fragment A : [aA]; // match either an 'a' or 'A'
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];
