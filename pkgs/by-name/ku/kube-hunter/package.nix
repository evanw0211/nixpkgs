{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "kube-hunter";
  version = "0.6.8";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "kube-hunter";
    tag = "v${version}";
    sha256 = "sha256-+M8P/VSF9SKPvq+yNPjokyhggY7hzQ9qLLhkiTNbJls=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    netaddr
    netifaces
    requests
    prettytable
    urllib3
    ruamel-yaml
    future
    packaging
    pluggy
    kubernetes
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest-cov-stub
    pytestCheckHook
    requests-mock
  ];

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "dataclasses" "" \
      --replace "kubernetes==12.0.1" "kubernetes"
  '';

  pythonImportsCheck = [
    "kube_hunter"
  ];

  disabledTests = [
    # Test is out-dated
    "test_K8sCveHunter"
  ];

  meta = with lib; {
    description = "Tool to search issues in Kubernetes clusters";
    homepage = "https://github.com/aquasecurity/kube-hunter";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ fab ];
    mainProgram = "kube-hunter";
  };
}
