{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  hatchling,
  hatch-vcs,
  pandas,
  numpy,
  scipy,
  h5py,
  natsort,
  packaging,
  array-api-compat,
  cupy,
  pytest-xdist,
  # loompy,
  zarr,
  joblib,
  scikit-learn,
  openpyxl,
  dask,
  distributed,
  numba,
  boltons,
  awkward,
  pyarrow,
  pytest-mock,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "anndata";
  version = "0.10.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "scverse";
    repo = "anndata";
    rev = "refs/tags/${version}";
    hash = "sha256-F2/m5zXN71oEKnEfQ90KhlpTQqoTS+Vurt1yUrxZj+M=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    pandas
    numpy
    scipy
    h5py
    natsort
    packaging
    array-api-compat
  ];

  optional-dependencies = [ cupy ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    # loompy
    zarr
    scikit-learn
    openpyxl
    joblib
    boltons
    dask
    distributed
    awkward
    pyarrow
    numba
    pytest-mock
  ];

  pythonImportsCheck = [ "array_api_compat" ];
  pytestFlagsArray = [ "-v" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "http://anndata.readthedocs.io";
    changelog = "https://github.com/scverse/anndata/releases/tag/v${version}";
    description = "Annotated data matrices in memory and on disk";
    license = licenses.bsd3;
    maintainers = [ maintainers.berquist ];
  };
}
