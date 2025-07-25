{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "snallygaster";
  version = "0.0.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hannob";
    repo = "snallygaster";
    tag = "v${version}";
    hash = "sha256-d94Z/vLOcOa9N8WIgCkiZAciNUzdI4qbGXQOc8KNDEE=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    beautifulsoup4
    dnspython
    urllib3
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTestPaths = [
    # we are not interested in linting the project
    "tests/test_codingstyle.py"
  ];

  meta = with lib; {
    description = "Tool to scan for secret files on HTTP servers";
    homepage = "https://github.com/hannob/snallygaster";
    license = licenses.bsd0;
    maintainers = with maintainers; [ fab ];
    mainProgram = "snallygaster";
  };
}
