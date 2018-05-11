{
  users.extraUsers.nixBuild = {
     name = "nixBuild";
     useDefaultShell = true;
     openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDab+n4WtwJIHf2kgGLD7WkXV6pIoC73vFMsIfs1y5vEiDgP/kkjbQZuZN19ptaJRCVCFw7wwX1RHzqm6WLAYNySYvDTGvTqkexEfDH/Lx+d3TiqmAV3kPqtsIdH9Shvr7/4Q+VprkbYabUYTg7s/c5FSDzhfDOXids6Ct2STJfmxFmZRsbo0xAydIhvV8r9aAgLC/uvYIiOMsadWH6cJr3IoyxCaEVNG8mGNITobLVoN0F03r4PqwoyYdFJ4KPYR2WGyAXcw9XeRFIGfjkmlbMH8Xc1tg3HMwTMZcKUlNlnD9tmPWvofZ3n6OwwYcE40+fivHrsVMGmg1X4ZjqOK3OhdTYb0RSqrkd4vm5z+NwLJO4K3sHtMJOwTWmi2yXVeSDf3qd1FdbEgG/0rLRaQI4UjID2uYrXEjmtqk2yLsei1n5aXPcJprrYkT9reab6+4IxIwpjiz+FZw8NoeqkpfjIgzWXu/OyORq3Te22AujcmNSGQ4MFoTUlrfJ5RlTZw1ezECo6aSDnAy99Hq/dIdgi50Ceamx4zLf3IORtbtqqHeID4scDXuEKgS38+bCCuVapTlyMgdBMkEYW0ksIuoEWOoOrvanslYMPVShkhNix6gcSjNI+KgKikvBU34jJwGCABNt5EM9jq5sQ5E/jI7ewlsiQaivb2hxA8Kw6V9I6w== silvio@pocket"];
   };
   nix.trustedUsers = ["nixBuild"];
}
