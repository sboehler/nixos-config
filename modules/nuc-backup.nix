{ pkgs, ... }:
{
  services.restic.backups = {
    b2_data_backup = {
      passwordFile = "/home/silvio/secrets/restic-b2-data";
      s3CredentialsFile = "/home/silvio/secrets/restic-b2-data-credentials";
      user = "silvio";
      paths = ["/mnt/data/repos"];
      repository = "b2:restic-smb:repos";
      extraOptions = ["b2.connections=25"];
      extraBackupArgs = [ "--exclude=/mnt/data/repos/Media"
                          "--verbose" ];
      timerConfig = {
        OnCalendar = "hourly";
      };
    };
  };
}
