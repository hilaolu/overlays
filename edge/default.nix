{
  beta = import ./browser.nix {
    channel = "beta";
    version = "100.0.1185.10";
    revision = "1";
    sha256 = "sha256:17cyp8r36g1ahbf8f25s2w8j7p2qyjmy79kypfqd5zadz93ngg2b";
  };
  dev = import ./browser.nix {
    channel = "dev";
    version = "101.0.1193.0";
    revision = "1";
    sha256 = "sha256:1yhk7ir0gwabw05knh6k7w6b8wf8l4l14f56gl5nqh7ggkzrif02";
  };
  stable = import ./browser.nix {
    channel = "stable";
    version = "99.0.1150.46";
    revision = "1";
    sha256 = "sha256:0w3155i4di8c40pzxj2lb9pjarz7lvif55z8qbnchci0wgmpp5sq";
  };
}
