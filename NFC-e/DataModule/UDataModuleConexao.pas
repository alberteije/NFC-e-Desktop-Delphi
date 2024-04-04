{ *******************************************************************************
Title: T2TiPDV
Description: DataModule

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
unit UDataModuleConexao;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr, Forms,
  Data.DBXMySQL;

type
  TFDataModuleConexao = class(TDataModule)
    Conexao: TSQLConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    var Banco: String;
    procedure ConfigurarConexao(var pConexao: TSQLConnection; pBD: String);
  public
    { Public declarations }
    procedure Conectar(BD: String);
    procedure Desconectar;
    function getConexao: TSQLConnection;
    function getBanco: String;
  end;

var
  FDataModuleConexao: TFDataModuleConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TFDataModuleConexao.DataModuleCreate(Sender: TObject);
begin
  Conectar('MySQL');
end;

procedure TFDataModuleConexao.Conectar(BD: String);
begin
  Desconectar;
  ConfigurarConexao(Conexao, BD);
  Conexao.KeepConnection := True;
  Conexao.AutoClone := False;
  Conexao.Connected := True;
  Banco := BD;
end;

procedure TFDataModuleConexao.Desconectar;
begin
  Conexao.Connected := False;
end;

function TFDataModuleConexao.getBanco: String;
begin
  Result := Banco;
end;

function TFDataModuleConexao.getConexao: TSQLConnection;
begin
  Result := Conexao;
end;

procedure TFDataModuleConexao.ConfigurarConexao(var pConexao: TSQLConnection; pBD: String);
var
  Arquivo: String;
  Parametros: TStrings;
begin
  if pBD = 'Oracle' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'Oracle_DBExpress_conn.txt';

    Conexao.DriverName     := 'Oracle';
    Conexao.ConnectionName := 'OracleConnection';
    Conexao.GetDriverFunc  := 'getSQLDriverORACLE';
    Conexao.LibraryName    := 'dbxora.dll';
    Conexao.VendorLib      := 'oci.dll';
  end
  else
  if pBD = 'MSSQL' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'MSSQL_DBExpress_conn.txt';

    Conexao.DriverName     := 'MSSQL';
    Conexao.ConnectionName := 'MSSQLCONNECTION';
    Conexao.GetDriverFunc  := 'getSQLDriverMSSQL';
    Conexao.LibraryName    := 'dbxmss.dll';
    Conexao.VendorLib      := 'oledb';
  end
  else
  if pBD = 'Firebird' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'Firebird_DBExpress_conn.txt';

    Conexao.DriverName     := 'Firebird';
    Conexao.ConnectionName := 'FBConnection';
    Conexao.GetDriverFunc  := 'getSQLDriverINTERBASE';
    Conexao.LibraryName    := 'dbxfb.dll';
    Conexao.VendorLib      := 'fbclient.dll';
  end
  else
  if pBD = 'Interbase' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'Interbase_DBExpress_conn.txt';

    Conexao.DriverName     := 'Interbase';
    Conexao.ConnectionName := 'IBConnection';
    Conexao.GetDriverFunc  := 'getSQLDriverINTERBASE';
    Conexao.LibraryName    := 'dbxint.dll';
    Conexao.VendorLib      := 'gds32.dll';
  end
  else
  if pBD = 'MySQL' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'MySQL_DBExpress_conn.txt';

    Conexao.DriverName     := 'MySQL';
    Conexao.ConnectionName := 'MySQLConnection';
    Conexao.GetDriverFunc  := 'getSQLDriverMYSQL';
    Conexao.LibraryName    := 'dbxmys.dll';
    Conexao.VendorLib      := 'libmysql.dll';
  end
  else
  if pBD = 'DB2' then
  begin
    //carrega o arquivo de parametros (neste caso o do MySQL)
    Arquivo := ExtractFilePath(Application.ExeName) + 'DB2_DBExpress_conn.txt';

    Conexao.DriverName     := 'Db2';
    Conexao.ConnectionName := 'DB2Connection';
    Conexao.GetDriverFunc  := 'getSQLDriverDB2';
    Conexao.LibraryName    := 'dbxdb2.dll';
    Conexao.VendorLib      := 'db2cli.dll';
  end
  else
  if pBD = 'Postgres' then
  begin
    //carrega o arquivo de parametros (neste caso o do Postgres)
    Arquivo := ExtractFilePath(Application.ExeName) + 'Postgres_DBExpress_conn.txt';

    Conexao.DriverName     := 'DevartPostgreSQL';
    Conexao.ConnectionName := 'PostgreConnection';
    Conexao.GetDriverFunc  := 'getSQLDriverPostgreSQL';
    Conexao.LibraryName    := 'dbexppgsql40.dll';
    Conexao.VendorLib      := 'not used';
  end;
  //vari�vel para carregar os parametros do banco
  Parametros := TStringList.Create;
  try
    Parametros.LoadFromFile(Arquivo);
    Conexao.Params.Text := Parametros.Text;
  finally
    Parametros.Free;
  end;
  Conexao.LoginPrompt := False;
end;

end.
