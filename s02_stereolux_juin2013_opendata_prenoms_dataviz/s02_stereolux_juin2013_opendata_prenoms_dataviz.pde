// Import des librairies
// PDF
import processing.pdf.*;

// ANI > http://www.looksgood.de/libraries/Ani/
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

// BezierSQLib > http://bezier.de/processing/libs/sql/
import de.bezier.data.sql.*;

// Object qui représente la connexion à la base de données sqlite
SQLite db;

// Liste de structures DataPrenom
// créées depuis la remontée des données de la table
ArrayList<DataPrenom> listPrenoms;


// Liste des années contenus dans la table
ArrayList<Integer> listAnnees;

// Nombre d'occurences maximum pour une requête
// Utilisé pour la normalisation
int occurrenceMax = 0;

// Variable utilisée pour la visualisation
String sexe = "GARCON";
// Couleurs utilisées pour l'interpolation
// Ces couleurs sont changées lors du changement de sexe (voir keyPressed)
color sexeCouleurOccurenceMin = color(188,222,255);
color sexeCouleurOccurenceMax = color(0,129,255);

// Variable utilisée pour passer d'année en année
int indexAnnee = 0;

// Dessin des histogrammes «plats» ou «radial»
boolean isDrawRadial = true;

// Export au format pdf ? 
boolean exportPDF = false;

// --------------------------------------------------------
void setup()
{
  // Taille de la fenêtre
  size(700, 500);
  smooth();

  // Initialisation de la librairie Ani (pour les transitions)
  Ani.init(this);

  // Connexion à la base de données (fichier .sqlite dans le dossier data du sketch)
  db = new SQLite(this, "prenoms.sqlite");

  // Récupération des années
  getAnnees();

  // Initialisation des données
  getData(sexe, listAnnees.get(indexAnnee));
}

// --------------------------------------------------------
void draw()
{
  // Export PDF activé ? 
  if (exportPDF)
  {
    beginRecord(PDF, "export.pdf");
  }

  background(255);
  // Dessin mode radial
  if (isDrawRadial)
  {
    float angle = 0;
    float d = TWO_PI / float( listPrenoms.size() );
    float rMin = 0.25*min(width/2, height/2);
    float rMax = 0.8*min(width/2, height/2);

    noStroke();
    translate(width/2, height/2);
    for (DataPrenom data : listPrenoms)
    {
      float t = float(data.occurrence)/float(occurrenceMax);
      float w = t * (rMax-rMin);
      float h = TWO_PI*rMin/float( listPrenoms.size() );

      textSize(h);
      pushMatrix();
      rotate(angle);
      translate(rMin, 0);
      fill(lerpColor(sexeCouleurOccurenceMin,sexeCouleurOccurenceMax,t));
      rect(0, -h/2, w, h);
      fill(sexeCouleurOccurenceMax);
      text(data.prenom+"("+data.occurrence+")", w+5, h/2);
      popMatrix(); 
      angle += d;
    }
    
    String strTitle = ""+listAnnees.get(indexAnnee);
    float hTitle = 30;
    textSize(hTitle);
    float wTitle = textWidth(strTitle);
    text(strTitle,-wTitle/2,hTitle/2);
  }
  // Dessin des histogrammes
  else
  {
    float w = float(width)/float(listPrenoms.size());
    float x = 0.0;
    textSize(w);
    noStroke();
    for (DataPrenom data : listPrenoms)
    {
      float t = float(data.occurrence)/float(occurrenceMax);
      float h = 0.75*height*t;
      fill(lerpColor(sexeCouleurOccurenceMin,sexeCouleurOccurenceMax,t));
      rect(x, height, w, -h);
      pushMatrix();
      translate(x, height-h);
      rotate(-PI/2);
      fill(sexeCouleurOccurenceMax);
      text(data.prenom+"("+data.occurrence+")", 5, w);
      popMatrix();
      x = x+w;
    }
  }

  // Export PDF ? Oui -> stop et remise à false de la var. exportPDF
  if (exportPDF)
  {
    endRecord();
    exportPDF = false;
  }
}

// --------------------------------------------------------
void keyPressed()
{
  boolean updateViz = false;
  if (keyCode == LEFT)
  {
    indexAnnee = indexAnnee-1;
    if (indexAnnee<0) indexAnnee = listAnnees.size()-1; 
    updateViz = true;
  }
  else if (keyCode == RIGHT)
  {
    indexAnnee = (indexAnnee+1)%listAnnees.size();
    updateViz = true;
  }
  
  if (key == 'g')
  {
    sexe = "GARCON";
    sexeCouleurOccurenceMin = color(188,222,255);
    sexeCouleurOccurenceMax = color(0,129,255);
    updateViz = true;
  }
  else if (key == 'f')
  {
    sexe = "FILLE";
    sexeCouleurOccurenceMin = color(255,165,228);
    sexeCouleurOccurenceMax = color(255,0,179);
    updateViz = true;
  }
  else if (key == 's')
  {
    saveFrame("export.png");
  }

  if (updateViz) {
    getData(sexe, listAnnees.get(indexAnnee));
  }
}

// --------------------------------------------------------
void mousePressed()
{
  exportPDF = true;
}

// --------------------------------------------------------
void getAnnees()
{
  if ( db.connect() )
  {
    listAnnees = new ArrayList<Integer>();
    db.query( "SELECT DISTINCT ANNEE_NAISSANCE FROM prenoms ORDER BY ANNEE_NAISSANCE ASC" );
    while ( db.next () ) 
    {
      println( db.getInt("ANNEE_NAISSANCE") );
      listAnnees.add(new Integer( db.getInt("ANNEE_NAISSANCE") ));
    }
  }
}

// --------------------------------------------------------
void getData(String sexe, int annee)
{
  if ( db.connect() )
  {
    // Construction de la requête
    String query = "SELECT DISTINCT PRENOM, OCCURRENCE FROM prenoms";
    query += " WHERE SEXE='"+sexe+"' AND ANNEE_NAISSANCE="+annee+" AND OCCURRENCE>13"; 
    //query += " ORDER BY OCCURRENCE DESC"; 
    db.query( query );

    occurrenceMax=0;
    listPrenoms = new ArrayList<DataPrenom>();
    while ( db.next () )
    {
      String prenom = db.getString("PRENOM");
      int occurrence = db.getInt("OCCURRENCE");
      if (occurrence>occurrenceMax)
        occurrenceMax = occurrence;
      listPrenoms.add( new DataPrenom(prenom, occurrence) );
    }
  }
}

