{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado � tabela [NFE_CONFIGURACAO] 
                                                                                
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

@author Albert Eije (t2ti.com@gmail.com)
@version 4.0
*******************************************************************************}
unit NfeConfiguracaoController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB,  Windows, Forms, Controller, Rtti,
  Atributos, NfeConfiguracaoVO, Generics.Collections;


type
  TNfeConfiguracaoController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean = False);
    class function ConsultaLista(pFiltro: String): TObjectList<TNfeConfiguracaoVO>;
    class function ConsultaObjeto(pFiltro: String): TNfeConfiguracaoVO;

    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
  end;

implementation

uses UDataModule, T2TiORM;

class procedure TNfeConfiguracaoController.Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean);
var
  Retorno: TObjectList<TNfeConfiguracaoVO>;
begin
  try
    Retorno := TT2TiORM.Consultar<TNfeConfiguracaoVO>(pFiltro, pPagina, pConsultaCompleta);
    TratarRetorno<TNfeConfiguracaoVO>(Retorno);
  finally
  end;
end;

class function TNfeConfiguracaoController.ConsultaLista(pFiltro: String): TObjectList<TNfeConfiguracaoVO>;
begin
  try
    Result := TT2TiORM.Consultar<TNfeConfiguracaoVO>(pFiltro, '-1', True);
  finally
  end;
end;

class function TNfeConfiguracaoController.ConsultaObjeto(pFiltro: String): TNfeConfiguracaoVO;
begin
  try
    Result := TT2TiORM.ConsultarUmObjeto<TNfeConfiguracaoVO>(pFiltro, True);
  finally
  end;
end;

class function TNfeConfiguracaoController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TNfeConfiguracaoController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

initialization
  Classes.RegisterClass(TNfeConfiguracaoController);

finalization
  Classes.UnRegisterClass(TNfeConfiguracaoController);

end.
