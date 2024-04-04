{ *******************************************************************************
  Title: T2TiPDV
  Description: Pesquisa por cliente e importa��o para a venda.

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
  t2ti.com@gmail.com

  @author Albert Eije
  @version 1.0
  ******************************************************************************* }
unit UImportaCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, Grids, DBGrids, JvExDBGrids, JvDBGrid, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls, Mask,
  JvEdit, JvValidateEdit, JvDBSearchEdit, DB, Provider, DBClient, FMTBcd,
  SqlExpr, JvEnterTab, JvComponentBase, Tipos, JvDBUltimGrid, Biblioteca,
  Controller, Vcl.Imaging.jpeg;

type
  TFImportaCliente = class(TFBase)
    Image1: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    JvEnterAsTab1: TJvEnterAsTab;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    DSCliente: TDataSource;
    EditLocaliza: TEdit;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    CDSCliente: TClientDataSet;
    GridPrincipal: TJvDBUltimGrid;
    Image2: TImage;
    procedure Localiza;
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure botaoConfirmaClick(Sender: TObject);
  private
    { Private declarations }
  public
    CpfCnpjPassou, QuemChamou: string;
    IdClientePassou: Integer;
    { Public declarations }
  end;

var
  FImportaCliente: TFImportaCliente;

implementation

uses
  ViewNfceClienteVO,
  ViewNfceClienteController,
  UCaixa, UIdentificaCliente;

{$R *.dfm}

{$REGION 'Infra'}
procedure TFImportaCliente.FormActivate(Sender: TObject);
begin
  EditLocaliza.SetFocus;
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  // Configura a Grid do Cliente
  ConfiguraCDSFromVO(CDSCliente, TViewNfceClienteVO);
  ConfiguraGridFromVO(GridPrincipal, TViewNfceClienteVO);
end;

procedure TFImportaCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFImportaCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F2 then
    Localiza;

  if Key = VK_F12 then
    Confirma;
end;

procedure TFImportaCliente.GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EditLocaliza.SetFocus;
end;
{$ENDREGION 'Infra'}

{$REGION 'Pesquisa e Confirma��o'}
procedure TFImportaCliente.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFImportaCliente.Confirma;
begin
  if Sessao.MenuAberto = snNao then
  begin
    if CDSCliente.FieldByName('CPF').AsString = '' then
      Application.MessageBox('Cliente sem CPF cadastrado.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION)
    else
    begin
      FIdentificaCliente.editCpfCnpj.Text := CDSCliente.FieldByName('CPF').AsString;
      FIdentificaCliente.EditNome.Text := CDSCliente.FieldByName('NOME').AsString;
      FIdentificaCliente.editIDCliente.asinteger := CDSCliente.FieldByName('ID').asinteger;
    end;
  end;
  Close;
end;

procedure TFImportaCliente.Localiza;
var
  ProcurePor, Filtro: String;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';
  Filtro := 'NOME LIKE ' + QuotedStr(ProcurePor);

  TViewNfceClienteController.SetDataSet(CDSCliente);
  TController.ExecutarMetodo('ViewNfceClienteController.TViewNfceClienteController', 'Consulta', [Filtro, '0', False], 'GET', 'Lista');
end;

procedure TFImportaCliente.SpeedButton1Click(Sender: TObject);
begin
  Localiza;
end;
{$ENDREGION 'Pesquisa e Confirma��o'}

end.
