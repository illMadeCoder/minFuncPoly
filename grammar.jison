/*
  By : Jesse Bergerstock
  Date : 02/19/2016
  Description : A minimal functional language grammar.
*/

%lex
%%

" "+                   /**/
(\n|";")+              return 'NEWLINE'
"print"                return 'PRINT'
"dump"                 return 'DUMP'
"func"                 return 'FUNCTION_DEFINE'
"("                    return 'LEFT_PAR'
")"                    return 'RIGHT_PAR'
","                    return 'COMMA'
"::"                   return 'SIGNATURE'
"|"                    return 'GUARD'
"\\"                   return 'END_GUARD'
"->"                   return 'NEXT_PARAMETER'
"+"|"-"|"*"|"/"|"%"    return 'BINARY_OP'
">"|"<"|">="|"<="|"==" return 'COMPARE'
"and"|"or"              return 'LOGIC'
[0-9]+                 return 'NUMBER'
[a-zA-Z]+              return 'IDENTIFIER'
"="                    return 'EQUAL'
<<EOF>>                return 'EOF'
.                      return 'INVALID'

/lex
/* precedence */
%left BINARY_OP
%right NEWLINE
%start program
%%

/* Grammar */

program
  : statements EOF
    {return {type : "program", statements : $1};}
  ;
statements
  : statement statements
    {$$ = [$1].concat($2)}
  | statement
    {$$ = [$1]}
  ;
statement
  : assignment NEWLINE
  | function_define NEWLINE
  | print NEWLINE
  | dump NEWLINE
  ;
print
  : PRINT expression
    {$$ = {type : "print", expression : $2, string : ""}}
  | PRINT STRING expression
    {$$ = {type : "print", expression : $3, string : $2}}
  ;
dump
  : DUMP
    {$$ = {type : "dump"}}
  ;
assignment
  : IDENTIFIER EQUAL expression
    {$$ = {type : "assignment", symbol : $1, expression : $3}}
  ;
expression
  : IDENTIFIER
    {$$ = {type : "identifier", symbol : $1, line : @1}}
  | NUMBER
    {$$ = {type : "number", value : parseInt($1)}}
  | expression BINARY_OP expression
    {$$ = {type : "binary_operation", lhs : $1, op : $2, rhs : $3}}
  | IDENTIFIER arguments
    {$$ = {type : "function_call", symbol : $1, arguments : $2}}
  ;
arguments
  : LEFT_PAR RIGHT_PAR
    {$$ = []}
  | LEFT_PAR expression RIGHT_PAR
    {$$ = [$2]}
  | LEFT_PAR expression argument
    {$$ = [$2].concat($3)}
  ;
argument
  : COMMA expression argument
    {$$ = [$2].concat($3)}
  | COMMA expression RIGHT_PAR
    {$$ = [$2]}
  ;
function_define
  : FUNCTION_DEFINE IDENTIFIER SIGNATURE parameters NEWLINE function_body
    {$$ = {type : "function_define", symbol : $2, parameters : $4, function_body : $6}}
  ;
function_body
  /*No conditional*/
  : expression
    {$$ = {type : "function_body_unconditional", expression : $1}}
  /*conditional*/
  | guards
    {$$ = {type : "function_body_conditional", guards : $1}}
  ;

guards
  : GUARD propositions expression NEWLINE guard
    {$$ = [{propositions : $2, expression : $3}].concat($5)}
  ;
guard
  : GUARD propositions expression NEWLINE guard
    {$$ = [{propositions : $2, expression : $3}].concat($5)}
  | END_GUARD
    {$$ = []}
  ;
propositions
  : expression COMPARE expression LOGIC proposition
    {$$ = [{logic : $4, lhs : $1, rhs : $3, compare : $2}].concat($5)}
  | expression COMPARE expression EQUAL
    {$$ = [{logic : $4, lhs : $1, rhs : $3, compare : $2}]}
  ;
proposition
  : expression COMPARE expression LOGIC proposition
    {$$ = [{logic : $4, lhs : $1, rhs : $3, compare : $2}].concat($5)}
  | expression COMPARE expression EQUAL
    {$$ = [{logic : $4, lhs : $1, rhs : $3, compare : $2}]}
  ;

parameters
  /*No parameters*/
  : NEXT_PARAMETER
    {$$ = []}
  | IDENTIFIER NEXT_PARAMETER parameter
    {$$ = [$1].concat($3)}
  ;
parameter
  : IDENTIFIER NEXT_PARAMETER parameter
    {$$ = [$1].concat($3)}
  |
    {$$ = []}
  ;
