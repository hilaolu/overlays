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

      haskellPackages = prev.haskellPackages.override {
        overrides = self: super: with prev.haskell.lib; {

          xmobar = overrideCabal super.xmobar
            (drv: { doCheck = false;
                    configureFlags = [ "-fwith_utf8" "-fwith_rtsopts" "-fwith_weather"
                                       "-fwith_xft" "-fwith_xpm" ];
                  });

          termonad = let
            rev = "fcfcefec04e7157be8c61a398dd7839d9672abd5";
            src = prev.fetchFromGitHub {
              owner = "cdepillabout";
              repo = "termonad";
              hash = "sha256-Y4Zm+fzyaEaybfG2i480jrWRfWmi4/JJ1bZaq3QC1zg=";
              inherit rev;
              extraPostFetch = ''
                (cd $out && patch -p1 -i ${./termonad/disable_alt_num_keys.patch})
              '';
            };
          in overrideSrc (super.callPackage ./termonad {
            inherit (final.pkgs) gtk3;
            inherit (final.pkgs) pcre2;
            vte_291 = final.pkgs.vte;
          }) {
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

      microsoft-edge-stable = prev.callPackage (import ./edge).stable { };
      microsoft-edge-beta = prev.callPackage (import ./edge).beta { };
      microsoft-edge-dev = prev.callPackage (import ./edge).dev { };

      mpv-full = prev.mpv-unwrapped.override {
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

      weechat = prev.weechat.override {
        configure = { availablePlugins, ... }: {
          plugins = builtins.attrValues availablePlugins;
          scripts = [ final.weechatScripts.weechat-matrix ];
        };
      };

      zathura = prev.zathura.override {
        useMupdf = true;
      };
    })
]
