program SqlServerIdeThemeEditor;

uses
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {Form1},
  URegistros in 'URegistros.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
