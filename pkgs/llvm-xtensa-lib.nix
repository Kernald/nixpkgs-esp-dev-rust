{ version ? "17.0.1_20240419"
, hashLinux ? "sha256-oOEVonjgssLp9qhrHrEwlNQpXOB18LnUgUUe5RlU6Sw="
, hashDarwin ? "sha256-rDCsR0Yu5rNkWJN/12PfzApAEvY262hAZ6jlCiHBuZA="
, stdenv
, lib
, fetchurl
, makeWrapper
}:

let
  sources = {
    linux-x86_64 = fetchurl {
      url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/libs-clang-esp-${version}-x86_64-linux-gnu.tar.xz";
      hash = hashLinux;
    };
    darwin-aarch64 = fetchurl {
      url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/libs-clang-esp-${version}-aarch64-apple-darwin.tar.xz";
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

  installPhase = ''
    cp -r . $out
  '';

  meta = with lib; {
    description = "Xtensa LLVM tool chain libraries";
    homepage = "https://github.com/espressif/llvm-project";
    license = licenses.gpl3;
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
  };
}

