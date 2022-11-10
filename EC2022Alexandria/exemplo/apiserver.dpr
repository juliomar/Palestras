program apiserver;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils;

begin
  {$IFDEF MSWINDOWS}
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

//  THorse.Get('/server',
//    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
//    begin
//      Res.Send(format('Servidor %s',[GetEnvironmentVariable('DBSERVER')]));
//    end);

  THorse.Listen(9000,
    procedure(Horse: THorse)
    begin
      Writeln(Format('Servidor rodando em %s:%d', [Horse.Host, Horse.Port]));
      Readln;
    end);
end.