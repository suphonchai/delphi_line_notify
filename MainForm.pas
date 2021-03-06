unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TFormMain = class(TForm)
    EditMessage: TEdit;
    ComboStickerPack: TComboBox;
    ComboStickerID: TComboBox;
    ButtonSend: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditToken: TEdit;
    Label4: TLabel;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure ButtonSendClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ClearScreen;
    procedure SendMessage(const AMsg: string;const AStickerPackID: string;const AStickerID: string);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

const
  MESSAGE_FORMAT = 'message=%s&stickerPackageId=%s&stickerId=%s';
  API_URL = 'https://notify-api.line.me/api/notify';
  CONTENT_TYPE = 'application/x-www-form-urlencoded';

{$R *.dfm}

procedure TFormMain.ButtonSendClick(Sender: TObject);
begin
  SendMessage(EditMessage.Text,ComboStickerPack.Text,ComboStickerID.Text);
end;

procedure TFormMain.ClearScreen;
var
  count: Integer;
begin
  EditMessage.Clear;

  with ComboStickerPack do
  begin
    Items.Clear;
    count := 1;
    while count <= 3 do
    begin
      Items.Add(IntToStr(count));
      Inc(count);
    end;
  end;

  with ComboStickerID do
  begin
    Items.Clear;
    count := 1;
    while count <= 632 do
    begin
      Items.Add(IntToStr(count));
      Inc(count);
    end;
  end;

  EditToken.SetFocus;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ClearScreen;
end;

procedure TFormMain.SendMessage(const AMsg: string;const AStickerPackID: string;const AStickerID: string);
var
  Response: string;
  StringStream: TStringStream;
  Msg: string;
  HTTPClient: TIdHTTP;
  Handler: TIdSSLIOHandlerSocketOpenSSL;
begin

  Msg := Format(MESSAGE_FORMAT,[AMsg,AStickerPackID,AStickerID]);
  StringStream := TStringStream.Create(Msg,TEncoding.UTF8);

  try
    HttpClient := TIdHTTP.Create();
    Handler := TIdSSLIOHandlerSocketOpenSSL.Create(HTTPClient);
    HTTPClient.IOHandler := Handler;
    try
      with HttpClient do
      begin
        HandleRedirects := True;
        Request.Method := 'POST';
        Request.ContentType := CONTENT_TYPE;
        Request.CustomHeaders.FoldLines := False;
        Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + EditToken.Text);
      end;
      Response := HTTPClient.Post(API_URL, StringStream);

    finally
      HTTPClient.Free;
    end;
  finally
    StringStream.Free;
  end;

end;

end.
