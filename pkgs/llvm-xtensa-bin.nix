{ version ? "17.0.1_20240419"
, hashLinux ? "sha256-xNS+9AUyt3eQe981zxDZFDKkxrg1HuCiHPMzL8mqvbE="
, hashDarwin ? "sha256-xCLr5sSXGCAg6bueWJb0FdO8djW02ZbH8W+wYBJMKMI="
, stdenv
, lib
, fetchurl
, makeWrapper
, buildFHSUserEnv
}:

let
  fhsEnv = buildFHSUserEnv {
    name = "xtensa-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib libxml2 ];
    runScript = "";
  };
  sources = {
    linux-x86_64 = fetchurl {
      url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/clang-esp-${version}-x86_64-linux-gnu.tar.xz";
      hash = hashLinux;
    };
    darwin-aarch64 = fetchurl {
      url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/clang-esp-${version}-aarch64-apple-darwin.tar.xz";
      hash = hashDarwin;
    };
  };
in

stdenv.mkDerivation rec {
  pname = "xtensa-llvm-toolchain";
  inherit version;

  src = if stdenv.isDarwin then sources.darwin-aarch64 else sources.linux-x86_64;

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase =
    if stdenv.isLinux then ''
      cp -r . $out
      for FILE in $(ls $out/bin); do
        FILE_PATH="$out/bin/$FILE"
        if [[ -x $FILE_PATH && $FILE != *lld* ]]; then
          mv $FILE_PATH $FILE_PATH-unwrapped
          makeWrapper ${fhsEnv}/bin/xtensa-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
        fi
      done
    ''
    else ''
      cp -r . $out
    '';

  meta = with lib; {
    description = "Xtensa LLVM tool chain";
    homepage = "https://github.com/espressif/llvm-project";
    license = licenses.gpl3;
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
  };
}




