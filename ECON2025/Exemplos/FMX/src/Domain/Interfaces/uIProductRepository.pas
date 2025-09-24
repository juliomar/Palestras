unit uIProductRepository;

interface

uses
  System.Generics.Collections,
  uProductEntity;

type
  IProductRepository = interface
    ['{B33E83A5-AF17-4DF5-A944-D67A2C744AE8}']
    function GetAll: TObjectList<TProductEntity>;
    function GetById(AId: Integer): TProductEntity;
    function GetByCode(const ACode: string): TProductEntity;
    function Search(const ASearchTerm: string): TObjectList<TProductEntity>;
    function Save(AProduct: TProductEntity): Boolean;
    function Update(AProduct: TProductEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function Exists(AId: Integer): Boolean;
    function ExistsByCode(const ACode: string): Boolean;
    function UpdateStock(AProductId: Integer; ANewQuantity: Integer): Boolean;
  end;

implementation

end.

