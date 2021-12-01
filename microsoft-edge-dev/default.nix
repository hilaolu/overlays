{ stdenv
, fetchurl
, lib

, binutils-unwrapped
, xz
, gnutar
, file

, glibc
, glib
, nss
, nspr
, atk
, at_spi2_atk
, xorg
, cups
, dbus_libs
, expat
, libdrm
, libxkbcommon
, gnome3
, gnome2
, cairo
, gdk-pixbuf
, mesa
, alsaLib
, at_spi2_core
, libuuid
, systemd
}:

stdenv.mkDerivation rec {
  pname = "microsoft-edge-dev";
  version = "97.0.1072.13";

  src = fetchurl {
    url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-dev/microsoft-edge-dev_${version}-1_amd64.deb";
    hash = "sha256-wgIiL/e3vtVgWqQQfJu5RibRUlzQZbCQQnNRZTYMMcc=";
  };

  unpackCmd = "${binutils-unwrapped}/bin/ar p $src data.tar.xz | ${xz}/bin/xz -dc | ${gnutar}/bin/tar -xf -";
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontPatchELF = true;

  buildPhase = let
    libPath = {
      msedge = lib.makeLibraryPath [
        glibc glib nss nspr atk at_spi2_atk xorg.libX11
        xorg.libxcb cups.lib dbus_libs.lib expat libdrm
        xorg.libXcomposite xorg.libXdamage xorg.libXext
        xorg.libXfixes xorg.libXrandr libxkbcommon
        gnome3.gtk gnome2.pango cairo gdk-pixbuf mesa
        alsaLib at_spi2_core xorg.libxshmfence systemd
      ];
      naclHelper = lib.makeLibraryPath [
        glib nspr atk libdrm xorg.libxcb mesa xorg.libX11
        xorg.libXext dbus_libs.lib libxkbcommon
      ];
      libwidevinecdm = lib.makeLibraryPath [
        glib nss nspr
      ];
      libGLESv2 = lib.makeLibraryPath [
        xorg.libX11 xorg.libXext xorg.libxcb
      ];
      libsmartscreen = lib.makeLibraryPath [
        libuuid stdenv.cc.cc.lib
      ];
      libsmartscreenn = lib.makeLibraryPath [
        libuuid
      ];
      liboneauth = lib.makeLibraryPath [
        libuuid xorg.libX11
      ];
    };
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.msedge}" \
      opt/microsoft/msedge-dev/msedge

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      opt/microsoft/msedge-dev/msedge-sandbox

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      opt/microsoft/msedge-dev/msedge_crashpad_handler

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.naclHelper}" \
      opt/microsoft/msedge-dev/nacl_helper

    patchelf \
      --set-rpath "${libPath.libwidevinecdm}" \
      opt/microsoft/msedge-dev/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so

    patchelf \
      --set-rpath "${libPath.libGLESv2}" \
      opt/microsoft/msedge-dev/libGLESv2.so

    patchelf \
      --set-rpath "${libPath.libsmartscreen}" \
      opt/microsoft/msedge-dev/libsmartscreen.so

    patchelf \
      --set-rpath "${libPath.libsmartscreenn}" \
      opt/microsoft/msedge-dev/libsmartscreenn.so

    patchelf \
      --set-rpath "${libPath.liboneauth}" \
      opt/microsoft/msedge-dev/liboneauth.so
  '';

  installPhase = ''
    mkdir -p $out
    cp -R opt usr/bin usr/share $out

    ln -sf $out/opt/microsoft/msedge-dev/microsoft-edge-dev $out/opt/microsoft/msedge-dev/microsoft-edge
    ln -sf $out/opt/microsoft/msedge-dev/microsoft-edge-dev $out/bin/microsoft-edge-dev

    rm -rf $out/share/doc
    rm -rf $out/opt/microsoft/msedge-dev/cron

    substituteInPlace $out/share/applications/microsoft-edge-dev.desktop \
      --replace /usr/bin/microsoft-edge-dev $out/bin/microsoft-edge-dev

    substituteInPlace $out/share/gnome-control-center/default-apps/microsoft-edge-dev.xml \
      --replace /opt/microsoft/msedge-dev $out/opt/microsoft/msedge-dev

    substituteInPlace $out/share/menu/microsoft-edge-dev.menu \
      --replace /opt/microsoft/msedge-dev $out/opt/microsoft/msedge-dev

    substituteInPlace $out/opt/microsoft/msedge-dev/xdg-mime \
      --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
      --replace "xdg_system_dirs=/usr/local/share/:/usr/share/" "xdg_system_dirs=/run/current-system/sw/share/" \
      --replace /usr/bin/file ${file}/bin/file

    substituteInPlace $out/opt/microsoft/msedge-dev/default-app-block \
      --replace /opt/microsoft/msedge-dev $out/opt/microsoft/msedge-dev

    substituteInPlace $out/opt/microsoft/msedge-dev/xdg-settings \
      --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
      --replace "''${XDG_CONFIG_DIRS:-/etc/xdg}" "''${XDG_CONFIG_DIRS:-/run/current-system/sw/etc/xdg}"
  '';

  meta = with lib; {
    homepage = "https://www.microsoftedgeinsider.com/en-us/";
    description = "Microsoft's fork of Chromium web browser";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [
      { name = "Azure Zanculmarktum";
        email = "zanculmarktum@gmail.com"; }
    ];
  };
}
