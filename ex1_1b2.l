/* Exercice 1.1 b2) : ajout des valeurs numériques (entières et flottantes). */

%option noyywrap

/* Définition d'une macro : l'exposant d'un flottant, par exemple e5, E-3, e+10 */
EXP     [eE][-+]?[0-9]+

%%
 /* Mots-clés avant symboles (même longueur : la première règle l'emporte) */
for|while|if|else|do|int|float|char|return|void|switch|case|break  { printf("<MOT-CLE:%s> ", yytext); }

 /* Identificateurs */
[a-zA-Z][a-zA-Z0-9]*                                              { printf("<SYMBOLE:%s> ", yytext); }

 /* Entier : suite de chiffres */
[0-9]+                                                            { printf("<ENTIER:%s> ", yytext); }

 /* Flottant : 12.3   12.   .5   1e5   2.5e-3
    Pour "12.3", cette règle (4 caractères) est plus longue que la règle
    des entiers (2 caractères) : Flex choisit donc le flottant. */
[0-9]+"."[0-9]*({EXP})?|"."[0-9]+({EXP})?|[0-9]+{EXP}             { printf("<FLOTTANT:%s> ", yytext); }

 /* Opérateurs à deux caractères */
"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="                 { printf("<OPERATEUR:%s> ", yytext); }

 /* Opérateurs à un caractère */
[-+*/%=<>!&|^~]                                                   { printf("<OPERATEUR:%s> ", yytext); }

 /* Caractères réservés */
[(){}\[\];,.:]                                                    { printf("<OPERATEUR:%s> ", yytext); }
%%

int main(void)
{
    yylex();
    return 0;
}
