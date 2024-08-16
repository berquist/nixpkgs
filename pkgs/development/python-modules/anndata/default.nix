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
  config,
  cudaSupport ? config.cudaSupport,
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

  optional-dependencies = [ ] ++ lib.optionals cudaSupport [ cupy ];

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
  ] ++ lib.optionals cudaSupport [ cupy ];

  pythonImportsCheck = [ "array_api_compat" ];

  disabledTests = [
    "anndata._core.anndata.AnnData.concatenate"
    "anndata._core.anndata.AnnData.obs_names_make_unique"
    "anndata._core.anndata.AnnData.var_names_make_unique"
    "anndata._core.merge.concat"
    "anndata._core.merge.gen_reindexer"
    "anndata._core.sparse_dataset.sparse_dataset"
    "anndata._io.utils.report_read_key_on_error"
    "anndata._io.utils.report_write_key_on_error"
    "anndata._warnings.ImplicitModificationWarning"
    "anndata.experimental.merge.concat_on_disk"
    "anndata.experimental.multi_files._anncollection.AnnCollection"
    "anndata.utils.make_index_unique"
    "concatenation.rst"
  ];

  # CUDA (used via cupy) is not available in the testing sandbox
  #
  # Only doctests import scanpy, which itself depends on this package, so
  # don't run the few doctests to avoid circular build errors.
  # checkPhase = ''
  #   runHook preCheck
  #   # python -m pytest -v -k "not cupy" --strict-markers --pyargs -ptesting.anndata._pytest
  #   python -m pytest -v
  #   runHook postCheck
  # '';


  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "http://anndata.readthedocs.io";
    changelog = "https://github.com/scverse/anndata/releases/tag/v${version}";
    description = "Annotated data matrices in memory and on disk";
    license = licenses.bsd3;
    maintainers = [ maintainers.berquist ];
  };
}
