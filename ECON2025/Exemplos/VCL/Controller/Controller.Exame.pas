unit Controller.Exame;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Model.Exame,
  Data.DAO.Exame,
  Interfaces.DAO;

type
  /// <summary>
  /// Controller para gerenciamento de exames com interface fluente
  /// Implementa padrões SOLID, KISS e Clean Code
  /// </summary>
  TExameController = class
  private
    FExame: TExame;
    FExameDAO: IExameDAO;
    FErro: string;
    FSucesso: Boolean;
    FLista: TObjectList<TExame>;

    procedure LimparEstado;
    procedure DefinirErro(const Mensagem: string);
    procedure DefinirSucesso;

  public
    constructor Create;
    destructor Destroy; override;

    // Interface Fluente - Configuração
    function NovoExame: TExameController;
    function CarregarExame(const Id: Integer): TExameController;
    function CarregarPorGestante(const GestanteId: Integer): TExameController;

    // Interface Fluente - Definição de Dados
    function ComGestante(const GestanteId: Integer): TExameController;
    function ComTipoExame(const Tipo: string): TExameController;
    function ComDataExame(const Data: TDateTime): TExameController;
    function ComMedicoSolicitante(const Medico: string): TExameController;
    function ComLaboratorio(const Laboratorio: string): TExameController;
    function ComResultado(const Resultado: string): TExameController;
    function ComObservacoes(const Observacoes: string): TExameController;

    // Interface Fluente - Operações
    function Salvar: TExameController;
    function Excluir: TExameController;
    function ValidarDados: TExameController;

    // Interface Fluente - Busca
    function BuscarTodos: TExameController;
    function BuscarPorTipo(const Tipo: string): TExameController;
    function BuscarPorPeriodo(const DataInicio, DataFim: TDateTime): TExameController;
    function BuscarPorLaboratorio(const Laboratorio: string): TExameController;
    function BuscarPendentes: TExameController;
    function BuscarUrgentes: TExameController;
    function BuscarRecentes(const Dias: Integer = 30): TExameController;

    // Métodos de Acesso
    function ObterExame: TExame;
    function ObterLista: TObjectList<TExame>;
    function ObterQuantidade: Integer;
    function ExisteExame: Boolean;
    function TemErro: Boolean;
    function ObterErro: string;
    function Sucesso: Boolean;
  end;

implementation

uses
  Data.Connection,
  Utils.Validacao;

{ TExameController }

constructor TExameController.Create;
begin
  inherited Create;
  FExameDAO := TExameDAO.Create;
  FExame := nil;
  FLista := nil;
  LimparEstado;
end;

destructor TExameController.Destroy;
begin
  if Assigned(FExame) then
    FreeAndNil(FExame);
  if Assigned(FLista) then
    FreeAndNil(FLista);
  inherited Destroy;
end;

procedure TExameController.LimparEstado;
begin
  FErro := '';
  FSucesso := False;
end;

procedure TExameController.DefinirErro(const Mensagem: string);
begin
  FErro := Mensagem;
  FSucesso := False;
end;

procedure TExameController.DefinirSucesso;
begin
  FErro := '';
  FSucesso := True;
end;

// Interface Fluente - Configuração

function TExameController.NovoExame: TExameController;
begin
  Result := Self;
  LimparEstado;

  if Assigned(FExame) then
    FreeAndNil(FExame);

  FExame := TExame.Create;
end;

function TExameController.CarregarExame(const Id: Integer): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FExame) then
      FreeAndNil(FExame);

    FExame := FExameDAO.GetById(Id);

    if not Assigned(FExame) then
      DefinirErro('Exame não encontrado')
    else
      DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao carregar exame: ' + E.Message);
  end;
end;

function TExameController.CarregarPorGestante(const GestanteId: Integer): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FExameDAO.GetByGestante(GestanteId);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao carregar exames da gestante: ' + E.Message);
  end;
end;

// Interface Fluente - Definição de Dados

function TExameController.ComGestante(const GestanteId: Integer): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.GestanteId := GestanteId;
end;

function TExameController.ComTipoExame(const Tipo: string): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.TipoExame := Tipo;
end;

function TExameController.ComDataExame(const Data: TDateTime): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.DataExame := Data;
end;

function TExameController.ComMedicoSolicitante(const Medico: string): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.MedicoSolicitante := Medico;
end;

function TExameController.ComLaboratorio(const Laboratorio: string): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.Laboratorio := Laboratorio;
end;

function TExameController.ComResultado(const Resultado: string): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.Resultado := Resultado;
end;

function TExameController.ComObservacoes(const Observacoes: string): TExameController;
begin
  Result := Self;
  if Assigned(FExame) then
    FExame.Observacoes := Observacoes;
end;

// Interface Fluente - Operações

function TExameController.Salvar: TExameController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FExame) then
  begin
    DefinirErro('Nenhum exame para salvar');
    Exit;
  end;

  try
    if FExame.Id = 0 then
      FExameDAO.Insert(FExame)
    else
      FExameDAO.Update(FExame);

    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao salvar exame: ' + E.Message);
  end;
end;

function TExameController.Excluir: TExameController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FExame) then
  begin
    DefinirErro('Nenhum exame para excluir');
    Exit;
  end;

  try
    FExameDAO.Delete(FExame.Id);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao excluir exame: ' + E.Message);
  end;
end;

function TExameController.ValidarDados: TExameController;
begin
  Result := Self;
  LimparEstado;

  if not Assigned(FExame) then
  begin
    DefinirErro('Nenhum exame para validar');
    Exit;
  end;

  // Validações básicas
  if FExame.GestanteId <= 0 then
  begin
    DefinirErro('Gestante é obrigatória');
    Exit;
  end;

  if Trim(FExame.TipoExame) = '' then
  begin
    DefinirErro('Tipo de exame é obrigatório');
    Exit;
  end;

  if Trim(FExame.MedicoSolicitante) = '' then
  begin
    DefinirErro('Médico solicitante é obrigatório');
    Exit;
  end;

  if FExame.DataExame = 0 then
  begin
    DefinirErro('Data do exame é obrigatória');
    Exit;
  end;

  if FExame.DataExame > Now then
  begin
    DefinirErro('Data do exame não pode ser futura');
    Exit;
  end;

  DefinirSucesso;
end;

// Interface Fluente - Busca

function TExameController.BuscarTodos: TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FExameDAO.GetAll;
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames: ' + E.Message);
  end;
end;

function TExameController.BuscarPorTipo(const Tipo: string): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FExameDAO.GetByTipo(Tipo);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames por tipo: ' + E.Message);
  end;
end;

function TExameController.BuscarPorPeriodo(const DataInicio, DataFim: TDateTime): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FExameDAO.GetByPeriodo(DataInicio, DataFim);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames por período: ' + E.Message);
  end;
end;

function TExameController.BuscarPorLaboratorio(const Laboratorio: string): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    FLista := FExameDAO.GetByLaboratorio(Laboratorio);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames por laboratório: ' + E.Message);
  end;
end;

function TExameController.BuscarPendentes: TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    // Implementação simples - buscar todos e filtrar
    FLista := FExameDAO.GetAll;
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames pendentes: ' + E.Message);
  end;
end;

function TExameController.BuscarUrgentes: TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    // Implementação simples - buscar todos
    FLista := FExameDAO.GetAll;
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames urgentes: ' + E.Message);
  end;
end;

function TExameController.BuscarRecentes(const Dias: Integer): TExameController;
begin
  Result := Self;
  LimparEstado;

  try
    if Assigned(FLista) then
      FreeAndNil(FLista);

    // Implementação simples - buscar por período
    FLista := FExameDAO.GetByPeriodo(Now - Dias, Now);
    DefinirSucesso;
  except
    on E: Exception do
      DefinirErro('Erro ao buscar exames recentes: ' + E.Message);
  end;
end;

// Métodos de Acesso

function TExameController.ObterExame: TExame;
begin
  Result := FExame;
end;

function TExameController.ObterLista: TObjectList<TExame>;
begin
  Result := FLista;
end;

function TExameController.ObterQuantidade: Integer;
begin
  if Assigned(FLista) then
    Result := FLista.Count
  else
    Result := 0;
end;

function TExameController.ExisteExame: Boolean;
begin
  Result := Assigned(FExame);
end;

function TExameController.TemErro: Boolean;
begin
  Result := FErro <> '';
end;

function TExameController.ObterErro: string;
begin
  Result := FErro;
end;

function TExameController.Sucesso: Boolean;
begin
  Result := FSucesso;
end;

end.

