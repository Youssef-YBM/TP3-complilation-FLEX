/* TP3 Compilation - tous les exercices dans un seul analyseur, avec menu.
 * Chaque exercice correspond a une condition de depart (%x).
 */
%option noyywrap

%x E11A E11B1 E11B2 E12 E12C E13A E13B E13C E13D

L       [a-zA-Z]
EXP     [eE][-+]?[0-9]+
KW      for|while|if|else|do|int|float|char|return|void|switch|case|break

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int nb_comm = 0;     /* ex 1.2 : commentaires supprimes */
int nb_lignes = 0;   /* ex 1.2 : lignes contenues dans les commentaires */
%}

%%

 /* ---------- Exercice 1.1 a) ---------- */
<E11A>{L}[a-zA-Z0-9]*      { printf("<%s> ", yytext); }

 /* ---------- Exercice 1.1 b1) ---------- */
<E11B1>{KW}                { printf("<MOT-CLE:%s> ", yytext); }
<E11B1>{L}[a-zA-Z0-9]*     { printf("<SYMBOLE:%s> ", yytext); }
<E11B1>"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="  { printf("<OPERATEUR:%s> ", yytext); }
<E11B1>[-+*/%=<>!&|^~]     { printf("<OPERATEUR:%s> ", yytext); }
<E11B1>[(){}\[\];,.:]      { printf("<OPERATEUR:%s> ", yytext); }

 /* ---------- Exercice 1.1 b2) ---------- */
<E11B2>{KW}                { printf("<MOT-CLE:%s> ", yytext); }
<E11B2>{L}[a-zA-Z0-9]*     { printf("<SYMBOLE:%s> ", yytext); }
<E11B2>[0-9]+              { printf("<ENTIER:%s> ", yytext); }
<E11B2>[0-9]+"."[0-9]*({EXP})?|"."[0-9]+({EXP})?|[0-9]+{EXP}  { printf("<FLOTTANT:%s> ", yytext); }
<E11B2>"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="  { printf("<OPERATEUR:%s> ", yytext); }
<E11B2>[-+*/%=<>!&|^~]     { printf("<OPERATEUR:%s> ", yytext); }
<E11B2>[(){}\[\];,.:]      { printf("<OPERATEUR:%s> ", yytext); }

 /* ---------- Exercice 1.2 : suppression des commentaires ---------- */
<E12>\"([^"\\\n]|\\.)*\"   { ECHO; /* chaine C : contenu intact */ }
<E12>"/*"                  { BEGIN(E12C); nb_comm++; }
<E12C>"*/"                 { BEGIN(E12); }
<E12C>\n                   { nb_lignes++; }
<E12C>.                    { /* ignore */ }
<E12C><<EOF>>              { fprintf(stderr, "Erreur : commentaire non termine\n"); return 0; }

 /* ---------- Exercice 1.3 : un mot par ligne ---------- */
<E13A,E13B,E13C,E13D>\n    { ECHO; }
<E13A,E13B,E13C,E13D>[ \t] { ECHO; }

<E13A>^{L}*[aA]{L}*[eE]{L}*[iI]{L}*[oO]{L}*[uU]{L}*$   { printf("%s  -> ACCEPTE", yytext); }
<E13B>^(a[ab]*|[ab]*a)$                                { printf("%s  -> ACCEPTE", yytext); }
<E13C>^((ab)+a?|(ba)+b?|a|b)$                          { printf("%s  -> ACCEPTE", yytext); }
<E13D>^(b+)?(a+bb+)*(a+b?)?$                           { printf("%s  -> ACCEPTE", yytext); }

<E13A,E13B,E13C,E13D>.     { printf("<?%c>", yytext[0]); }

%%

/* lit tout le fichier : supprime les \r (fichiers Windows) et garantit un \n final */
static char *lire(FILE *f)
{
    size_t n = 0, cap = 1024;
    char *buf = malloc(cap);
    int c;
    while ((c = fgetc(f)) != EOF) {
        if (c == '\r') continue;
        if (n + 2 >= cap) buf = realloc(buf, cap *= 2);
        buf[n++] = c;
    }
    if (n == 0 || buf[n - 1] != '\n') buf[n++] = '\n';
    buf[n] = 0;
    return buf;
}

static void analyser(int cond, const char *nom)
{
    FILE *f = fopen(nom, "r");
    char *buf;
    YY_BUFFER_STATE st;

    if (!f) {
        perror(nom);
        return;
    }
    buf = lire(f);
    fclose(f);

    nb_comm = nb_lignes = 0;
    printf("\n----- resultat (%s) -----\n", nom);
    st = yy_scan_string(buf);
    BEGIN(cond);
    yylex();
    yy_delete_buffer(st);
    free(buf);
    if (cond == E12)
        printf("\n[%d commentaire(s) supprime(s), %d saut(s) de ligne dans les commentaires]\n",
               nb_comm, nb_lignes);
    printf("\n----- fin -----\n");
}

int main(void)
{
    static const struct {
        const char *titre;
        int cond;
        const char *defaut;
    } ex[] = {
        { "Ex 1.1 a)  symboles (lettre puis lettres/chiffres)", E11A,  "0.dat"  },
        { "Ex 1.1 b1) mots-cles, operateurs, symboles",         E11B1, "0.dat"  },
        { "Ex 1.1 b2) + valeurs numeriques",                    E11B2, "0.dat"  },
        { "Ex 1.2     suppression des commentaires C",          E12,   "prog.c" },
        { "Ex 1.3 a)  les 5 voyelles dans l'ordre",             E13A,  "a.txt"  },
        { "Ex 1.3 b)  {a,b} commence ou finit par a",           E13B,  "b.txt"  },
        { "Ex 1.3 c)  {a,b} sans 2 lettres identiques de suite", E13C, "c.txt"  },
        { "Ex 1.3 d)  {a,b} sans la sous-chaine aba",           E13D,  "d.txt"  },
    };
    char ligne[256];
    int i, choix;

    for (;;) {
        printf("\n===== TP3 - MENU =====\n");
        for (i = 0; i < 8; i++)
            printf("  %d. %s\n", i + 1, ex[i].titre);
        printf("  0. Quitter\n");
        printf("Votre choix : ");
        if (!fgets(ligne, sizeof ligne, stdin))
            break;
        choix = atoi(ligne);
        if (choix == 0)
            break;
        if (choix < 1 || choix > 8) {
            printf("Choix invalide.\n");
            continue;
        }
        printf("Fichier a analyser (Entree = %s) : ", ex[choix - 1].defaut);
        if (!fgets(ligne, sizeof ligne, stdin))
            break;
        ligne[strcspn(ligne, "\r\n")] = 0;
        analyser(ex[choix - 1].cond, ligne[0] ? ligne : ex[choix - 1].defaut);
    }
    return 0;
}
