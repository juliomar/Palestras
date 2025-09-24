unit Interfaces.DAO;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Model.Gestante,
  Model.Consulta,
  Model.Exame;

type
  /// <summary>
  /// Interface genérica para operações CRUD
  /// Implementa o princípio da Inversão de Dependência (SOLID)
  /// </summary>
  IBaseDAO<T: class> = interface
    ['{B8F5E8A1-2345-4567-8901-234567890123}']
    function Insert(const Entity: T): Boolean;
    function Update(const Entity: T): Boolean;
    function Delete(const Id: Integer): Boolean;
    function GetById(const Id: Integer): T;
    function GetAll: TObjectList<T>;
    function GetCount: Integer;
  end;

  /// <summary>
  /// Interface específica para DAO de Gestantes
  /// Estende a interface base com métodos específicos
  /// </summary>
  IGestanteDAO = interface(IBaseDAO<TGestante>)
    ['{C9F6E9B2-3456-5678-9012-345678901234}']
    function GetByCPF(const CPF: string): TGestante;
    function GetByNome(const Nome: string): TObjectList<TGestante>;
    function GetAtivas: TObjectList<TGestante>;
    function GetInativas: TObjectList<TGestante>;
    function ExistsCPF(const CPF: string; const ExcludeId: Integer = 0): Boolean;
    function GetGestantesComConsultasRecentes(const Dias: Integer = 30): TObjectList<TGestante>;
    function GetGestantesPorIdadeGestacional(const SemanaMin, SemanaMax: Integer): TObjectList<TGestante>;
  end;

  /// <summary>
  /// Interface específica para DAO de Consultas
  /// Estende a interface base com métodos específicos
  /// </summary>
  IConsultaDAO = interface(IBaseDAO<TConsulta>)
    ['{D0F7F0C3-4567-6789-0123-456789012345}']
    function GetByGestante(const GestanteId: Integer): TObjectList<TConsulta>;
    function GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TConsulta>;
    function GetByMedico(const Medico: string): TObjectList<TConsulta>;
    function GetUltimaConsulta(const GestanteId: Integer): TConsulta;
    function GetConsultasHoje: TObjectList<TConsulta>;
    function GetConsultasPorSemana(const DataInicio: TDateTime): TObjectList<TConsulta>;
    function GetEstatisticasPorMedico(const DataInicio, DataFim: TDateTime): TStringList;
  end;

  /// <summary>
  /// Interface específica para DAO de Exames
  /// Estende a interface base com métodos específicos
  /// </summary>
  IExameDAO = interface(IBaseDAO<TExame>)
    ['{E1F8F1D4-5678-7890-1234-567890123456}']
    function GetByGestante(const GestanteId: Integer): TObjectList<TExame>;
    function GetByTipo(const TipoExame: string): TObjectList<TExame>;
    function GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TExame>;
    function GetByLaboratorio(const Laboratorio: string): TObjectList<TExame>;
    function GetExamesPendentes: TObjectList<TExame>;
    function GetExamesUrgentes: TObjectList<TExame>;
    function GetEstatisticasPorTipo(const DataInicio, DataFim: TDateTime): TStringList;
    function GetExamesPorGestanteETipo(const GestanteId: Integer; const TipoExame: string): TObjectList<TExame>;
  end;

  /// <summary>
  /// Interface para Factory de DAOs
  /// Implementa o padrão Abstract Factory
  /// </summary>
  IDAOFactory = interface
    ['{F2F9F2E5-6789-8901-2345-678901234567}']
    function CreateGestanteDAO: IGestanteDAO;
    function CreateConsultaDAO: IConsultaDAO;
    function CreateExameDAO: IExameDAO;
  end;

  /// <summary>
  /// Interface para Unit of Work
  /// Gerencia transações e coordena múltiplos DAOs
  /// </summary>
  IUnitOfWork = interface
    ['{03FAF3F6-789A-9012-3456-789012345678}']
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
    function GestanteDAO: IGestanteDAO;
    function ConsultaDAO: IConsultaDAO;
    function ExameDAO: IExameDAO;
  end;

  /// <summary>
  /// Interface para Repository Pattern
  /// Abstrai o acesso aos dados com métodos de alto nível
  /// </summary>
  IGestanteRepository = interface
    ['{14FBF4F7-89AB-0123-4567-89AB01234567}']
    function SalvarGestante(const Gestante: TGestante): Boolean;
    function BuscarGestantePorCPF(const CPF: string): TGestante;
    function BuscarGestantesAtivas: TObjectList<TGestante>;
    function BuscarGestantesPorNome(const Nome: string): TObjectList<TGestante>;
    function ExcluirGestante(const Id: Integer): Boolean;
    function ValidarCPFUnico(const CPF: string; const ExcludeId: Integer = 0): Boolean;
  end;

  /// <summary>
  /// Interface para serviços de relatórios
  /// Abstrai a geração de relatórios e estatísticas
  /// </summary>
  IRelatorioService = interface
    ['{25FCF5F8-9ABC-1234-5678-9ABC12345678}']
    function GerarRelatorioGestantes(const DataInicio, DataFim: TDateTime): TStringList;
    function GerarRelatorioConsultas(const DataInicio, DataFim: TDateTime): TStringList;
    function GerarRelatorioExames(const DataInicio, DataFim: TDateTime): TStringList;
    function GerarEstatisticasGerais: TStringList;
    function GerarRelatorioGestantePorId(const GestanteId: Integer): TStringList;
  end;

  /// <summary>
  /// Interface para validação de dados
  /// Centraliza as regras de validação
  /// </summary>
  IValidationService = interface
    ['{36FDF6F9-ABCD-2345-6789-ABCD23456789}']
    function ValidarGestante(const Gestante: TGestante): TStringList;
    function ValidarConsulta(const Consulta: TConsulta): TStringList;
    function ValidarExame(const Exame: TExame): TStringList;
    function ValidarCPF(const CPF: string): Boolean;
    function ValidarEmail(const Email: string): Boolean;
    function ValidarData(const Data: TDateTime; const PermitirFutura: Boolean = False): Boolean;
  end;

  /// <summary>
  /// Interface para auditoria
  /// Registra operações realizadas no sistema
  /// </summary>
  IAuditoriaService = interface
    ['{47FEF7FA-BCDE-3456-789A-BCDE3456789A}']
    procedure RegistrarOperacao(const Operacao, Tabela: string; const RegistroId: Integer; const Detalhes: string = '');
    procedure RegistrarLogin(const Usuario: string);
    procedure RegistrarLogout(const Usuario: string);
    function ObterHistoricoOperacoes(const DataInicio, DataFim: TDateTime): TStringList;
  end;

implementation

end.

