{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado � tabela [DAV_DETALHE] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2010 T2Ti.COM                                          
                                                                                
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
t2ti.com@gmail.com</p>

Albert Eije (T2Ti.COM)
@version 4.0
*******************************************************************************}
unit DavDetalheController;

interface

uses
  Classes, SysUtils, DBClient, DB, Windows, Forms, Controller, Rtti, Atributos,
  VO, DavDetalheVO, Generics.Collections;


type
  TDavDetalheController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean = False);
    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
    class procedure TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
  end;

implementation

uses T2TiORM;

class procedure TDavDetalheController.Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean);
var
  Retorno: TObjectList<TDavDetalheVO>;
begin
  try
    Retorno := TT2TiORM.Consultar<TDavDetalheVO>(pFiltro, pPagina, pConsultaCompleta);
    TratarRetorno<TDavDetalheVO>(Retorno);
  finally
  end;
end;

class function TDavDetalheController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TDavDetalheController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

class procedure TDavDetalheController.TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
begin
  try
    TratarRetorno<TDavDetalheVO>(TObjectList<TDavDetalheVO>(pListaObjetos));
  finally
    FreeAndNil(pListaObjetos);
  end;
end;

initialization
  Classes.RegisterClass(TDavDetalheController);

finalization
  Classes.UnRegisterClass(TDavDetalheController);

end.
