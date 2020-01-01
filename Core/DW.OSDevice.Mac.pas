unit DW.OSDevice.Mac;

{*******************************************************}
{                                                       }
{                    Kastri Free                        }
{                                                       }
{          DelphiWorlds Cross-Platform Library          }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

interface

uses
  DW.OSDevice;

type
  /// <remarks>
  ///   DO NOT ADD ANY FMX UNITS TO THESE FUNCTIONS
  /// </remarks>
  TPlatformOSDevice = record
  public
    class function GetCurrentLocaleInfo: TLocaleInfo; static;
    class function GetDeviceName: string; static;
    class function GetPackageID: string; static;
    class function GetPackageVersion: string; static;
    class function GetUniqueDeviceID: string; static;
    class function GetUsername: string; static;
    class function IsTouchDevice: Boolean; static;
    class procedure ShowFilesInFolder(const AFileNames: array of string); static;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Mac
  Macapi.CoreFoundation, Macapi.Foundation, Macapi.Helpers, Macapi.IOKit, Macapi.AppKit,
  // DW
  DW.Macapi.IOKit, DW.Macapi.Helpers, DW.Macapi.Foundation;

{ TPlatformOSDevice }

class function TPlatformOSDevice.GetCurrentLocaleInfo: TLocaleInfo;
var
  LLocale: NSLocale;
begin
  LLocale := TNSLocale.Wrap(TNSLocale.OCClass.currentLocale);
  Result.LanguageCode := NSStrToStr(LLocale.languageCode);
  Result.LanguageDisplayName := NSStrToStr(LLocale.localizedStringForLanguageCode(LLocale.languageCode));
  Result.CountryCode := NSStrToStr(LLocale.countryCode);
  Result.CountryDisplayName := NSStrToStr(LLocale.localizedStringForCountryCode(LLocale.countryCode));
  Result.CurrencySymbol := NSStrToStr(LLocale.currencySymbol);
end;

class function TPlatformOSDevice.GetDeviceName: string;
begin
  Result := NSStrToStr(TNSHost.Wrap(TNSHost.OCClass.currentHost).localizedName);
end;

class function TPlatformOSDevice.GetUniqueDeviceID: string;
var
  LService: io_service_t;
  LSerialRef: CFTypeRef;
begin
  Result := '';
  LService := IOServiceGetMatchingService(kIOMasterPortDefault, CFDictionaryRef(IOServiceMatching('IOPlatformExpertDevice')));
  if LService > 0 then
  try
    LSerialRef := IORegistryEntryCreateCFProperty(LService, kIOPlatformSerialNumberKey, kCFAllocatorDefault, 0);
    if LSerialRef <> nil then
      Result := CFStringRefToStr(LSerialRef);
  finally
    IOObjectRelease(LService);
  end;
end;

class function TPlatformOSDevice.GetUsername: string;
begin
  Result := NSStrToStr(TNSString.Wrap(NSUserName));
end;

class function TPlatformOSDevice.IsTouchDevice: Boolean;
begin
  Result := False;
end;

class function TPlatformOSDevice.GetPackageID: string;
begin
  Result := TMacHelperEx.GetBundleValue('CFBundleIdentifier');
end;

class function TPlatformOSDevice.GetPackageVersion: string;
begin
  Result := TMacHelperEx.GetBundleValue('CFBundleVersion');
end;

class procedure TPlatformOSDevice.ShowFilesInFolder(const AFileNames: array of string);
var
  LArray: array of Pointer;
  LNSArray: NSArray;
  I: Integer;
begin
  SetLength(LArray, Length(AFileNames));
  for I := 0 to Length(AFileNames) - 1 do
    LArray[I] := TNSURL.OCClass.fileURLWithPath(StrToNSStr(AFileNames[I]));
  LNSArray := TNSArray.Wrap(TNSArray.OCClass.arrayWithObjects(@LArray[0], Length(LArray)));
  TNSWorkspace.wrap(TNSWorkspace.OCClass.sharedWorkspace).activateFileViewerSelectingURLs(LNSArray);
end;

end.



