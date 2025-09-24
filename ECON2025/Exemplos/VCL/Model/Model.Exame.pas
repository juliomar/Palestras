unit Model.Exame;

interface

uses
  System.SysUtils,
  System.Classes;

type
  /// <summary>
  /// Classe que representa um Exame no sistema
  /// Implementa o padrão de domínio rico com validações
  /// </summary>
  TExame = class
  private
    FId: Integer;
    FGestanteId: Integer;
    FTipoExame: string;
    FDataExame: TDateTime;
    FResultado: string;
    FObservacoes: string;
    FMedicoSolicitante: string;
    FLaboratorio: string;
    FDataCadastro: TDateTime;

    procedure SetTipoExame(const Value: string);
    procedure SetMedicoSolicitante(const Value: string);
    procedure SetLaboratorio(const Value: string);
    procedure SetDataExame(const Value: TDateTime);

  public
    constructor Create;

    // Propriedades
    property Id: Integer read FId write FId;
    property GestanteId: Integer read FGestanteId write FGestanteId;
    property TipoExame: string read FTipoExame write SetTipoExame;
    property DataExame: TDateTime read FDataExame write SetDataExame;
    property Resultado: string read FResultado write FResultado;
    property Observacoes: string read FObservacoes write FObservacoes;
    property MedicoSolicitante: string read FMedicoSolicitante write SetMedicoSolicitante;
    property Laboratorio: string read FLaboratorio write SetLaboratorio;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    // Métodos de negócio
    function IsValid: Boolean;
    function GetValidationErrors: TStringList;
    function GetTiposExameComuns: TStringList;
    function IsExameUrgente: Boolean;

    // Métodos utilitários
    procedure Clear;
    function Clone: TExame;
  end;

implementation

uses
  System.DateUtils;

{ TExame }

constructor TExame.Create;
begin
  inherited Create;
  Clear;
end;

procedure TExame.Clear;
begin
  FId := 0;
  FGestanteId := 0;
  FTipoExame := '';
  FDataExame := Now;
  FResultado := '';
  FObservacoes := '';
  FMedicoSolicitante := '';
  FLaboratorio := '';
  FDataCadastro := Now;
end;

function TExame.Clone: TExame;
begin
  Result := TExame.Create;
  Result.FId := Self.FId;
  Result.FGestanteId := Self.FGestanteId;
  Result.FTipoExame := Self.FTipoExame;
  Result.FDataExame := Self.FDataExame;
  Result.FResultado := Self.FResultado;
  Result.FObservacoes := Self.FObservacoes;
  Result.FMedicoSolicitante := Self.FMedicoSolicitante;
  Result.FLaboratorio := Self.FLaboratorio;
  Result.FDataCadastro := Self.FDataCadastro;
end;

procedure TExame.SetTipoExame(const Value: string);
begin
  FTipoExame := Trim(Value);
end;

procedure TExame.SetMedicoSolicitante(const Value: string);
begin
  FMedicoSolicitante := Trim(Value);
end;

procedure TExame.SetLaboratorio(const Value: string);
begin
  FLaboratorio := Trim(Value);
end;

procedure TExame.SetDataExame(const Value: TDateTime);
begin
  FDataExame := Value;
end;

function TExame.IsValid: Boolean;
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

function TExame.GetValidationErrors: TStringList;
begin
  Result := TStringList.Create;

  // Validação da gestante
  if FGestanteId <= 0 then
    Result.Add('Gestante é obrigatória');

  // Validação do tipo de exame
  if Trim(FTipoExame) = '' then
    Result.Add('Tipo de exame é obrigatório')
  else if Length(Trim(FTipoExame)) < 3 then
    Result.Add('Tipo de exame deve ter pelo menos 3 caracteres');

  // Validação da data do exame
  if FDataExame = 0 then
    Result.Add('Data do exame é obrigatória')
  else if FDataExame > Now then
    Result.Add('Data do exame não pode ser futura');

  // Validação do médico solicitante
  if Trim(FMedicoSolicitante) = '' then
    Result.Add('Médico solicitante é obrigatório')
  else if Length(Trim(FMedicoSolicitante)) < 3 then
    Result.Add('Nome do médico deve ter pelo menos 3 caracteres');
end;

function TExame.GetTiposExameComuns: TStringList;
begin
  Result := TStringList.Create;

  // Exames laboratoriais comuns na gestação
  Result.Add('Hemograma Completo');
  Result.Add('Glicemia de Jejum');
  Result.Add('Teste de Tolerância à Glicose (TTG)');
  Result.Add('Urina Tipo I (EAS)');
  Result.Add('Urocultura');
  Result.Add('Sorologia para Toxoplasmose');
  Result.Add('Sorologia para Rubéola');
  Result.Add('Sorologia para Citomegalovírus');
  Result.Add('Sorologia para Sífilis (VDRL)');
  Result.Add('Sorologia para HIV');
  Result.Add('Sorologia para Hepatite B');
  Result.Add('Sorologia para Hepatite C');
  Result.Add('Tipagem Sanguínea e Fator Rh');
  Result.Add('Coombs Indireto');
  Result.Add('TSH e T4 Livre');
  Result.Add('Cultura para Streptococcus B');

  // Exames de imagem
  Result.Add('Ultrassom Obstétrico');
  Result.Add('Ultrassom Morfológico');
  Result.Add('Ultrassom com Doppler');
  Result.Add('Ecocardiografia Fetal');
  Result.Add('Cardiotocografia');

  // Exames especializados
  Result.Add('Amniocentese');
  Result.Add('Biópsia de Vilo Corial');
  Result.Add('Translucência Nucal');
  Result.Add('Teste do Pezinho');
  Result.Add('Perfil Biofísico Fetal');
end;

function TExame.IsExameUrgente: Boolean;
var
  TiposUrgentes: TStringList;
begin
  TiposUrgentes := TStringList.Create;
  try
    TiposUrgentes.Add('CARDIOTOCOGRAFIA');
    TiposUrgentes.Add('PERFIL BIOFÍSICO FETAL');
    TiposUrgentes.Add('DOPPLER');
    TiposUrgentes.Add('AMNIOCENTESE');
    TiposUrgentes.Add('GLICEMIA');
    TiposUrgentes.Add('HEMOGRAMA');

    Result := TiposUrgentes.IndexOf(UpperCase(FTipoExame)) >= 0;
  finally
    TiposUrgentes.Free;
  end;
end;

end.

