{ pkgs, ... }:
{
  services.restic.backups = {
    tw-data-gs = {
      passwordFile = "/home/silvio/secrets/backup/restic-backup-tw-data-gs-password";
      s3CredentialsFile = "/home/silvio/secrets/backup/restic-backup-tw-data-gs-vars";
      user = "silvio";
      paths = ["/mnt/data/sync/@tw"];
      repository = "gs:truewealth-ch-restic-backup:";
      extraOptions = ["gs.connections=25"];
      extraBackupArgs = [ "--verbose" ];
      timerConfig = {
        OnCalendar = "hourly";
      };
    };
  };
}
