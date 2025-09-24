unit uINFCeService;

interface

uses
  System.Generics.Collections,
  uNFCeEntity,
  uProductEntity,
  uCustomerEntity;

type
  INFCeService = interface
    ['{BAB5F969-2BE3-453F-A3AC-CCE5513A2C6F}']
    function CreateNFCe(ACustomer: TCustomerEntity = nil): TNFCeEntity;
    function AddItemToNFCe(ANFCe: TNFCeEntity; AProduct: TProductEntity; AQuantity: Double): Boolean;
    function RemoveItemFromNFCe(ANFCe: TNFCeEntity; AItemIndex: Integer): Boolean;
    function IssueNFCe(ANFCe: TNFCeEntity): Boolean;
    function GeneratePDF(ANFCe: TNFCeEntity): string;
    function CancelNFCe(ANFCe: TNFCeEntity): Boolean;
    function GetNFCeList: TObjectList<TNFCeEntity>;
    function GetNFCeById(AId: Integer): TNFCeEntity;
    function ValidateNFCe(ANFCe: TNFCeEntity): string;
  end;

implementation

end.

