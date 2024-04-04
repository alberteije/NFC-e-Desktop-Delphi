{*******************************************************************************
Title: T2TiPDV
Description: Carrega DAVs.

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
*******************************************************************************}
unit UCarregaDAV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UBase,
  Dialogs, Grids, DBGrids, JvExDBGrids, JvDBGrid, StdCtrls, JvExStdCtrls,
  JvButton, JvCtrls, Buttons, JvExButtons, JvBitBtn, pngimage, ExtCtrls, FMTBcd,
  Provider, DBClient, DB, SqlExpr, DBCtrls,Generics.Collections, JvDBUltimGrid,
  Biblioteca, Controller, DavCabecalhoVO, Vcl.Imaging.jpeg;

type
  TFCarregaDAV = class(TFBase)
    Image1: TImage;
    botaoConfirma: TJvBitBtn;
    botaoCancela: TJvImgBtn;
    DSMestre: TDataSource;
    CDSMestre: TClientDataSet;
    DSDetalhe: TDataSource;
    CDSDetalhe: TClientDataSet;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    GridMestre: TJvDBUltimGrid;
    GridDetalhe: TJvDBUltimGrid;
    Image2: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CDSMestreAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCarregaDAV: TFCarregaDAV;
  ListaDavCabecalho: TObjectList<TDavCabecalhoVO>;
  JanelaAtiva: Boolean;

implementation

uses
  UCaixa, DavController, DavDetalheController,
  DavDetalheVO;

{$R *.dfm}

procedure TFCarregaDAV.FormCreate(Sender: TObject);
begin
  JanelaAtiva := False;

  ConfiguraCDSFromVO(CDSMestre, TDavCabecalhoVO);
  ConfiguraGridFromVO(GridMestre, TDavCabecalhoVO);

  ConfiguraCDSFromVO(CDSDetalhe, TDavDetalheVO);
  ConfiguraGridFromVO(GridDetalhe, TDavDetalheVO);
end;

procedure TFCarregaDAV.FormActivate(Sender: TObject);
var
  Camadas: Integer;
  Filtro: String;
begin
  try
    Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

    Filtro := 'SITUACAO = ' + QuotedStr('P');
    TDavController.SetDataSet(CDSMestre);

    ListaDavCabecalho := TObjectList<TDavCabecalhoVO>(TController.BuscarLista('DAVController.TDAVController', 'ConsultaLista', [Filtro], 'GET'));

    TController.TratarRetorno<TDavCabecalhoVO>(ListaDavCabecalho, True, True, CDSMestre);

    JanelaAtiva := True;
    CDSMestre.First;
    GridMestre.SetFocus;
  finally
  end;
end;

procedure TFCarregaDAV.CDSMestreAfterScroll(DataSet: TDataSet);
begin
  if JanelaAtiva then
    TController.TratarRetorno<TDavDetalheVO>(ListaDavCabecalho.Items[CDSMestre.RecNo - 1].ListaDavDetalheVO, True, True, CDSDetalhe);
end;

procedure TFCarregaDAV.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(ListaDavCabecalho);
end;

procedure TFCarregaDAV.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_F12 then
    botaoConfirma.Click;
end;

end.
