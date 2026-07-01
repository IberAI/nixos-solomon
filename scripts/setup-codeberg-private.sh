#!/usr/bin/env bash
set -Eeuo pipefail

MANAGED_BEGIN="# BEGIN setup-codeberg-private"
MANAGED_END="# END setup-codeberg-private"

usage() {
  cat <<'USAGE'
Usage:
  scripts/setup-codeberg-private [options]

Required unless provided by environment variables:
  --name "Your Name"          Git commit name            env: GIT_NAME
  --codeberg-user USER        Codeberg username          env: CODEBERG_USER

Options:
  --email EMAIL               Git commit email           env: GIT_EMAIL
                              default: USER@noreply.codeberg.org
  --repo REPO                 Codeberg repository name   env: CODEBERG_REPO
                              default: current repo directory name
  --key-path PATH             SSH private key path       env: KEY_PATH
                              default: ~/.ssh/id_ed25519_codeberg
  --force                     Update/overwrite managed local config after backup
  --no-key                    Do not create an SSH key
  -h, --help                  Show this help

Examples:
  scripts/setup-codeberg-private --name "Solomon" --codeberg-user solomon
  scripts/setup-codeberg-private --name "Solomon" --codeberg-user solomon --repo nixos
  scripts/setup-codeberg-private --name "Solomon" --codeberg-user solomon --email solomon@noreply.codeberg.org
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

info() {
  echo "==> $*"
}

warn() {
  echo "warning: $*" >&2
}

need_arg() {
  local option="$1"
  local value="${2:-}"

  [[ -n "$value" && "${value:0:1}" != "-" ]] || die "$option requires a value"
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile_file="$repo_root/lib/profile.nix"

git_name="${GIT_NAME:-}"
codeberg_user="${CODEBERG_USER:-}"
git_email="${GIT_EMAIL:-}"
repo_name="${CODEBERG_REPO:-$(basename "$repo_root")}"
key_path="${KEY_PATH:-~/.ssh/id_ed25519_codeberg}"
force=0
create_key=1

while [[ $# -gt 0 ]]; do
  case "$1" in
  --name)
    need_arg "$1" "${2:-}"
    git_name="$2"
    shift 2
    ;;
  --codeberg-user)
    need_arg "$1" "${2:-}"
    codeberg_user="$2"
    shift 2
    ;;
  --email)
    need_arg "$1" "${2:-}"
    git_email="$2"
    shift 2
    ;;
  --repo)
    need_arg "$1" "${2:-}"
    repo_name="$2"
    shift 2
    ;;
  --key-path)
    need_arg "$1" "${2:-}"
    key_path="$2"
    shift 2
    ;;
  --force)
    force=1
    shift
    ;;
  --no-key)
    create_key=0
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    die "unknown option: $1"
    ;;
  esac
done

[[ -f "$profile_file" ]] || die "missing $profile_file"

need_command awk
need_command grep
need_command install

if [[ "$create_key" -eq 1 ]]; then
  need_command ssh-keygen
fi

extract_private_include() {
  local key="$1"

  awk -v key="$key" '
    /privateIncludes[[:space:]]*=/ { in_block = 1 }

    in_block {
      pattern = "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*\""
      if ($0 ~ pattern) {
        line = $0
        sub(/^[^"]*"/, "", line)
        sub(/";[[:space:]]*$/, "", line)
        print line
        exit
      }
    }

    in_block && /^[[:space:]]*};/ { in_block = 0 }
  ' "$profile_file"
}

expand_path() {
  local path="$1"

  case "$path" in
  "~")
    printf '%s\n' "$HOME"
    ;;
  "~/"*)
    printf '%s/%s\n' "$HOME" "${path#\~/}"
    ;;
  '$HOME'/*)
    printf '%s/%s\n' "$HOME" "${path#\$HOME/}"
    ;;
  "${HOME}/"*)
    printf '%s\n' "$path"
    ;;
  /*)
    printf '%s\n' "$path"
    ;;
  *)
    printf '%s/%s\n' "$repo_root" "$path"
    ;;
  esac
}

backup_file() {
  local file="$1"

  if [[ -e "$file" ]]; then
    local backup="${file}.bak.$(date +%Y%m%d-%H%M%S)"
    cp -p "$file" "$backup"
    info "backed up $file -> $backup"
  fi
}

prompt_if_empty() {
  local var_name="$1"
  local label="$2"
  local default_value="$3"
  local current_value="${!var_name:-}"

  if [[ -n "$current_value" ]]; then
    return
  fi

  if [[ ! -t 0 ]]; then
    die "$label is required; pass it as an option or environment variable"
  fi

  local answer
  read -r -p "$label [$default_value]: " answer
  printf -v "$var_name" '%s' "${answer:-$default_value}"
}

validate_inputs() {
  [[ -n "$git_name" ]] || die "Git name cannot be empty"
  [[ -n "$codeberg_user" ]] || die "Codeberg username cannot be empty"
  [[ -n "$git_email" ]] || die "Git email cannot be empty"
  [[ -n "$repo_name" ]] || die "repository name cannot be empty"
  [[ -n "$key_path" ]] || die "key path cannot be empty"

  [[ "$codeberg_user" != */* ]] || die "Codeberg username must not contain '/'"
  [[ "$repo_name" != */* ]] || die "repository name must not contain '/'"
  [[ "$git_email" == *@* && "$git_email" != *[[:space:]]* ]] || die "Git email does not look valid: $git_email"
}

write_git_include() {
  local tmp
  tmp="$(mktemp)"

  cat >"$tmp" <<EOF_GIT
[user]
  name = $git_name
  email = $git_email

[commit]
  gpgsign = false

[tag]
  gpgsign = false
EOF_GIT

  if [[ -e "$git_include" && "$force" -eq 0 ]]; then
    if grep -qE 'Your Name|you@example\.com' "$git_include"; then
      backup_file "$git_include"
      install -m 600 "$tmp" "$git_include"
      info "updated placeholder Git local include"
    else
      rm -f "$tmp"
      info "kept existing Git local include: $git_include"
      info "use --force to overwrite it"
      return
    fi
  else
    backup_file "$git_include"
    install -m 600 "$tmp" "$git_include"
    info "wrote Git local include"
  fi

  rm -f "$tmp"
}

build_ssh_block() {
  cat <<EOF_SSH
$MANAGED_BEGIN
Host codeberg.org codeberg
  HostName codeberg.org
  User git
  IdentityFile $key_path_expanded
  IdentitiesOnly yes
  AddKeysToAgent yes
$MANAGED_END
EOF_SSH
}

replace_managed_block() {
  local file="$1"
  local block_file="$2"
  local output="$3"

  awk -v begin="$MANAGED_BEGIN" -v end="$MANAGED_END" -v block_file="$block_file" '
    BEGIN {
      while ((getline line < block_file) > 0) {
        block = block line ORS
      }
      close(block_file)
    }

    $0 == begin {
      printf "%s", block
      in_managed = 1
      next
    }

    $0 == end {
      in_managed = 0
      next
    }

    !in_managed { print }
  ' "$file" >"$output"
}

write_ssh_include() {
  local block tmp
  block="$(mktemp)"
  tmp="$(mktemp)"
  build_ssh_block >"$block"

  if [[ ! -e "$ssh_include" ]]; then
    install -m 600 "$block" "$ssh_include"
    info "wrote SSH local include"
    rm -f "$block" "$tmp"
    return
  fi

  if grep -qF "$MANAGED_BEGIN" "$ssh_include"; then
    backup_file "$ssh_include"
    replace_managed_block "$ssh_include" "$block" "$tmp"
    install -m 600 "$tmp" "$ssh_include"
    info "updated managed Codeberg SSH block"
  elif grep -qE '^Host[[:space:]].*(^|[[:space:]])(codeberg\.org|codeberg)([[:space:]]|$)' "$ssh_include" && [[ "$force" -eq 0 ]]; then
    info "kept existing unmanaged Codeberg SSH block in: $ssh_include"
    info "use --force to prepend this script's managed block"
  else
    backup_file "$ssh_include"
    {
      cat "$block"
      echo
      cat "$ssh_include"
    } >"$tmp"
    install -m 600 "$tmp" "$ssh_include"
    info "prepended managed Codeberg SSH block"
  fi

  rm -f "$block" "$tmp"
}

create_codeberg_key() {
  if [[ "$create_key" -eq 0 ]]; then
    info "skipping SSH key creation because --no-key was set"
    return
  fi

  if [[ -f "$key_path_expanded" ]]; then
    info "SSH key already exists: $key_path_expanded"
    return
  fi

  info "creating SSH key: $key_path_expanded"
  ssh-keygen -t ed25519 -a 100 -C "codeberg-${codeberg_user}@$(hostname)" -f "$key_path_expanded"
  chmod 600 "$key_path_expanded"
  [[ -f "${key_path_expanded}.pub" ]] && chmod 644 "${key_path_expanded}.pub"
}

show_checks() {
  local remote_url="git@codeberg.org:${codeberg_user}/${repo_name}.git"

  echo
  info "resolved Git identity"
  if command -v git >/dev/null 2>&1; then
    git config --global --includes --show-origin --get user.name || warn "Git name is not visible yet; run your Home Manager switch if needed"
    git config --global --includes --show-origin --get user.email || warn "Git email is not visible yet; run your Home Manager switch if needed"
  else
    warn "git is not installed; skipping Git visibility check"
  fi

  echo
  info "resolved SSH config for codeberg.org"
  if command -v ssh >/dev/null 2>&1; then
    ssh -G codeberg.org 2>/dev/null |
      grep -Ei '^(hostname|user|identityfile|identitiesonly|addkeystoagent)' ||
      warn "Codeberg SSH config is not visible yet; run your Home Manager switch if needed"
  else
    warn "ssh is not installed; skipping SSH visibility check"
  fi

  echo
  info "public key to add to Codeberg"
  if [[ -f "${key_path_expanded}.pub" ]]; then
    cat "${key_path_expanded}.pub"
  else
    warn "public key not found: ${key_path_expanded}.pub"
  fi

  echo
  info "Codeberg SSH fingerprints to verify on first connect"
  cat <<'EOF_FP'
RSA:     SHA256:6QQmYi4ppFS4/+zSZ5S4IU+4sa6rwvQ4PbhCtPEBekQ
ECDSA:   SHA256:T9FYDEHELhVkulEKKwge5aVhVTbqCW0MIRwAfpARs/E
ED25519: SHA256:mIlxA9k46MmM6qdJOdMnAQpzGxF4WIVVL+fj+wZbw0g
EOF_FP

  echo
  info "next steps"
  cat <<EOF_NEXT
1. Add the public key above to Codeberg:
   Codeberg -> Settings -> SSH / GPG Keys -> Add key

2. Test SSH after adding the key:
   ssh -T git@codeberg.org

3. Create the empty private repo on Codeberg first.
   Do not initialize it with README/LICENSE/.gitignore if this local repo already has commits.

4. Set this repo remote:
   cd "$repo_root"
   git remote add origin $remote_url 2>/dev/null || git remote set-url origin $remote_url

5. Push:
   git push -u origin main
EOF_NEXT
}

if command -v git >/dev/null 2>&1; then
  default_name="$(git config --global --get user.name 2>/dev/null || true)"
else
  default_name=""
fi
default_name="${default_name:-${USER:-solomon}}"

prompt_if_empty git_name "Git name" "$default_name"
prompt_if_empty codeberg_user "Codeberg username" "${USER:-solomon}"

if [[ -z "$git_email" ]]; then
  git_email="${codeberg_user}@noreply.codeberg.org"
fi

validate_inputs

git_include_raw="$(extract_private_include git)"
ssh_include_raw="$(extract_private_include ssh)"

[[ -n "$git_include_raw" ]] || die "could not read privateIncludes.git from $profile_file"
[[ -n "$ssh_include_raw" ]] || die "could not read privateIncludes.ssh from $profile_file"

git_include="$(expand_path "$git_include_raw")"
ssh_include="$(expand_path "$ssh_include_raw")"
key_path_expanded="$(expand_path "$key_path")"

info "repo root: $repo_root"
info "Git local include: $git_include"
info "SSH local include: $ssh_include"
info "Codeberg key: $key_path_expanded"
info "Codeberg repo: git@codeberg.org:${codeberg_user}/${repo_name}.git"

mkdir -p "$(dirname "$git_include")" "$(dirname "$ssh_include")" "$(dirname "$key_path_expanded")"
chmod 700 "$(dirname "$key_path_expanded")"

write_git_include
write_ssh_include
create_codeberg_key
show_checks
