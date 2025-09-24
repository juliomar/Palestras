unit Model.Consulta;

interface

uses
  System.SysUtils,
  System.Classes;

type
  /// <summary>
  /// Classe que representa uma Consulta no sistema
  /// Implementa o padrão de domínio rico com validações
  /// </summary>
  TConsulta = class
  private
    FId: Integer;
    FGestanteId: Integer;
    FDataConsulta: TDateTime;
    FPesoAtual: Double;
    FPressaoArterial: string;
    FAlturaUterina: Double;
    FBatimentosFetais: Integer;
    FIdadeGestacional: string;
    FObservacoes: string;
    FMedicoResponsavel: string;
    FDataCadastro: TDateTime;

    procedure SetDataConsulta(const Value: TDateTime);
    procedure SetMedicoResponsavel(const Value: string);
    procedure SetPressaoArterial(const Value: string);

  public
    constructor Create;

    // Propriedades
    property Id: Integer read FId write FId;
    property GestanteId: Integer read FGestanteId write FGestanteId;
    property DataConsulta: TDateTime read FDataConsulta write SetDataConsulta;
    property PesoAtual: Double read FPesoAtual write FPesoAtual;
    property PressaoArterial: string read FPressaoArterial write SetPressaoArterial;
    property AlturaUterina: Double read FAlturaUterina write FAlturaUterina;
    property BatimentosFetais: Integer read FBatimentosFetais write FBatimentosFetais;
    property IdadeGestacional: string read FIdadeGestacional write FIdadeGestacional;
    property Observacoes: string read FObservacoes write FObservacoes;
    property MedicoResponsavel: string read FMedicoResponsavel write SetMedicoResponsavel;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    // Métodos de negócio
    function IsValid: Boolean;
    function GetValidationErrors: TStringList;
    function GetStatusPressao: string;
    function GetStatusBatimentos: string;

    // Métodos utilitários
    procedure Clear;
    function Clone: TConsulta;
  end;

implementation

uses
  System.RegularExpressions,
  System.DateUtils;

{ TConsulta }

constructor TConsulta.Create;
begin
  inherited Create;
  Clear;
end;

procedure TConsulta.Clear;
begin
  FId := 0;
  FGestanteId := 0;
  FDataConsulta := Now;
  FPesoAtual := 0;
  FPressaoArterial := '';
  FAlturaUterina := 0;
  FBatimentosFetais := 0;
  FIdadeGestacional := '';
  FObservacoes := '';
  FMedicoResponsavel := '';
  FDataCadastro := Now;
end;

function TConsulta.Clone: TConsulta;
begin
  Result := TConsulta.Create;
  Result.FId := Self.FId;
  Result.FGestanteId := Self.FGestanteId;
  Result.FDataConsulta := Self.FDataConsulta;
  Result.FPesoAtual := Self.FPesoAtual;
  Result.FPressaoArterial := Self.FPressaoArterial;
  Result.FAlturaUterina := Self.FAlturaUterina;
  Result.FBatimentosFetais := Self.FBatimentosFetais;
  Result.FIdadeGestacional := Self.FIdadeGestacional;
  Result.FObservacoes := Self.FObservacoes;
  Result.FMedicoResponsavel := Self.FMedicoResponsavel;
  Result.FDataCadastro := Self.FDataCadastro;
end;

procedure TConsulta.SetDataConsulta(const Value: TDateTime);
begin
  FDataConsulta := Value;
end;

procedure TConsulta.SetMedicoResponsavel(const Value: string);
begin
  FMedicoResponsavel := Trim(Value);
end;

procedure TConsulta.SetPressaoArterial(const Value: string);
begin
  FPressaoArterial := Trim(Value);
end;

function TConsulta.IsValid: Boolean;
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

function TConsulta.GetValidationErrors: TStringList;
begin
  Result := TStringList.Create;

  // Validação da gestante
  if FGestanteId <= 0 then
    Result.Add('Gestante é obrigatória');

  // Validação da data da consulta
  if FDataConsulta = 0 then
    Result.Add('Data da consulta é obrigatória')
  else if FDataConsulta > Now then
    Result.Add('Data da consulta não pode ser futura');

  // Validação do peso
  if (FPesoAtual > 0) and ((FPesoAtual < 30) or (FPesoAtual > 200)) then
    Result.Add('Peso deve estar entre 30 e 200 kg');

  // Validação da pressão arterial
  if (Trim(FPressaoArterial) <> '') and
    (not TRegEx.IsMatch(FPressaoArterial, '^\d{2,3}x\d{2,3}$')) then
    Result.Add('Pressão arterial deve estar no formato 120x80');

  // Validação da altura uterina
  if (FAlturaUterina > 0) and ((FAlturaUterina < 10) or (FAlturaUterina > 50)) then
    Result.Add('Altura uterina deve estar entre 10 e 50 cm');

  // Validação dos batimentos fetais
  if (FBatimentosFetais > 0) and ((FBatimentosFetais < 110) or (FBatimentosFetais > 180)) then
    Result.Add('Batimentos fetais devem estar entre 110 e 180 bpm');

  // Validação do médico responsável
  if Trim(FMedicoResponsavel) = '' then
    Result.Add('Médico responsável é obrigatório')
  else if Length(Trim(FMedicoResponsavel)) < 3 then
    Result.Add('Nome do médico deve ter pelo menos 3 caracteres');
end;

function TConsulta.GetStatusPressao: string;
var
  Sistolica, Diastolica: Integer;
  Partes: TArray<string>;
begin
  Result := 'Não informada';

  if Trim(FPressaoArterial) <> '' then
  begin
    Partes := FPressaoArterial.Split(['x', 'X']);
    if Length(Partes) = 2 then
    begin
      if TryStrToInt(Partes[0], Sistolica) and TryStrToInt(Partes[1], Diastolica) then
      begin
        if (Sistolica < 120) and (Diastolica < 80) then
          Result := 'Normal'
        else if (Sistolica <= 129) and (Diastolica < 80) then
          Result := 'Elevada'
        else if ((Sistolica >= 130) and (Sistolica <= 139)) or
          ((Diastolica >= 80) and (Diastolica <= 89)) then
          Result := 'Hipertensão Estágio 1'
        else if (Sistolica >= 140) or (Diastolica >= 90) then
          Result := 'Hipertensão Estágio 2'
        else if (Sistolica > 180) or (Diastolica > 120) then
          Result := 'Crise Hipertensiva';
      end;
    end;
  end;
end;

function TConsulta.GetStatusBatimentos: string;
begin
  Result := 'Não informado';

  if FBatimentosFetais > 0 then
  begin
    if (FBatimentosFetais >= 110) and (FBatimentosFetais <= 160) then
      Result := 'Normal'
    else if (FBatimentosFetais > 160) and (FBatimentosFetais <= 180) then
      Result := 'Taquicardia'
    else if FBatimentosFetais < 110 then
      Result := 'Bradicardia'
    else
      Result := 'Alterado';
  end;
end;

end.

