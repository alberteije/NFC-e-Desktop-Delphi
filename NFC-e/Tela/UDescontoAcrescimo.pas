{ *******************************************************************************
Title: T2TiPDV
Description: Janela para informar valores de acr�scimos ou descontos

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
unit UDescontoAcrescimo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, StdCtrls, JvExStdCtrls, JvEdit, JvValidateEdit, JvLabel,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls,
  JvEnterTab, JvComponentBase, Vcl.Mask, JvExMask, JvToolEdit, JvBaseEdits,
  Vcl.Imaging.jpeg;

type
  TFDescontoAcrescimo = class(TFBase)
    Image1: TImage;
    ComboOperacao: TComboBox;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    JvEnterAsTab1: TJvEnterAsTab;
    EditEntrada: TJvCalcEdit;
    Image2: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Confirma;
  end;

var
  FDescontoAcrescimo: TFDescontoAcrescimo;
  Confirmou: Boolean;

implementation

{$R *.dfm}

procedure TFDescontoAcrescimo.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFDescontoAcrescimo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Confirmou then
    ModalResult := MROK;
end;

procedure TFDescontoAcrescimo.FormCreate(Sender: TObject);
begin
  Confirmou := False;
end;

procedure TFDescontoAcrescimo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 123 then
    Confirma;
end;

procedure TFDescontoAcrescimo.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFDescontoAcrescimo.Confirma;
begin
  Confirmou := True;
  Close;
end;

end.
