{ *******************************************************************************
Title: T2Ti ERP
Description: Unit que cont�m os atributos (annotations)

The MIT License

Copyright: Copyright (C) 2024 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM)
@version 1.0
******************************************************************************* }
unit Atributos;

interface

uses Classes, SysUtils, DB;

type
  TLocalDisplay = (ldGrid, ldLookup, ldComboBox);
  TLocalDisplayColumn = set of TLocalDisplay;

  { Mapeia uma classe como uma entidade persistente }
  TEntity = class(TCustomAttribute)
  end;

  { Mapeia uma classe como uma entidade transiente }
  TTransient = class(TCustomAttribute)
  end;

  { Mapeia a classe de acordo com a tabela do banco de dados }
  TTable = class(TCustomAttribute)
  private
    { Para informar o nome da tabela - usado no servidor }
    FName: String;
    FCatalog: String;
    FSchema: String;
  public
    constructor Create(pName, pCatalog, pSchema: String); overload;
    constructor Create(pName, pSchema: String); overload;
    constructor Create(pName: String); overload;

    property Name: String read FName write FName;
    property Catalog: String read FCatalog write FCatalog;
    property Schema: String read FSchema write FSchema;
  end;

  { Estrat�gia de gera��o de valores para chaves prim�rias, valores poss�veis:
    sAuto = o provedor de persist�ncia escolhe a estrat�gia mais adequada dependendo do banco de dados
    sIdentity = utiliza��o se identity do banco de dados
    sSequence = utiliza��o se sequence do banco de dados
    sTable = chave gerada por uma tabela exclusiva para este fim
    }
  TStrategy = (sAuto, sIdentity, sSequence, sTable);

  { Informa a estrat�gia de gera��o de valores para chaves prim�rias }
  TGeneratedValue = class(TCustomAttribute)
  private
    FStrategy: TStrategy;
    FGenerator: String;
  public
    constructor Create(pStrategy: TStrategy; pGenerator: String); overload;
    constructor Create(pStrategy: TStrategy); overload;

    property Strategy: TStrategy read FStrategy write FStrategy;
    property Generator: String read FGenerator write FGenerator;
  end;

  { Mapeia o identificador da classe, a chave prim�ria na tabela do banco de dados }
  TId = class(TCustomAttribute)
  private
    FNameField: String;
    FLocalDisplay: TLocalDisplayColumn;
  public
    constructor Create(pNameField: String); overload;
    constructor Create(pNameField: String; pLocalDisplay: TLocalDisplayColumn); overload;

    property NameField: String read FNameField write FNameField;
    property LocalDisplay: TLocalDisplayColumn read FLocalDisplay write FLocalDisplay;

    function LocalDisplayIs(pLocalDisplay: TLocalDisplay): Boolean;
    function LocalDisplayContainsOneTheseItems(pLocalDisplay: TLocalDisplayColumn): Boolean;
  end;

  { Mapeia um campo de uma tabela do banco de dados }
  TColumn = class(TCustomAttribute)
  private
    FName: String;
    FCaption: String;
    FLength: Integer;
    FLocalDisplay: TLocalDisplayColumn;
    FTransiente: Boolean;
  public
    constructor Create(pName: String; pCaption: String; pLocalDisplay: TLocalDisplayColumn; pTransiente: Boolean); overload;
    constructor Create(pName: String; pCaption: String; pLength: Integer; pLocalDisplay: TLocalDisplayColumn; pTransiente: Boolean); overload;

    { Para informar o nome da coluna - usado no servidor (CRUD) e no cliente (CDS) }
    property Name: String read FName write FName;
    { Para informar o caption da coluna que ser� exibida na grid - usado no cliente }
    property Caption: String read FCaption write FCaption;
    { Para informar o tamanho da coluna que ser� exibida na grid - usado no cliente }
    property Length: Integer read FLength write FLength;
    { Para informar em que local o campo deve aparecer - usado no cliente
      ldGrid = grid da janela principal
      ldLookup = grid da janela de lookup
      ldComboBox = combobox da janela principal utilizado para definir um crit�rio de filtro
    }
    property LocalDisplay: TLocalDisplayColumn read FLocalDisplay write FLocalDisplay;
    { Para informar que um campo n�o deve ser persistido no banco de dados - usado no servidor (CRUD) e no cliente (CDS) }
    property Transiente: Boolean read FTransiente write FTransiente;

    function Clone: TColumn;
    function LocalDisplayIs(pLocalDisplay: TLocalDisplay): Boolean;
    function LocalDisplayContainsOneTheseItems(pLocalDisplay: TLocalDisplayColumn): Boolean;
  end;


  { Mapeia um campo de um objeto que est� na �rvore do objeto principal, mas n�o vinculado diretamente a ele }
  TColumnDisplay = class(TColumn)
  private
    FFieldDisplayType: TFieldType;
    FQualifiedName: String;
  public
    constructor Create(pName: String; pCaption: String; pLength: Integer; pLocalDisplay: TLocalDisplayColumn; pFieldDisplayType: TFieldType; pQualifiedName: String; pTransiente: Boolean);

    { Para informar o tipo de dado do campo que ser� inclu�do no CDS - usado no lado cliente }
    property FieldDisplayType: TFieldType read FFieldDisplayType write FFieldDisplayType;
    { Para informar o nome da classe do objeto que dever� ser encontrado para exibir um de seus campos na grid
      Exemplo: "ProdutoGrupoVO.TProdutoGrupoVO" - (Unit.TNomeClasse)
      Usado no lado cliente}
    property QualifiedName: String read FQualifiedName write FQualifiedName;
  end;


  { Define uma associa��o da classe atual para outra classe de entidade }
  TAssociation = class(TCustomAttribute)
  private
    FForeingColumn: String;
    FLocalColumn: String;
  public
    constructor Create(pForeingColumn: String; pLocalColumn: String); overload;

    { Para informar o nome do campo que deve ser buscado na tabela associada para realizar o Join - Usado no servidor }
    property ForeingColumn: String read FForeingColumn write FForeingColumn;
    { Para informar o nome do campo da tabela local utilizado para realizar o Join - Usado no servidor }
    property LocalColumn: String read FLocalColumn write FLocalColumn;
  end;

  { Define uma associa��o para outra classe em um atributo multivalorado, como por exemplo, uma lista de itens }
  TManyValuedAssociation = class(TAssociation)
  end;


  { Mapeia Formul�rios do Sistema }
  TFormDescription = class(TCustomAttribute)
  private
    FModule: String;
    FDescription: String;
  public
    constructor Create(pModule, pDescription: String);

    property Module: String read FModule;
    property Description: String read FDescription;
  end;

  { Mapeia Componentes do Sistema }
  TComponentDescription = class(TCustomAttribute)
  private
    FDescription: String;
    FClassOwner: TClass;
  public
    constructor Create(pDescription: String); overload;
    constructor Create(pDescription: String; pClassOwner: TClass); overload;

    property Description: String read FDescription;
    property ClassOwner: TClass read FClassOwner;
  end;

  { Formata os dados de acordo com m�scara e alinhamento - usado no lado cliente }
  TFormatter = class(TCustomAttribute)
  private
    FFormatter: String;
    FAlignment: TAlignment;
  public
    constructor Create(pFormatter: String); overload;
    constructor Create(pAlignment: TAlignment); overload;
    constructor Create(pFormatter: String; pAlignment: TAlignment); overload;

    property Formatter: String read FFormatter write FFormatter;
    property Alignment: TAlignment read FAlignment write FAlignment;
  end;

implementation

{$Region 'TTable'}
constructor TTable.Create(pName, pCatalog, pSchema: String);
begin
  FName := pName;
  FCatalog := pCatalog;
  FSchema := pSchema;
end;

constructor TTable.Create(pName, pSchema: String);
begin
  FName := pName;
  FSchema := pSchema;
end;

constructor TTable.Create(pName: String);
begin
  FName := pName;
end;
{$EndRegion 'TTable'}

{$Region 'TGeneratedValue'}
constructor TGeneratedValue.Create(pStrategy: TStrategy; pGenerator: String);
begin
  FStrategy := pStrategy;
  FGenerator := pGenerator;
end;

constructor TGeneratedValue.Create(pStrategy: TStrategy);
begin
  FStrategy := pStrategy;
end;
{$EndRegion 'TGeneratedValue'}

{$Region 'TId'}
constructor TId.Create(pNameField: String);
begin
  FNameField := pNameField;
end;

constructor TId.Create(pNameField: String; pLocalDisplay: TLocalDisplayColumn);
begin
  FNameField := pNameField;
  FLocalDisplay := pLocalDisplay;
end;

function TId.LocalDisplayIs(pLocalDisplay: TLocalDisplay): Boolean;
begin
  Result := pLocalDisplay in FLocalDisplay;
end;

function TId.LocalDisplayContainsOneTheseItems(pLocalDisplay: TLocalDisplayColumn): Boolean;
var
  Local: TLocalDisplay;
begin
  Result := False;

  for Local in pLocalDisplay do
  begin
    if LocalDisplayIs(Local) then
    begin
      Exit(True)
    end;
  end;
end;
{$EndRegion 'TId'}

{$Region 'TColumn'}
constructor TColumn.Create(pName, pCaption: String; pLength: Integer; pLocalDisplay: TLocalDisplayColumn; pTransiente: Boolean);
begin
  Create(pName, pCaption, pLocalDisplay, pTransiente);
  FLength := pLength;
end;

constructor TColumn.Create(pName, pCaption: String; pLocalDisplay: TLocalDisplayColumn; pTransiente: Boolean);
begin
  FName := pName;
  FCaption := pCaption;
  FLocalDisplay := pLocalDisplay;
  FTransiente := pTransiente;
end;

function TColumn.Clone: TColumn;
begin
  Result := TColumn.Create(FName, FCaption, FLength, FLocalDisplay, FTransiente);
end;

function TColumn.LocalDisplayIs(pLocalDisplay: TLocalDisplay): Boolean;
begin
  Result := pLocalDisplay in FLocalDisplay;
end;

function TColumn.LocalDisplayContainsOneTheseItems(pLocalDisplay: TLocalDisplayColumn): Boolean;
var
  Local: TLocalDisplay;
begin
  Result := False;

  for Local in pLocalDisplay do
  begin
    if LocalDisplayIs(Local) then
    begin
      Exit(True)
    end;
  end;
end;
{$EndRegion 'TColumn'}

{$Region 'TColumnDisplay'}
constructor TColumnDisplay.Create(pName, pCaption: String; pLength: Integer;
  pLocalDisplay: TLocalDisplayColumn; pFieldDisplayType: TFieldType; pQualifiedName: String; pTransiente: Boolean);
begin
  FName := pName;
  FCaption := pCaption;
  FLength := pLength;
  FLocalDisplay := pLocalDisplay;
  FFieldDisplayType := pFieldDisplayType;
  FQualifiedName := pQualifiedName;
  FTransiente := pTransiente;
end;
{$EndRegion 'TColumnDisplay'}

{$Region 'TAssociation'}
constructor TAssociation.Create(pForeingColumn, pLocalColumn: String);
begin
  FForeingColumn := pForeingColumn;
  FLocalColumn := pLocalColumn;
end;
{$EndRegion 'TAssociation'}

{$Region 'TFormDescription'}
constructor TFormDescription.Create(pModule, pDescription: String);
begin
  FModule := pModule;
  FDescription := pDescription;
end;
{$EndRegion 'TFormDescription'}

{$Region 'TComponentDescription'}
constructor TComponentDescription.Create(pDescription: String);
begin
  FDescription := pDescription;
  FClassOwner := nil;
end;

constructor TComponentDescription.Create(pDescription: String; pClassOwner: TClass);
begin
  FDescription := pDescription;
  FClassOwner := pClassOwner;
end;
{$EndRegion 'TComponentDescription'}

{$Region 'TFormatter'}
constructor TFormatter.Create(pFormatter: String);
begin
  FFormatter := pFormatter;
end;

constructor TFormatter.Create(pAlignment: TAlignment);
begin
  FAlignment := pAlignment;
end;

constructor TFormatter.Create(pFormatter: String; pAlignment: TAlignment);
begin
  FFormatter := pFormatter;
  FAlignment := pAlignment;
end;
{$EndRegion 'TFormatter'}

end.
