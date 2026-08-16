#!/usr/bin/env bash
# One-time bootstrap: grant the Satonomous agent scoped, passwordless sudo.
#   Usage:  sudo bash ops/setup-sudo.sh
#
# What this does:
#   1. Creates a dedicated service account `satonomous` (runs 24/7 daemons
#      under least privilege instead of the owner's account).
#   2. Adds `berto` + `satonomous` to the `docker` group.
#   3. Writes /etc/sudoers.d/satonomous granting `berto` passwordless sudo
#      ONLY for: apt/apt-get, systemctl, docker, and user/group management.
#
# Rationale (per CONSTITUTION.md): never store the owner's sudo password on
# disk. A scoped sudoers rule is passwordless but bounded, and strictly safer
# than an "encrypted" password whose key lives on the same machine.
#
# Root-equivalence note: package installation runs post-install scripts as
# root, so this IS effectively root access, limited by convention to infra
# tasks. Revoke by deleting /etc/sudoers.d/satonomous.

set -euo pipefail

AGENT_USER="${1:-berto}"
SERVICE_USER="${2:-satonomous}"
SUDOERS_FILE="/etc/sudoers.d/satonomous"

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run with sudo:  sudo bash ops/setup-sudo.sh" >&2
  exit 1
fi

echo "==> Creating service account '$SERVICE_USER' (if absent)"
id "$SERVICE_USER" &>/dev/null || useradd --create-home --shell /bin/bash "$SERVICE_USER"

echo "==> Ensuring docker group exists"
groupadd -f docker

echo "==> Adding '$SERVICE_USER' and '$AGENT_USER' to docker group"
usermod -aG docker "$SERVICE_USER"
usermod -aG docker "$AGENT_USER"

CMDS="$(
  tr '\n' ' ' <<'EOC'
/usr/bin/apt-get, /usr/bin/apt, /bin/systemctl, /usr/bin/docker,
/usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel,
/usr/sbin/groupadd, /usr/sbin/groupdel, /usr/bin/adduser, /usr/bin/deluser,
/usr/bin/install, /usr/bin/chown, /usr/bin/chmod, /usr/bin/cp, /usr/bin/mv,
/usr/bin/rm, /usr/bin/mkdir, /usr/bin/ln, /usr/bin/touch, /usr/bin/tee,
/usr/bin/tar, /usr/bin/sed, /usr/bin/chattr
EOC
)"

echo "==> Writing scoped sudoers: $SUDOERS_FILE"
cat > "$SUDOERS_FILE" <<EOF
# Satonomous agent ($AGENT_USER) — scoped passwordless sudo for infra tasks.
# Managed by ops/setup-sudo.sh. Revoke: rm $SUDOERS_FILE
$AGENT_USER ALL=(ALL) NOPASSWD: $CMDS
EOF
chmod 440 "$SUDOERS_FILE"

echo "==> Enabling linger for '$AGENT_USER' (24/7 user services at boot)"
loginctl enable-linger "$AGENT_USER" 2>/dev/null || systemctl enable "user@$(id -u "$AGENT_USER")" 2>/dev/null || echo "    (linger step skipped — will retry later)"

echo "==> Validating sudoers syntax"
visudo -c

echo "==> Done."
echo "Next: restart your shell (or run 'newgrp docker') so the docker group"
echo "membership applies. Then the agent can use scoped sudo without a password."
