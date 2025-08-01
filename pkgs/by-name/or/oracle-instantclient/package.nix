{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  fixDarwinDylibNames,
  unzip,
  _7zz,
  libaio,
  makeWrapper,
  odbcSupport ? true,
  unixODBC,
}:

assert odbcSupport -> unixODBC != null;

let
  inherit (lib) optional optionals optionalString;

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  # assemble list of components
  components = [
    "basic"
    "sdk"
    "sqlplus"
    "tools"
  ]
  ++ optional odbcSupport "odbc";

  # determine the version number, there might be different ones per architecture
  version =
    {
      x86_64-linux = "21.10.0.0.0";
      aarch64-linux = "19.10.0.0.0";
      x86_64-darwin = "19.8.0.0.0";
      aarch64-darwin = "23.3.0.23.09";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  directory =
    {
      x86_64-linux = "2110000";
      aarch64-linux = "191000";
      x86_64-darwin = "198000";
      aarch64-darwin = "233023";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  # hashes per component and architecture
  hashes =
    {
      x86_64-linux = {
        basic = "sha256-uo0QBOmx7TQyroD+As60IhjEkz//+0Cm1tWvLI3edaE=";
        sdk = "sha256-TIBFi1jHLJh+SUNFvuL7aJpxh61hG6gXhFIhvdPgpts=";
        sqlplus = "sha256-mF9kLjhZXe/fasYDfmZrYPL2CzAp3xDbi624RJDA4lM=";
        tools = "sha256-ay8ynzo1fPHbCg9GoIT5ja//iZPIZA2yXI/auVExiRY=";
        odbc = "sha256-3M6/cEtUrIFzQay8eHNiLGE+L0UF+VTmzp4cSBcrzlk=";
      };
      aarch64-linux = {
        basic = "sha256-DNntH20BAmo5kOz7uEgW2NXaNfwdvJ8l8oMnp50BOsY=";
        sdk = "sha256-8VpkNyLyFMUfQwbZpSDV/CB95RoXfaMr8w58cRt/syw=";
        sqlplus = "sha256-iHcyijHhAvjsAqN9R+Rxo2R47k940VvPbScc2MWYn0Q=";
        tools = "sha256-4QY0EwcnctwPm6ZGDZLudOFM4UycLFmRIluKGXVwR0M=";
        odbc = "sha256-T+RIIKzZ9xEg/E72pfs5xqHz2WuIWKx/oRfDrQbw3ms=";
      };
      x86_64-darwin = {
        basic = "sha256-V+1BmPOhDYPNXdwkcsBY1MOwt4Yka66/a7/HORzBIIc=";
        sdk = "sha256-D6iuTEQYqmbOh1z5LnKN16ga6vLmjnkm4QK15S/Iukw=";
        sqlplus = "sha256-08uoiwoKPZmTxLZLYRVp0UbN827FXdhOukeDUXvTCVk=";
        tools = "sha256-1xFFGZapFq9ogGQ6ePSv4PrXl5qOAgRZWAp4mJ5uxdU=";
        odbc = "sha256-S6+5P4daK/+nXwoHmOkj4DIkHtwdzO5GOkCCI612bRY=";
      };
      aarch64-darwin = {
        basic = "sha256-G83bWDhw9wwjLVee24oy/VhJcCik7/GtKOzgOXuo1/4=";
        sdk = "sha256-PerfzgietrnAkbH9IT7XpmaFuyJkPHx0vl4FCtjPzLs=";
        sqlplus = "sha256-khOjmaExAb3rzWEwJ/o4XvRMQruiMw+UgLFtsOGn1nY=";
        tools = "sha256-gA+SbgXXpY12TidpnjBzt0oWQ5zLJg6wUpzpSd/N5W4=";
        odbc = "sha256-JzoSdH7mJB709cdXELxWzpgaNTjOZhYH/wLkdzKA2N0=";
      };
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  # rels per component and architecture, optional
  rels =
    {
      aarch64-darwin = {
        basic = "1";
        tools = "1";
      };
    }
    .${stdenv.hostPlatform.system} or { };

  # convert platform to oracle architecture names
  arch =
    {
      x86_64-linux = "linux.x64";
      aarch64-linux = "linux.arm64";
      x86_64-darwin = "macos.x64";
      aarch64-darwin = "macos.arm64";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  shortArch =
    {
      x86_64-linux = "linux";
      aarch64-linux = "linux";
      x86_64-darwin = "mac";
      aarch64-darwin = "mac";
    }
    .${stdenv.hostPlatform.system} or throwSystem;

  suffix =
    {
      aarch64-darwin = ".dmg";
    }
    .${stdenv.hostPlatform.system} or "dbru.zip";

  # calculate the filename of a single zip file
  srcFilename =
    component: arch: version: rel:
    "instantclient-${component}-${arch}-${version}" + (optionalString (rel != "") "-${rel}") + suffix;

  # fetcher for the non clickthrough artifacts
  fetcher =
    srcFilename: hash:
    fetchurl {
      url = "https://download.oracle.com/otn_software/${shortArch}/instantclient/${directory}/${srcFilename}";
      sha256 = hash;
    };

  # assemble srcs
  srcs = map (
    component:
    (fetcher (srcFilename component arch version rels.${component} or "") hashes.${component} or "")
  ) components;

  isDarwinAarch64 = stdenv.hostPlatform.system == "aarch64-darwin";

  pname = "oracle-instantclient";
  extLib = stdenv.hostPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation {
  inherit pname version srcs;

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
  ]
  ++ optional stdenv.hostPlatform.isLinux libaio
  ++ optional odbcSupport unixODBC;

  nativeBuildInputs = [
    makeWrapper
    (if isDarwinAarch64 then _7zz else unzip)
  ]
  ++ optional stdenv.hostPlatform.isLinux autoPatchelfHook
  ++ optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  unpackCmd = if isDarwinAarch64 then "7zz x $curSrc -aoa -oinstantclient" else "unzip $curSrc";

  installPhase = ''
    mkdir -p "$out/"{bin,include,lib,"share/java","share/${pname}-${version}/demo/"} $lib/lib
    install -Dm755 {adrci,genezi,uidrvci,sqlplus,exp,expdp,imp,impdp} $out/bin

    # cp to preserve symlinks
    cp -P *${extLib}* $lib/lib

    install -Dm644 *.jar $out/share/java
    install -Dm644 sdk/include/* $out/include
    install -Dm644 sdk/demo/* $out/share/${pname}-${version}/demo

    # provide alias
    ln -sfn $out/bin/sqlplus $out/bin/sqlplus64
  '';

  postFixup = optionalString stdenv.hostPlatform.isDarwin ''
    for exe in "$out/bin/"* ; do
      if [ ! -L "$exe" ]; then
        install_name_tool -add_rpath "$lib/lib" "$exe"
      fi
    done
  '';

  meta = with lib; {
    description = "Oracle instant client libraries and sqlplus CLI";
    longDescription = ''
      Oracle instant client provides access to Oracle databases (OCI,
      OCCI, Pro*C, ODBC or JDBC). This package includes the sqlplus
      command line SQL client.
    '';
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with maintainers; [ dylanmtaylor ];
    hydraPlatforms = [ ];
  };
}
