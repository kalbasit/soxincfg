{
  coreutils,
  git,
  inetutils,
  libnotify,
  writeShellScript,
  yl_home
}:

let
  # TODO: Add support for macOS
  notifySuccess = ''
    ${libnotify}/bin/notify-send -u low "Obsidian Auto Backup" "Obsidian auto backup succeeded"
  '';

  # TODO: Add support for macOS
  notifyFailure = ''
    ${libnotify}/bin/notify-send -u critical "Obsidian Auto Backup" "Obsidian auto backup failed, check the logs"
  '';
in
writeShellScript "auto-backup-obsidian-vaults.sh" ''
  set -euo pipefail

  if ! test -d ~/SynologyDrive/Obsidian
  then
    exit 0
  fi

  cd ~/SynologyDrive/Obsidian

  GIT_AUTHOR_NAME="Wael Nasreddine"
  GIT_AUTHOR_EMAIL="wael.nasreddine+$(${inetutils}/bin/hostname)@gmail.com"
  GIT_SSH_COMMAND='ssh -i "${yl_home}/.ssh/per-host/github.com_obsidian_vaults_deploy_key_ed25519" -o IdentitiesOnly=yes -o ControlPath=/dev/null -o ControlMaster=no -o ControlPersist=no'
  export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_SSH_COMMAND

  status=

  for try in $(${coreutils}/bin/seq 1 5)
  do
    ${git}/bin/git add -A .

    if ! ${git}/bin/git commit --no-gpg-sign -m 'Auto-Backup from user agent auto-backup-obsidian-vaults'
    then
      status=empty
      break
    fi

    if ${git}/bin/git push origin main
    then
      status=success
      break
    fi

    status=failure
    sleep 5m
  done

  if [[ "$status" == "success" ]]
  then
    ${notifySuccess}
  elif [[ "$status" == "failure" ]]
  then
    ${notifyFailure}
  elif [[ "$status" == "empty" ]]
  then
    echo "Nothing to commit"
  fi
''
