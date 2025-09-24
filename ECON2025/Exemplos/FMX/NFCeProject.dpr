program NFCeProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'src\View\uMainForm.pas' {MainForm},
  uDMConnection in 'src\DataModule\uDMConnection.pas' ,
  uDMACBr in 'src\DataModule\uDMACBr.pas' ,
  uNFCeEntity in 'src\Domain\Entities\uNFCeEntity.pas',
  uProductEntity in 'src\Domain\Entities\uProductEntity.pas',
  uCustomerEntity in 'src\Domain\Entities\uCustomerEntity.pas',
  uINFCeRepository in 'src\Domain\Interfaces\uINFCeRepository.pas',
  uIProductRepository in 'src\Domain\Interfaces\uIProductRepository.pas',
  uICustomerRepository in 'src\Domain\Interfaces\uICustomerRepository.pas',
  uINFCeService in 'src\Domain\Interfaces\uINFCeService.pas',
  uNFCeRepository in 'src\Infrastructure\Repository\uNFCeRepository.pas',
  uProductRepository in 'src\Infrastructure\Repository\uProductRepository.pas',
  uCustomerRepository in 'src\Infrastructure\Repository\uCustomerRepository.pas',
  uNFCeService in 'src\Application\Services\uNFCeService.pas',
  uNFCeBuilder in 'src\Application\Builders\uNFCeBuilder.pas',
  uDIContainer in 'src\Infrastructure\DI\uDIContainer.pas';

{$R *.res}

begin
  Application.Initialize;
  
  // Registrar dependências antes de criar o formulário
  TDIContainer.RegisterDependencies;
  
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.