{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "fits-cloudctl";
  version = "0.12.21"; # also update these 3 vars:
  gitversion = "tags/v0.12.21-0-g0a0d89a"; # git describe --long --all
  gitsha = "0a0d89a8"; # git rev-parse --short=8 HEAD
  gittime = "2024-05-15T17:34:46+02:00"; # date --iso-8601=seconds

  src = fetchFromGitHub {
    owner = "fi-ts";
    repo = "cloudctl";
    rev = "v${version}";
    hash = "sha256-O3wX7IW2puMg0xhOf9BUfxzCMCKHxtPJxOCpc+wY0Ao=";
  };

  vendorHash = "sha256-YSWO7Y9qtqCWfAMnzSMOWlXezjnggMLV8xF42vgOS7s=";

  ldflags = [
    "-X github.com/metal-stack/v.Version=${version}"
    "-X github.com/metal-stack/v.Revision=${gitversion}"
    "-X github.com/metal-stack/v.GitSHA1=${gitsha}"
    "-X github.com/metal-stack/v.BuildDate=${gittime}"
  ];

  meta = with lib; {
    description = "Command-line client for FI-TS Finance Cloud Native services";
    homepage = "https://github.com/fi-ts/cloudctl";
    license = licenses.mit;
    maintainers = with maintainers; [ j0xaf ];
    mainProgram = "cloudctl";
  };
}
