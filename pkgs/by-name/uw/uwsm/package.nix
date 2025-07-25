{
  stdenv,
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  meson,
  ninja,
  scdoc,
  pkg-config,
  nix-update-script,
  bash,
  dmenu,
  libnotify,
  newt,
  python3Packages,
  systemd,
  util-linux,
  fumonSupport ? true,
  uuctlSupport ? true,
  uwsmAppSupport ? true,
}:
let
  python = python3Packages.python.withPackages (ps: [
    ps.pydbus
    ps.dbus-python
    ps.pyxdg
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "uwsm";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "uwsm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VQhU88JvL7O2MP41JVuBdieIopmqrNiAWacGWvsNhSc=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    util-linux # waitpid
    newt # whiptail
    libnotify # notify
    bash # sh
    systemd
    python
  ]
  ++ lib.optionals uuctlSupport [ dmenu ];

  mesonFlags = [
    "--prefix=${placeholder "out"}"
    (lib.mapAttrsToList lib.mesonEnable {
      "uwsm-app" = uwsmAppSupport;
      "fumon" = fumonSupport;
      "uuctl" = uuctlSupport;
      "man-pages" = true;
    })
    (lib.mesonOption "python-bin" python.interpreter)
  ];

  postInstall =
    let
      wrapperArgs = "--suffix PATH : ${lib.makeBinPath finalAttrs.buildInputs}";
    in
    ''
      wrapProgram $out/bin/uwsm ${wrapperArgs}
    ''
    + lib.optionalString uuctlSupport ''
      wrapProgram $out/bin/uuctl ${wrapperArgs}
    ''
    + lib.optionalString uwsmAppSupport ''
      wrapProgram $out/bin/uwsm-app ${wrapperArgs}
    ''
    + lib.optionalString fumonSupport ''
      wrapProgram $out/bin/fumon ${wrapperArgs}
    '';

  outputs = [
    "out"
    "man"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal wayland session manager";
    homepage = "https://github.com/Vladimir-csp/uwsm";
    changelog = "https://github.com/Vladimir-csp/uwsm/releases/tag/v${finalAttrs.version}";
    mainProgram = "uwsm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      johnrtitor
      kai-tub
    ];
    platforms = lib.platforms.linux;
  };
})
