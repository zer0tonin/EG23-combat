program projet_combat_EG23;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
<<<<<<< HEAD
  Forms, conception, jeu
=======
  Forms, conception, jeu, aide
>>>>>>> refs/remotes/origin/develop
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
<<<<<<< HEAD
=======
  Application.CreateForm(TForm3, Form3);
>>>>>>> refs/remotes/origin/develop
  Application.Run;
end.

