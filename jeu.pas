unit jeu;

{$mode objfpc}{$H+}

interface

uses
<<<<<<< HEAD
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;

type
  TForm2 = class(TForm)
=======
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, aide;

type

  { TForm2 }

  TForm2 = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
>>>>>>> refs/remotes/origin/develop
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;

implementation
<<<<<<< HEAD

{$R *.lfm}

=======
uses conception;

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //On affiche la fenêtre conception
  Form1.Show();
  Form2.Hide();
end;

>>>>>>> refs/remotes/origin/develop
end.

