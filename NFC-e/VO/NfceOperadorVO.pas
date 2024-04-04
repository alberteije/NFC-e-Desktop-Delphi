{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado � tabela [NFCE_OPERADOR] 
                                                                                
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
unit NfceOperadorVO;

interface

uses
  VO, Atributos, Classes, Constantes, Generics.Collections, SysUtils;

type
  [TEntity]
  [TTable('NFCE_OPERADOR')]
  TNfceOperadorVO = class(TVO)
  private
    FID: Integer;
    FLOGIN: String;
    FSENHA: String;
    FNIVEL_AUTORIZACAO: String;

  public 
    [TId('ID')]
    [TGeneratedValue(sAuto)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property Id: Integer  read FID write FID;
    [TColumn('LOGIN', 'Login', 160, [ldGrid, ldLookup, ldCombobox], False)]
    property Login: String  read FLOGIN write FLOGIN;
    [TColumn('SENHA', 'Senha', 160, [ldGrid, ldLookup, ldCombobox], False)]
    property Senha: String  read FSENHA write FSENHA;
    [TColumn('NIVEL_AUTORIZACAO', 'Nivel Autorizacao', 8, [ldGrid, ldLookup, ldCombobox], False)]
    property NivelAutorizacao: String  read FNIVEL_AUTORIZACAO write FNIVEL_AUTORIZACAO;

  end;

implementation


initialization
  Classes.RegisterClass(TNfceOperadorVO);

finalization
  Classes.UnRegisterClass(TNfceOperadorVO);

end.
