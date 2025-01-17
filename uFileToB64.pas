unit uFileToB64;

interface

uses
SysUtils, Classes, Soap.EncdDecd, idCoderMIME, StrUtils, UrlMon;

type
TFileToB64 = Class(TComponent)
private
FNomeArq:      string;
FLoadFromFile: string;
function MimeType(AFileName: string): string;
function DownloadFile(SourceFile: string; DestFile: string = ''; NameFile: string = ''): Boolean;
function ExtLink(substr: string): string;
published

public
function DecodeBase64(ABase64: string; ADest: string = ''; AFileName: string = ''): Boolean;
function LoadFromFile(ASourceFile: string): string;
 constructor Create(AOwner: TComponent); override;
 destructor Destroy; override;
end;

 procedure register;

implementation

{$R .\TFileToB64.dcr}

 procedure register;
 begin
  RegisterComponents('BMCoder', [TFileToB64]);
 end;

constructor TFileToB64.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFileToB64.Destroy;
begin

  inherited;
end;

function TFileToB64.DownloadFile(SourceFile: string; DestFile: string = ''; NameFile: string = ''): Boolean;
begin
  try
   if DestFile = '' then
    DestFile := ExtractFilePath(ParamStr(0));

   if NameFile = '' then
    raise Exception.Create('Informe o NameFile + extens�o do arquivo, Ex: imagem.jpg');

    Result := UrlDownloadToFile(nil, PChar(SourceFile), PChar(DestFile + NameFile),
    0, nil) = 0;
  except
    Result := False;
  end;
end;

function TFileToB64.LoadFromFile(ASourceFile: string): string;
var
  stream:    TFileStream;
  base64:    TIdEncoderMIME;
  output:    string;
  extention: string;
  MimeTypeFile, vType, vDestFile, vNameFile:  string;
begin
  vType := Copy(ASourceFile,1,4);

  if vType = 'http' then
  begin
   extention := ExtLink(ASourceFile);
   vDestFile := ExtractFilePath(ParamStr(0));
   vNameFile := 'file.'+extention;
   DownloadFile(ASourceFile,vDestFile,vNameFile);
  end
  else begin
   extention     := ExtractFileExt(ASourceFile);
   extention     := StringReplace(extention, '.', '',[rfReplaceAll]);
   vNameFile     := ExtractFileName(ASourceFile);
   vDestFile     := ExtractFilePath(ASourceFile);
  end;

  if (FileExists(vDestFile+vNameFile)) then
  begin
    try
     MimeTypeFile  := MimeType(extention);
      begin
        base64 := TIdEncoderMIME.Create(nil);
        stream := TFileStream.Create(vDestFile+vNameFile, fmOpenRead);
        output := TIdEncoderMIME.EncodeStream(stream);
        FreeAndNil(stream);
        FreeAndNil(base64);
        if not(output = '') then
        begin
          Result := MimeTypeFile + output;

          if vType = 'http' then
          DeleteFile(vNameFile);
        end
        else
        begin
          Result := 'Error';
        end;
      end;
    except
      begin
        Result := 'Error'
      end;
    end;
  end
  else
  begin
    Result := 'Error'
  end;
end;

function TFileToB64.MimeType(AFileName: string): string;
 begin
  case AnsiIndexStr(AFileName, ['pdf', 'png','jpg','jpeg','mp4','doc','bmp','ogg','xml']) of
  0 : Result := 'data:application/pdf;base64,';
  1 : Result := 'data:image/png;base64,';
  2 : Result := 'data:image/jpg;base64,';
  3 : Result := 'data:image/jpeg;base64,';
  4 : Result := 'data:video/mp4;base64,';
  5 : Result := 'application/msword;base64,';
  6 : Result := 'data:image/bmp;base64,';
  7 : Result := 'data:application/ogg;base64,';
  8 : Result := 'data:application/xml;base64,';
  end;
 end;

function TFileToB64.ExtLink(substr: string): string;
var ext,urlc: string;
begin
 urlc   :=  ReverseString(substr);
 ext    :=  Copy(urlc,1,Pos('.',urlc)-1);
 result :=  ReverseString(ext);
end;

function TFileToB64.DecodeBase64(ABase64: string; ADest: string = ''; AFileName: string = ''): Boolean;
  var
    Input:    TStringStream;
    Output:   TStringStream;
    vMimeType: string;
  begin
   if ADest = '' then
   ADest := ExtractFilePath(ParamStr(0));

   if AFileName = '' then
   raise Exception.Create('Informe o FileName + extens�o do arquivo, Ex: imagem.jpg');

   vMimeType := MimeType(Copy(AFileName, Pos('.', AFileName) + 1, Length (AFileName)));
   ABase64   := StringReplace(ABase64,vMimeType,'',[rfReplaceAll]);

    Input := TStringStream.Create(ABase64);
    try
      Output := TStringStream.Create(ABase64);
      DecodeStream(Input, Output);
      Output.Position := 0;
      Output.SaveToFile(ADest+AFileName);
      Result := true;
    except
      Result := false;
    end;
    Input.Free;
    Output.Free;
 end;

end.
