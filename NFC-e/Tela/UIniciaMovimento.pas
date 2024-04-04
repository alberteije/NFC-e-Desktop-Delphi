{ *******************************************************************************
Title: T2TiPDV
Description: Janela utilizada para iniciar um novo movimento.

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
unit UIniciaMovimento;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, Grids, DBGrids, JvExDBGrids, JvDBGrid, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls,
  JvEdit, JvValidateEdit, DB, FMTBcd, Provider, DBClient, SqlExpr,
  JvEnterTab, JvComponentBase, Tipos, JvDBUltimGrid, Biblioteca, Controller,
  Vcl.Mask, JvExMask, JvToolEdit, JvBaseEdits, DateUtils, Vcl.Imaging.jpeg,
  Printers;

type
  TFIniciaMovimento = class(TFBase)
    Image1: TImage;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    GroupBox3: TGroupBox;
    JvEnterAsTab1: TJvEnterAsTab;
    GroupBox1: TGroupBox;
    editLoginGerente: TLabeledEdit;
    editSenhaGerente: TLabeledEdit;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    GroupBox4: TGroupBox;
    editLoginOperador: TLabeledEdit;
    editSenhaOperador: TLabeledEdit;
    DSTurno: TDataSource;
    CDSTurno: TClientDataSet;
    GridTurno: TJvDBUltimGrid;
    EditValorSuprimento: TJvCalcEdit;
    Image2: TImage;
    Memo1: TMemo;
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure GridTurnoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImprimeAbertura;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIniciaMovimento: TFIniciaMovimento;

implementation

uses
  NfceOperadorVO, NfceMovimentoVO, NfceTurnoVO, NfceSuprimentoVO,
  NfceTurnoController;

{$R *.dfm}

{$REGION 'Infra'}
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

procedure TFIniciaMovimento.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  // Configura a Grid do Turno
  ConfiguraCDSFromVO(CDSTurno, TNfceTurnoVO);
  ConfiguraGridFromVO(GridTurno, TNfceTurnoVO);

  // Consulta os turnos
  TNfceTurnoController.SetDataSet(CDSTurno);
  TController.ExecutarMetodo('NfceTurnoController.TNfceTurnoController', 'Consulta', ['ID>0', '0', False], 'GET', 'Lista');

  GridTurno.SelectedIndex := 1;
  GridTurno.SetFocus;
end;

procedure TFIniciaMovimento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Release;
end;

procedure TFIniciaMovimento.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F12 then
    Confirma;
end;

procedure TFIniciaMovimento.GridTurnoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    editValorSuprimento.SetFocus;
end;
{$ENDREGION 'Infra'}

{$Region 'Confirma��o e In�cio do Movimento'}
procedure TFIniciaMovimento.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFIniciaMovimento.Confirma;
var
  Gerente: TNfceOperadorVO;
  Suprimento: TNfceSuprimentoVO;
begin
  try
    try
      // verifica se senha e o n�vel do operador est�o corretos
      Sessao.AutenticaUsuario(editLoginOperador.Text, editSenhaOperador.Text);
      if Assigned(Sessao.Usuario) then
      begin
        // verifica se senha do gerente esta correta
        Gerente := TNfceOperadorVO(TController.BuscarObjeto('NfceOperadorController.TNfceOperadorController', 'Usuario', [editLoginGerente.Text, editSenhaGerente.Text], 'GET'));
        if Assigned(Gerente) then
        begin
          // verifica nivel de acesso do gerente/supervisor
          if (Gerente.NivelAutorizacao = 'G') or (Gerente.NivelAutorizacao = 'S') then
          begin
            // insere movimento
            Sessao.Movimento := TNfceMovimentoVO.Create;

            Sessao.Movimento.IdNfceTurno := CDSTurno.FieldByName('ID').AsInteger;
            Sessao.Movimento.IdEmpresa := Sessao.Configuracao.IdEmpresa;
            Sessao.Movimento.IdNfceOperador := Sessao.Usuario.Id;
            Sessao.Movimento.IdNfceCaixa := Sessao.Configuracao.IdNfceCaixa;
            Sessao.Movimento.IdGerenteSupervisor := Gerente.Id;
            Sessao.Movimento.DataAbertura := Date;
            Sessao.Movimento.HoraAbertura := FormatDateTime('hh:nn:ss', Now);
            Sessao.Movimento.TotalSuprimento := editValorSuprimento.Value;
            Sessao.Movimento.StatusMovimento := 'A';

            TController.ExecutarMetodo('NfceMovimentoController.TNfceMovimentoController', 'IniciaMovimento', [Sessao.Movimento], 'PUT', 'Objeto');
            Sessao.Movimento := TNfceMovimentoVO(TController.ObjetoConsultado);

            // insere suprimento
            if editValorSuprimento.Value > 0 then
            begin
              try
                Suprimento := TNfceSuprimentoVO.Create;
                Suprimento.IdNfceMovimento := Sessao.Movimento.Id;
                Suprimento.DataSuprimento := Date;
                Suprimento.Observacao := 'Abertura do Caixa';
                Suprimento.Valor := editValorSuprimento.Value;
                TController.ExecutarMetodo('NfceSuprimentoController.TNfceSuprimentoController', 'Insere', [Suprimento], 'PUT', 'Lista');
                Sessao.Movimento.TotalSuprimento := Sessao.Movimento.TotalSuprimento + Suprimento.Valor;
                TController.ExecutarMetodo('NfceMovimentoController.TNfceMovimentoController', 'Altera', [Sessao.Movimento], 'POST', 'Boolean');
              finally
                FreeAndNil(Suprimento);
              end;
            end; // if StrToFloat(editValorSuprimento.Text) <> 0 then

            if Assigned(Sessao.Movimento) then
            begin
              Application.MessageBox('Movimento aberto com sucesso.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
              Sessao.StatusCaixa := scAberto;
              ImprimeAbertura;
            end;
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
    FreeAndNil(Gerente);
  end;
end;
{$EndRegion 'Confirma��o e In�cio do Movimento'}

{$Region 'Impress�o da Abertura'}
procedure TFIniciaMovimento.ImprimeAbertura;
begin
  // Exerc�cio: implemente o relat�rio no seu gerenciador preferido

  Memo1.Lines.Add(StringOfChar('=', 48));
  Memo1.Lines.Add('               ABERTURA DE CAIXA ');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('DATA DE ABERTURA  : ' + FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura));
  Memo1.Lines.Add('HORA DE ABERTURA  : ' + Sessao.Movimento.HoraAbertura);
  Memo1.Lines.Add(Sessao.Movimento.NfceCaixaVO.Nome + '  OPERADOR: ' + Sessao.Movimento.NfceOperadorVO.Login);
  Memo1.Lines.Add('MOVIMENTO: ' + IntToStr(Sessao.Movimento.Id));
  Memo1.Lines.Add(StringOfChar('=', 48));
  Memo1.Lines.Add('');
  Memo1.Lines.Add('SUPRIMENTO...: ' + formatfloat('##,###,##0.00', EditValorSuprimento.Value));
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(' ________________________________________ ');
  Memo1.Lines.Add(' VISTO DO CAIXA ');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(' ________________________________________ ');
  Memo1.Lines.Add(' VISTO DO SUPERVISOR ');

  ImprimirMemo(Memo1);
end;
{$EndRegion 'Impress�o da Abertura'}

end.
