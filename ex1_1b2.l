%option noyywrap
EXP     [eE][-+]?[0-9]+
%%
for|while|if|else|do|int|float|char|return|void|switch|case|break  { printf("<MOT-CLE:%s> ", yytext); }
[a-zA-Z][a-zA-Z0-9]*                                              { printf("<SYMBOLE:%s> ", yytext); }
[0-9]+                                                            { printf("<ENTIER:%s> ", yytext); }
[0-9]+"."[0-9]*({EXP})?|"."[0-9]+({EXP})?|[0-9]+{EXP}             { printf("<FLOTTANT:%s> ", yytext); }
"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="                 { printf("<OPERATEUR:%s> ", yytext); }
[-+*/%=<>!&|^~]                                                   { printf("<OPERATEUR:%s> ", yytext); }
[(){}\[\];,.:]                                                    { printf("<OPERATEUR:%s> ", yytext); }
%%
int main(void)
{
    yylex();
    return 0;
}
