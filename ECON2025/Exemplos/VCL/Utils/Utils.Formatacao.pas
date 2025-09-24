unit Utils.Formatacao;

interface

uses
  System.SysUtils,
  System.Classes;

type
  /// <summary>
  /// Classe utilitária para formatação de dados
  /// Implementa formatações comuns seguindo princípios KISS e Clean Code
  /// </summary>
  TFormatacao = class
  public
    // Formatação de CPF
    class function FormatarCPF(const CPF: string): string;

    // Formatação de telefone
    class function FormatarTelefone(const Telefone: string): string;
    class function FormatarCelular(const Celular: string): string;

    // Formatação de CEP
    class function FormatarCEP(const CEP: string): string;

    // Formatação de datas
    class function FormatarData(const Data: TDateTime): string;
    class function FormatarDataHora(const DataHora: TDateTime): string;
    class function FormatarIdadeGestacional(const DataUltimaMenstruacao: TDateTime): string;

    // Formatação de valores numéricos
    class function FormatarPeso(const Peso: Double): string;
    class function FormatarAltura(const Altura: Double): string;
    class function FormatarIMC(const IMC: Double): string;

    // Formatação de texto
    class function FormatarNome(const Nome: string): string;
    class function FormatarTextoLimitado(const Texto: string; const TamanhoMaximo: Integer): string;

    // Formatação específica da maternidade
    class function FormatarTipoSanguineo(const Tipo: string): string;
    class function FormatarPressaoArterial(const Pressao: string): string;
    class function FormatarBatimentosFetais(const Batimentos: Integer): string;

    // Formatação para relatórios
    class function FormatarRelatorioLinha(const Campo, Valor: string; const TamanhoTotal: Integer = 50): string;
    class function FormatarCabecalhoRelatorio(const Titulo: string; const TamanhoTotal: Integer = 80): string;

    // Utilitários de formatação
    class function PadLeft(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char = ' '): string;
    class function PadRight(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char = ' '): string;
    class function CentralizarTexto(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char = ' '): string;

    // Formatação de máscaras
    class function AplicarMascara(const Valor, Mascara: string): string;
    class function RemoverMascara(const ValorComMascara: string): string;
  end;

implementation

uses
  System.DateUtils,
  System.Math,
  Utils.Validacao;

{ TFormatacao }

class function TFormatacao.FormatarCPF(const CPF: string): string;
var
  CPFLimpo: string;
begin
  CPFLimpo := TValidacao.LimparCPF(CPF);

  if Length(CPFLimpo) = 11 then
    Result := Format('%s.%s.%s-%s', [
        Copy(CPFLimpo, 1, 3),
        Copy(CPFLimpo, 4, 3),
        Copy(CPFLimpo, 7, 3),
        Copy(CPFLimpo, 10, 2)
      ])
  else
    Result := CPF;
end;

class function TFormatacao.FormatarTelefone(const Telefone: string): string;
var
  TelefoneLimpo: string;
begin
  TelefoneLimpo := TValidacao.LimparTelefone(Telefone);

  case Length(TelefoneLimpo) of
    10:
      Result := Format('(%s) %s-%s', [
          Copy(TelefoneLimpo, 1, 2),
          Copy(TelefoneLimpo, 3, 4),
          Copy(TelefoneLimpo, 7, 4)
        ]);
    11:
      Result := Format('(%s) %s-%s', [
          Copy(TelefoneLimpo, 1, 2),
          Copy(TelefoneLimpo, 3, 5),
          Copy(TelefoneLimpo, 8, 4)
        ]);
  else
    Result := Telefone;
  end;
end;

class function TFormatacao.FormatarCelular(const Celular: string): string;
begin
  // Celular usa a mesma formatação que telefone
  Result := FormatarTelefone(Celular);
end;

class function TFormatacao.FormatarCEP(const CEP: string): string;
var
  CEPLimpo: string;
begin
  CEPLimpo := TValidacao.LimparCEP(CEP);

  if Length(CEPLimpo) = 8 then
    Result := Format('%s-%s', [
        Copy(CEPLimpo, 1, 5),
        Copy(CEPLimpo, 6, 3)
      ])
  else
    Result := CEP;
end;

class function TFormatacao.FormatarData(const Data: TDateTime): string;
begin
  if Data > 0 then
    Result := FormatDateTime('dd/mm/yyyy', Data)
  else
    Result := '';
end;

class function TFormatacao.FormatarDataHora(const DataHora: TDateTime): string;
begin
  if DataHora > 0 then
    Result := FormatDateTime('dd/mm/yyyy hh:nn', DataHora)
  else
    Result := '';
end;

class function TFormatacao.FormatarIdadeGestacional(const DataUltimaMenstruacao: TDateTime): string;
var
  Dias, Semanas: Integer;
begin
  Result := '';

  if DataUltimaMenstruacao > 0 then
  begin
    Dias := DaysBetween(Now, DataUltimaMenstruacao);
    Semanas := Dias div 7;
    Dias := Dias mod 7;

    if Semanas > 0 then
    begin
      if Dias > 0 then
        Result := Format('%d semanas e %d dias', [Semanas, Dias])
      else
        Result := Format('%d semanas', [Semanas]);
    end
    else
      Result := Format('%d dias', [Dias]);
  end;
end;

class function TFormatacao.FormatarPeso(const Peso: Double): string;
begin
  if Peso > 0 then
    Result := FormatFloat('0.0 "kg"', Peso)
  else
    Result := '';
end;

class function TFormatacao.FormatarAltura(const Altura: Double): string;
begin
  if Altura > 0 then
    Result := FormatFloat('0.00 "m"', Altura)
  else
    Result := '';
end;

class function TFormatacao.FormatarIMC(const IMC: Double): string;
var
  Classificacao: string;
begin
  if IMC > 0 then
  begin
    // Classifica o IMC
    if IMC < 18.5 then
      Classificacao := 'Baixo peso'
    else if IMC < 25 then
      Classificacao := 'Normal'
    else if IMC < 30 then
      Classificacao := 'Sobrepeso'
    else
      Classificacao := 'Obesidade';

    Result := Format('%.1f (%s)', [IMC, Classificacao]);
  end
  else
    Result := '';
end;

class function TFormatacao.FormatarNome(const Nome: string): string;
begin
  Result := TValidacao.CapitalizarNome(Nome);
end;

class function TFormatacao.FormatarTextoLimitado(const Texto: string; const TamanhoMaximo: Integer): string;
begin
  Result := Trim(Texto);

  if Length(Result) > TamanhoMaximo then
    Result := Copy(Result, 1, TamanhoMaximo - 3) + '...';
end;

class function TFormatacao.FormatarTipoSanguineo(const Tipo: string): string;
begin
  Result := UpperCase(Trim(Tipo));
end;

class function TFormatacao.FormatarPressaoArterial(const Pressao: string): string;
var
  Partes: TArray<string>;
  Sistolica, Diastolica: Integer;
begin
  Result := Trim(Pressao);

  if Result <> '' then
  begin
    Partes := Result.Split(['x', 'X', '/']);
    if Length(Partes) = 2 then
    begin
      if TryStrToInt(Trim(Partes[0]), Sistolica) and TryStrToInt(Trim(Partes[1]), Diastolica) then
        Result := Format('%d x %d mmHg', [Sistolica, Diastolica]);
    end;
  end;
end;

class function TFormatacao.FormatarBatimentosFetais(const Batimentos: Integer): string;
begin
  if Batimentos > 0 then
    Result := Format('%d bpm', [Batimentos])
  else
    Result := '';
end;

class function TFormatacao.FormatarRelatorioLinha(const Campo, Valor: string; const TamanhoTotal: Integer): string;
var
  TamanhoCampo, TamanhoValor, TamanhoPontos: Integer;
  Pontos: string;
begin
  TamanhoCampo := Length(Campo);
  TamanhoValor := Length(Valor);
  TamanhoPontos := TamanhoTotal - TamanhoCampo - TamanhoValor;

  if TamanhoPontos > 0 then
    Pontos := StringOfChar('.', TamanhoPontos)
  else
    Pontos := ' ';

  Result := Campo + Pontos + Valor;
end;

class function TFormatacao.FormatarCabecalhoRelatorio(const Titulo: string; const TamanhoTotal: Integer): string;
var
  Linha: string;
begin
  Linha := StringOfChar('=', TamanhoTotal);
  Result := Linha + sLineBreak +
    CentralizarTexto(Titulo, TamanhoTotal) + sLineBreak +
    Linha;
end;

class function TFormatacao.PadLeft(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char): string;
var
  TamanhoTexto: Integer;
begin
  TamanhoTexto := Length(Texto);

  if TamanhoTexto >= TamanhoTotal then
    Result := Texto
  else
    Result := StringOfChar(CaracterPreenchimento, TamanhoTotal - TamanhoTexto) + Texto;
end;

class function TFormatacao.PadRight(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char): string;
var
  TamanhoTexto: Integer;
begin
  TamanhoTexto := Length(Texto);

  if TamanhoTexto >= TamanhoTotal then
    Result := Texto
  else
    Result := Texto + StringOfChar(CaracterPreenchimento, TamanhoTotal - TamanhoTexto);
end;

class function TFormatacao.CentralizarTexto(const Texto: string; const TamanhoTotal: Integer; const CaracterPreenchimento: Char): string;
var
  TamanhoTexto, EspacosEsquerda, EspacosDireita: Integer;
begin
  TamanhoTexto := Length(Texto);

  if TamanhoTexto >= TamanhoTotal then
    Result := Texto
  else
  begin
    EspacosEsquerda := (TamanhoTotal - TamanhoTexto) div 2;
    EspacosDireita := TamanhoTotal - TamanhoTexto - EspacosEsquerda;

    Result := StringOfChar(CaracterPreenchimento, EspacosEsquerda) +
      Texto +
      StringOfChar(CaracterPreenchimento, EspacosDireita);
  end;
end;

class function TFormatacao.AplicarMascara(const Valor, Mascara: string): string;
var
  I, J: Integer;
  ValorLimpo: string;
begin
  ValorLimpo := RemoverMascara(Valor);
  Result := '';
  J := 1;

  for I := 1 to Length(Mascara) do
  begin
    if Mascara[I] = '#' then
    begin
      if J <= Length(ValorLimpo) then
      begin
        Result := Result + ValorLimpo[J];
        Inc(J);
      end;
    end
    else
      Result := Result + Mascara[I];
  end;
end;

class function TFormatacao.RemoverMascara(const ValorComMascara: string): string;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(ValorComMascara) do
  begin
    if CharInSet(ValorComMascara[I], ['0'..'9']) then
      Result := Result + ValorComMascara[I];
  end;
end;

end.

