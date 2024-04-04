{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado � tabela [NFCE_CONFIGURACAO] 
                                                                                
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
unit NfceConfiguracaoController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB,  Windows, Forms, Controller, Rtti,
  Atributos, VO, Generics.Collections, NfceConfiguracaoVO, EmpresaEnderecoVO;

type
  TNfceConfiguracaoController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean = False);
    class function ConsultaLista(pFiltro: String): TObjectList<TNfceConfiguracaoVO>;
    class function ConsultaObjeto(pFiltro: String): TNfceConfiguracaoVO;

    class procedure Insere(pObjeto: TNfceConfiguracaoVO);
    class function Altera(pObjeto: TNfceConfiguracaoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
    class procedure TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
  end;

implementation

uses T2TiORM;

class procedure TNfceConfiguracaoController.Consulta(pFiltro: String; pPagina: String; pConsultaCompleta: Boolean);
var
  Retorno: TObjectList<TNfceConfiguracaoVO>;
begin
  try
    Retorno := TT2TiORM.Consultar<TNfceConfiguracaoVO>(pFiltro, pPagina, pConsultaCompleta);
    TratarRetorno<TNfceConfiguracaoVO>(Retorno);
  finally
  end;
end;

class function TNfceConfiguracaoController.ConsultaLista(pFiltro: String): TObjectList<TNfceConfiguracaoVO>;
begin
  try
    Result := TT2TiORM.Consultar<TNfceConfiguracaoVO>(pFiltro, '-1', True);
  finally
  end;
end;

class function TNfceConfiguracaoController.ConsultaObjeto(pFiltro: String): TNfceConfiguracaoVO;
var
  EnderecoPrincipal: TEmpresaEnderecoVO;
  Filtro: String;
begin
  try
    Result := TT2TiORM.ConsultarUmObjeto<TNfceConfiguracaoVO>(pFiltro, True);

    // Pega o endere�o principal da empresa
    Filtro := 'PRINCIPAL=' + QuotedStr('S') + ' AND ID_EMPRESA=' + IntToStr(Result.EmpresaVO.Id);
    Result.EmpresaVO.EnderecoPrincipal := TEmpresaEnderecoVO(TController.BuscarObjeto('EmpresaEnderecoController.TEmpresaEnderecoController', 'ConsultaObjeto', [Filtro], 'GET'));
  finally
  end;
end;

class procedure TNfceConfiguracaoController.Insere(pObjeto: TNfceConfiguracaoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TNfceConfiguracaoController.Altera(pObjeto: TNfceConfiguracaoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TNfceConfiguracaoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TNfceConfiguracaoVO;
begin
  try
    ObjetoLocal := TNfceConfiguracaoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
    TratarRetorno(Result);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TNfceConfiguracaoController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TNfceConfiguracaoController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

class procedure TNfceConfiguracaoController.TratarListaRetorno(pListaObjetos: TObjectList<TVO>);
begin
  try
    TratarRetorno<TNfceConfiguracaoVO>(TObjectList<TNfceConfiguracaoVO>(pListaObjetos));
  finally
    FreeAndNil(pListaObjetos);
  end;
end;

initialization
  Classes.RegisterClass(TNfceConfiguracaoController);

finalization
  Classes.UnRegisterClass(TNfceConfiguracaoController);

end.
