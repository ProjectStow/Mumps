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
     Fix $Select



 Recent changes:
     12/15/23 - Fixed operator presidence, Conversion to Seperate Lexar started.

 Created by Jerry Goodnough
*/


parser grammar Mumps95;

options {
 tokenVocab=MumpsLexar;
 }

program:
    (commandLine)+ EOF;

commandLine:
    (lineStart)+ commandSeq lineEnd # normalLine
    | (entryRef)? lineStart commandSeq lineEnd  # entryline
    | (lineStart)+ PERIOD + commandSeq lineEnd # dotLine
    ;

lineStart:
 (SPACE)+
 ;
lineEnd:
 EOL
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


breakCommand:
 BREAK (postcondRef)? SPACE (expr (postcondRef)?)?;


closeCommand:
 CLOSE (postcondRef)? SPACE closeArg (COMMA closeArg)*;

closeArg:
    AT expr(postcondRef)?
    | expr (postcondRef)?;


doCommand:
   doWithOutArg
   | doWithArg
   ;

doWithArg:
    DO postcondRef? SPACE doArgs;

doWithOutArg:
    DO postcondRef? SPACE* ; //Hack for Do at EOL

doArgs:
   doArg (postcondRef)? ( COMMA doArg)*;

doArg:
    doIndirect
    | doDirect;

doIndirect:
    AT expr;

doDirect:
    callRef (params)? (COMMA doDirect)*;

 elseCommand:
  ELSE SPACE;

forCommand:
    forWithOutArgs
    | forWithArgs
    ;

forWithOutArgs:
    FOR (postcondRef)? SPACE*;  //Hack for EOL

forWithArgs:
    FOR (postcondRef)? SPACE forArgs (COMMA forArgs)*;

forArgs:
    AT expr
    | lvarName EQUALS expr (COLON  expr (COLON expr)?)?;


gotoCommand:
    GOTO (postcondRef)? SPACE gotoCall (COMMA gotoCall);

gotoCall:
    AT expr (postcondRef)?
    | callRef (postcondRef)?;

hangCommandId:
    HANG
    | HALT_OR_HANG
    ;

hangCommand:
    hangCommandId (postcondRef)? SPACE hangArg (COMMA hangArg);

hangArg:
    AT expr (postcondRef)?
    | expr (postcondRef)?;

haltCommandId:
 HALT
 | HALT_OR_HANG
 ;

haltCommand:
    haltCommandId (postcondRef) SPACE;

ifCommand:
 ifWithoutArg
 | ifWithArg
 ;

ifWithoutArg:
 IF SPACE
 ;

ifWithArg:
  IF SPACE ifArg
  ;

ifArg:
  AT expr
  | boolExpr
  ;

jobCommand:
    JOB (postcondRef)? SPACE jobArg  (COMMA jobArg)*
    ;
jobArg:
    AT expr (postcondRef)?
    | jobTarget (postcondRef)?;


jobTarget:
    callRef
    ;

killCommand:
    killWithoutArg
    | killWithArgument;

killWithArgument:
    KILL (postcondRef)? killArgument (postcondRef) (COMMA killArgument (postcondRef)?)*
    ;

killArgument:
     varRef;

killWithoutArg:
    KILL (postcondRef)? SPACE;


lockCommand:
    unlockAll
    | lockWithArgs
    ;

lockWithArgs:
   LOCK (postcondRef)? lockArg (COMMA lockArg)*;

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
   LOCK(postcondRef)? SPACE;

mergeCommand:
    MERGE (postcondRef)? mergeArg (postcondRef)? (COMMA mergeArg (postcondRef)?) *
    ;

mergeArg:
    varRef EQUALS varRef;

newCommand:
    newWithArg
    | newWithoutArgs
    ;


newWithoutArgs:
    NEW (postcondRef)? SPACE*;  //Hack for EOL


//We might have an issue here with indirection.
newWithArg:
    NEW (postcondRef)? SPACE newArgument+ (COMMA newArgument)*;


newArgument:
    LEFTPAREN (lvarName (COMMA lvarName)*) RIGHTPAREN  # newExcept
    | lvarName (postcondRef)? #newExplicit
    | AT expr (postcondRef)? #newIdirect
    ;


openCommand:
    OPEN (postcondRef)? SPACE openArgs (COMMA openArgs)*;


//TODO: Adopt a commmon style for handleing postcode arguments and Timeout
openArgs:
    AT expr (postcondRef)?
    | expr (postcondRef)?
    ;



quitCommand:
 quitWithoutArgs
 | quitWithArgs
 ;
quitWithoutArgs
:
 QUIT (postcondRef)? SPACE*;   //Hack for Quit at EOL

quitWithArgs:
 QUIT (postcondRef)? SPACE expr;

readCommand:
  READ (postcondRef)? SPACE readArg (COMMA readArg)*;

//TODO: Add Fixed Length, and Timeout
readArg:
  lvarRef (postcondRef)?
  | STAR lvarRef (postcondRef)?
  | AT expr;


setCommand:
  SET postcondRef? SPACE setArgs;

setArgs:
   setArg (postcondRef)? ( COMMA setArg)*;

setArg:
    setTarget EQUALS expr
    | LEFTPAREN setTarget ( COMMA setTarget)* RIGHTPAREN;

setTarget:
    gvarRef
    | lvarRef
    | partialRef
    | AT expr;

useCommand:
    USE (postcondRef) SPACE useArg (COMMA useArg)*;

useArg:
    AT expr (postcondRef)?
    | expr (postcondRef)?
    ;

viewArg:
    AT expr (postcondRef)?
    | expr (postcondRef)?
    ;
viewCommand:
 VIEW (postcondRef) SPACE viewArg (COMMA viewArg)*
 ;


//TODO: Deal with timeout, write * and other forms if any
writeArg:
 AT expr (postcondRef)? # writeCmdIndiirect
 | BANG + # writeNewLin
 | expr # writeExpression
 ;

writeCommand:
 WRITE (postcondRef)? SPACE writeArg (COMMA writeArg)*;


xecuteCommand:
  XECUTE (postcondRef)? expr (COMMA expr)*;

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
   LEFTPAREN RIGHTPAREN
   | LEFTPAREN lvarName (COMMA lvarName)* RIGHTPAREN;

params:
   LEFTPAREN RIGHTPAREN
   | LEFTPAREN paramref (COMMA paramref)*RIGHTPAREN;

paramref:
   PERIOD ? lvarName
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
 SV_HORLOG
 | SV_IO
 | SV_JOB
 | storageVariableId
 ;


storageVariableId:
 SV_STORAGE
 | STORAGE_OR_SELECT
 ;

// **** Functions ***
funtion:
 extractFunction
 | orderFunction
 | pieceFunction
 | selectFunction
 ;

selectFunctionId:
 FN_SELECT
 | STORAGE_OR_SELECT
 ;

selectPair:
  expr ':' expr
  ;

selectFunction:
  selectFunctionId LEFTPAREN selectPair ( ',' selectPair)* RIGHTPAREN
  ;


extractFunction:
    FN_EXTRACT LEFTPAREN expr (COMMA expr (COMMA expr)?)? RIGHTPAREN;

orderFunction:
    FN_ORDER LEFTPAREN varRef (COMMA expr)? RIGHTPAREN;



pieceFunction:
 FN_PIECE LEFTPAREN expr (COMMA expr (COMMA expr)?)? RIGHTPAREN;

partialRef:
 AT expr AT LEFTPAREN expr (COMMA expr)* RIGHTPAREN;

extrinFunctionCall:

   EXTRINSIC callRef (params)
    ;
subsciptList:
  expr (COMMA expr)*;

scinote:
    NUMBER ENOTE PLUS NUMBER+
    | NUMBER ENOTE MINUS NUMBER+;

expr:
    varRef # variable
    | LEFTPAREN expr RIGHTPAREN # paren
    | uop expr #unary
    | expr binop expr # binaryop
    | expr QUESTION expr # patern  // Todo: fix for patterns.
    | extrinFunctionCall # extrinCall
    | funtion # function
    | specialVariable # svn
    | partialRef # pRef
    | AT varRef # indirect
    | scinote #scientifcNotation
    | NUMBER # number
    | STRING_LITERAL # stringLit
    ;

   uop:
    ( NOT | PLUS  | MINUS )
    ;

   binop:
     ( PLUS| MINUS  |  STAR | BACKSLASH | SLASH |POUND |  EQUALS | GT  |LT   NOT_GT |  NOT_LT | UNDERSCORE | EXPONENT| BANG | AND | BANG );

id:
  NAME;


