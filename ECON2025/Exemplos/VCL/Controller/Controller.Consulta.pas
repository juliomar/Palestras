unit Controller.Consulta;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Model.Consulta,
  Data.DAO.Consulta,
  Interfaces.DAO;

type
  /// <summary>
  /// Controller para gerenciamento de consultas com interface fluente
  /// Implementa padrões SOLID, KISS e Clean Code
  /// </summary>
  TConsultaController = class
  private
    FConsulta: TConsulta;
    FConsultaDAO: IConsultaDAO;
    FErro: string;
    FSucesso: Boolean;
    FLista: TObjectList<TConsulta>;

    procedure LimparEstado;
    procedure DefinirErro(const Mensagem: string);
    procedure DefinirSucesso;

  public
    constructor Create;
    destructor Destroy; override;

    // Interface Fluente - Configuração
    function NovaConsulta: TConsultaController;
    function CarregarConsulta(const Id: Integer): TConsultaController;
    function CarregarPorGestante(const GestanteId: Integer): TConsultaController;

    // Interface Fluente - Definição de Dados
    function ComGestante(const GestanteId: Integer): TConsultaController;
    function ComDataConsulta(const Data: TDateTime): TConsultaController;
    function ComPesoAtual(const Peso: Double): TConsultaController;
    function ComPressaoArterial(const Pressao: string): TConsultaController;
    function ComAlturaUterina(const Altura: Double): TConsultaController;
    function ComBatimentosFetais(const Batimentos: Integer): TConsultaController;
    function ComIdadeGestacional(const Idade: string): TConsultaController;
    function ComMedicoResponsavel(const Medico: string): TConsultaController;
    function ComObservacoes(const Observacoes: string): TConsultaController;

    // Interface Fluente - Operações
    function Salvar: TConsultaController;
    function Excluir: TConsultaController;
    function ValidarDados: TConsultaController;

    // Interface Fluente - Busca
    function BuscarTodas: TConsultaController;
    function BuscarPorPeriodo(const DataInicio, DataFim: TDateTime): TConsultaController;
    function BuscarPorMedico(const Medico: string): TConsultaController;
    function BuscarRecentes(const Dias: Integer = 30): TConsultaController;

    // Métodos de Acesso
    function ObterConsulta: TConsulta;
    function ObterLista: TObjectList<TConsulta>;
    function ObterQuantidade: Integer;
    function ExisteConsulta: Boolean;
    function TemErro: Boolean;
    function ObterErro: string;
    function Sucesso: Boolean;
  end;

implementation

uses
  Data.Connection,
  Utils.Validacao;

{ TConsultaController }

constructor TConsultaController.Create;
begin
  inherited Create;
  FConsultaDAO := TConsultaDAO.Create;
  FConsulta := nil;
  FLista := nil;
  LimparEstado;
end;

destructor TConsultaController.Destroy;
begin
  if Assigned(FConsulta) then
    FreeAndNil(FConsulta);
  if Assigned(FLista) then
    FreeAndNil(FLista);
  inherited Destroy;
end;

procedure TConsultaController.LimparEstado;
begin
  FErro := '';
  FSucesso := False;
end;

procedure TConsultaController.DefinirErro(const Mensagem: string);
begin
  FErro := Mensagem;
  FSucesso := False;
end;

procedure TConsultaController.DefinirSucesso;
begin
  FErro := '';
  FSucesso := True;
end;

// Interface Fluente - Configuração

function TConsultaController.NovaConsulta: TConsultaController;
begin
  Result := Self;
  LimparEstado;

  if Assigned(FConsulta) then
    FreeAndNil(FConsulta);

  FConsulta := TConsulta.Create;
end;

function TConsultaController.CarregarConsulta(const Id: Integer): TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FConsulta) then
      FreeAndNil(FConsulta);

    FConsulta := FConsultaDAO.GetById(Id);

    if not Assigned(FConsulta) then
      DefinirErro('Consulta não encontrada')
    else
      DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao carregar consulta: ' + E.Message);
  end;
end;

function TConsultaController.CarregarPorGestante(const GestanteId: Integer): TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FConsultaDAO.GetByGestante(GestanteId);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao carregar consultas da gestante: ' + E.Message);
  end;
end;

// Interface Fluente - Definição de Dados

function TConsultaController.ComGestante(const GestanteId: Integer): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.GestanteId := GestanteId;
end;

function TConsultaController.ComDataConsulta(const Data: TDateTime): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.DataConsulta := Data;
end;

function TConsultaController.ComPesoAtual(const Peso: Double): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.PesoAtual := Peso;
end;

function TConsultaController.ComPressaoArterial(const Pressao: string): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.PressaoArterial := Pressao;
end;

function TConsultaController.ComAlturaUterina(const Altura: Double): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.AlturaUterina := Altura;
end;

function TConsultaController.ComBatimentosFetais(const Batimentos: Integer): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.BatimentosFetais := Batimentos;
end;

function TConsultaController.ComIdadeGestacional(const Idade: string): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.IdadeGestacional := Idade;
end;

function TConsultaController.ComMedicoResponsavel(const Medico: string): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.MedicoResponsavel := Medico;
end;

function TConsultaController.ComObservacoes(const Observacoes: string): TConsultaController;
begin
  Result := Self;
  if Assigned(FConsulta) then
    FConsulta.Observacoes := Observacoes;
end;

// Interface Fluente - Operações

function TConsultaController.Salvar: TConsultaController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FConsulta) then
  begin
    DefinirErro('Nenhuma consulta para salvar');
    Exit;
  end;

  try
    if FConsulta.Id = 0 then
      FConsultaDAO.Insert(FConsulta)
    else
      FConsultaDAO.Update(FConsulta);

    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao salvar consulta: ' + E.Message);
  end;
end;

function TConsultaController.Excluir: TConsultaController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FConsulta) then
  begin
    DefinirErro('Nenhuma consulta para excluir');
    Exit;
  end;

  try
    FConsultaDAO.Delete(FConsulta.Id);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao excluir consulta: ' + E.Message);
  end;
end;

function TConsultaController.ValidarDados: TConsultaController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FConsulta) then
  begin
    DefinirErro('Nenhuma consulta para validar');
    Exit;
  end;

  // Validações básicas
  if FConsulta.GestanteId <= 0 then
  begin
    DefinirErro('Gestante é obrigatória');
    Exit;
  end;

  if Trim(FConsulta.MedicoResponsavel) = '' then
  begin
    DefinirErro('Médico responsável é obrigatório');
    Exit;
  end;

  if FConsulta.DataConsulta = 0 then
  begin
    DefinirErro('Data da consulta é obrigatória');
    Exit;
  end;

  // Validar pressão arterial se informada
  if (Trim(FConsulta.PressaoArterial) <> '') and
    (not TValidacao.ValidarPressaoArterial(FConsulta.PressaoArterial)) then
  begin
    DefinirErro('Pressão arterial deve estar no formato 120x80');
    Exit;
  end;

  // Validar batimentos fetais se informados
  if (FConsulta.BatimentosFetais > 0) and
    (not TValidacao.ValidarBatimentosFetais(FConsulta.BatimentosFetais)) then
  begin
    DefinirErro('Batimentos fetais devem estar entre 110 e 180 bpm');
    Exit;
  end;

  // Validar peso se informado
  if (FConsulta.PesoAtual > 0) and
    (not TValidacao.ValidarPeso(FConsulta.PesoAtual)) then
  begin
    DefinirErro('Peso deve estar entre 30 e 200 kg');
    Exit;
  end;

  DefinirSucesso;
end;

// Interface Fluente - Busca

function TConsultaController.BuscarTodas: TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FConsultaDAO.GetAll;
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar consultas: ' + E.Message);
  end;
end;

function TConsultaController.BuscarPorPeriodo(const DataInicio, DataFim: TDateTime): TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FConsultaDAO.GetByPeriodo(DataInicio, DataFim);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar consultas por período: ' + E.Message);
  end;
end;

function TConsultaController.BuscarPorMedico(const Medico: string): TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FConsultaDAO.GetByMedico(Medico);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar consultas por médico: ' + E.Message);
  end;
end;

function TConsultaController.BuscarRecentes(const Dias: Integer): TConsultaController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    // Implementação simples - buscar por período
    FLista := FConsultaDAO.GetByPeriodo(Now - Dias, Now);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar consultas recentes: ' + E.Message);
  end;
end;

// Métodos de Acesso

function TConsultaController.ObterConsulta: TConsulta;
begin
  Result := FConsulta;
end;

function TConsultaController.ObterLista: TObjectList<TConsulta>;
begin
  Result := FLista;
end;

function TConsultaController.ObterQuantidade: Integer;
begin
  if Assigned(FLista) then
    Result := FLista.Count
  else
    Result := 0;
end;

function TConsultaController.ExisteConsulta: Boolean;
begin
  Result := Assigned(FConsulta);
end;

function TConsultaController.TemErro: Boolean;
begin
  Result := FErro <> '';
end;

function TConsultaController.ObterErro: string;
begin
  Result := FErro;
end;

function TConsultaController.Sucesso: Boolean;
begin
  Result := FSucesso;
end;

end.

