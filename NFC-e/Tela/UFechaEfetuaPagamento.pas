{ *******************************************************************************
  Title: T2Ti ERP
  Description: Tela que aparece ap�s efetuarem todos os pagamentos.

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
unit UFechaEfetuaPagamento;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, UBase;

type
  TFFechaEfetuaPagamento = class(TFBase)
    Timer1: TTimer;
    JvPanel1: TJvPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FFechaEfetuaPagamento: TFFechaEfetuaPagamento;

implementation

{$R *.dfm}

procedure TFFechaEfetuaPagamento.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TFFechaEfetuaPagamento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  FFechaEfetuaPagamento := nil;
end;

procedure TFFechaEfetuaPagamento.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      Close;
    VK_ESCAPE:
      Close;
  end;
end;

procedure TFFechaEfetuaPagamento.FormShow(Sender: TObject);
begin
  JvPanel1.Caption := 'Enter ou ESC para continuar';
  JvPanel1.Color := clYellow;
  Timer1.Enabled := true;
end;

procedure TFFechaEfetuaPagamento.Timer1Timer(Sender: TObject);
begin
  if JvPanel1.Font.Color = clBlack then
  begin
    JvPanel1.Color := clRed;
    JvPanel1.Font.Color := clWhite;
  end
  else
  begin
    JvPanel1.Font.Color := clBlack;
    JvPanel1.Color := clYellow;
  end;
end;

end.
