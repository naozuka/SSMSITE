unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Win.Registry, Vcl.StdCtrls,
  Vcl.Grids, StrUtils, URegistros, IniFiles;

type
  TForm1 = class(TForm)
    BtnCarregar: TButton;
    EdtRegistro: TEdit;
    Label1: TLabel;
    StrGrid: TStringGrid;
    BtnSalvarConfig: TButton;
    BtnCarregarConfig: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure BtnCarregarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StrGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure BtnSalvarConfigClick(Sender: TObject);
    procedure BtnCarregarConfigClick(Sender: TObject);
  private
    { Private declarations }
    Registros : TGrupoRegistros;
    function ReadRegistry(APath, AValue: string; var ADataType: string): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BtnCarregarConfigClick(Sender: TObject);
var iniFile: TIniFile;
    i: integer;
    list: TStringList;
    reg: TRegistry;
    openResult: Boolean;
begin
  if OpenDialog1.Execute then
  begin
    if MessageDlg('Confirma a importa��o das configura��es?', mtConfirmation, mbYesNo, 0) = mrYes then
    begin
      iniFile := TIniFile.Create(OpenDialog1.FileName);
      list := TStringList.Create;
      reg := TRegistry.Create(KEY_WRITE);
      reg.RootKey := HKEY_CURRENT_USER;

      if (not reg.KeyExists(EdtRegistro.Text)) then
      begin
        MessageDlg('Chave n�o encontrada!', mtInformation, [mbOK], 0);
        Exit;
      end;

      openResult := reg.OpenKey(EdtRegistro.Text, False);

      if not openResult then
      begin
        MessageDlg('N�o foi poss�vel abrir carregar a chave!', mtError, [mbOK], 0);
        Exit;
      end;

      try
        iniFile.ReadSection('FontsAndColor', list);

        for i := 1 to list.Count-1 do
        begin
          reg.WriteInteger(list.Strings[i], iniFile.ReadInteger('FontsAndColor', list.Strings[i], 0));
        end;
        MessageDlg('Importa��o conclu�da com sucesso!', mtInformation, [mbOK], 0);
      finally
        iniFile.Free;
      end;
    end;
  end;

end;

procedure TForm1.BtnSalvarConfigClick(Sender: TObject);
var iniFile: TIniFile;
    i: integer;
    reg: TRegistry;
    openResult: boolean;
    list: TStringList;
    dataType: string;
begin
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey := HKEY_CURRENT_USER;

  try
    if (not reg.KeyExists(EdtRegistro.Text)) then
    begin
      MessageDlg('Chave n�o encontrada!', mtInformation, [mbOK], 0);
      Exit;
    end;

    reg.Access := KEY_READ;
    openResult := reg.OpenKeyReadOnly(EdtRegistro.Text);

    if not openResult then
    begin
      MessageDlg('N�o foi poss�vel abrir carregar a chave!', mtError, [mbOK], 0);
      Exit;
    end;

    list := TStringList.Create;
    reg.GetKeyNames(list);
    reg.GetValueNames(list);


    if SaveDialog1.Execute then
    begin
      if RightStr(SaveDialog1.FileName, 4) <> '.ini' then
        SaveDialog1.FileName := SaveDialog1.FileName + '.ini';

      iniFile := TIniFile.Create(SaveDialog1.FileName);

      for i := 0 to list.Count-1 do
      begin
        iniFile.WriteInteger('FontsAndColor', list.Strings[i], StrToIntDef(ReadRegistry(EdtRegistro.Text, list.Strings[i], dataType), 0));
      end;

      MessageDlg('Exporta��o conclu�da com sucesso!', mtInformation, [mbOK], 0);

    end;

    BtnSalvarConfig.Enabled := true;

  finally
    list.Free;
    iniFile.Free;

    reg.CloseKey();
    reg.Free;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  StrGrid.Cells[0, 0] := 'Propriedade';
  StrGrid.Cells[1, 0] := 'Valor';
  StrGrid.Cells[2, 0] := 'Tipo';

  Registros := TGrupoRegistros.Create(TRegistro);
end;

function TForm1.ReadRegistry(APath, AValue: string; var ADataType: string): string;
var
  reg        : TRegistry;
  openResult : Boolean;
  valor      : string;
begin
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey := HKEY_CURRENT_USER;

  try
    if (not reg.KeyExists(APath)) then
    begin
      MessageDlg('Chave n�o encontrada!', mtInformation, [mbOK], 0);
      Exit;
    end;

    reg.Access := KEY_READ;
    openResult := reg.OpenKeyReadOnly(APath);

    if not openResult then
    begin
      MessageDlg('N�o foi poss�vel abrir carregar a chave! Exiting.', mtError, [mbOK], 0);
      Exit;
    end;

    valor := reg.GetDataAsString(AValue, true);
    Result := valor;
    ADataType := Copy(valor, 1, Pos(':', valor)-1);
    Delete(Result, 1, Pos(':', valor));

    if reg.GetDataType(AValue) = rdString then
    begin
      ADataType := 'string';
      Result := reg.ReadString(AValue)
    end
    else if reg.GetDataType(AValue) = rdInteger then
    begin
      ADataType := 'integer';
      Result := IntToStr(reg.ReadInteger(AValue));
    end
    else
    begin
      ADataType := Copy(reg.GetDataAsString(AValue, true), 1, Pos(':', reg.GetDataAsString(AValue, true))-1);
      Result := 'N�o tratado: ' + reg.GetDataAsString(AValue, true);
    end;

  finally
    reg.CloseKey();
    reg.Free;
  end;

end;

procedure TForm1.StrGridDrawCell(Sender: TObject; ACol, ARow: Integer;  Rect: TRect; State: TGridDrawState);
var valor: integer;
begin
  if (ACol = 3) and (ARow > 0) then
  begin
    with TStringGrid(Sender) do
    begin
      valor := StrToIntDef(StrGrid.Cells[1, ARow], -1);

      if valor >= 0 then
      begin
        //Canvas.Brush.Color := valor;
        //Canvas.FillRect(Rect);
      end;
    end;
  end;
end;

procedure TForm1.BtnCarregarClick(Sender: TObject);

  function GetLastWord(const AText: string): string;
  var s: string;
  begin
    s := ReverseString(AText);
    s := Copy(s, 1, Pos(' ', s)-1);
    Result := ReverseString(s);
  end;

var
  reg        : TRegistry;
  openResult : Boolean;
  list       : TStringList;
  i          : integer;
  datatype   : string;
  DrawEvent  : TDrawCellEvent;
  registro   : TRegistro;
  keyWord    : string;
begin
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey := HKEY_CURRENT_USER;

  DrawEvent := StrGrid.OnDrawCell;
  StrGrid.OnDrawCell := nil;

  try
    if (not reg.KeyExists(EdtRegistro.Text)) then
    begin
      MessageDlg('Chave n�o encontrada!', mtInformation, [mbOK], 0);
      Exit;
    end;

    reg.Access := KEY_READ;
    openResult := reg.OpenKeyReadOnly(EdtRegistro.Text);

    if not openResult then
    begin
      MessageDlg('N�o foi poss�vel abrir carregar a chave! Exiting.', mtError, [mbOK], 0);
      Exit;
    end;

    list := TStringList.Create;
    reg.GetKeyNames(list);
    reg.GetValueNames(list);

    StrGrid.RowCount := list.Count + 1;
    keyWord := '';

    for i := 0 to list.Count-1 do
    begin
      {
      if GetLastWord(list.Strings[i]) = 'Background' then
      begin
        registro := Registros.AddItem;
        keyWord := ReverseString(list.Strings[i]);
        Delete(keyWord, 1, Pos(' ', keyWord));
        registro.Name := ReverseString(keyWord);
        //registro.Background :=
      end
      else if GetLastWord(list.Strings[i]) = 'FontFlags' then
      begin
      end
      else if GetLastWord(list.Strings[i]) = 'Foreground' then
      begin

      end;
      }

      StrGrid.Cells[0, i+1] := list.Strings[i];
      StrGrid.Cells[1, i+1] := ReadRegistry(EdtRegistro.Text, list.Strings[i], datatype);
      StrGrid.Cells[2, i+1] := dataType;

    end;

    BtnSalvarConfig.Enabled := true;
  finally
    StrGrid.OnDrawCell := DrawEvent;

    list.Free;

    reg.CloseKey();
    reg.Free;
  end;

end;

end.
