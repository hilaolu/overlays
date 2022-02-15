{
  description = "My nix overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/f6ddd55d5f9d5eca08df138c248008c1ba73ecec";
  };

  outputs = { self, nixpkgs }:
    let

      systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      forAllSystems = f: lib.genAttrs systems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = self.overlay;
        }
      );

      derivations = [
        "android-udev-rules"
        "conky-nox"
        "dmenu"
        "dwm"
        "gaupol"
        "github-linguist"
        "klatexformula"
        #"xorg.libX11"
        "haskellPackages.xmobar"
        "haskellPackages.termonad"
        "microsoft-edge-stable"
        "microsoft-edge-beta"
        "microsoft-edge-dev"
        "mpv-full"
        "nixpkgs-manual"
        #"systemd"
        "weechat"
        "zathura"
      ];

      lib = nixpkgs.lib;

      attrList = s: builtins.filter (x: ! builtins.isList x) (builtins.split "\\." s);

      fetchAttr = l: set: let
        attr = builtins.getAttr (builtins.head l) set;
      in if builtins.tail l == []
         then attr
         else fetchAttr (builtins.tail l) attr;

      last = l: if builtins.tail l == []
                then builtins.head l
                else last (builtins.tail l);

    in {

      packages = forAllSystems (system:
        builtins.listToAttrs
          (builtins.map
            (x: if builtins.match ".*\\..*" x != null
                then let l = attrList x;
                     in { name = last l; value = fetchAttr l nixpkgsFor.${system}.pkgs; }
                else { name = x; value = nixpkgsFor.${system}.pkgs.${x}; })
            #(if system == "aarch64-linux" || system == "i686-linux"
            # then builtins.filter (x: x != "haskellPackages.termonad") derivations
            # else derivations)
            derivations
          )
      );

      overlay = import ./overlays.nix;

    };
}
