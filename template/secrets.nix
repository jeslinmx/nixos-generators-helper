let
  users = {
    user1 = "ssh-ed25519 ...";
    user2 = "ssh-ed25519 ...";
  };
  systems = {
    system1 = "ssh-ed25519 ...";
    system2 = "ssh-ed25519 ...";
  };
in
{
  "secret1.age".publicKeys = [ users.user1 systems.system1 ];
  "secret2.age".publicKeys = builtins.attrValues (users // systems);
}
