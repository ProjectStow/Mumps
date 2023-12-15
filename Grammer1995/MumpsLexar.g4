
lexer grammar MumpsLexar;

EXTRINSIC:
 '$$'
 ;

EXPONENT:
 '**';

UNDERSCORE:
    '_'
    ;

NOT_LT:
    '\'<'
    ;

NOT_GT:
    '\'>'
    ;

DOLLAR:
 '$'
 ;

PERIOD:
  '.'
  ;

AT:
 '@'
 ;

COLON:
 ':'
 ;

CIRCUMFLEX:
 '^';

RIGHTPAREN:
 ')';

LEFTPAREN:
 '(';

COMMA:
 ',';

SPACE:
 ' '+ -> mode(COMMANDMODE);  // Eat one or more spaces and then look for commands

PLUS:
 '+';

BANG:
 '!';

STAR:
 '*';

EQUALS:
 '=';

GT:
 '>';

LT:
 '<';

AND:
 '&';

MINUS:
 '-';

NOT:
  '\'';

QUESTION:
 '?'
 ;

POUND:
 '#'
 ;

SLASH:
 '/'
 ;

BACKSLASH:
 '\\'
 ;

NAME:
 ('a' .. 'z' | 'A' .. 'Z' | '%')  ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9')*;


STRING_LITERAL:
     '"' ('""' | ~'"')* '"';

EOL:
 '\r\n'
 | '\n'
 ;


NUMBER:
     ('0' .. '9')+ ('.' ('0' .. '9')+)?;


COMMENT
    : ';' ~[\r\n]*
    ;

// Functions and Special varibles - Some case might be ambiuious and require the parser to make a determination


FN_ASCII:
    DOLLAR A S C I I
    | DOLLAR A
    ;

FN_CHAR:
    DOLLAR C  H A R
    | DOLLAR C
    ;

FN_DATA:
    DOLLAR D A T A
    | DOLLAR D
    ;

SV_ECODDE:
    DOLLAR E C O D E
    | DOLLAR E C
    ;

FN_EXTRACT:
    DOLLAR E X T R A C T
    | E
    ;

FN_FORMAT_NUMBER:
    DOLLAR F N |
    DOLLAR F N U M B R
    ;

FN_FIND:
    DOLLAR F I N D
    | DOLLAR F
    ;

FN_GET:
    DOLLAR G E COMMENT
    | DOLLAR G
    ;

SV_HORLOG:
    DOLLAR H O R L O G |
    DOLLAR H
    ;

SV_IO:
    DOLLAR I O
    | DOLLAR I
    ;

SV_JOB:
    DOLLAR J O B
    | DOLLAR J
    ;

FN_NEXT:
    DOLLAR N E X T
    | DOLLAR N
    ;

FN_ORDER:
    DOLLAR O R D E R
    | DOLLAR O
    ;

FN_PIECE:
    DOLLAR P I E C E
    | DOLLAR P
    ;

FN_QUERY:
    DOLLAR Q U E R Y
    | DOLLAR Q
    ;
FN_RANDOM:
    DOLLAR R A N D O M
    | DOLLAR R
    ;

SV_STORAGE:
    DOLLAR S T O R A G E
    ;
FN_SELECT:
    DOLLAR S E L E C T
    ;

STORAGE_OR_SELECT:
    DOLLAR S
    ;

FN_TEXT:
     DOLLAR T E X T;

SV_TRUTH:
    DOLLAR T R U T H;

DOLLAR_T:
   DOLLAR T;

FN_VIEW:
    DOLLAR V I E W
    | DOLLAR V
    ;

ENOTE:
 E
 ;

mode COMMANDMODE;

BREAK:
 B (R E A K)?;

CLOSE:
 C (L O S E)?;

DO:
 D ( O)?;

ELSE:
 E (L S E)?;

FOR:
 F (O R)?;

GOTO:
 G ( O T O)?;

HANG:
  H A N G;

HALT:
  H A L T;

HALT_OR_HANG :
 H;

IF:
 I (F)?;

JOB:
  J ( O B)?;

KILL:
  K ( I L L)?;

LOCK:
  L (O C K)?;

MERGE:
 M ( E R G E)?;

NEW:
 N ( E W)?;

OPEN:
 O ( P E N)?;

QUIT:
 Q ( U I T)?;

READ:
 R ( E A D)?;

SET:
 S ( E T )?-> mode(DEFAULT_MODE);

TSTART:
 T S (T A R T)?;

TCOMMIT:
 T C ( O M M I T)?;

TROLLBACK:
 T R ( O L L B A C K)?;

USE:
 U ( S E)?;

VIEW:
 V ( I E W)?;

WRITE:
 W ( R I T E)?;

XECUTE:
 X ( E C U T E)?;

CMDSPACE:
 ' ' -> mode(DEFAULT_MODE),type(SPACE);

LINECOMMENT
    : ';' ~[\r\n]* ->mode(DEFAULT_MODE),type(COMMENT)
    ;

CMDDOT:
 '.' -> type(PERIOD);

CMDPOSTCOND:
 ':' -> mode(DEFAULT_MODE),type(COLON);

CMDEOL:   //Alway leave command mode at EOL
 ('\n' |'\r\n' | EOF)  -> mode(DEFAULT_MODE),type(EOL);


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
