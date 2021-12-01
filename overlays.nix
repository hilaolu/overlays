[
  ( #self: super:
    final: prev:

    {
      android-udev-rules = prev.android-udev-rules.overrideAttrs (oldAttrs: {
        installPhase = (oldAttrs.installPhase or "") + ''
          sed -i \
            -e 's/ATTR{idVendor}=="2b4c", ENV{adb_user}="yes"/&\n\n# Vivo\nATTR{idVendor}=="2d95", ENV{adb_user}="yes"/' \
            $out/lib/udev/rules.d/51-android.rules
        '';
      });

      conky-nox = prev.conky.override {
        x11Support = false;
      };

      dmenu = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dmenu/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dmenu/patches/${x}") patchFiles;
      in
        prev.dmenu.override {
          inherit patches;
        };

      dwm = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dwm/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dwm/patches/${x}") patchFiles;
      in (prev.dwm.override {
        inherit patches;
      }).overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace dwm.c \
            --replace '@psmisc@' '${final.psmisc}/bin/'
          substituteInPlace config.def.h \
            --replace '@dmenu@' '${final.dmenu}/bin/' \
            --replace '@j4_dmenu_desktop@' '${final.j4-dmenu-desktop}/bin/' \
            --replace '@alacritty@' '${final.alacritty}/bin/'
        '';
      });

      gaupol = prev.callPackage ./gaupol { };

      github-linguist = (import ./github-linguist { nixpkgs = prev; }).github-linguist;

      haskellPackages = (prev.dontRecurseIntoAttrs prev.haskell.packages.ghc8104).override {
        overrides = self: super: with prev.haskell.lib; {

          xmobar = overrideCabal super.xmobar
            (drv: { doCheck = false;
                    configureFlags = [ "-fwith_utf8" "-fwith_rtsopts" "-fwith_weather"
                                       "-fwith_xft" "-fwith_xpm" ];
                  });

          termonad = let
            rev = "d817fe47139d3b39a9c4ec1e4f27ed419214d3b3";
            src = prev.fetchFromGitHub {
              owner = "cdepillabout";
              repo = "termonad";
              hash = "sha256-XIqGM64jQ+lKWcMjisVxeuKRMm2K8zKNiZ1rhdnY8pE=";
              inherit rev;
            };
          in overrideSrc super.termonad {
            inherit src;
            version = builtins.substring 0 7 rev;
          };
          #in overrideCabal (super.callCabal2nix
          #  "termonad"
          #  src
          #  { inherit (prev.pkgs) gtk3;
          #    inherit (prev.pkgs) pcre2;
          #    vte_291 = prev.pkgs.vte;
          #  }
          #) (drv: { version = builtins.substring 0 7 rev; });

        };
      };

      klatexformula = prev.callPackage ./klatexformula { };

      # Fix X11 apps not respecting the cursors.
      # https://github.com/NixOS/nixpkgs/issues/24137
      #xorg =
      #  /*
      #  prev.xorg.overrideScope' (self: super: {
      #    libX11 = super.libX11.overrideAttrs (oldAttrs: {
      #      postPatch = (oldAttrs.postPatch or "") + ''
      #        substituteInPlace src/CrGlCur.c --replace "libXcursor.so.1" "${self.libXcursor}/lib/libXcursor.so.1"
      #      '';
      #    });
      #  });
      #  */
      #  prev.xorg // {
      #    libX11 = prev.xorg.libX11.overrideAttrs (oldAttrs: {
      #      postPatch = (oldAttrs.postPatch or "") + ''
      #        substituteInPlace src/CrGlCur.c --replace "libXcursor.so.1" "${final.xorg.libXcursor}/lib/libXcursor.so.1"
      #      '';
      #    });
      #  };

      microsoft-edge-dev = prev.callPackage ./microsoft-edge-dev { };

      mpv-full = prev.callPackage (prev.path + "/pkgs/applications/video/mpv") {
        inherit (prev) lua;
        inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation Cocoa CoreAudio MediaPlayer;
        ffmpeg = prev.ffmpeg-full;
      };

      nix-index = prev.nix-index.override {
        nix = final.nixFlakes;
      };

      nixpkgs-manual = prev.callPackage (prev.path + "/doc") { };

      #systemd = prev.systemd.overrideAttrs (oldAttrs: {
      #  mesonFlags = oldAttrs.mesonFlags ++ [ "-Ddns-servers=''" ];
      #});

      zathura = prev.zathura.override {
        useMupdf = true;
      };
    })
]
