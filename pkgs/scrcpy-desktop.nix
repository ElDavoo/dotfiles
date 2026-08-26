{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:
buildNpmPackage {
  pname = "scrcpy-desktop";
  version = "unstable-2025-09-12";

  # Repo è archiviato (nessun commit successivo), quindi fissare l'HEAD di
  # main equivale a una release stabile.
  src = fetchFromGitHub {
    owner = "serifpersia";
    repo = "scrcpy-desktop";
    rev = "09f4fcb57a00da3130764295853aa963aaf1fa30";
    hash = "sha256-Fe5RFISEfNiWktcvM5EQMy9O+b9/0RClT6H+9x0wVEk=";
  };

  npmDepsHash = "sha256-Jm7cHeMKhoPiliqzauk1qbIhiSSpNzYbpClFhSredE4=";

  nativeBuildInputs = [makeWrapper];

  npmBuildScript = "build";

  # Niente campo "bin" in package.json: il progetto è pensato per girare in
  # loco con `npm start` (= node src-server/server.js). Ricostruiamo a mano
  # un layout runtime ed eliminiamo le devDependencies (parcel e affini) usate
  # solo in fase di build.
  installPhase = ''
    runHook preInstall

    npm prune --omit=dev

    mkdir -p $out/share/scrcpy-desktop
    cp -r src-server public/dist node_modules package.json $out/share/scrcpy-desktop/

    makeWrapper ${nodejs}/bin/node $out/bin/scrcpy-desktop \
      --add-flags "$out/share/scrcpy-desktop/src-server/server.js" \
      --chdir "$out/share/scrcpy-desktop"

    runHook postInstall
  '';

  meta = {
    description = "User-friendly web frontend for scrcpy (Android screen mirroring) streamed to the browser";
    homepage = "https://github.com/serifpersia/scrcpy-desktop";
    license = lib.licenses.mit;
    mainProgram = "scrcpy-desktop";
    platforms = lib.platforms.linux;
  };
}
