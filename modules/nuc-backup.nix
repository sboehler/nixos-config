{ pkgs, ... }:
{
  services.restic.backups = {
    maildir-b2 = {
      passwordFile = "/home/silvio/secrets/restic-b2-data";
      s3CredentialsFile = "/home/silvio/secrets/restic-b2-data-credentials";
      user = "silvio";
      paths = ["/home/silvio/mbsync"];
      repository = "b2:restic-smb:maildir";
      extraOptions = ["b2.connections=25"];
      extraBackupArgs = [ "--verbose" ];
      timerConfig = {
        OnCalendar = "hourly";
      };
    };

    repos-b2 = {
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

    repos-disk = {
      passwordFile = "/home/silvio/secrets/restic-b2-data";
      user = "silvio";
      paths = ["/mnt/data/repos"];
      repository = "/mnt/backup/@restic-repos";
      extraBackupArgs = [ "--exclude=/mnt/data/repos/Media"
                          "--verbose" ];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
      };
    };
  };

  systemd.services.restic-backups-repos-disk.unitConfig = {
    ConditionPathIsMountPoint="/mnt/backup";
  };
}
