{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, numpy
, packaging
, periodictable
, scipy
}:

buildPythonPackage rec {
  pname = "cclib";
  version = "1.8";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "cclib";
    repo = "cclib";
    rev = "refs/tags/v${version}";
    hash = "sha256-LPOBErbYQVrTnWphGYjNEftfM+sJNGZmqHJjvrqWFOA=";
  };

  propagatedBuildInputs = [
    numpy
    packaging
    periodictable
    scipy
  ];

  pythonImportsCheck = [
    "cclib"
  ];

  meta = with lib; {
    description = "Parsers and algorithms for computational chemistry";
    longDescription = ''
      Cclib is a Python library that provides parsers for computational
      chemistry log files. It also provides a platform to implement
      algorithms in a package-independent manner.
    '';
    homepage = "https://cclib.github.io";
    changelog = "https://github.com/cclib/cclib/releases/tag/${src.rev}";
    license = licenses.bsd3;
    maintainers = with maintainers; [ berquist ];
  };
}
