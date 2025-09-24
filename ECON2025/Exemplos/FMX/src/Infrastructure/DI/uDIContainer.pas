unit uDIContainer;

interface

uses
  uICustomerRepository,
  uIProductRepository,
  uINFCeRepository,
  uINFCeService,
  uCustomerRepository,
  uProductRepository,
  uNFCeRepository,
  uDMConnection,
  FireDAC.Comp.Client,
  uSimpleContainer;

type
  TDIContainer = class
  private
    class var
      FInstance: TDIContainer;
    class var
      FContainer: uSimpleContainer.TContainer;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance: TDIContainer;
    class procedure RegisterDependencies;
    class function Resolve<T>: T;
    class procedure Release;
  end;

implementation

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo;

class constructor TDIContainer.Create;
begin
  FContainer := uSimpleContainer.TContainer.Create;
  FInstance := nil;
end;

class destructor TDIContainer.Destroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
  if Assigned(FContainer) then
    FContainer.Free;
end;

class function TDIContainer.GetInstance: TDIContainer;
begin
  if not Assigned(FInstance) then
    FInstance := TDIContainer.Create;
  Result := FInstance;
end;

class procedure TDIContainer.RegisterDependencies;
var
  Connection: TFDConnection;
  CustomerRepo: TCustomerRepository;
  ProductRepo: TProductRepository;
  NFCeRepo: TNFCeRepository;
begin
  // Registrar DataModules como Singleton
  FContainer.RegisterInstance<TDMConnection>(TDMConnection.GetInstance);
//  FContainer.RegisterInstance<TDMACBrMock>(TDMACBrMock.GetInstance);

  // Registrar conexão como Singleton
  Connection := TDMConnection.GetInstance.Connection;
  FContainer.RegisterInstance<TFDConnection>(Connection);

  // Criar e registrar repositórios com injeção de dependência
  CustomerRepo := TCustomerRepository.Create(Connection);
  ProductRepo := TProductRepository.Create(Connection);
  NFCeRepo := TNFCeRepository.Create(Connection);

  FContainer.RegisterInstance<TCustomerRepository>(CustomerRepo);
  FContainer.RegisterInstance<TProductRepository>(ProductRepo);
  FContainer.RegisterInstance<TNFCeRepository>(NFCeRepo);

end;

class procedure TDIContainer.Release;
begin
  if Assigned(FContainer) then
    FContainer.Clear;
end;

class function TDIContainer.Resolve<T>: T;
begin
  try
    Result := FContainer.Resolve<T>;
  except
    on E: Exception do
      raise Exception.Create('Erro ao resolver dependência ' + GetTypeName(TypeInfo(T)) + ': ' + E.Message);
  end;
end;

end.

