unit uICustomerRepository;

interface

uses
  System.Generics.Collections,
  uCustomerEntity;

type
  ICustomerRepository = interface
    ['{C1ADB1E4-74D8-4890-8DCB-418F1138EF6A}']
    function GetAll: TObjectList<TCustomerEntity>;
    function GetById(AId: Integer): TCustomerEntity;
    function GetByDocument(const ADocument: string): TCustomerEntity;
    function Save(ACustomer: TCustomerEntity): Boolean;
    function Update(ACustomer: TCustomerEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function Exists(AId: Integer): Boolean;
    function ExistsByDocument(const ADocument: string): Boolean;
  end;

implementation

end.

