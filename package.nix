{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dokieli";
  version = "0-unstable-2024-08-10";

  src = fetchFromGitHub {
    owner = "linkeddata";
    repo = "dokieli";
    rev = "a5624b2ae9db124501812e3ba56ced44553b58e5";
    hash = "sha256-eoEoztjfEFLvRVqwgLkRH6O3tD6LT1G+FKkmywmbf0g=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-IeW86K3HrtajxJxqo37gxCjb2BrV8rlZTrP35z1ihv4=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp *.html $out/share/
    cp extension-*.js $out/share/
    cp manifest.json $out/share/
    cp favicon.ico $out/share/
    cp -r scripts $out/share/
    cp -r media $out/share/

    runHook postInstall
  '';

  meta = {
    description = "Clientside editor for decentralised article publishing, annotations and social interactions";
    homepage = "https://dokie.li/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.feathecutie ];
    platforms = lib.platforms.all;
  };
})
