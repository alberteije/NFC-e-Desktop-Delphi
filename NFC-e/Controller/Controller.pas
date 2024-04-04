{ *******************************************************************************
Title: T2Ti ERP
Description: Unit de controle Base - Cliente.

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
@version 1.0
******************************************************************************* }
unit Controller;

interface

uses
  Classes, DBXJson, SessaoUsuario, SysUtils, Forms, Windows, DB, DBClient, dialogs,
  JsonVO, VO, Rtti, Atributos, StrUtils, TypInfo, Generics.Collections, Biblioteca, T2TiORM;

type
  TController = class(TPersistent)
  private
    class var ObjetoColumnDisplayVO: TVO;
    class var NomeClasseController: String;

    class function MontarParametros(pParametros: array of TValue): String;
    class procedure BuscarObjetoColumnDisplay(pObjeto: TVO; pNomeClasse: String);
  public
    class var FDataSet: TClientDataSet;
    class var ObjetoConsultado: TVO;
    class var ListaObjetoConsultado: TObjectList<TVO>;
    class var RetornoBoolean: Boolean;

    class function GetDataSet: TClientDataSet; virtual;
    class procedure SetDataSet(pDataSet: TClientDataSet); virtual;

    class function ServidorAtivo: Boolean;

    class procedure ExecutarMetodo(pNomeClasseController: String; pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String = ''; pTipoRetorno: String = '');
    class function BuscarLista(pNomeClasseController: String; pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String = ''): TObjectList<TVO>;
    class function BuscarObjeto(pNomeClasseController: String; pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String = ''): TVO;
    class function BuscarArquivo(pNomeClasseController: String; pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String = ''): String;

    class procedure PreencherObjectListFromCDS<O: class>(pListaObjetos: TObjectList<O>; pDataSet: TClientDataSet);

    class procedure TratarRetorno<O: class>(pListaObjetos: TObjectList<O>); overload;
    class procedure TratarRetorno<O: class>(pListaObjetos: TObjectList<O>; pLimparDataSet: Boolean; pPreencherGridInterna: Boolean = False; pDataSet: TClientDataset = Nil); overload;
    class procedure TratarRetorno<O: class>(pObjeto: O); overload;
    class procedure TratarRetorno(pRetornoBoolean: Boolean); overload;

  protected
    class function Sessao: TSessaoUsuario;
  end;

  TClassController = class of TController;

implementation

uses Conversor;
{ TController }

class function TController.GetDataSet: TClientDataSet;
begin
  Result := nil;
  // Implementar nas classes filhas
end;

class function TController.Sessao: TSessaoUsuario;
begin
  Result := TSessaoUsuario.Instance;
end;

class procedure TController.SetDataSet(pDataSet: TClientDataSet);
begin
  //
end;

class procedure TController.BuscarObjetoColumnDisplay(pObjeto: TVO; pNomeClasse: String);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ObjetoPai: TVO;
begin
  try
    if Assigned(ObjetoColumnDisplayVO) then
      Exit;

    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    for Propriedade in Tipo.GetProperties do
    begin
      // Percorre atributos
      for Atributo in Propriedade.GetAttributes do
      begin
        // Verifica se o atributo � um atributo de associa��o para muitos - passa direto, n�o vamos pegar um campo dentro de uma lista
        if Atributo is TManyValuedAssociation then
        begin
          Continue;
        end;
        // Verifica se o atributo � um atributo de associa��o para uma classe
        if Atributo is TAssociation then
        begin
          if Propriedade.PropertyType.TypeKind = tkClass then
          begin
            if Propriedade.PropertyType.QualifiedName = pNomeClasse then
            begin
              ObjetoColumnDisplayVO := Propriedade.GetValue(TObject(pObjeto)).AsObject as TVO;
              Exit;
            end
            else
            begin
              ObjetoPai := Propriedade.GetValue(TObject(pObjeto)).AsObject as TVO;
              if Assigned(ObjetoPai) then
                BuscarObjetoColumnDisplay(ObjetoPai, pNomeClasse);
            end;
          end;
        end;
      end;
    end;

  finally
  end;
end;

class procedure TController.TratarRetorno<O>(pListaObjetos: TObjectList<O>; pLimparDataSet: Boolean; pPreencherGridInterna: Boolean; pDataSet: TClientDataset);
var
  I: Integer;
  ObjetoVO: O;
  Contexto: TRttiContext;
  Tipo, TipoInterno: TRttiType;
  Propriedade, PropriedadeInterna: TRttiProperty;
  Atributo, AtributoInterno: TCustomAttribute;
  DataSetField: TField;
  DataSet: TClientDataSet;
  ObjetoAssociado: TVO;
  NomeCampoObjetoAssociado: String;
  NomeClasseObjetoColumnDisplay, NomeCampoObjetoColumnDisplay: String;

  RttiInstanceType: TRttiInstanceType;
begin
  if not pPreencherGridInterna then
  begin
    if Sessao.Camadas = 2 then
    begin
      ListaObjetoConsultado := TObjectList<TVO>(pListaObjetos);
    end;

    RttiInstanceType := Contexto.FindType(NomeClasseController) as TRttiInstanceType;
    DataSet := TClientDataSet(RttiInstanceType.GetMethod('GetDataSet').Invoke(RttiInstanceType.MetaclassType, []).AsObject);

    if not Assigned(DataSet) then
      Exit;
  end
  else
  begin
    if not Assigned(pDataSet) then
      Exit
    else
      DataSet := pDataSet;
  end;

  try
    DataSet.DisableControls;
    if pLimparDataset then
      DataSet.EmptyDataSet;

    try
      Contexto := TRttiContext.Create;
      Tipo := Contexto.GetType(TClass(O));

      for I := 0 to pListaObjetos.Count - 1 do
      begin

        ObjetoVO := O(pListaObjetos[i]);
        try
          DataSet.Append;

          for Propriedade in Tipo.GetProperties do
          begin

            for Atributo in Propriedade.GetAttributes do
            begin

              // Preenche o valor do campo ID
              if Atributo is TId then
              begin
                DataSetField := DataSet.FindField((Atributo as TId).NameField);
                if Assigned(DataSetField) then
                begin
                  DataSetField.Value := Propriedade.GetValue(TObject(ObjetoVO)).AsVariant;
                end;
              end

              // Preenche o valor dos campos que sejam TColumnDisplay
              else if Atributo is TColumnDisplay then
              begin
                ObjetoColumnDisplayVO := Nil;

                // Atribui o valor encontrado ao campo que ser� exibido na grid
                DataSetField := DataSet.FindField((Atributo as TColumnDisplay).Name);
                if Assigned(DataSetField) then
                begin
                  // Nome da classe do objeto que ser� procurado no objeto principal
                  NomeClasseObjetoColumnDisplay := (Atributo as TColumnDisplay).QualifiedName;
                  // Se o nome for "UNIDADE_PRODUTO.SIGLA" vai pegar o "SIGLA" para procurar pelo valor desse campo no VO
                  NomeCampoObjetoColumnDisplay := Copy((Atributo as TColumnDisplay).Name, Pos('.', (Atributo as TColumnDisplay).Name) + 1, Length((Atributo as TColumnDisplay).Name));
                  // Chama o procedimento para encontrar o objeto vinculado
                  BuscarObjetoColumnDisplay(TVO(ObjetoVO), NomeClasseObjetoColumnDisplay);

                  if Assigned(ObjetoColumnDisplayVO) then
                  begin
                    TipoInterno := Contexto.GetType(ObjetoColumnDisplayVO.ClassType);

                    for PropriedadeInterna in TipoInterno.GetProperties do
                    begin
                      for AtributoInterno in PropriedadeInterna.GetAttributes do
                      begin
                        if AtributoInterno is TColumn then
                        begin
                          if (AtributoInterno as TColumn).Name = NomeCampoObjetoColumnDisplay then
                          begin
                            DataSetField.Value := PropriedadeInterna.GetValue(TObject(ObjetoColumnDisplayVO)).AsVariant;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end

              // Preenche o valor dos campos que sejam TColumn
              else if Atributo is TColumn then
              begin
                DataSetField := DataSet.FindField((Atributo as TColumn).Name);
                if Assigned(DataSetField) then
                begin
                  if Propriedade.PropertyType.TypeKind in [tkEnumeration] then
                    DataSetField.AsBoolean := Propriedade.GetValue(TObject(ObjetoVO)).AsBoolean
                  else
                    DataSetField.Value := Propriedade.GetValue(TObject(ObjetoVO)).AsVariant;

                  if DataSetField.DataType = ftDateTime then
                  begin
                    if DataSetField.AsDateTime = 0 then
                      DataSetField.Clear;
                  end;
                end;
              end

            end;
          end;
        finally
        end;

        DataSet.Post;
      end;
    finally
      Contexto.Free;
    end;

    DataSet.Open;
    DataSet.First;
  finally
    DataSet.EnableControls;
  end;
end;

class procedure TController.TratarRetorno<O>(pListaObjetos: TObjectList<O>);
begin
  TratarRetorno<O>(pListaObjetos, True);
end;

class procedure TController.TratarRetorno<O>(pObjeto: O);
begin
  ObjetoConsultado := TVO(pObjeto);
end;

class procedure TController.TratarRetorno(pRetornoBoolean: Boolean);
begin
  RetornoBoolean := pRetornoBoolean;
end;

class procedure TController.PreencherObjectListFromCDS<O>(pListaObjetos: TObjectList<O>; pDataSet: TClientDataSet);
var
  I: Integer;
  ObjetoVO: TVO;

  RttiInstanceType: TRttiInstanceType;
  ObjetoLocalRtti: TValue;

  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
  Value: TValue;
begin
  if pDataSet.IsEmpty then
    Exit;

  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(TClass(O));

    pDataSet.DisableControls;
    pDataSet.First;
    while not pDataSet.Eof do
    begin
      if (pDataSet.FieldByName('PERSISTE').AsString = 'S') or (pDataSet.FieldByName('ID').AsInteger = 0) then
      begin
        try
          // Cria objeto
          RttiInstanceType := (Contexto.FindType(TClass(O).QualifiedClassName) as TRttiInstanceType);
          ObjetoLocalRtti := RttiInstanceType.GetMethod('Create').Invoke(RttiInstanceType.MetaclassType,[]);
          ObjetoVO := TVO(ObjetoLocalRtti.AsObject);
        finally
        end;

        for I := 0 to pDataSet.Fields.Count - 1 do
        begin
          Value := TValue.FromVariant(pDataSet.Fields[I].Value);
          Tipo.GetField('F'+pDataSet.Fields[I].FieldName).SetValue(ObjetoVO, Value);
        end;
        pListaObjetos.Add(ObjetoVO);
      end;
      pDataSet.Next;
    end;
    pDataSet.First;
    pDataSet.EnableControls;
  finally
    Contexto.Free;
  end;
end;

class function TController.ServidorAtivo: Boolean;
var
  Url: String;
begin
  Result := False;
  try
    Sessao.HTTP.Get(Sessao.Url);
    Result := True;
  except
    Result := False;
  end;
end;

class procedure TController.ExecutarMetodo(pNomeClasseController, pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String; pTipoRetorno: String);
var
  Contexto: TRttiContext;
  RttiInstanceType: TRttiInstanceType;
  Url, StringJson: String;

  StreamResposta: TStringStream;
  StreamEnviado: TStringStream;
  ObjetoResposta, ObjetoRespostaPrincipal: TJSONObject;
  ParResposta: TJSONPair;
  ArrayResposta: TJSONArray;

  ObjetoLocal: TVO;
  i: Integer;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    try

      NomeClasseController := pNomeClasseController;

      if Sessao.Camadas = 2 then
      begin
        RttiInstanceType := Contexto.FindType(pNomeClasseController) as TRttiInstanceType;
        RttiInstanceType.GetMethod(pNomeMetodo).Invoke(RttiInstanceType.MetaclassType, pParametros);
        FreeAndNil(ListaObjetoConsultado);
      end
      else if Sessao.Camadas = 3 then
      begin
        try
          StreamResposta := TStringStream.Create;

          if pMetodoRest = 'GET' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/' + pTipoRetorno + '/' + MontarParametros(pParametros);
            Sessao.HTTP.Get(Url, StreamResposta);
          end
          else if pMetodoRest = 'DELETE' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/' + pTipoRetorno + '/' + MontarParametros(pParametros);
            Sessao.HTTP.Delete(Url, StreamResposta);
          end
          else if pMetodoRest = 'POST' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/' + pTipoRetorno + '/';
            StringJson := TVO(pParametros[0].AsObject).ToJsonString;
            StreamEnviado := TStringStream.Create(TEncoding.UTF8.GetBytes(StringJson));
            Sessao.HTTP.Post(Url, StreamEnviado, StreamResposta);
          end
          else if pMetodoRest = 'PUT' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/' + pTipoRetorno + '/';
            StringJson := TVO(pParametros[0].AsObject).ToJsonString;
            StreamEnviado := TStringStream.Create(TEncoding.UTF8.GetBytes(StringJson));
            Sessao.HTTP.Put(Url, StreamEnviado, StreamResposta);
          end;

          ObjetoRespostaPrincipal := TJSONObject.Create;
          ObjetoRespostaPrincipal.Parse(StreamResposta.Bytes, 0);
          ParResposta := ObjetoRespostaPrincipal.Get(0);
          ArrayResposta := TJSONArray(TJSONArray(ParResposta.JsonValue).Get(0));

          // se o array que retornou cont�m um erro, gera uma exce��o
          if ArrayResposta.Size > 0 then
          begin
            if ArrayResposta.Get(0).ToString = '"ERRO"' then
            begin
              raise Exception.Create(ArrayResposta.Get(1).ToString);
            end;
          end;

          // Faz o tratamento de acordo com o tipo de retorno
          if pTipoRetorno = 'Objeto' then
          begin
            ObjetoResposta := TJSONObject.ParseJsonValue(TEncoding.UTF8.GetBytes(ArrayResposta.Get(0).ToString), 0) as TJSONObject;
            ObjetoConsultado := TJsonVO.JSONToObject<TVO>(ObjetoResposta);
            ObjetoResposta.Free;
          end
          else if pTipoRetorno = 'Lista' then
          begin
            ListaObjetoConsultado := TObjectList<TVO>.Create;
            for i := 0 to ArrayResposta.Size - 1 do
            begin
              ObjetoResposta := TJSONObject.ParseJsonValue(TEncoding.UTF8.GetBytes(ArrayResposta.Get(i).ToString), 0) as TJSONObject;
              ObjetoLocal := TJsonVO.JSONToObject<TVO>(ObjetoResposta);
              ListaObjetoConsultado.Add(ObjetoLocal);
              ObjetoResposta.Free;
            end;
            RttiInstanceType := Contexto.FindType(pNomeClasseController) as TRttiInstanceType;
            RttiInstanceType.GetMethod('TratarListaRetorno').Invoke(RttiInstanceType.MetaclassType, [ListaObjetoConsultado]);
          end
          else if pTipoRetorno = 'Boolean' then
          begin
            if ArrayResposta.ToString = '[true]' then
              RetornoBoolean := True
            else
              RetornoBoolean := False;
          end;

        finally
          StreamResposta.Free;
          StreamEnviado.Free;
          ObjetoRespostaPrincipal.Free;
        end;
      end;
    except
      on E: Exception do
        Application.MessageBox(PChar('Ocorreu um erro durante a execu��o do m�todo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    Contexto.Free;
  end;
end;

class function TController.BuscarLista(pNomeClasseController, pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String): TObjectList<TVO>;
var
  Contexto: TRttiContext;
  RttiInstanceType: TRttiInstanceType;
  Url, StringJson: String;

  StreamResposta: TStringStream;
  ObjetoResposta, ObjetoRespostaPrincipal: TJSONObject;
  ParResposta: TJSONPair;
  ArrayResposta: TJSONArray;

  ObjetoLocal: TVO;
  i: Integer;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    try

      NomeClasseController := pNomeClasseController;

      if Sessao.Camadas = 2 then
      begin
        RttiInstanceType := Contexto.FindType(pNomeClasseController) as TRttiInstanceType;
        Result := TObjectList<TVO>(RttiInstanceType.GetMethod(pNomeMetodo).Invoke(RttiInstanceType.MetaclassType, pParametros).AsObject);
      end
      else if Sessao.Camadas = 3 then
      begin
        try
          StreamResposta := TStringStream.Create;

          if pMetodoRest = 'GET' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/Lista/' + MontarParametros(pParametros);
            Sessao.HTTP.Get(Url, StreamResposta);
          end;

          ObjetoRespostaPrincipal := TJSONObject.Create;
          ObjetoRespostaPrincipal.Parse(StreamResposta.Bytes, 0);
          ParResposta := ObjetoRespostaPrincipal.Get(0);
          ArrayResposta := TJSONArray(TJSONArray(ParResposta.JsonValue).Get(0));

          // se o array que retornou cont�m um erro, gera uma exce��o
          if ArrayResposta.Size > 0 then
          begin
            if ArrayResposta.Get(0).ToString = '"ERRO"' then
            begin
              raise Exception.Create(ArrayResposta.Get(1).ToString);
            end;
          end;

          Result := TObjectList<TVO>.Create;
          for i := 0 to ArrayResposta.Size - 1 do
          begin
            ObjetoResposta := TJSONObject.ParseJsonValue(TEncoding.UTF8.GetBytes(ArrayResposta.Get(i).ToString), 0) as TJSONObject;
            ObjetoLocal := TJsonVO.JSONToObject<TVO>(ObjetoResposta);
            Result.Add(ObjetoLocal);
            ObjetoResposta.Free;
          end;

        finally
          StreamResposta.Free;
          ObjetoRespostaPrincipal.Free;
        end;
      end;
    except
      on E: Exception do
        Application.MessageBox(PChar('Ocorreu um erro durante a execu��o do m�todo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    Contexto.Free;
  end;
end;

class function TController.BuscarObjeto(pNomeClasseController, pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String): TVO;
var
  Contexto: TRttiContext;
  RttiInstanceType: TRttiInstanceType;
  Url, StringJson: String;

  StreamResposta: TStringStream;
  ObjetoResposta, ObjetoRespostaPrincipal: TJSONObject;
  ParResposta: TJSONPair;
  ArrayResposta: TJSONArray;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    try

      NomeClasseController := pNomeClasseController;

      if Sessao.Camadas = 2 then
      begin
        RttiInstanceType := Contexto.FindType(pNomeClasseController) as TRttiInstanceType;
        Result := TVO(RttiInstanceType.GetMethod(pNomeMetodo).Invoke(RttiInstanceType.MetaclassType, pParametros).AsObject);
      end
      else if Sessao.Camadas = 3 then
      begin
        try
          StreamResposta := TStringStream.Create;

          if pMetodoRest = 'GET' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/Objeto/' + MontarParametros(pParametros);
            Sessao.HTTP.Get(Url, StreamResposta);
          end;

          ObjetoRespostaPrincipal := TJSONObject.Create;
          ObjetoRespostaPrincipal.Parse(StreamResposta.Bytes, 0);
          ParResposta := ObjetoRespostaPrincipal.Get(0);
          ArrayResposta := TJSONArray(TJSONArray(ParResposta.JsonValue).Get(0));

          if ArrayResposta.Size > 0 then
          begin
            // se o array que retornou cont�m um erro, gera uma exce��o
            if ArrayResposta.Get(0).ToString = '"ERRO"' then
            begin
              raise Exception.Create(ArrayResposta.Get(1).ToString);
            end;
            // se o array que retornou cont�m um null, retorna nil
            if ArrayResposta.Get(0).ToString = 'null' then
            begin
              Result := Nil;
            end
            else
            begin
              try
                // Faz o tratamento de acordo com o tipo de retorno
                ObjetoResposta := TJSONObject.ParseJsonValue(TEncoding.UTF8.GetBytes(ArrayResposta.Get(0).ToString), 0) as TJSONObject;
                Result := TJsonVO.JSONToObject<TVO>(ObjetoResposta);
              finally
                ObjetoResposta.Free;
              end;
            end;
          end;
        finally
          StreamResposta.Free;
          ObjetoRespostaPrincipal.Free;
        end;
      end;
    except
      on E: Exception do
        Application.MessageBox(PChar('Ocorreu um erro durante a execu��o do m�todo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    Contexto.Free;
  end;
end;

class function TController.BuscarArquivo(pNomeClasseController, pNomeMetodo: String; pParametros: array of TValue; pMetodoRest: String): String;
var
  I: Integer;

  Contexto: TRttiContext;
  RttiInstanceType: TRttiInstanceType;
  Url, StringJson: String;

  ArquivoStream, StreamResposta: TStringStream;
  ObjetoResposta, ObjetoRespostaPrincipal: TJSONObject;
  ParResposta: TJSONPair;
  ArrayResposta: TJSONArray;

  ArquivoBytes: Tbytes;
  ArrayStringsArquivo: TStringList;
  ArquivoBytesString, TipoArquivo, CaminhoSalvarArquivo, NomeArquivo: String;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    try

      NomeClasseController := pNomeClasseController;

      if Sessao.Camadas = 2 then
      begin
        RttiInstanceType := Contexto.FindType(pNomeClasseController) as TRttiInstanceType;
        Result := RttiInstanceType.GetMethod(pNomeMetodo).Invoke(RttiInstanceType.MetaclassType, pParametros).AsString;
      end
      else if Sessao.Camadas = 3 then
      begin
        try
          StreamResposta := TStringStream.Create;
          ArquivoStream := TStringStream.Create;

          if pMetodoRest = 'GET' then
          begin
            Url := Sessao.Url + Sessao.IdSessao + '/' + pNomeClasseController + '/' + pNomeMetodo + '/Arquivo/' + MontarParametros(pParametros);
            Sessao.HTTP.Get(Url, StreamResposta);
          end;

          ObjetoRespostaPrincipal := TJSONObject.Create;
          ObjetoRespostaPrincipal.Parse(StreamResposta.Bytes, 0);
          ParResposta := ObjetoRespostaPrincipal.Get(0);
          ArrayResposta := TJSONArray(TJSONArray(ParResposta.JsonValue).Get(0));

          // se o array que retornou cont�m um erro, gera uma exce��o
          if ArrayResposta.Size > 0 then
          begin
            if ArrayResposta.Get(0).ToString = '"ERRO"' then
            begin
              raise Exception.Create(ArrayResposta.Get(1).ToString);
            end;
          end;

          // Faz o tratamento do arquivo
          if ArrayResposta.Get(0).ToString <> '"RESPOSTA"' then
          begin
            // na posicao zero temos o arquivo enviado
            ArquivoBytesString := (ArrayResposta as TJSONArray).Get(0).ToString;
            // retira as aspas do JSON
            System.Delete(ArquivoBytesString, Length(ArquivoBytesString), 1);
            System.Delete(ArquivoBytesString, 1, 1);

            // Nome do arquivo
            NomeArquivo := (ArrayResposta as TJSONArray).Get(1).ToString;
            // retira as aspas do JSON
            System.Delete(NomeArquivo, Length(NomeArquivo), 1);
            System.Delete(NomeArquivo, 1, 1);

            CaminhoSalvarArquivo := ExtractFilePath(Application.ExeName) + 'Temp\';
            if not DirectoryExists(CaminhoSalvarArquivo) then
              ForceDirectories(CaminhoSalvarArquivo);
            CaminhoSalvarArquivo := CaminhoSalvarArquivo + NomeArquivo;

            // na posicao um temos o tipo de arquivo enviado
            TipoArquivo := (ArrayResposta as TJSONArray).Get(2).ToString;
            // retira as aspas do JSON
            System.Delete(TipoArquivo, Length(TipoArquivo), 1);
            System.Delete(TipoArquivo, 1, 1);

            // salva o arquivo enviado em disco de forma temporaria
            ArrayStringsArquivo := TStringList.Create;
            Split(',', ArquivoBytesString, ArrayStringsArquivo);

            SetLength(ArquivoBytes, ArrayStringsArquivo.Count);

            for I := 0 to ArrayStringsArquivo.Count - 1 do
            begin
              ArquivoBytes[I] := StrToInt(ArrayStringsArquivo[I]);
            end;
            ArquivoStream := TStringStream.Create(ArquivoBytes);
            ArquivoStream.SaveToFile(CaminhoSalvarArquivo);

            Result := CaminhoSalvarArquivo;
          end;

        finally
          StreamResposta.Free;
          ArquivoStream.Free;
          ObjetoResposta.Free;
          ObjetoRespostaPrincipal.Free;
          FreeAndNil(ArrayStringsArquivo);
        end;
      end;
    except
      on E: Exception do
        Application.MessageBox(PChar('Ocorreu um erro durante a execu��o do m�todo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    Contexto.Free;
  end;
end;

class function TController.MontarParametros(pParametros: array of TValue): String;
var
  Parametro: String;
  I: Integer;
begin
  Result := '';

  for I := 0 to Length(pParametros) - 1 do
  begin
    Parametro := pParametros[I].ToString;

    Parametro := StringReplace(Parametro, '%', '*', [rfReplaceAll]);
    Parametro := StringReplace(Parametro, '"', '\"', [rfReplaceAll]);

    if Parametro <> '' then
    begin
      Result := Result + Parametro + '|';
    end;
  end;

  if Result <> '' then
  begin
    // Remove a �ltima barra
    Result := Copy(Result, 1, Length(Result) - 1);
  end;
end;

end.

