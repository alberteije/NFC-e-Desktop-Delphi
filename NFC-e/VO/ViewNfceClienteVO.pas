{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado � tabela [VIEW_NFCE_CLIENTE] 
                                                                                
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
unit ViewNfceClienteVO;

interface

uses
  VO, Atributos, Classes, Constantes, Generics.Collections, SysUtils;

type
  [TEntity]
  [TTable('VIEW_NFCE_CLIENTE')]
  TViewNfceClienteVO = class(TVO)
  private
    FID: Integer;
    FID_OPERACAO_FISCAL: Integer;
    FNOME: String;
    FEMAIL: String;
    FCPF: String;
    FRG: String;
    FORGAO_RG: String;
    FDATA_EMISSAO_RG: TDateTime;
    FSEXO: String;
    FDATA_CADASTRO: TDateTime;
    FID_PESSOA: Integer;
    FID_ATIVIDADE_FOR_CLI: Integer;
    FID_SITUACAO_FOR_CLI: Integer;
    FDESDE: TDateTime;
    FLOGRADOURO: String;
    FNUMERO: String;
    FCOMPLEMENTO: String;
    FBAIRRO: String;
    FCIDADE: String;
    FCEP: String;
    FMUNICIPIO_IBGE: Integer;
    FUF: String;
    FFONE: String;

  public 
    [TId('ID')]
    [TGeneratedValue(sAuto)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property Id: Integer  read FID write FID;
    [TColumn('NOME', 'Nome', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Nome: String  read FNOME write FNOME;
    [TColumn('CPF', 'Cpf', 88, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftCpf, taLeftJustify)]
    property Cpf: String  read FCPF write FCPF;
    [TColumn('EMAIL', 'Email', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Email: String  read FEMAIL write FEMAIL;
    [TColumn('RG', 'Rg', 160, [ldGrid, ldLookup, ldCombobox], False)]
    property Rg: String  read FRG write FRG;
    [TColumn('ORGAO_RG', 'Orgao Rg', 160, [ldGrid, ldLookup, ldCombobox], False)]
    property OrgaoRg: String  read FORGAO_RG write FORGAO_RG;
    [TColumn('DATA_EMISSAO_RG', 'Data Emissao Rg', 80, [ldGrid, ldLookup, ldCombobox], False)]
    property DataEmissaoRg: TDateTime  read FDATA_EMISSAO_RG write FDATA_EMISSAO_RG;
    [TColumn('SEXO', 'Sexo', 8, [ldGrid, ldLookup, ldCombobox], False)]
    property Sexo: String  read FSEXO write FSEXO;
    [TColumn('DATA_CADASTRO', 'Data Cadastro', 80, [ldGrid, ldLookup, ldCombobox], False)]
    property DataCadastro: TDateTime  read FDATA_CADASTRO write FDATA_CADASTRO;
    [TColumn('ID_PESSOA', 'Id Pessoa', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property IdPessoa: Integer  read FID_PESSOA write FID_PESSOA;
    [TColumn('ID_ATIVIDADE_FOR_CLI', 'Id Atividade For Cli', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property IdAtividadeForCli: Integer  read FID_ATIVIDADE_FOR_CLI write FID_ATIVIDADE_FOR_CLI;
    [TColumn('ID_SITUACAO_FOR_CLI', 'Id Situacao For Cli', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property IdSituacaoForCli: Integer  read FID_SITUACAO_FOR_CLI write FID_SITUACAO_FOR_CLI;
    [TColumn('DESDE', 'Desde', 80, [ldGrid, ldLookup, ldCombobox], False)]
    property Desde: TDateTime  read FDESDE write FDESDE;
    [TColumn('LOGRADOURO', 'Logradouro', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Logradouro: String  read FLOGRADOURO write FLOGRADOURO;
    [TColumn('NUMERO', 'Numero', 80, [ldGrid, ldLookup, ldCombobox], False)]
    property Numero: String  read FNUMERO write FNUMERO;
    [TColumn('COMPLEMENTO', 'Complemento', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Complemento: String  read FCOMPLEMENTO write FCOMPLEMENTO;
    [TColumn('BAIRRO', 'Bairro', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Bairro: String  read FBAIRRO write FBAIRRO;
    [TColumn('CIDADE', 'Cidade', 450, [ldGrid, ldLookup, ldCombobox], False)]
    property Cidade: String  read FCIDADE write FCIDADE;
    [TColumn('CEP', 'Cep', 64, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftCep, taLeftJustify)]
    property Cep: String  read FCEP write FCEP;
    [TColumn('MUNICIPIO_IBGE', 'Municipio Ibge', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property MunicipioIbge: Integer  read FMUNICIPIO_IBGE write FMUNICIPIO_IBGE;
    [TColumn('UF', 'Uf', 16, [ldGrid, ldLookup, ldCombobox], False)]
    property Uf: String  read FUF write FUF;
    [TColumn('FONE', 'Fone', 112, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftTelefone, taLeftJustify)]
    property Fone: String  read FFONE write FFONE;
    [TColumn('ID_OPERACAO_FISCAL', 'Id Operacao Fiscal', 80, [ldGrid, ldLookup, ldCombobox], False)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property IdOperacaoFiscal: Integer  read FID_OPERACAO_FISCAL write FID_OPERACAO_FISCAL;


  end;

implementation


initialization
  Classes.RegisterClass(TViewNfceClienteVO);

finalization
  Classes.UnRegisterClass(TViewNfceClienteVO);

end.
