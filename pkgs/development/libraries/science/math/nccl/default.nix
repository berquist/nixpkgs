{ lib
, backendStdenv
, fetchFromGitHub
, which
, autoAddOpenGLRunpathHook
, cuda_cccl
, cuda_cudart
, cuda_nvcc
, cudaFlags
, cudaVersion
}:
let
  # Output looks like "-gencode=arch=compute_86,code=sm_86 -gencode=arch=compute_86,code=compute_86"
  gencode = lib.concatStringsSep " " cudaFlags.gencode;
in
backendStdenv.mkDerivation (finalAttrs: {
  name = "nccl-${finalAttrs.version}-cuda-${cudaVersion}";
  version = "2.18.3-1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "nccl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-v4U4IzwiuiYFyFhxVmNOCUmkbSg/AM0QtWPve0ehVhs=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    which
    autoAddOpenGLRunpathHook
    cuda_nvcc
  ];

  buildInputs = [
    cuda_cudart
  ]
  # NOTE: CUDA versions in Nixpkgs only use a major and minor version. When we do comparisons
  # against other version, like below, it's important that we use the same format. Otherwise,
  # we'll get incorrect results.
  # For example, lib.versionAtLeast "12.0" "12.0.0" == false.
  ++ lib.optionals (lib.versionAtLeast cudaVersion "12.0") [
    cuda_cccl
  ];

  preConfigure = ''
    patchShebangs src/collectives/device/gen_rules.sh
    makeFlagsArray+=(
      "NVCC_GENCODE=${gencode}"
    )
  '';

  makeFlags = [
    "CUDA_HOME=${cuda_nvcc}"
    "CUDA_LIB=${lib.getLib cuda_cudart}/lib"
    "CUDA_INC=${lib.getDev cuda_cudart}/include"
    "PREFIX=$(out)"
  ];

  postFixup = ''
    moveToOutput lib/libnccl_static.a $dev
  '';

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-unused-function" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Multi-GPU and multi-node collective communication primitives for NVIDIA GPUs";
    homepage = "https://developer.nvidia.com/nccl";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ mdaiter orivej ];
  };
})
