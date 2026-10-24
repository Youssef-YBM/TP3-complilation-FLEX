%option noyywrap
%x COMMENT

%{
int nb_comm = 0;     /* commentaires supprimes */
int nb_lignes = 0;   /* lignes contenues dans les commentaires */
%}

%%
\"([^"\\\n]|\\.)*\"    { ECHO; /* chaine C : on ne touche pas a son contenu */ }
"/*"                   { BEGIN(COMMENT); nb_comm++; }
<COMMENT>"*/"          { BEGIN(INITIAL); }
<COMMENT>\n            { nb_lignes++; }
<COMMENT>.             { /* ignore */ }
<COMMENT><<EOF>>       { fprintf(stderr, "Erreur : commentaire non termine\n"); return 0; }
%%
int main(void)
{
    yylex();
    fprintf(stderr, "\n[%d commentaire(s) supprime(s), %d saut(s) de ligne dans les commentaires]\n",
            nb_comm, nb_lignes);
    return 0;
}
