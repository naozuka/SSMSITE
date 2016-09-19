unit URegistros;

interface

uses
  Classes, SysUtils, Graphics;

type
  TRegistro = class(TCollectionItem)
    private
      FName: string;
      FForeground: TColor;
      FBackground: TColor;
      FBold: boolean;
    public
    published
      property Name: string read FName write FName;
      property Foreground: TColor read FForeground write FForeground;
      property Background: TColor read FBackground write FBackground;
      property Bold: boolean read FBold write FBold;
  end;

  TGrupoRegistros = class(TCollection)
    private
      function GetItem(Index: integer): TRegistro;
      //function GetPessoas(Idade: integer): TGrupo;
    public
      function AddItem: TRegistro;
      //property BuscaPessoa[Index: Integer]: TPessoa read GetPessoa;
      //property BuscaPessoas[Idade: Integer]: TGrupo read GetPessoas;
      constructor Create(ItemClass: TCollectionItemClass);
      property Items[Index: integer]: TRegistro read GetItem;
  end;

implementation

function TGrupoRegistros.AddItem: TRegistro;
begin
  Result := add as TRegistro;
end;

constructor TGrupoRegistros.Create(ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
end;

function TGrupoRegistros.GetItem(Index: integer): TRegistro;
begin
  Result := inherited Items[Index] as TRegistro;
end;

end.
