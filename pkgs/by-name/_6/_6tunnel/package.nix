{
  stdenv,
  lib,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "6tunnel";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "wojtekka";
    repo = "6tunnel";
    rev = version;
    sha256 = "0zsx9d6xz5w8zvrqsm8r625gpbqqhjzvjdzc3z8yix668yg8ff8h";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Tunnelling for application that don't speak IPv6";
    mainProgram = "6tunnel";
    homepage = "https://github.com/wojtekka/6tunnel";
    changelog = "https://github.com/wojtekka/6tunnel/blob/${version}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Br1ght0ne ];
    platforms = lib.platforms.unix;
  };
}
