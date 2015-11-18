unit conception;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Fichier: TMenuItem;
    Aide: TMenuItem;
    Enregistrer: TMenuItem;
    Quitter: TMenuItem;
    Nouveau: TMenuItem;
    Ouvrir: TMenuItem;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



end.

