unit Controller.Gestante;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Model.Gestante,
  Data.DAO.Gestante,
  Interfaces.DAO;

type
  /// <summary>
  /// Controller para Gestante com interface fluente
  /// Implementa padrões SOLID, KISS e Clean Code
  /// </summary>
  TGestanteController = class
  private
    FGestanteDAO: IGestanteDAO;
    FGestante: TGestante;
    FListaGestantes: TObjectList<TGestante>;
    FUltimoErro: string;

    function ValidarGestante: Boolean;
    procedure LimparErro;

  public
    constructor Create;
    destructor Destroy; override;

    // Interface fluente para configuração
    function NovaGestante: TGestanteController;
    function CarregarGestante(const Id: Integer): TGestanteController;
    function CarregarPorCPF(const CPF: string): TGestanteController;

    // Interface fluente para definir dados
    function ComNome(const Nome: string): TGestanteController;
    function ComCPF(const CPF: string): TGestanteController;
    function ComRG(const RG: string): TGestanteController;
    function ComDataNascimento(const Data: TDateTime): TGestanteController;
    function ComTelefone(const Telefone: string): TGestanteController;
    function ComCelular(const Celular: string): TGestanteController;
    function ComEmail(const Email: string): TGestanteController;
    function ComEndereco(const Endereco: string): TGestanteController;
    function ComCEP(const CEP: string): TGestanteController;
    function ComCidade(const Cidade: string): TGestanteController;
    function ComEstado(const Estado: string): TGestanteController;
    function ComDataUltimaMenstruacao(const Data: TDateTime): TGestanteController;
    function ComTipoSanguineo(const Tipo: string): TGestanteController;
    function ComPesoInicial(const Peso: Double): TGestanteController;
    function ComAltura(const Altura: Double): TGestanteController;
    function ComObservacoes(const Observacoes: string): TGestanteController;
    function Ativa(const Ativo: Boolean = True): TGestanteController;

    // Interface fluente para operações
    function Salvar: TGestanteController;
    function Excluir: TGestanteController;
    function BuscarTodas: TGestanteController;
    function BuscarAtivas: TGestanteController;
    function BuscarPorNome(const Nome: string): TGestanteController;
    function BuscarComConsultasRecentes(const Dias: Integer = 30): TGestanteController;
    function BuscarPorIdadeGestacional(const SemanaMin, SemanaMax: Integer): TGestanteController;

    // Interface fluente para validação
    function ValidarCPFUnico: TGestanteController;
    function ValidarDados: TGestanteController;

    // Métodos de resultado
    function Sucesso: Boolean;
    function TemErro: Boolean;
    function ObterErro: string;
    function ObterGestante: TGestante;
    function ObterLista: TObjectList<TGestante>;
    function ObterQuantidade: Integer;

    // Métodos utilitários
    function ExisteGestante: Boolean;
    function ObterIdade: Integer;
    function ObterIdadeGestacional: string;
    function ObterIMC: Double;

    // Propriedades para acesso direto (quando necessário)
    property Gestante: TGestante read FGestante;
    property Lista: TObjectList<TGestante> read FListaGestantes;
    property UltimoErro: string read FUltimoErro;
  end;

implementation

uses
  System.DateUtils;

{ TGestanteController }

constructor TGestanteController.Create;
begin
  inherited Create;
  FGestanteDAO := TGestanteDAO.Create;
  FGestante := nil;
  FListaGestantes := nil;
  FUltimoErro := '';
end;

destructor TGestanteController.Destroy;
begin
  if Assigned(FGestante) then
    FreeAndNil(FGestante);

  if Assigned(FListaGestantes) then
    FreeAndNil(FListaGestantes);

  inherited Destroy;
end;

procedure TGestanteController.LimparErro;
begin
  FUltimoErro := '';
end;

function TGestanteController.ValidarGestante: Boolean;
var
  Erros: TStringList;
begin
  Result := False;
  LimparErro;

  if not Assigned(FGestante) then
  begin
    FUltimoErro := 'Nenhuma gestante carregada para validação';
    Exit;
  end;

  Erros := FGestante.GetValidationErrors;
  try
    if Erros.Count > 0 then
    begin
      FUltimoErro := Erros.Text;
      Exit;
    end;

    Result := True;
  finally
    Erros.Free;
  end;
end;

// Interface fluente para configuração

function TGestanteController.NovaGestante: TGestanteController;
begin
  LimparErro;

  if Assigned(FGestante) then
    FreeAndNil(FGestante);

  FGestante := TGestante.Create;
  Result := Self;
end;

function TGestanteController.CarregarGestante(const Id: Integer): TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FGestante) then
      FreeAndNil(FGestante);

    FGestante := FGestanteDAO.GetById(Id);

    if not Assigned(FGestante) then
      FUltimoErro := 'Gestante não encontrada com o ID informado';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao carregar gestante: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.CarregarPorCPF(const CPF: string): TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FGestante) then
      FreeAndNil(FGestante);

    FGestante := FGestanteDAO.GetByCPF(CPF);

    if not Assigned(FGestante) then
      FUltimoErro := 'Gestante não encontrada com o CPF informado';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao carregar gestante por CPF: ' + E.Message;
  end;

  Result := Self;
end;

// Interface fluente para definir dados

function TGestanteController.ComNome(const Nome: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Nome := Nome
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComCPF(const CPF: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.CPF := CPF
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComRG(const RG: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.RG := RG
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComDataNascimento(const Data: TDateTime): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.DataNascimento := Data
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComTelefone(const Telefone: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Telefone := Telefone
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComCelular(const Celular: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Celular := Celular
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComEmail(const Email: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Email := Email
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComEndereco(const Endereco: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Endereco := Endereco
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComCEP(const CEP: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.CEP := CEP
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComCidade(const Cidade: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Cidade := Cidade
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComEstado(const Estado: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Estado := Estado
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComDataUltimaMenstruacao(const Data: TDateTime): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.DataUltimaMenstruacao := Data
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComTipoSanguineo(const Tipo: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.TipoSanguineo := Tipo
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComPesoInicial(const Peso: Double): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.PesoInicial := Peso
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComAltura(const Altura: Double): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Altura := Altura
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.ComObservacoes(const Observacoes: string): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Observacoes := Observacoes
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

function TGestanteController.Ativa(const Ativo: Boolean): TGestanteController;
begin
  if Assigned(FGestante) then
    FGestante.Ativo := Ativo
  else
    FUltimoErro := 'Nenhuma gestante carregada';

  Result := Self;
end;

// Interface fluente para operações

function TGestanteController.Salvar: TGestanteController;
begin
  LimparErro;

  try
    if not Assigned(FGestante) then
    begin
      FUltimoErro := 'Nenhuma gestante carregada para salvar';
      Result := Self;
      Exit;
    end;

    if not ValidarGestante then
    begin
      Result := Self;
      Exit;
    end;

    if FGestante.Id = 0 then
    begin
      if not FGestanteDAO.Insert(FGestante) then
        FUltimoErro := 'Erro ao inserir gestante';
    end
    else
    begin
      if not FGestanteDAO.Update(FGestante) then
        FUltimoErro := 'Erro ao atualizar gestante';
    end;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao salvar gestante: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.Excluir: TGestanteController;
begin
  LimparErro;

  try
    if not Assigned(FGestante) then
    begin
      FUltimoErro := 'Nenhuma gestante carregada para excluir';
      Result := Self;
      Exit;
    end;

    if FGestante.Id = 0 then
    begin
      FUltimoErro := 'Gestante não possui ID válido para exclusão';
      Result := Self;
      Exit;
    end;

    if not FGestanteDAO.Delete(FGestante.Id) then
      FUltimoErro := 'Erro ao excluir gestante';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao excluir gestante: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.BuscarTodas: TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FListaGestantes) then
      FreeAndNil(FListaGestantes);

    FListaGestantes := FGestanteDAO.GetAll;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao buscar todas as gestantes: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.BuscarAtivas: TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FListaGestantes) then
      FreeAndNil(FListaGestantes);

    FListaGestantes := FGestanteDAO.GetAtivas;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao buscar gestantes ativas: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.BuscarPorNome(const Nome: string): TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FListaGestantes) then
      FreeAndNil(FListaGestantes);

    FListaGestantes := FGestanteDAO.GetByNome(Nome);
  except
    on E: Exception do
      FUltimoErro := 'Erro ao buscar gestantes por nome: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.BuscarComConsultasRecentes(const Dias: Integer): TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FListaGestantes) then
      FreeAndNil(FListaGestantes);

    FListaGestantes := FGestanteDAO.GetGestantesComConsultasRecentes(Dias);
  except
    on E: Exception do
      FUltimoErro := 'Erro ao buscar gestantes com consultas recentes: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.BuscarPorIdadeGestacional(const SemanaMin, SemanaMax: Integer): TGestanteController;
begin
  LimparErro;

  try
    if Assigned(FListaGestantes) then
      FreeAndNil(FListaGestantes);

    FListaGestantes := FGestanteDAO.GetGestantesPorIdadeGestacional(SemanaMin, SemanaMax);
  except
    on E: Exception do
      FUltimoErro := 'Erro ao buscar gestantes por idade gestacional: ' + E.Message;
  end;

  Result := Self;
end;

// Interface fluente para validação

function TGestanteController.ValidarCPFUnico: TGestanteController;
begin
  LimparErro;

  try
    if not Assigned(FGestante) then
    begin
      FUltimoErro := 'Nenhuma gestante carregada para validar CPF';
      Result := Self;
      Exit;
    end;

    if FGestanteDAO.ExistsCPF(FGestante.CPF, FGestante.Id) then
      FUltimoErro := 'CPF já cadastrado para outra gestante';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao validar CPF único: ' + E.Message;
  end;

  Result := Self;
end;

function TGestanteController.ValidarDados: TGestanteController;
begin
  ValidarGestante;
  Result := Self;
end;

// Métodos de resultado

function TGestanteController.Sucesso: Boolean;
begin
  Result := FUltimoErro = '';
end;

function TGestanteController.TemErro: Boolean;
begin
  Result := FUltimoErro <> '';
end;

function TGestanteController.ObterErro: string;
begin
  Result := FUltimoErro;
end;

function TGestanteController.ObterGestante: TGestante;
begin
  Result := FGestante;
end;

function TGestanteController.ObterLista: TObjectList<TGestante>;
begin
  Result := FListaGestantes;
end;

function TGestanteController.ObterQuantidade: Integer;
begin
  try
    Result := FGestanteDAO.GetCount;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter quantidade: ' + E.Message;
      Result := 0;
    end;
  end;
end;

// Métodos utilitários

function TGestanteController.ExisteGestante: Boolean;
begin
  Result := Assigned(FGestante);
end;

function TGestanteController.ObterIdade: Integer;
begin
  if Assigned(FGestante) then
    Result := FGestante.GetIdade
  else
    Result := 0;
end;

function TGestanteController.ObterIdadeGestacional: string;
begin
  if Assigned(FGestante) then
    Result := FGestante.GetIdadeGestacional
  else
    Result := '';
end;

function TGestanteController.ObterIMC: Double;
begin
  if Assigned(FGestante) then
    Result := FGestante.GetIMC
  else
    Result := 0;
end;

end.

