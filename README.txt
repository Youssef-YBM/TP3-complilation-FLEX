TP3 COMPILATION - INITIATION A FLEX
===================================

CONTENU

  tp3_menu.l   Tous les exercices dans un seul analyseur, avec menu (test final)

  ex1_1a.l     Ex 1.1 a)  symboles : lettre suivie de lettres/chiffres
  ex1_1b1.l    Ex 1.1 b1) mots-cles, operateurs, symboles
  ex1_1b2.l    Ex 1.1 b2) + valeurs numeriques (entiers et flottants)
  ex1_2.l      Ex 1.2     suppression des commentaires /* ... */ (multi-lignes)
  ex1_3a.l     Ex 1.3 a)  les 5 voyelles dans l'ordre
  ex1_3b.l     Ex 1.3 b)  {a,b} commencant ou finissant par a
  ex1_3c.l     Ex 1.3 c)  {a,b} sans 2 occurrences consecutives du meme caractere
  ex1_3d.l     Ex 1.3 d)  {a,b} sans la sous-chaine aba

  Fichiers de test : 0.dat (ex 1.1), prog.c (ex 1.2),
                     a.txt b.txt c.txt d.txt (ex 1.3)

COMPILATION (Cygwin, il faut flex et gcc installes)

  Programme avec menu :
      flex tp3_menu.l
      gcc lex.yy.c -o tp3_menu
      ./tp3_menu

  Un exercice seul (exemple ex1_1a) :
      flex ex1_1a.l
      gcc lex.yy.c -o ex1_1a
      ./ex1_1a < 0.dat

  Tous les fichiers .l contiennent %option noyywrap et leur propre main(),
  donc l'option -ll (ou -lfl) n'est pas necessaire.
  Si on prefere la commande du sujet : gcc lex.yy.c -ll  (ou -lfl sous Cygwin)
  fonctionne aussi.

COMMANDES POUR CHAQUE EXERCICE

  Ex 1.1 a)
      flex ex1_1a.l && gcc lex.yy.c -o ex1_1a && ./ex1_1a < 0.dat
  Ex 1.1 b1)
      flex ex1_1b1.l && gcc lex.yy.c -o ex1_1b1 && ./ex1_1b1 < 0.dat
  Ex 1.1 b2)
      flex ex1_1b2.l && gcc lex.yy.c -o ex1_1b2 && ./ex1_1b2 < 0.dat
  Ex 1.2
      flex ex1_2.l && gcc lex.yy.c -o ex1_2 && ./ex1_2 < prog.c
  Ex 1.3 a)
      flex ex1_3a.l && gcc lex.yy.c -o ex1_3a && ./ex1_3a a.txt
  Ex 1.3 b)
      flex ex1_3b.l && gcc lex.yy.c -o ex1_3b && ./ex1_3b b.txt
  Ex 1.3 c)
      flex ex1_3c.l && gcc lex.yy.c -o ex1_3c && ./ex1_3c c.txt
  Ex 1.3 d)
      flex ex1_3d.l && gcc lex.yy.c -o ex1_3d && ./ex1_3d d.txt

  Les programmes 1.3 acceptent aussi l'entree standard :  ./ex1_3a < a.txt

EXPLICATION DU RESULTAT DE L'EXERCICE 1.1 a)

  La regle [a-zA-Z][a-zA-Z0-9]* reconnait un mot qui commence par une lettre.
  Chaque mot reconnu est affiche entre < >. Tout ce qui n'est pas reconnu
  (chiffres seuls, espaces, ( ) [ ] = ; < + { } .) est recopie tel quel par la
  regle par defaut de Lex (ECHO). Exemple :
      for( i=0; ...   donne   <for>( <i>=0; ...
  Les nombres 10, 12.3 et .0 ne commencent pas par une lettre : ils sont
  recopies sans changement. "for" est traite comme un simple symbole car
  aucune regle ne le distingue encore des identificateurs.

REMARQUES SUR LES AUTRES EXERCICES

  1.1 b1 : les mots-cles sont ecrits avant la regle des symboles : a longueur
           egale, Lex choisit la premiere regle. Les nombres sont encore
           recopies tels quels (chiffres seuls, "." vu comme operateur).
  1.1 b2 : ajout des entiers (ENTIER) et des flottants (FLOTTANT, ex 12.3,
           .0, 1e5).
  1.2    : condition de depart COMMENT, compteurs (nombre de commentaires et
           de lignes) affiches a la fin. Une chaine "..." contenant /* n'est
           pas touchee.
  1.3    : un seul mot par ligne. Mot accepte : il est recopie suivi de
           "-> ACCEPTE". Mot rejete : chaque caractere est signale par
           <?x> (regle attrape-tout). Espaces, tabulations et fins de ligne
           sont simplement recopies. Les \r de fichiers Windows sont ignores.

  Expressions regulieres utilisees (1.3) :
      a) L*[aA]L*[eE]L*[iI]L*[oO]L*[uU]L*          (L = lettre)
      b) a[ab]* | [ab]*a
      c) (ab)+a? | (ba)+b? | a | b
      d) b* (a+ bb+)* (a+ b?)?    (un b isole entre deux a est interdit)

MENU DU PROGRAMME tp3_menu

  Choisir un numero de 1 a 8 (0 pour quitter), puis donner le nom du fichier
  a analyser, ou appuyer sur Entree pour utiliser le fichier de test par defaut.
