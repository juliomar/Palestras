unit uSimpleContainer;

{******************************************************************************
*  Unidade de contêiner de injeção de dependência extremamente simplificada   *
*  Criada apenas para suprir a ausência do framework Spring4D neste exemplo.  *
*  Implementa somente as funcionalidades utilizadas em uDIContainer.pas:       *
*  - TContainer.Create / Free                                                *
*  - RegisterInstance<T>                                                     *
*  - RegisterType<Interface, Implementacao>.AsSingleton                       *
*  - Resolve<T>                                                              *
*  - Clear                                                                   *
******************************************************************************}

interface

uses
  System.Rtti,
  System.Generics.Collections,
  System.SysUtils,
  System.TypInfo,
  FireDAC.Comp.Client;

// Tipo record/"builder" retornado por RegisterType que suporta encadeamento
// de chamada AsSingleton. É somente um wrapping para manter compatibilidade
// com a sintaxe usada no código original.

type
  TRegistrationBuilder = record
  private
    FContainer : TObject;
  public
    constructor Create(AContainer: TObject);
    function AsSingleton: TRegistrationBuilder; // efeito no-op
  end;

  TContainer = class
  private
    // Mapeia tipo (PTypeInfo) para instância já criada
    FInstances : TObjectDictionary<PTypeInfo, TObject>;
    // Mapeia interface (PTypeInfo) para fábrica (TFunc<TObject>)
    FFacts     : TObjectDictionary<PTypeInfo, TFunc<TObject>>;
  public
    constructor Create;
    destructor Destroy; override;

    // Registra instância concreta
    procedure RegisterInstance<T: class>(const AInstance: T);

    // Registra tipo para interface -> implementação
    function RegisterType<TIntf: IInterface; TImpl: class, constructor> : TRegistrationBuilder;

    // Resolve tipo (classe ou interface)
    function Resolve<T>: T;

    // Limpa todos os registros e destrói instâncias criadas
    procedure Clear;
  end;

implementation

{ TRegistrationBuilder }

constructor TRegistrationBuilder.Create(AContainer: TObject);
begin
  FContainer := AContainer;
end;

function TRegistrationBuilder.AsSingleton: TRegistrationBuilder;
begin
  // Para compatibilidade, não é necessário fazer nada, pois todas as
  // instâncias criadas são tratadas como singletons pelo contêiner simples.
  Result := Self;
end;

{ TContainer }

constructor TContainer.Create;
begin
  inherited Create;
  FInstances := TObjectDictionary<PTypeInfo, TObject>.Create([doOwnsValues]);
  FFacts     := TObjectDictionary<PTypeInfo, TFunc<TObject>>.Create;
end;

destructor TContainer.Destroy;
begin
  Clear;
  FFacts.Free;
  FInstances.Free;
  inherited;
end;

procedure TContainer.Clear;
begin
  FInstances.Clear;
  FFacts.Clear;
end;

procedure TContainer.RegisterInstance<T>(const AInstance: T);
begin
  FInstances.AddOrSetValue(TypeInfo(T), TObject(AInstance));
end;

function TContainer.RegisterType<TIntf, TImpl>: TRegistrationBuilder;
begin
  // Armazena fábrica que cria instância de TImpl
  FFacts.AddOrSetValue(TypeInfo(TIntf),
    function: TObject
    begin
      Result := TImpl.Create;
    end);
  Result := TRegistrationBuilder.Create(Self);
end;

function TContainer.Resolve<T>: T;
var
  PInf : PTypeInfo;
  Obj  : TObject;
  Factory : TFunc<TObject>;
begin
  PInf := TypeInfo(T);

  // Verifica se já existe instância
  if FInstances.TryGetValue(PInf, Obj) then
  begin
    Result := TValue.From<TObject>(Obj).AsType<T>;
    Exit;
  end;

  // Caso contrário, procura fábrica registrada
  if FFacts.TryGetValue(PInf, Factory) then
  begin
    Obj := Factory();
    FInstances.AddOrSetValue(PInf, Obj);
    Result := TValue.From<TObject>(Obj).AsType<T>;
    Exit;
  end;

  raise Exception.CreateFmt('Tipo %s não registrado no contêiner.', [PInf^.Name]);
end;

end.