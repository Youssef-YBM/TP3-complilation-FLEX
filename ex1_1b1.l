/* Exercice 1.1 b1) : mots-clés, symboles et opérateurs.
 * Trois catégories sont affichées : MOT-CLE, SYMBOLE, OPERATEUR.
 * Les nombres ne sont pas encore traités (voir ex1_1b2.l) : ils sont recopiés.
 */

%option noyywrap

%%
 /* Les mots-clés sont placés AVANT les symboles : pour le mot "for", les deux
    règles reconnaissent la même longueur, et Flex choisit la première écrite. */
for|while|if|else|do|int|float|char|return|void|switch|case|break  { printf("<MOT-CLE:%s> ", yytext); }

 /* Identificateur : lettre suivie de lettres/chiffres */
[a-zA-Z][a-zA-Z0-9]*                                              { printf("<SYMBOLE:%s> ", yytext); }

 /* Opérateurs à deux caractères : plus longs, donc prioritaires sur "+" ou "=" seuls */
"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="                 { printf("<OPERATEUR:%s> ", yytext); }

 /* Opérateurs à un caractère */
[-+*/%=<>!&|^~]                                                   { printf("<OPERATEUR:%s> ", yytext); }

 /* Caractères réservés : parenthèses, accolades, crochets, ponctuation */
[(){}\[\];,.:]                                                    { printf("<OPERATEUR:%s> ", yytext); }
%%

int main(void)
{
    yylex();
    return 0;
}
