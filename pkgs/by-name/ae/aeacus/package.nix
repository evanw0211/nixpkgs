{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "aeacus";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "elysium-suite";
    repo = "aeacus";
    tag = "v${version}";
    hash = "sha256-LMsfogcz3CoShQDqyshMshb+iz2r0k5I7NDLXevMakI=";
  };

  vendorHash = "sha256-WOXOM08UYECdGx+e54n4BgLP3cr+st3qKi8iQXebPvk=";

  ldflags = [
    "-s"
    "-w"
  ];

  # Tests require network access
  doCheck = false;

  meta = {
    description = "Vulnerability remediation scoring system";
    homepage = "https://github.com/elysium-suite/aeacus";
    changelog = "https://github.com/elysium-suite/aeacus/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aeacus";
    platforms = lib.platforms.linux;
  };
}
