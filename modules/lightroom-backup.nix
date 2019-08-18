{ pkgs, ... }:
{
  services.restic.backups = {
    pictures-b2 = {
      passwordFile = "/home/silvio/secrets/restic-b2-data";
      s3CredentialsFile = "/home/silvio/secrets/restic-b2-data-credentials";
      user = "silvio";
      paths = [''"/mnt/pictures-backup/Lightroom CC Pictures XPS 15/Lightroom CC"''];
      repository = "b2:restic-smb:repos";
      extraOptions = ["b2.connections=25"];
      extraBackupArgs = [ "--verbose" ];
    };
  };
  systemd.services.restic-backups-pictures-b2.unitConfig = {
    # ConditionPathIsMountPoint="/mnt/backup";
    After="mnt-pictures\\x2dbackup.mount";
    Requires="mnt-pictures\\x2dbackup.mount";

  };
}
