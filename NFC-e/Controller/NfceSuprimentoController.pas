{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado � tabela [NFCE_SUPRIMENTO] 
                                                                                
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
unit NfceSuprimentoController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB,  Windows, Forms, Controller, Rtti,
  Atributos, VO, Generics.Collections, NfceSuprimentoVO;

type
  TNfceSuprimentoController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean = False);
    class function ConsultaLista(pFiltro: String): TObjectList<TNfceSuprimentoVO>;
    class function ConsultaObjeto(pFiltro: String): TNfceSuprimentoVO;

    class procedure Insere(pObjeto: TNfceSuprimentoVO);
    class function Altera(pObjeto: TNfceSuprimentoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
    class procedure TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
  end;

implementation

uses T2TiORM;

class procedure TNfceSuprimentoController.Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean);
var
  Retorno: TObjectList<TNfceSuprimentoVO>;
begin
  try
    Retorno := TT2TiORM.Consultar<TNfceSuprimentoVO>(pFiltro, pPagina, pConsultaCompleta);
    TratarRetorno<TNfceSuprimentoVO>(Retorno);
  finally
  end;
end;

class function TNfceSuprimentoController.ConsultaLista(pFiltro: String): TObjectList<TNfceSuprimentoVO>;
begin
  try
    Result := TT2TiORM.Consultar<TNfceSuprimentoVO>(pFiltro, '-1', True);
  finally
  end;
end;

class function TNfceSuprimentoController.ConsultaObjeto(pFiltro: String): TNfceSuprimentoVO;
begin
  try
    Result := TT2TiORM.ConsultarUmObjeto<TNfceSuprimentoVO>(pFiltro, True);
  finally
  end;
end;

class procedure TNfceSuprimentoController.Insere(pObjeto: TNfceSuprimentoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TNfceSuprimentoController.Altera(pObjeto: TNfceSuprimentoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TNfceSuprimentoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TNfceSuprimentoVO;
begin
  try
    ObjetoLocal := TNfceSuprimentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
    TratarRetorno(Result);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TNfceSuprimentoController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TNfceSuprimentoController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

class procedure TNfceSuprimentoController.TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
begin
  try
    TratarRetorno<TNfceSuprimentoVO>(TObjectList<TNfceSuprimentoVO>(pListaObjetos));
  finally
    FreeAndNil(pListaObjetos);
  end;
end;

initialization
  Classes.RegisterClass(TNfceSuprimentoController);

finalization
  Classes.UnRegisterClass(TNfceSuprimentoController);

end.
