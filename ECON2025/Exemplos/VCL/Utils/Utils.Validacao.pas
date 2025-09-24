unit Utils.Validacao;

interface

uses
  System.SysUtils,
  System.Classes,
  System.RegularExpressions;

type
  /// <summary>
  /// Classe utilitária para validações
  /// Implementa validações comuns seguindo princípios KISS e Clean Code
  /// </summary>
  TValidacao = class
  public
    // Validações de CPF
    class function ValidarCPF(const CPF: string): Boolean;
    class function LimparCPF(const CPF: string): string;

    // Validações de email
    class function ValidarEmail(const Email: string): Boolean;

    // Validações de telefone
    class function ValidarTelefone(const Telefone: string): Boolean;
    class function LimparTelefone(const Telefone: string): string;

    // Validações de CEP
    class function ValidarCEP(const CEP: string): Boolean;
    class function LimparCEP(const CEP: string): string;

    // Validações de data
    class function ValidarData(const Data: TDateTime; const PermitirFutura: Boolean = False): Boolean;
    class function ValidarIdade(const DataNascimento: TDateTime; const IdadeMinima: Integer = 0; const IdadeMaxima: Integer = 120): Boolean;

    // Validações numéricas
    class function ValidarPeso(const Peso: Double): Boolean;
    class function ValidarAltura(const Altura: Double): Boolean;
    class function ValidarPressaoArterial(const Pressao: string): Boolean;
    class function ValidarBatimentosFetais(const Batimentos: Integer): Boolean;

    // Validações de texto
    class function ValidarNome(const Nome: string): Boolean;
    class function ValidarTextoObrigatorio(const Texto: string; const TamanhoMinimo: Integer = 1): Boolean;

    // Validações específicas da maternidade
    class function ValidarTipoSanguineo(const Tipo: string): Boolean;
    class function ValidarIdadeGestacional(const DataUltimaMenstruacao: TDateTime): Boolean;

    // Utilitários
    class function RemoverCaracteresEspeciais(const Texto: string): string;
    class function ApenasNumeros(const Texto: string): string;
    class function CapitalizarNome(const Nome: string): string;
  end;

implementation

uses
  System.DateUtils,
  System.StrUtils;

{ TValidacao }

class function TValidacao.ValidarCPF(const CPF: string): Boolean;
var
  CPFLimpo: string;
  I, Soma, Resto: Integer;
  Digito1, Digito2: Integer;
begin
  Result := False;

  CPFLimpo := LimparCPF(CPF);

  // Verifica se tem 11 dígitos
  if Length(CPFLimpo) <> 11 then
    Exit;

  // Verifica se todos os dígitos são iguais
  if CPFLimpo = StringOfChar(CPFLimpo[1], 11) then
    Exit;

  try
    // Calcula o primeiro dígito verificador
    Soma := 0;
    for I := 1 to 9 do
      Soma := Soma + StrToInt(CPFLimpo[I]) * (11 - I);

    Resto := Soma mod 11;
    if Resto < 2 then
      Digito1 := 0
    else
      Digito1 := 11 - Resto;

    // Calcula o segundo dígito verificador
    Soma := 0;
    for I := 1 to 10 do
      Soma := Soma + StrToInt(CPFLimpo[I]) * (12 - I);

    Resto := Soma mod 11;
    if Resto < 2 then
      Digito2 := 0
    else
      Digito2 := 11 - Resto;

    // Verifica se os dígitos calculados conferem
    Result := (Digito1 = StrToInt(CPFLimpo[10])) and (Digito2 = StrToInt(CPFLimpo[11]));
  except
    Result := False;
  end;
end;

class function TValidacao.LimparCPF(const CPF: string): string;
begin
  Result := ApenasNumeros(CPF);
end;

class function TValidacao.ValidarEmail(const Email: string): Boolean;
const
  EMAIL_PATTERN = '^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$';
begin
  Result := (Trim(Email) <> '') and TRegEx.IsMatch(Trim(Email), EMAIL_PATTERN);
end;

class function TValidacao.ValidarTelefone(const Telefone: string): Boolean;
var
  TelefoneLimpo: string;
begin
  TelefoneLimpo := LimparTelefone(Telefone);
  // Aceita telefones com 10 ou 11 dígitos (com ou sem celular)
  Result := (Length(TelefoneLimpo) >= 10) and (Length(TelefoneLimpo) <= 11);
end;

class function TValidacao.LimparTelefone(const Telefone: string): string;
begin
  Result := ApenasNumeros(Telefone);
end;

class function TValidacao.ValidarCEP(const CEP: string): Boolean;
var
  CEPLimpo: string;
begin
  CEPLimpo := LimparCEP(CEP);
  Result := Length(CEPLimpo) = 8;
end;

class function TValidacao.LimparCEP(const CEP: string): string;
begin
  Result := ApenasNumeros(CEP);
end;

class function TValidacao.ValidarData(const Data: TDateTime; const PermitirFutura: Boolean): Boolean;
begin
  Result := Data > 0;

  if Result and not PermitirFutura then
    Result := Data <= Now;
end;

class function TValidacao.ValidarIdade(const DataNascimento: TDateTime; const IdadeMinima, IdadeMaxima: Integer): Boolean;
var
  Idade: Integer;
begin
  Result := False;

  if not ValidarData(DataNascimento, False) then
    Exit;

  Idade := YearsBetween(Now, DataNascimento);
  Result := (Idade >= IdadeMinima) and (Idade <= IdadeMaxima);
end;

class function TValidacao.ValidarPeso(const Peso: Double): Boolean;
begin
  Result := (Peso >= 30) and (Peso <= 200);
end;

class function TValidacao.ValidarAltura(const Altura: Double): Boolean;
begin
  Result := (Altura >= 1.0) and (Altura <= 2.5);
end;

class function TValidacao.ValidarPressaoArterial(const Pressao: string): Boolean;
const
  PRESSAO_PATTERN = '^\d{2,3}x\d{2,3}$';
begin
  Result := TRegEx.IsMatch(Trim(Pressao), PRESSAO_PATTERN);
end;

class function TValidacao.ValidarBatimentosFetais(const Batimentos: Integer): Boolean;
begin
  Result := (Batimentos >= 110) and (Batimentos <= 180);
end;

class function TValidacao.ValidarNome(const Nome: string): Boolean;
var
  NomeLimpo: string;
begin
  NomeLimpo := Trim(Nome);
  Result := (Length(NomeLimpo) >= 3) and (Length(NomeLimpo) <= 100);

  if Result then
  begin
    // Verifica se contém apenas letras, espaços e alguns caracteres especiais
//    Result := TRegEx.IsMatch(NomeLimpo, '^[a-zA-ZÀ-ÿ\s''\-\.]+$');
  end;
end;

class function TValidacao.ValidarTextoObrigatorio(const Texto: string; const TamanhoMinimo: Integer): Boolean;
begin
  Result := Length(Trim(Texto)) >= TamanhoMinimo;
end;

class function TValidacao.ValidarTipoSanguineo(const Tipo: string): Boolean;
var
  TiposValidos: TArray<string>;
  TipoLimpo: string;
begin
  TipoLimpo := UpperCase(Trim(Tipo));
  TiposValidos := ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Result := False;
  for var TipoValido in TiposValidos do
  begin
    if TipoLimpo = TipoValido then
    begin
      Result := True;
      Break;
    end;
  end;
end;

class function TValidacao.ValidarIdadeGestacional(const DataUltimaMenstruacao: TDateTime): Boolean;
var
  DiasGestacao: Integer;
begin
  Result := False;

  if DataUltimaMenstruacao <= 0 then
    Exit;

  DiasGestacao := DaysBetween(Now, DataUltimaMenstruacao);

  // Gestação normal: até 42 semanas (294 dias)
  Result := DiasGestacao <= 294;
end;

class function TValidacao.RemoverCaracteresEspeciais(const Texto: string): string;
begin
  Result := TRegEx.Replace(Texto, '[^a-zA-Z0-9\s]', '');
end;

class function TValidacao.ApenasNumeros(const Texto: string): string;
begin
  Result := TRegEx.Replace(Texto, '[^0-9]', '');
end;

class function TValidacao.CapitalizarNome(const Nome: string): string;
var
  Palavras: TArray<string>;
  I: Integer;
begin
  Result := Trim(LowerCase(Nome));

  if Result = '' then
    Exit;

  Palavras := Result.Split([' ']);
  Result := '';

  for I := 0 to High(Palavras) do
  begin
    if Palavras[I] <> '' then
    begin
      // Não capitaliza preposições pequenas (exceto se for a primeira palavra)
      if (I > 0) and (Length(Palavras[I]) <= 3) and
        ((Palavras[I] = 'de') or (Palavras[I] = 'da') or (Palavras[I] = 'do') or
        (Palavras[I] = 'das') or (Palavras[I] = 'dos') or (Palavras[I] = 'e')) then
        Result := Result + Palavras[I]
      else
        Result := Result + UpperCase(Palavras[I][1]) + Copy(Palavras[I], 2, Length(Palavras[I]));

      if I < High(Palavras) then
        Result := Result + ' ';
    end;
  end;
end;

end.

