/* Exercice 1.2 : suppression des commentaires d'un programme C.
 * Les commentaires C-style peuvent s'étendre sur plusieurs lignes.
 * On utilise une condition de départ (un "état") nommée COMMENT.
 */

%option noyywrap

/* %x = condition exclusive : dans cet état, seules les règles <COMMENT> sont actives */
%x COMMENT

%{
/* Variables C utilisées dans les actions */
int nb_comm = 0;     /* nombre de commentaires supprimés */
int nb_lignes = 0;   /* nombre de sauts de ligne à l'intérieur des commentaires */
%}

%%
 /* Chaîne de caractères C : on la recopie sans y toucher,
    pour ne pas supprimer un faux commentaire comme "a / * b * / c" */
\"([^"\\\n]|\\.)*\"    { ECHO; }

 /* Début de commentaire : on passe dans l'état COMMENT et on compte */
"/*"                   { BEGIN(COMMENT); nb_comm++; }

 /* Fin de commentaire : retour à l'état normal */
<COMMENT>"*/"          { BEGIN(INITIAL); }

 /* Dans un commentaire : on compte les lignes, le reste est ignoré (rien n'est affiché) */
<COMMENT>\n            { nb_lignes++; }
<COMMENT>.             { /* on ignore le caractère */ }

 /* Fin de fichier atteinte sans avoir fermé le commentaire : erreur */
<COMMENT><<EOF>>       { fprintf(stderr, "Erreur : commentaire non termine\n"); return 0; }
%%

int main(void)
{
    yylex();
    /* Bilan affiché sur la sortie d'erreur pour ne pas polluer le texte nettoyé */
    fprintf(stderr, "\n[%d commentaire(s) supprime(s), %d saut(s) de ligne dans les commentaires]\n",
            nb_comm, nb_lignes);
    return 0;
}
