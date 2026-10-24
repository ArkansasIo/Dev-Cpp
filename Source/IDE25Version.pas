unit IDE25Version;

interface

const
  IDE25_PRODUCT_NAME = 'ArkansasIo IDE';
  IDE25_VERSION = '2.5.0-alpha';
  IDE25_API_VERSION = 250;
  IDE25_BUILD_CHANNEL = 'alpha';

function IDE25VersionString: string;

implementation

function IDE25VersionString: string;
begin
  Result := IDE25_VERSION;
end;

end.
