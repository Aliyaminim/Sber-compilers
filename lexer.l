%option c++
%{
    /*definitions*/
    #include <iostream>
    #include <stdexcept>
    int comments = 0;
    int begin_comments_line = 0;
%}

%option noyywrap nounput noinput nodefault yylineno

WS [ \t\n\r\v]+
DIGIT [0-9]
DIGIT1 [1-9]
NUMBER (0|{DIGIT1}{DIGIT}*)
ID      [a-z][a-zA-Z_0-9]*
TYPE_ID [A-Z][a-zA-Z_0-9]*
STRING \"[^\n"]*\"
SINGLE_COMMENT [-][-]

IF      ["i"|"I"]["f"|"F"]
THEN    ["t"|"T"]["h"|"H"]["e"|"E"]["n"|"N"]
ELSE    ["e"|"E"]["l"|"L"]["s"|"S"]["e"|"E"]
WHILE   ["w"|"W"]["h"|"H"]["i"|"I"]["l"|"L"]["e"|"E"]
PRINT   ["p"|"P"]["r"|"R"]["i"|"I"]["n"|"N"]["t"|"T"]
PRINTLN ["p"|"P"]["r"|"R"]["i"|"I"]["n"|"N"]["t"|"T"]["l"|"L"]["n"|"N"]
LOOP    ["l"|"L"]["o"|"O"]["o"|"O"]["p"|"P"]
NOT     ["n"|N]["o"|"O"]["t"|"T"]

%s MULTI_COMMENT

/* rules */
%%

<INITIAL>"/*" { begin_comments_line = yylineno; comments++; BEGIN(MULTI_COMMENT);}
<MULTI_COMMENT>
{
    "*/"        { comments--; if (!comments) BEGIN(INITIAL);}
    "/*"        { comments++; }
    [^*\n]*        /* eat anything that's not a '*' */
    "*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
    "\n"          yylineno++;
    <<EOF>> { std::cout << "Error on line " << begin_comments_line << ":";
              throw std::runtime_error(" Unterminated comment '/*'");
            }
}

{WS}

{SINGLE_COMMENT}.*\n

"("         {std::cout << "LPAREN (" << std::endl; }
")"         {std::cout << "RPAREN )" << std::endl; }
"{"         {std::cout << "LBRACE {" << std::endl; }
"}"         {std::cout << "RBRACE }" << std::endl; }
";"         {std::cout << "SCOLON ;" << std::endl; }
":"         {std::cout << "COLON :" << std::endl; }
","         {std::cout << "COMMA ," << std::endl; }

"+"         { std::cout << "ARITH_OP PLUS" << std::endl; }
"-"         { std::cout << "ARITH_OP MINUS" << std::endl; }
"*"         { std::cout << "ARITH_OP MULTIPLY" << std::endl; }
"/"         { std::cout << "ARITH_OP DIVIDE" << std::endl; }
"%"         { std::cout << "ARITH_OP MODULUS" << std::endl; }
"="         { std::cout << "ARITH_OP ASSIGN" << std::endl; }

"=="        { std::cout << "COMP_OP EQUAL" << std::endl; }
"!="        { std::cout << "COMP_OP NOT_EQUAL" << std::endl; }
"<"         { std::cout << "COMP_OP LESS" << std::endl; }
"<="        { std::cout << "COMP_OP LESS_EQ" << std::endl; }
">"         { std::cout << "COMP_OP GREATER" << std::endl; }
">="        { std::cout << "COMP_OP GREATER_EQ" << std::endl; }

"&&"        { std::cout << "LOGIC_OP AND" << std::endl; }
"||"        { std::cout << "LOGIC_OP OR" << std::endl; }
"!"         { std::cout << "LOGIC_OP NOT" << std::endl; }

{IF}        {std::cout << "KEYWORD IF" << std::endl; }
{THEN}      {std::cout << "KEYWORD THEN" << std::endl; }
{ELSE}      {std::cout << "KEYWORD ELSE" << std::endl; }
{WHILE}     {std::cout << "KEYWORD WHILE" << std::endl; }
{PRINT}     {std::cout << "PRINT" << std::endl; }
{PRINTLN}   {std::cout << "PRINTLN" << std::endl; }
{LOOP}      {std::cout << "KEYWORD LOOP" << std::endl; }
{NOT}       {std::cout << "KEYWORD NOT" << std::endl; }
"true"      {std::cout << "KEYWORD true" << std::endl; }
"false"     {std::cout << "KEYWORD false" << std::endl; }
"?"         {std::cout << "SCAN" << std::endl; }

{ID}        { std::cout << "ID " << yytext << std::endl; }

{TYPE_ID}   { std::cout << "TYPE_ID " << yytext << std::endl; }

{NUMBER}    { std::cout << "NUMBER " << yytext << std::endl; }

{STRING}    { std::cout << "STRING " << yytext << std::endl; }

.           { std::cout << "Error on line " << yylineno << ": '" << yytext << "'";
              throw std::runtime_error(" Unknown symbol"); }
<<EOF>>     { return 0; }

%%

int main() {
    int ret = 0;
    FlexLexer* lexer = new yyFlexLexer;
    try {
        while(lexer->yylex() != 0)
        ;
    }
    catch(const std::runtime_error& e) {
        ret = 1;
        std::cout << e.what() << std::endl;
    }
    return ret;
}