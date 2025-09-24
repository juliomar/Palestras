unit uINFCeRepository;

interface

uses
  System.Generics.Collections,
  uNFCeEntity;

type
  INFCeRepository = interface
    ['{ED01296F-1C68-4394-8003-EFC64924F484}']
    function GetAll: TObjectList<TNFCeEntity>;
    function GetById(AId: Integer): TNFCeEntity;
    function GetByNumber(ANumber: Integer; ASeries: Integer = 1): TNFCeEntity;
    function GetByDateRange(AStartDate, AEndDate: TDateTime): TObjectList<TNFCeEntity>;
    function GetByStatus(AStatus: TNFCeStatus): TObjectList<TNFCeEntity>;
    function Save(ANFCe: TNFCeEntity): Boolean;
    function Update(ANFCe: TNFCeEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function GetNextNumber(ASeries: Integer = 1): Integer;
    function SaveWithItems(ANFCe: TNFCeEntity): Boolean;
    function UpdateStatus(AId: Integer; AStatus: TNFCeStatus): Boolean;
  end;

implementation

end.

