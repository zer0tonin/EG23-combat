unit jeu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, aide,windows, CommCtrl;

type

  { TForm2 }

  TForm2 = class(TForm)
    rejouer: TButton;
    combatBtn: TButton;
    Attaques: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    j1btn1: TButton;
    j1btn2: TButton;
    j1btn3: TButton;
    j1btn4: TButton;
    j1btn5: TButton;
    j1btn6: TButton;
    j1btn7: TButton;
    j1btn8: TButton;
    j1btn9: TButton;
    lb3: TLabel;
    winnerPanel: TPanel;
    gagnant: TStaticText;
    rejouer1: TButton;
    Timer2: TTimer;
    Timer3: TTimer;
    Timer4: TTimer;
    time_count: TLabel;
    hintLabel: TLabel;
    label_joueur: TLabel;
    lb6: TLabel;
    lb9: TLabel;
    lb2: TLabel;
    lb8: TLabel;
    lb5: TLabel;
    lb1: TLabel;
    lb4: TLabel;
    lb7: TLabel;
    JeuPanel: TPanel;
    Timer1: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    j1ViePb: TProgressBar;
    j2ViePb: TProgressBar;
    j1EnergiePb: TProgressBar;
    j2EnergiePb: TProgressBar;
    vieJ2: TEdit;
    procedure combatBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GroupBox2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure initCombatClick(Sender: TObject);
    procedure j1btn1Click(Sender: TObject);
    procedure j1btn2Click(Sender: TObject);
    procedure j1btn3Click(Sender: TObject);
    procedure j1btn4Click(Sender: TObject);
    procedure j1btn5Click(Sender: TObject);
    procedure j1btn6Click(Sender: TObject);
    procedure j1btn7Click(Sender: TObject);
    procedure j1btn8Click(Sender: TObject);
    procedure j1btn9Click(Sender: TObject);
    procedure lb6Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure rejouerClick(Sender: TObject);
    procedure Timer1StartTimer(Sender: TObject);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;
Type TJoueur = record
  Vie: integer;
  Energie: integer;
  Prochain_Coup_critique: boolean;  // True si le prochain coup sera critique s'il est réussi
  Code_coup_Choisi: integer // de 1 à 9 en fonction du coup choisi.
end;
var
  Form2: TForm2;
    // Les paramètres
  vie_max: integer;
  energie_max: integer;
  degat_min: integer;
  degat_max: integer;
  Coefficient_Coup_Critique: real;
  Duree_pour_une_action: integer;
  Point_vie_recuperer: integer;
  Point_energie_pour_action: integer;
  Point_energie_bonus: integer;
  Point_energie_pour_blocage: integer;
  combat_commence: Boolean=false;
  tour_time:Integer;
  time_conf:Integer=3;
  tour :Integer;
  pause : Boolean;
  pause_duration : integer;
  time_cpu:Integer;
      trueVal: Boolean;
    falseVal:Boolean ;
    mode_jeu:integer;
  // Les 2 joueurs
  Joueur_humain: Tjoueur;
  Joueur_Ordinateur: Tjoueur;
implementation
uses conception;

{$R *.lfm}



// Enregistrement des Paramètres dans les variables d'environnnement
Procedure Enregistre_Parametres;
begin
  vie_max:= maxPV;
  energie_max:= maxPE;
  degat_min:= minDegat;
  degat_max:= maxDegat;
  Coefficient_Coup_Critique:= coeffCrit;
  Duree_pour_une_action:= dureeMax;
  Point_vie_recuperer:= regenPE;
  Point_energie_pour_action:= depensePEaction;
  Point_energie_bonus:= 3;
  Point_energie_pour_blocage:= depensePEblocage;
  mode_jeu:=mode;
  randomize; // Initialisation du générateur de nombres aléatoires
  combat_commence:=false;
   Form2.combatBtn.Enabled:=true;
  time_conf:=5;
  tour_time:=time_conf;
  pause_duration:=0;
  trueVal:=true;
  falseVal:=false;
  tour:=1;
end;


//Disable actions
Procedure change_btn_state(var state: Boolean);
begin
  if mode_jeu = 2 then state :=false;
    Form2.j1btn1.Enabled:=state;
    Form2.j1btn2.Enabled:=state;
    Form2.j1btn3.Enabled:=state;
    Form2.j1btn4.Enabled:=state;
    Form2.j1btn5.Enabled:=state;
    Form2.j1btn6.Enabled:=state;
    Form2.j1btn7.Enabled:=state;
    Form2.j1btn8.Enabled:=state;
    Form2.j1btn9.Enabled:=state;
end;

// Initialise les paramètres d'un joueur
Procedure Initialise_Joueur (var un_joueur: TJoueur);
begin
  un_joueur.Vie:=vie_max;
  un_joueur.energie:=energie_max;
  un_joueur.Prochain_Coup_critique:=false;
  un_joueur.Code_coup_Choisi:=0; // au départ aucun coup n'est choisi
end;

//gestion couleur attaque
Procedure afficher_attaque_en_entete(attaque: String);
begin
     case attaque of
         '1':  begin Form2.hintLabel.Caption:='Blocage haut';
               Form2.j1btn1.Font.Color:=clRed;
               Form2.lb1.Font.Color:=clRed;
               end;
         '2':  begin Form2.hintLabel.Caption:='Esquive haute';
               Form2.j1btn2.Font.Color:=clRed;
               Form2.lb2.Font.Color:=clRed;

         end;
         '3':  begin Form2.hintLabel.Caption:='Attaque à la tête';
               Form2.j1btn3.Font.Color:=clRed;
               Form2.lb3.Font.Color:=clRed;

         end;
         '4': begin Form2.hintLabel.Caption:='Blocage centre';
               Form2.j1btn4.Font.Color:=clRed;
               Form2.lb4.Font.Color:=clRed;

         end;
         '5': begin Form2.hintLabel.Caption:='Concentration';
               Form2.j1btn5.Font.Color:=clRed;
               Form2.lb5.Font.Color:=clRed;

         end;
         '6': begin Form2.hintLabel.Caption:='Attaque à l abdomen';
               Form2.j1btn6.Font.Color:=clRed;
               Form2.lb6.Font.Color:=clRed;

         end;
         '7': begin Form2.hintLabel.Caption:='Blocage bas';
               Form2.j1btn7.Font.Color:=clRed;
               Form2.lb7.Font.Color:=clRed;

         end;
         '8': begin Form2.hintLabel.Caption:='Esquive basse';
               Form2.j1btn8.Font.Color:=clRed;
               Form2.lb8.Font.Color:=clRed;

         end;
         '9': begin Form2.hintLabel.Caption:='Attaque aux jambes';
               Form2.j1btn9.Font.Color:=clRed;
               Form2.lb9.Font.Color:=clRed;

         end;

     end;
      change_btn_state(falseVal);
end;

Procedure initialiser_afficher_attaque;
begin
     Form2.lb1.Font.Color:=clBlack;
     Form2.lb2.Font.Color:=clBlack;
     Form2.lb3.Font.Color:=clBlack;
     Form2.lb4.Font.Color:=clBlack;
     Form2.lb5.Font.Color:=clBlack;
     Form2.lb6.Font.Color:=clBlack;
     Form2.lb7.Font.Color:=clBlack;
     Form2.lb8.Font.Color:=clBlack;
     Form2.lb9.Font.Color:=clBlack;
     Form2.hintLabel.Caption:='';
end;

// le coup joué par l'ordinateur;
Procedure Coup_Joueur_Ordinateur;
begin
  Joueur_Ordinateur.Code_coup_Choisi:=random(9)+1;   // renvoie un valeur entre 1 et 9
  afficher_attaque_en_entete(IntToStr(Joueur_Ordinateur.Code_coup_Choisi));
   tour:=1;
end;

// Renvoie les dégats subits par un joueur
Function Degat_subit (un_joueur: Tjoueur): integer;
begin
if un_joueur.Prochain_Coup_critique
   then Degat_subit:=trunc ((random(degat_max-degat_min)+degat_min)*Coefficient_Coup_Critique)
   else Degat_subit:=trunc(random(degat_max-degat_min)+degat_min);
end;

// Simule un tour de combatBtn quand les 2 joueurs ont déjà choisi leur coups.
procedure Combat (var joueurA, joueurB: Tjoueur);
begin
  joueurA.Energie:=joueurA.Energie-Point_energie_pour_action;
  joueurB.Energie:=joueurB.Energie-Point_energie_pour_action;

  case joueurA.Code_coup_Choisi of
    1: case joueurB.Code_coup_Choisi of
        1: begin end;
        2: begin end;
        3: joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        4: begin end;
        5: joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        6: begin
             joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
           end;
        7: begin end;
        8: begin end;
        9: begin
             joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
           end;
       end;
    2: case joueurB.Code_coup_Choisi of
        1: begin end;
        2: begin end;
        3:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
            end;
        4: begin end;
        5:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        6:  joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        7: begin end;
        8: begin end;
        9:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
       end;
    3: case joueurB.Code_coup_Choisi of
        1:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        2:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        3:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        4:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        5:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        6:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        7:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        8:  joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        9:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
       end;
    4: case joueurB.Code_coup_Choisi of
        1:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        2: begin end;
        3:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
        4:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        5:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        6:  joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        7:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        8: begin end;
        9:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
            end;
       end;
    5: case joueurB.Code_coup_Choisi of
        1:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Prochain_Coup_critique:=true;
            end;
        2:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Prochain_Coup_critique:=true;
            end;
        3:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
        4:  joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        5:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Prochain_Coup_critique:=true;
            end;
        6:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
        7:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Prochain_Coup_critique:=true;
            end;
        8:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Prochain_Coup_critique:=true;
            end;
        9:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
       end;
    6: case joueurB.Code_coup_Choisi of
        1:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        2:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        3:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        4:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        5:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        6:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        7:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
        8:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        9:  begin
              joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
              joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
            end;
       end;
    7: case joueurB.Code_coup_Choisi of
        1: begin end;
        2: begin end;
        3:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
        4: begin end;
        5:  joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        6:  begin
              joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
              joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
              joueurA.Prochain_Coup_critique:=false;
           end;
        7: begin end;
        8: begin end;
        9: joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
       end;
    8: case joueurB.Code_coup_Choisi of
        1: begin end;
        2: begin end;
        3: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
           end;
        4: begin end;
        5: joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        6: begin end;
        7: begin end;
        8: joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
        9: joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
       end;
    9: case joueurB.Code_coup_Choisi of
        1: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
              joueurB.Prochain_Coup_critique:=false;
          end;
        2: joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        3: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
        4: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
        5: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
        6: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
        7: joueurB.Energie:=joueurB.Energie+Point_energie_bonus;
        8: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
        9: begin
             joueurA.Energie:=joueurA.Energie+Point_energie_bonus;
             joueurA.Vie:=joueurA.Vie-Degat_subit(joueurA);
             joueurA.Prochain_Coup_critique:=false;
             joueurB.Vie:=joueurB.Vie-Degat_subit(joueurB);
             joueurB.Prochain_Coup_critique:=false;
           end;
       end;
  end;

end;

//Vie energie update
Procedure Affiche_vie_energie;
begin
if Joueur_Ordinateur.Vie < 0 then Joueur_Ordinateur.Vie := 0;
if Joueur_Ordinateur.Energie < 0 then Joueur_Ordinateur.Energie := 0;
if Joueur_humain.Vie < 0 then Joueur_humain.Vie := 0;
if Joueur_humain.Energie < 0 then Joueur_humain.Energie := 0;
Form2.j1ViePb.Position:= (Joueur_humain.Vie * 100) div vie_max;
Form2.j2ViePb.Position:= (Joueur_Ordinateur.Vie * 100) div vie_max;
Form2.j1EnergiePb.Position:= (Joueur_humain.Energie * 100) div energie_max;
Form2.j2EnergiePb.Position:= (Joueur_Ordinateur.Energie * 100) div energie_max;
if ((Joueur_humain.Vie <> 0) and (Joueur_Ordinateur.vie <> 0)) then
    begin
   // Form2.vieJ1.Text:=inttostr(joueur_humain.Vie);
   // Form2.energieJ1.Text:=inttostr(joueur_humain.Energie);
   // Form2.vieJ2.Text:=inttostr(joueur_ordinateur.Vie);
   // Form2.energieJ2.Text:=inttostr(joueur_ordinateur.Energie);
    end
 else
     begin
          Form2.Timer1.Enabled:=false;
          Form2.Timer2.Enabled:=false;
          Form2.Timer3.Enabled:=false;
          Form2.Timer4.Enabled:=false;
          Form2.JeuPanel.Visible:=false;
          Form2.winnerPanel.Visible:=True;

          if Joueur_humain.Vie > Joueur_Ordinateur.vie  then Form2.gagnant.Caption:= 'Joueur 1 gagne'
          else if Joueur_humain.Vie < Joueur_Ordinateur.Vie  then Form2.gagnant.Caption:='Joueur 2 gagne'
          else Form2.gagnant.Caption:='Egalité';
          Form2.time_count.Caption:='0';

     end;
end;


procedure actionCombat;
begin
if ((mode_jeu = 0) or (mode_jeu = 2)) then
begin
  if joueur_ordinateur.Energie>Point_energie_pour_action
   then Coup_Joueur_Ordinateur
   else joueur_ordinateur.Code_coup_Choisi:=5;
end;
//Form2.Text:=inttostr(joueur_ordinateur.Code_coup_Choisi);
Combat(Joueur_humain, joueur_ordinateur);
Affiche_vie_energie;

end;

//Action sur bouton
procedure actionSurBouton(action:integer);
begin
  if tour = 1 then
   begin
     tour:=2;
     Joueur_humain.Code_coup_Choisi:=action;
     afficher_attaque_en_entete(IntToStr(Joueur_humain.Code_coup_Choisi));
   end
else
begin
     tour:=1;
     if mode = 1 then
      begin
          Joueur_Ordinateur.Code_coup_Choisi:=action;
          afficher_attaque_en_entete(IntToStr(Joueur_Ordinateur.Code_coup_Choisi));
      end;
end;

tour_time:=0;
end;

{ TForm2 }

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //On affiche la fenêtre conception
  Form1.Show();
  Form2.Hide;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin


end;

procedure TForm2.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
         VK_9:  actionSurBouton(9);
         VK_8:  actionSurBouton(8);
         VK_7:  actionSurBouton(7);
         VK_6:  actionSurBouton(6);
         VK_5:  actionSurBouton(5);
         VK_4:  actionSurBouton(4);
         VK_3:  actionSurBouton(3);
         VK_2:  actionSurBouton(2);
         VK_1:  actionSurBouton(1);
         VK_NUMPAD9: actionSurBouton(9);
         VK_NUMPAD8: actionSurBouton(8);
         VK_NUMPAD7: actionSurBouton(7);
         VK_NUMPAD6: actionSurBouton(6);
         VK_NUMPAD5: actionSurBouton(5);
         VK_NUMPAD4: actionSurBouton(4);
         VK_NUMPAD3: actionSurBouton(3);
         VK_NUMPAD2: actionSurBouton(2);
         VK_NUMPAD1: actionSurBouton(1);
   end;
end;


procedure TForm2.FormShow(Sender: TObject);
begin
Enregistre_Parametres;
Initialise_Joueur(Joueur_humain);
Initialise_Joueur(Joueur_Ordinateur);
Affiche_vie_energie;
change_btn_state(falseVal);
end;

procedure TForm2.GroupBox2Click(Sender: TObject);
begin

end;

procedure TForm2.Image1Click(Sender: TObject);
begin

end;

procedure TForm2.Image2Click(Sender: TObject);
begin

end;

procedure TForm2.combatBtnClick(Sender: TObject);
begin
      if mode = 3 then time_cpu:= 0
      else time_cpu:=random(time_conf)+1;
      combat_commence:=true;
      Timer1.Enabled:=true;
      combatBtn.Enabled:=false;
      hintLabel.Caption:='';
      change_btn_state(trueVal);
end;

procedure TForm2.initCombatClick(Sender: TObject);
begin

end;

procedure TForm2.j1btn1Click(Sender: TObject);
begin
    actionSurBouton(1);
end;

procedure TForm2.j1btn2Click(Sender: TObject);
begin
    actionSurBouton(2);
end;

procedure TForm2.j1btn3Click(Sender: TObject);
begin
  actionSurBouton(3);
end;

procedure TForm2.j1btn4Click(Sender: TObject);
begin
  actionSurBouton(4);
end;

procedure TForm2.j1btn5Click(Sender: TObject);
begin
    actionSurBouton(5);
end;

procedure TForm2.j1btn6Click(Sender: TObject);
begin
    actionSurBouton(6);
end;

procedure TForm2.j1btn7Click(Sender: TObject);
begin
    actionSurBouton(7);
end;

procedure TForm2.j1btn8Click(Sender: TObject);
begin
    actionSurBouton(8);
end;

procedure TForm2.j1btn9Click(Sender: TObject);
begin
    actionSurBouton(9);
end;

procedure TForm2.lb6Click(Sender: TObject);
begin

end;

procedure TForm2.Panel3Click(Sender: TObject);
begin

end;

procedure TForm2.rejouerClick(Sender: TObject);
begin

Enregistre_Parametres;
Initialise_Joueur(Joueur_humain);
Initialise_Joueur(Joueur_Ordinateur);
Affiche_vie_energie;
change_btn_state(falseVal);
combatBtn.Enabled:=true;
JeuPanel.Visible:=true;
winnerPanel.Visible:=false;
end;

procedure TForm2.Timer1StartTimer(Sender: TObject);
begin
 // tour_time:=time_conf;
end;

procedure TForm2.Timer1StopTimer(Sender: TObject);
begin

end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
     tour_time:=tour_time-1;
      if tour_time <time_cpu then
       begin
         if mode_jeu = 2 then
          begin
            Joueur_humain.Code_coup_Choisi:=random(9)+1;
            actionSurBouton(Joueur_humain.Code_coup_Choisi);
          end;
       tour_time:=0;
        time_count.Caption := inttostr(tour_time);
         tour_time:=time_conf;
         //actionCombat;
         Timer1.Enabled := false;
         Timer2.Enabled:=true;
         //change_btn_state(trueVal);

         time_count.Caption := '0';
        // change_btn_state(falseVal);
       end
      else time_count.Caption := inttostr(tour_time);


end;

procedure TForm2.Timer2Timer(Sender: TObject);
begin
  if mode_jeu=1 then change_btn_state(trueVal)
  else change_btn_state(falseVal);
   pause_duration:=pause_duration-1;
      if pause_duration <0 then
       begin
         pause_duration:=1;
         pause:=true ;
         Timer2.Enabled := false;
         Timer3.Enabled:=true;
         label_joueur.Caption:='Joueur 2';
         hintLabel.Caption:='';
         initialiser_afficher_attaque;
         if ((mode_jeu = 0) or (mode_jeu = 2)) then time_cpu:=random(time_conf)+1
         else time_cpu:=0;
       end
      else




end;

procedure TForm2.Timer3Timer(Sender: TObject);
begin
  tour_time:=tour_time-1;
      if tour_time <time_cpu then
       begin
         tour_time:=0;
         time_count.Caption := inttostr(tour_time);
         tour_time:=time_conf;
         actionCombat;
         Timer3.Enabled := false;
         Timer4.Enabled:=true;
         change_btn_state(trueVal);
         if ((mode_jeu = 0) or (mode_jeu = 2)) then
          afficher_attaque_en_entete(inttostr(Joueur_Ordinateur.Code_coup_Choisi));
       end
       else time_count.Caption := inttostr(tour_time);

end;

procedure TForm2.Timer4Timer(Sender: TObject);
begin
      pause_duration:=pause_duration-1;
      if pause_duration <0 then
       begin
         pause_duration:=1;
         Timer4.Enabled := false;
         Timer1.Enabled:=true;
         label_joueur.Caption:='Joueur 1';
         change_btn_state(trueVal);
          initialiser_afficher_attaque;
          if mode = 3 then time_cpu:= 0
          else time_cpu:=random(time_conf)+1;
       end
      else
end;




end.

