unit Model.Gestante;

interface

uses
  System.SysUtils,
  System.Classes;

type
  /// <summary>
  /// Classe que representa uma Gestante no sistema
  /// Implementa o padrão de domínio rico com validações
  /// </summary>
  TGestante = class
  private
    FId: Integer;
    FNome: string;
    FCPF: string;
    FRG: string;
    FDataNascimento: TDateTime;
    FTelefone: string;
    FCelular: string;
    FEmail: string;
    FEndereco: string;
    FCEP: string;
    FCidade: string;
    FEstado: string;
    FDataUltimaMenstruacao: TDateTime;
    FDataProvavelParto: TDateTime;
    FTipoSanguineo: string;
    FPesoInicial: Double;
    FAltura: Double;
    FObservacoes: string;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;
    FDataAlteracao: TDateTime;

    procedure SetCPF(const Value: string);
    procedure SetEmail(const Value: string);
    procedure SetNome(const Value: string);
    procedure SetDataNascimento(const Value: TDateTime);
    procedure SetDataUltimaMenstruacao(const Value: TDateTime);
    procedure CalcularDataProvavelParto;

  public
    constructor Create;

    // Propriedades
    property Id: Integer read FId write FId;
    property Nome: string read FNome write SetNome;
    property CPF: string read FCPF write SetCPF;
    property RG: string read FRG write FRG;
    property DataNascimento: TDateTime read FDataNascimento write SetDataNascimento;
    property Telefone: string read FTelefone write FTelefone;
    property Celular: string read FCelular write FCelular;
    property Email: string read FEmail write SetEmail;
    property Endereco: string read FEndereco write FEndereco;
    property CEP: string read FCEP write FCEP;
    property Cidade: string read FCidade write FCidade;
    property Estado: string read FEstado write FEstado;
    property DataUltimaMenstruacao: TDateTime read FDataUltimaMenstruacao write SetDataUltimaMenstruacao;
    property DataProvavelParto: TDateTime read FDataProvavelParto write FDataProvavelParto;
    property TipoSanguineo: string read FTipoSanguineo write FTipoSanguineo;
    property PesoInicial: Double read FPesoInicial write FPesoInicial;
    property Altura: Double read FAltura write FAltura;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property DataAlteracao: TDateTime read FDataAlteracao write FDataAlteracao;

    // Métodos de negócio
    function GetIdade: Integer;
    function GetIdadeGestacional: string;
    function GetIMC: Double;
    function IsValid: Boolean;
    function GetValidationErrors: TStringList;

    // Métodos utilitários
    procedure Clear;
    function Clone: TGestante;
  end;

implementation

uses
  System.RegularExpressions,
  System.DateUtils;

{ TGestante }

constructor TGestante.Create;
begin
  inherited Create;
  Clear;
end;

procedure TGestante.Clear;
begin
  FId := 0;
  FNome := '';
  FCPF := '';
  FRG := '';
  FDataNascimento := 0;
  FTelefone := '';
  FCelular := '';
  FEmail := '';
  FEndereco := '';
  FCEP := '';
  FCidade := '';
  FEstado := '';
  FDataUltimaMenstruacao := 0;
  FDataProvavelParto := 0;
  FTipoSanguineo := '';
  FPesoInicial := 0;
  FAltura := 0;
  FObservacoes := '';
  FAtivo := True;
  FDataCadastro := Now;
  FDataAlteracao := Now;
end;

function TGestante.Clone: TGestante;
begin
  Result := TGestante.Create;
  Result.FId := Self.FId;
  Result.FNome := Self.FNome;
  Result.FCPF := Self.FCPF;
  Result.FRG := Self.FRG;
  Result.FDataNascimento := Self.FDataNascimento;
  Result.FTelefone := Self.FTelefone;
  Result.FCelular := Self.FCelular;
  Result.FEmail := Self.FEmail;
  Result.FEndereco := Self.FEndereco;
  Result.FCEP := Self.FCEP;
  Result.FCidade := Self.FCidade;
  Result.FEstado := Self.FEstado;
  Result.FDataUltimaMenstruacao := Self.FDataUltimaMenstruacao;
  Result.FDataProvavelParto := Self.FDataProvavelParto;
  Result.FTipoSanguineo := Self.FTipoSanguineo;
  Result.FPesoInicial := Self.FPesoInicial;
  Result.FAltura := Self.FAltura;
  Result.FObservacoes := Self.FObservacoes;
  Result.FAtivo := Self.FAtivo;
  Result.FDataCadastro := Self.FDataCadastro;
  Result.FDataAlteracao := Self.FDataAlteracao;
end;

procedure TGestante.SetCPF(const Value: string);
var
  CleanCPF: string;
begin
  // Remove caracteres não numéricos
  CleanCPF := TRegEx.Replace(Value, '[^0-9]', '');
  FCPF := CleanCPF;
end;

procedure TGestante.SetEmail(const Value: string);
begin
  FEmail := Trim(LowerCase(Value));
end;

procedure TGestante.SetNome(const Value: string);
begin
  FNome := Trim(Value);
end;

procedure TGestante.SetDataNascimento(const Value: TDateTime);
begin
  FDataNascimento := Value;
end;

procedure TGestante.SetDataUltimaMenstruacao(const Value: TDateTime);
begin
  FDataUltimaMenstruacao := Value;
  CalcularDataProvavelParto;
end;

procedure TGestante.CalcularDataProvavelParto;
begin
  if FDataUltimaMenstruacao > 0 then
    FDataProvavelParto := IncDay(FDataUltimaMenstruacao, 280); // 40 semanas
end;

function TGestante.GetIdade: Integer;
begin
  if FDataNascimento > 0 then
    Result := YearsBetween(Now, FDataNascimento)
  else
    Result := 0;
end;

function TGestante.GetIdadeGestacional: string;
var
  Dias, Semanas: Integer;
begin
  Result := '';
  if FDataUltimaMenstruacao > 0 then
  begin
    Dias := DaysBetween(Now, FDataUltimaMenstruacao);
    Semanas := Dias div 7;
    Dias := Dias mod 7;
    Result := Format('%d semanas e %d dias', [Semanas, Dias]);
  end;
end;

function TGestante.GetIMC: Double;
begin
  if (FAltura > 0) and (FPesoInicial > 0) then
    Result := FPesoInicial / (FAltura * FAltura)
  else
    Result := 0;
end;

function TGestante.IsValid: Boolean;
var
  Errors: TStringList;
begin
  Errors := GetValidationErrors;
  try
    Result := Errors.Count = 0;
  finally
    Errors.Free;
  end;
end;

function TGestante.GetValidationErrors: TStringList;
begin
  Result := TStringList.Create;

  // Validação do nome
  if Trim(FNome) = '' then
    Result.Add('Nome é obrigatório');

  if Length(Trim(FNome)) < 3 then
    Result.Add('Nome deve ter pelo menos 3 caracteres');

  // Validação do CPF
  if Trim(FCPF) = '' then
    Result.Add('CPF é obrigatório')
  else if Length(FCPF) <> 11 then
    Result.Add('CPF deve ter 11 dígitos');

  // Validação da data de nascimento
  if FDataNascimento = 0 then
    Result.Add('Data de nascimento é obrigatória')
  else if FDataNascimento >= Now then
    Result.Add('Data de nascimento deve ser anterior à data atual');

  // Validação do email
  if (Trim(FEmail) <> '') and
    (not TRegEx.IsMatch(FEmail, '^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$')) then
    Result.Add('Email inválido');

  // Validação da altura
  if (FAltura > 0) and ((FAltura < 1.0) or (FAltura > 2.5)) then
    Result.Add('Altura deve estar entre 1,0 e 2,5 metros');

  // Validação do peso
  if (FPesoInicial > 0) and ((FPesoInicial < 30) or (FPesoInicial > 200)) then
    Result.Add('Peso deve estar entre 30 e 200 kg');
end;

end.

