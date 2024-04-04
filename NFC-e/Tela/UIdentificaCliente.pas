{ *******************************************************************************
Title: T2TiPDV
Description: Identifica um cliente n�o cadastrado para a venda. Permite chamar
a janela de pesquisa para importar um cliente cadastrado.

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
unit UIdentificaCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, JvExDBGrids, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls, Mask,
  JvEdit, JvValidateEdit, Biblioteca, JvEnterTab, JvComponentBase,
  JvExMask, JvToolEdit, JvBaseEdits, Controller, Vcl.Imaging.jpeg;

type
  TFIdentificaCliente = class(TFBase)
    Image1: TImage;
    panPeriodo: TPanel;
    editCpfCnpj: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    editNome: TEdit;
    editEndereco: TEdit;
    botaoLocaliza: TJvBitBtn;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    JvEnterAsTab1: TJvEnterAsTab;
    editIDCliente: TJvCalcEdit;
    Label4: TLabel;
    Image2: TImage;
    procedure Localiza;
    procedure LocalizaClienteNoBanco;
    procedure Confirma;
    procedure botaoLocalizaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure editCpfCnpjExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function ValidaDados: Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIdentificaCliente: TFIdentificaCliente;

implementation

uses UImportaCliente, ViewNfceClienteVO;

var
  Cliente: TViewNfceClienteVO;

{$R *.dfm}

procedure TFIdentificaCliente.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
  Cliente := TViewNfceClienteVO.Create;
end;

procedure TFIdentificaCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Cliente);
  Action := caFree;
end;

procedure TFIdentificaCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F11 then
    Localiza;
  if Key = VK_F12 then
    Confirma;
end;

procedure TFIdentificaCliente.botaoLocalizaClick(Sender: TObject);
begin
  Localiza;
end;

procedure TFIdentificaCliente.Localiza;
begin
  Application.CreateForm(TFImportaCliente, FImportaCliente);
  FImportaCliente.QuemChamou := 'IdentificaCliente';
  FImportaCliente.ShowModal;
end;

procedure TFIdentificaCliente.editCpfCnpjExit(Sender: TObject);
begin
  if trim(editCpfCnpj.Text) <> '' then
    LocalizaClienteNoBanco;
end;

procedure TFIdentificaCliente.LocalizaClienteNoBanco;
var
  Filtro: String;
begin
  Filtro := 'CPF = ' + QuotedStr(editCpfCnpj.Text);
  Cliente := TViewNfceClienteVO(TController.BuscarObjeto('ViewNfceClienteController.TViewNfceClienteController', 'ConsultaObjeto', [Filtro], 'GET'));
  if Assigned(Cliente) then
  begin
    editIDCliente.AsInteger := Cliente.Id;
    editNome.Text := Cliente.Nome;
  end
  else
    Cliente := TViewNfceClienteVO.Create;
end;

function TFIdentificaCliente.ValidaDados: Boolean;
begin
  Result := False;
  if length(editCpfCnpj.Text) = 11 then
    Result := ValidaCPF(editCpfCnpj.Text);

  if length(editCpfCnpj.Text) = 14 then
    Result := ValidaCNPJ(editCpfCnpj.Text);
end;

procedure TFIdentificaCliente.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFIdentificaCliente.Confirma;
begin
  if ValidaDados then
  begin
    Sessao.VendaAtual.NfeDestinatarioVO.Nome := EditNome.Text;
    Sessao.VendaAtual.NfeDestinatarioVO.CpfCnpj := editCpfCnpj.Text;
    Close;
  end
  else
  begin
    Application.MessageBox('CPF ou CNPJ Inv�lido!', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
    editCpfCnpj.SetFocus;
  end;
end;

end.
