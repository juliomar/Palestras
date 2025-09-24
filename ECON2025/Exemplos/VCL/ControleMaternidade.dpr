program ControleMaternidade;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  View.Principal in 'View\View.Principal.pas' {frmPrincipal},
  View.CadastroGestante in 'View\View.CadastroGestante.pas' {frmCadastroGestante},
  View.CadastroConsulta in 'View\View.CadastroConsulta.pas' {frmCadastroConsulta},
  View.CadastroExame in 'View\View.CadastroExame.pas' {frmCadastroExame},
  Data.Connection in 'Data\Data.Connection.pas',
  Model.Gestante in 'Model\Model.Gestante.pas',
  Model.Consulta in 'Model\Model.Consulta.pas',
  Model.Exame in 'Model\Model.Exame.pas',
  Interfaces.DAO in 'Interfaces\Interfaces.DAO.pas',
  Data.DAO.Gestante in 'Data\Data.DAO.Gestante.pas',
  Data.DAO.Consulta in 'Data\Data.DAO.Consulta.pas',
  Data.DAO.Exame in 'Data\Data.DAO.Exame.pas',
  Controller.Gestante in 'Controller\Controller.Gestante.pas',
  Controller.Consulta in 'Controller\Controller.Consulta.pas',
  Controller.Exame in 'Controller\Controller.Exame.pas',
  Utils.Validacao in 'Utils\Utils.Validacao.pas',
  Utils.Formatacao in 'Utils\Utils.Formatacao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.