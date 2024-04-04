{ *******************************************************************************
Title: T2TiPDV
Description: Detecta um movimento aberto e solicita autentica��o.

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
unit UMovimentoAberto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, JvExDBGrids, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls,
  JvEdit, JvValidateEdit, DB, NfceMovimentoVO, FMTBcd,
  JvEnterTab, Biblioteca, JvComponentBase, Tipos, Controller, Vcl.Imaging.jpeg;

type
  TFMovimentoAberto = class(TFBase)
    Image1: TImage;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    JvEnterAsTab1: TJvEnterAsTab;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel4: TBevel;
    LabelTurno: TLabel;
    LabelTerminal: TLabel;
    editSenhaOperador: TLabeledEdit;
    Label3: TLabel;
    LabelOperador: TLabel;
    Bevel3: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    LabelData: TLabel;
    LabelHora: TLabel;
    Image2: TImage;
    procedure Confirma;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoCancelaClick(Sender: TObject);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMovimentoAberto: TFMovimentoAberto;

implementation

{$R *.dfm}

procedure TFMovimentoAberto.FormShow(Sender: TObject);
begin
  LabelTurno.Caption := Sessao.Movimento.NfceTurnoVO.Descricao;
  LabelTerminal.Caption := Sessao.Movimento.NfceCaixaVO.Nome;
  LabelOperador.Caption := Sessao.Movimento.NfceOperadorVO.Login;
  LabelData.Caption := FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura);
  LabelHora.Caption := Sessao.Movimento.HoraAbertura;
  Self.Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFMovimentoAberto.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFMovimentoAberto.Confirma;
begin
  try
    try
      // verifica se senha do operador esta correta
      Sessao.AutenticaUsuario(LabelOperador.Caption, editSenhaOperador.Text);
      if Assigned(Sessao.Usuario) then
      begin
        Sessao.StatusCaixa := scAberto;
        Close;
        if Sessao.Movimento.StatusMovimento = 'T' then
        begin
          Sessao.Movimento.StatusMovimento := 'A';
          TController.ExecutarMetodo('NfceMovimentoController.TNfceMovimentoController', 'Altera', [Sessao.Movimento], 'POST', 'Boolean');
        end;
      end
      else
      begin
        Application.MessageBox('Operador: dados incorretos.', 'Informa��o do Sistema', MB_OK + MB_ICONINFORMATION);
        editSenhaOperador.SetFocus;
      end;
    except
    end;
  finally
  end;
end;

procedure TFMovimentoAberto.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 123 then
    Confirma;
  if Key = 27 then
    botaoCancela.Click;
end;

procedure TFMovimentoAberto.botaoCancelaClick(Sender: TObject);
begin
  SetTaskBar(True);
  Sessao.Free;
  ExitProcess(0);
end;

end.
