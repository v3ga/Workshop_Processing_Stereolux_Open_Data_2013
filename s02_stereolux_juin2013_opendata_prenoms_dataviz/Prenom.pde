// Classe qui permet de stocker / mettre en cache
// les données remontées depuis la base de données
class DataPrenom
{
  String prenom;
  int occurrence;

  DataPrenom(String prenom_, int occurrence_)
  {
    // Initialisation des paramètres
    this.prenom = prenom_;
    this.occurrence = 0; // on met à 0 ici pour la transition

    // Nouvelle animation
    // durée, délai, propriété à animer, valeur cible, fonction d'interpolation
    // > pour les fonctions d'interpolation, voir ici : http://www.looksgood.de/libraries/Ani/Ani_Cheat_Sheet.pdf
    new Ani(this, random(0.5,1.5), random(0,0.25), "occurrence", occurrence_, Ani.BOUNCE_OUT);
  }
}


