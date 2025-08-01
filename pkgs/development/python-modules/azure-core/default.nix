{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  aiodns,
  aiohttp,
  flask,
  mock,
  pytest,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
  requests,
  setuptools,
  six,
  trio,
  typing-extensions,
}:

buildPythonPackage rec {
  version = "1.32.0";
  pname = "azure-core";
  pyproject = true;

  disabled = pythonOlder "3.7";

  __darwinAllowLocalNetworking = true;

  src = fetchPypi {
    pname = "azure_core";
    inherit version;
    hash = "sha256-IrPDXWstrhSZD2wb4pEr8j/+ULIg5wiiirG7krHHMOU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    requests
    six
    typing-extensions
  ];

  optional-dependencies = {
    aio = [ aiohttp ];
  };

  nativeCheckInputs = [
    aiodns
    flask
    mock
    pytest
    pytest-trio
    pytest-asyncio
    pytestCheckHook
    trio
  ]
  ++ lib.flatten (builtins.attrValues optional-dependencies);

  # test server needs to be available
  preCheck = ''
    export PYTHONPATH=tests/testserver_tests/coretestserver:$PYTHONPATH
  '';

  enabledTestPaths = [ "tests/" ];

  # disable tests which touch network
  disabledTests = [
    "aiohttp"
    "multipart_send"
    "response"
    "request"
    "timeout"
    "test_sync_transport_short_read_download_stream"
    "test_aio_transport_short_read_download_stream"
    # disable 8 tests failing on some darwin machines with errors:
    # azure.core.polling.base_polling.BadStatus: Invalid return status 403 for 'GET' operation
    # azure.core.exceptions.HttpResponseError: Operation returned an invalid status 'Forbidden'
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "location_polling_fail" ];

  disabledTestPaths = [
    # requires testing modules which aren't published, and likely to create cyclic dependencies
    "tests/test_connection_string_parsing.py"
    # wants network
    "tests/async_tests/test_streaming_async.py"
    "tests/test_streaming.py"
    # testserver tests require being in a very specific working directory to make it work
    "tests/testserver_tests/"
    # requires missing pytest plugin
    "tests/async_tests/test_rest_asyncio_transport.py"
    # needs msrest, which cannot be included in nativeCheckInputs due to circular dependency new in msrest 0.7.1
    # azure-core needs msrest which needs azure-core
    "tests/test_polling.py"
    "tests/async_tests/test_base_polling_async.py"
    "tests/async_tests/test_polling_async.py"
  ];

  meta = with lib; {
    description = "Microsoft Azure Core Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/core/azure-core";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-core_${version}/sdk/core/azure-core/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
  };
}
