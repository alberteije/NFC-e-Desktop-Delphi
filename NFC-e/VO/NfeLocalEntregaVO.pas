{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado � tabela [NFE_LOCAL_ENTREGA] 
                                                                                
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
unit NfeLocalEntregaVO;

interface

uses
  VO, Atributos, Classes, Constantes, Generics.Collections, SysUtils;

type
  [TEntity]
  [TTable('NFE_LOCAL_ENTREGA')]
  TNfeLocalEntregaVO = class(TVO)
  private
    FID: Integer;
    FID_NFE_CABECALHO: Integer;
    FCPF_CNPJ: String;
    FLOGRADOURO: String;
    FNUMERO: String;
    FCOMPLEMENTO: String;
    FBAIRRO: String;
    FCODIGO_MUNICIPIO: Integer;
    FNOME_MUNICIPIO: String;
    FUF: String;

    //Usado no lado cliente para controlar quais registros ser�o persistidos
    FPersiste: String;

  public 
    [TId('ID')]
    [TGeneratedValue(sAuto)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property Id: Integer  read FID write FID;
    [TColumn('ID_NFE_CABECALHO', 'Id Nfe Cabecalho', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property IdNfeCabecalho: Integer  read FID_NFE_CABECALHO write FID_NFE_CABECALHO;
    [TColumn('CPF_CNPJ', 'Cpf Cnpj', 112, [ldGrid, ldLookup, ldCombobox], False)]
    property CpfCnpj: String  read FCPF_CNPJ write FCPF_CNPJ;
    [TColumn('LOGRADOURO', 'Logradouro', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Logradouro: String  read FLOGRADOURO write FLOGRADOURO;
    [TColumn('NUMERO', 'Numero', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Numero: String  read FNUMERO write FNUMERO;
    [TColumn('COMPLEMENTO', 'Complemento', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Complemento: String  read FCOMPLEMENTO write FCOMPLEMENTO;
    [TColumn('BAIRRO', 'Bairro', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Bairro: String  read FBAIRRO write FBAIRRO;
    [TColumn('CODIGO_MUNICIPIO', 'Codigo Municipio', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property CodigoMunicipio: Integer  read FCODIGO_MUNICIPIO write FCODIGO_MUNICIPIO;
    [TColumn('NOME_MUNICIPIO', 'Nome Municipio', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property NomeMunicipio: String  read FNOME_MUNICIPIO write FNOME_MUNICIPIO;
    [TColumn('UF', 'Uf', 16, [ldGrid, ldLookup, ldCombobox], False)]
    property Uf: String  read FUF write FUF;

    [TColumn('PERSISTE', 'Persiste', 60, [], True)]
    property Persiste: String  read FPersiste write FPersiste;

  end;

implementation


initialization
  Classes.RegisterClass(TNfeLocalEntregaVO);

finalization
  Classes.UnRegisterClass(TNfeLocalEntregaVO);

end.
