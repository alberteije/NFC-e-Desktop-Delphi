{ *******************************************************************************
Title: T2TiPDV
Description: Janela que permite a digita��o e importa��o de um valor monet�rio.

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
unit UValorReal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, StdCtrls, JvExStdCtrls, JvEdit, JvValidateEdit, JvExControls, JvLabel,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls, Mask,
  JvExMask, JvToolEdit, JvBaseEdits, Vcl.Imaging.jpeg, LabeledCtrls;

type
  TFValorReal = class(TFBase)
    LabelEntrada: TJvLabel;
    JvBitBtn1: TJvBitBtn;
    JvImgBtn1: TJvImgBtn;
    Image1: TImage;
    EditEntrada: TJvCalcEdit;
    Image2: TImage;
    MemoObservacao: TLabeledMemo;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FValorReal: TFValorReal;

implementation

{$R *.dfm}

procedure TFValorReal.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFValorReal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
