{
  lib,
  stdenv,
  fetchMavenArtifact,
}:

stdenv.mkDerivation rec {
  pname = "postgresql-jdbc";
  version = "42.6.1";

  src = fetchMavenArtifact {
    artifactId = "postgresql";
    groupId = "org.postgresql";
    hash = "sha256-ywd0/X0JsjniHp0Es3RKQId7/0Y6jVjD9AfPfZdsNVc=";
    inherit version;
  };

  installPhase = ''
    runHook preInstall
    install -m444 -D $src/share/java/*postgresql-${version}.jar $out/share/java/postgresql-jdbc.jar
    runHook postInstall
  '';

  meta = {
    homepage = "https://jdbc.postgresql.org/";
    changelog = "https://github.com/pgjdbc/pgjdbc/releases/tag/REL${version}";
    description = "JDBC driver for PostgreSQL allowing Java programs to connect to a PostgreSQL database";
    license = lib.licenses.bsd2;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.unix;
  };
}
