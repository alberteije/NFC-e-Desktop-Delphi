{ *******************************************************************************
Title: T2TiPDV
Description: Encerra um movimento aberto.

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
unit UEncerraMovimento;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, Grids, DBGrids, JvExDBGrids, JvDBGrid, StdCtrls, ExtCtrls,
  JvExStdCtrls, JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage,
  FMTBcd, JvEnterTab, Provider, DBClient, DB, SqlExpr, Generics.Collections,
  JvComponentBase, Mask, JvExMask, JvToolEdit, JvBaseEdits, Biblioteca,
  Controller, JvDBUltimGrid, Tipos, DateUtils, Vcl.Imaging.jpeg, Printers;

type
  TFEncerraMovimento = class(TFBase)
    Image1: TImage;
    GroupBox2: TGroupBox;
    editSenhaOperador: TLabeledEdit;
    GroupBox1: TGroupBox;
    editLoginGerente: TLabeledEdit;
    editSenhaGerente: TLabeledEdit;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    JvEnterAsTab1: TJvEnterAsTab;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    LabelTurno: TLabel;
    LabelTerminal: TLabel;
    LabelOperador: TLabel;
    GroupBox3: TGroupBox;
    ComboTipoPagamento: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    edtValor: TJvCalcEdit;
    btnAdicionar: TBitBtn;
    btnRemover: TBitBtn;
    edtTotal: TJvCalcEdit;
    DSFechamento: TDataSource;
    GridFechamento: TJvDBUltimGrid;
    CDSFechamento: TClientDataSet;
    Image2: TImage;
    Bevel4: TBevel;
    Memo1: TMemo;
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TotalizaFechamento;
    procedure ImprimeFechamento;
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverClick(Sender: TObject);
    procedure edtValorExit(Sender: TObject);
    procedure editSenhaGerenteExit(Sender: TObject);
    procedure botaoCancelaClick(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  FEncerraMovimento: TFEncerraMovimento;
  FechouMovimento: Boolean;

implementation

uses
  NfceFechamentoController,
  NfceTipoPagamentoVO, NfceOperadorVO, NfceFechamentoVO;

{$R *.dfm}

{$Region 'Infra'}
procedure ImprimirMemo(Memo: TMemo);
var
  I: integer;
  F: Text;
begin
  { Usa na impressora a mesma fonte do memo }
  Printer.Canvas.Font.Assign(Memo.Font);

  AssignPrn(F);
  Rewrite(F);
  try
    for I := 0 to Memo.Lines.Count -1 do
      WriteLn(F, Memo.Lines[I]);
  finally
    CloseFile(F);
  end;
end;

procedure TFEncerraMovimento.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FechouMovimento := False;

  LabelTurno.Caption := Sessao.Movimento.NfceTurnoVO.Descricao;
  LabelTerminal.Caption := Sessao.Movimento.NfceCaixaVO.Nome;
  LabelOperador.Caption := Sessao.Movimento.NfceOperadorVO.Login;

  try
    for i := 0 to Sessao.ListaTipoPagamento.Count - 1 do
      ComboTipoPagamento.Items.Add(TNfceTipoPagamentoVO(Sessao.ListaTipoPagamento.Items[i]).Descricao);
    ComboTipoPagamento.ItemIndex := 0;
  finally
  end;
end;

procedure TFEncerraMovimento.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
  ComboTipoPagamento.SetFocus;

  // Configura a Grid do Fechamento
  ConfiguraCDSFromVO(CDSFechamento, TNfceFechamentoVO);
  ConfiguraGridFromVO(GridFechamento, TNfceFechamentoVO);

  TotalizaFechamento;
end;

procedure TFEncerraMovimento.editSenhaGerenteExit(Sender: TObject);
begin
  botaoConfirma.SetFocus;
end;

procedure TFEncerraMovimento.edtValorExit(Sender: TObject);
begin
  if edtValor.Value = 0 then
    editSenhaOperador.SetFocus;
end;

procedure TFEncerraMovimento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FechouMovimento then
  begin
    ModalResult := mrOK;
    Sessao.Movimento := Nil;
  end
  else
    ModalResult := mrCancel;
  Action := caFree;
end;

procedure TFEncerraMovimento.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F12 then
    Confirma;
  if Key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFEncerraMovimento.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TFEncerraMovimento.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;
{$EndRegion 'Infra'}

{$Region 'Dados de Fechamento'}
procedure TFEncerraMovimento.btnAdicionarClick(Sender: TObject);
var
  Fechamento: TNfceFechamentoVO;
begin
  if trim(ComboTipoPagamento.Text) = '' then
  begin
    Application.MessageBox('Informe um tipo de Pagamento V�lido!', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
    ComboTipoPagamento.SetFocus;
    Exit;
  end;

  if edtValor.Value <= 0 then
  begin
    Application.MessageBox('Informe um Valor V�lido!', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
    edtValor.SetFocus;
    Exit;
  end;

  try
    Fechamento := TNfceFechamentoVO.Create;
    Fechamento.IdNfceMovimento := Sessao.Movimento.Id;
    Fechamento.TipoPagamento := ComboTipoPagamento.Text;
    Fechamento.Valor := edtValor.Value;

    TController.ExecutarMetodo('NfceFechamentoController.TNfceFechamentoController', 'Insere', [Fechamento], 'PUT', 'Lista');

    TotalizaFechamento;
  finally
    FreeAndNil(Fechamento);
  end;
  edtValor.Clear;
  ComboTipoPagamento.SetFocus;
end;

procedure TFEncerraMovimento.btnRemoverClick(Sender: TObject);
begin
  if not CDSFechamento.IsEmpty then
  begin
    TController.ExecutarMetodo('NfceFechamentoController.TNfceFechamentoController', 'Exclui', [CDSFechamento.FieldByName('ID').AsInteger], 'DELETE', 'Boolean');
    TotalizaFechamento;
  end;
  ComboTipoPagamento.SetFocus;
end;

procedure TFEncerraMovimento.TotalizaFechamento;
var
  Total: Extended;
  Filtro: String;
begin
  // Verifica se j� existem dados para o fechamento
  Filtro := 'ID_NFCE_MOVIMENTO = ' + IntToStr(Sessao.Movimento.Id);
  TNfceFechamentoController.SetDataSet(CDSFechamento);
  TController.ExecutarMetodo('NfceFechamentoController.TNfceFechamentoController', 'Consulta', [Filtro, '0', False], 'GET', 'Lista');

  Total := 0;

  if not CDSFechamento.IsEmpty then
  begin
    CDSFechamento.DisableControls;
    CDSFechamento.First;
    while not CDSFechamento.Eof do
    begin
      Total := Total + CDSFechamento.FieldByName('VALOR').AsExtended;
      CDSFechamento.Next;
    end;
    CDSFechamento.EnableControls;
  end;
  edtTotal.Value := Total;
end;
{$EndRegion 'Dados de Fechamento'}

{$Region 'Confirma��o e Encerramento do Movimento'}
procedure TFEncerraMovimento.Confirma;
var
  Operador: TNfceOperadorVO;
  Gerente: TNfceOperadorVO;
begin
  try
   try
      // verifica se senha do operador esta correta
      Operador := TNfceOperadorVO(TController.BuscarObjeto('NfceOperadorController.TNfceOperadorController', 'Usuario', [LabelOperador.Caption, editSenhaOperador.Text], 'GET'));
      if Assigned(Operador) then
      begin
        // verifica se senha do gerente esta correta
        Gerente := TNfceOperadorVO(TController.BuscarObjeto('NfceOperadorController.TNfceOperadorController', 'Usuario', [editLoginGerente.Text, editSenhaGerente.Text], 'GET'));
        if Assigned(Gerente) then
        begin
          if (Gerente.NivelAutorizacao = 'G') or (Gerente.NivelAutorizacao = 'S') then
          begin
            // encerra movimento
            Sessao.Movimento.DataFechamento := Date;
            Sessao.Movimento.HoraFechamento := FormatDateTime('hh:nn:ss', Now);
            Sessao.Movimento.StatusMovimento := 'F';

            TController.ExecutarMetodo('NfceMovimentoController.TNfceMovimentoController', 'Altera', [Sessao.Movimento], 'POST', 'Boolean');

            ImprimeFechamento;

            Application.MessageBox('Movimento encerrado com sucesso.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);

            FechouMovimento := True;

            botaoConfirma.ModalResult := mrOK;
            self.ModalResult := mrOK;
            Close;
          end
          else
          begin
            Application.MessageBox('Gerente ou Supervisor: n�vel de acesso incorreto.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
            editLoginGerente.SetFocus;
          end; // if (Gerente.Nivel = 'G') or (Gerente.Nivel = 'S') then
        end
        else
        begin
          Application.MessageBox('Gerente ou Supervisor: dados incorretos.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
          editLoginGerente.SetFocus;
        end; // if Gerente.Id <> 0 then
      end
      else
      begin
        Application.MessageBox('Operador: dados incorretos.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
        editSenhaOperador.SetFocus;
      end; // if Operador.Id <> 0 then
    except
    end;
  finally
    if Assigned(Operador) then
      FreeAndNil(Operador);
    if Assigned(Gerente) then
      FreeAndNil(Gerente);
  end;
end;
{$EndRegion 'Confirma��o e Encerramento do Movimento'}

{$Region 'Impress�o do Fechamento'}
procedure TFEncerraMovimento.ImprimeFechamento;
var
  Declarado, Meio: AnsiString;
  Suprimento, Sangria, NaoFiscal, TotalVenda, Desconto, Acrescimo, Recebido, Troco, Cancelado, TotalFinal: AnsiString;
  TotDeclarado: Currency;
begin
  // Exerc�cio: implemente o relat�rio no seu gerenciador preferido
  try
    Memo1.Lines.Add(StringOfChar('=', 48));
    Memo1.Lines.Add('             FECHAMENTO DE CAIXA                ');
    Memo1.Lines.Add(StringOfChar('=', 48));
    Memo1.Lines.Add('');
    Memo1.Lines.Add('DATA DE ABERTURA  : ' + FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura));
    Memo1.Lines.Add('HORA DE ABERTURA  : ' + Sessao.Movimento.HoraAbertura);
    Memo1.Lines.Add('DATA DE FECHAMENTO: ' + FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataFechamento));
    Memo1.Lines.Add('HORA DE FECHAMENTO: ' + Sessao.Movimento.HoraFechamento);
    Memo1.Lines.Add(Sessao.Movimento.NfceCaixaVO.Nome + '  OPERADOR: ' + Sessao.Movimento.NfceOperadorVO.Login);
    Memo1.Lines.Add('MOVIMENTO: ' + IntToStr(Sessao.Movimento.Id));
    Memo1.Lines.Add(StringOfChar('=', 48));
    Memo1.Lines.Add('');

    Suprimento := FloatToStrF(Sessao.Movimento.TotalSuprimento, ffNumber, 11, 2);
    Suprimento := StringOfChar(' ', 33 - Length(Suprimento)) + Suprimento;
    Sangria := FloatToStrF(Sessao.Movimento.TotalSangria, ffNumber, 11, 2);
    Sangria := StringOfChar(' ', 33 - Length(Sangria)) + Sangria;
    NaoFiscal := FloatToStrF(Sessao.Movimento.TotalNaoFiscal, ffNumber, 11, 2);
    NaoFiscal := StringOfChar(' ', 33 - Length(NaoFiscal)) + NaoFiscal;
    TotalVenda := FloatToStrF(Sessao.Movimento.TotalVenda, ffNumber, 11, 2);
    TotalVenda := StringOfChar(' ', 33 - Length(TotalVenda)) + TotalVenda;
    Desconto := FloatToStrF(Sessao.Movimento.TotalDesconto, ffNumber, 11, 2);
    Desconto := StringOfChar(' ', 33 - Length(Desconto)) + Desconto;
    Acrescimo := FloatToStrF(Sessao.Movimento.TotalAcrescimo, ffNumber, 11, 2);
    Acrescimo := StringOfChar(' ', 33 - Length(Acrescimo)) + Acrescimo;
    Recebido := FloatToStrF(Sessao.Movimento.TotalRecebido, ffNumber, 11, 2);
    Recebido := StringOfChar(' ', 33 - Length(Recebido)) + Recebido;
    Troco := FloatToStrF(Sessao.Movimento.TotalTroco, ffNumber, 11, 2);
    Troco := StringOfChar(' ', 33 - Length(Troco)) + Troco;
    Cancelado := FloatToStrF(Sessao.Movimento.TotalCancelado, ffNumber, 11, 2);
    Cancelado := StringOfChar(' ', 33 - Length(Cancelado)) + Cancelado;
    TotalFinal := FloatToStrF(Sessao.Movimento.TotalFinal, ffNumber, 11, 2);
    TotalFinal := StringOfChar(' ', 33 - Length(TotalFinal)) + TotalFinal;

    Memo1.Lines.Add('SUPRIMENTO...: ' + Suprimento);
    Memo1.Lines.Add('SANGRIA......: ' + Sangria);
    Memo1.Lines.Add('NAO FISCAL...: ' + NaoFiscal);
    Memo1.Lines.Add('TOTAL VENDA..: ' + TotalVenda);
    Memo1.Lines.Add('DESCONTO.....: ' + Desconto);
    Memo1.Lines.Add('ACRESCIMO....: ' + Acrescimo);
    Memo1.Lines.Add('RECEBIDO.....: ' + Recebido);
    Memo1.Lines.Add('TROCO........: ' + Troco);
    Memo1.Lines.Add('CANCELADO....: ' + Cancelado);
    Memo1.Lines.Add('TOTAL FINAL..: ' + TotalFinal);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add(StringOfChar('=', 48));
    Memo1.Lines.Add('       VALORES DECLARADOS PARA FECHAMENTO');
    Memo1.Lines.Add(StringOfChar('=', 48));
    Memo1.Lines.Add('');

    CDSFechamento.DisableControls;
    CDSFechamento.First;
    while not CDSFechamento.Eof do
    begin
      Declarado := FloatToStrF(CDSFechamento.FieldByName('VALOR').AsExtended, ffNumber, 9, 2);
      Declarado := StringOfChar(' ', 28 - Length(Declarado)) + Declarado;

      Meio := CDSFechamento.FieldByName('TIPO_PAGAMENTO').AsString;
      Meio := StringOfChar(' ', 20 - Length(Meio)) + Meio;

      TotDeclarado := TotDeclarado + CDSFechamento.FieldByName('VALOR').AsExtended;

      Memo1.Lines.Add(Meio + Declarado);

      CDSFechamento.Next;
    end;
    CDSFechamento.First;
    CDSFechamento.EnableControls;

    Memo1.Lines.Add(StringOfChar('-', 48));

    Declarado := FloatToStrF(TotDeclarado, ffNumber, 9, 2);
    Declarado := StringOfChar(' ', 33 - Length(Declarado)) + Declarado;

    Memo1.Lines.Add('TOTAL.........:' + Declarado);
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('    ________________________________________    ');
    Memo1.Lines.Add('                 VISTO DO CAIXA                 ');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('    ________________________________________    ');
    Memo1.Lines.Add('               VISTO DO SUPERVISOR              ');

    ImprimirMemo(Memo1);

  finally
  end;
end;
{$EndRegion 'Impress�o do Fechamento'}



end.
