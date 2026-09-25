#!/usr/bin/env bash
# ==============================================================================
# Craftsman Skills Installer
# Idempotent, reversible installer for Craftsman agent skills.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="install"
MODE="symlink"
DRY_RUN=false
TARGET_DIR=""
SELECTED_SKILLS=()

# Known platform directories
DEFAULT_PROJECT_DIR="${PWD}/.agents/skills"
HOME_DIR="${HOME:-}"

show_help() {
  cat <<EOF
Craftsman Skills Installer

Usage:
  ./install.sh [options]

Options:
  -t, --target <path>   Explicit destination directory for skills
  -c, --copy            Copy directories instead of creating symlinks (default: symlink)
  -u, --uninstall       Remove installed Craftsman skills from destination
  -d, --dry-run         Print planned actions without modifying filesystem
  -s, --skill <name>    Install specific skill (can be specified multiple times)
  -a, --all             Install all 14 skills (default behavior)
  -h, --help            Show this help message

Examples:
  ./install.sh --target .agents/skills
  ./install.sh --target ~/.claude/skills --copy
  ./install.sh --target .agents/skills --uninstall
  ./install.sh --dry-run
EOF
}

# Discover all skills in repository
discover_skills() {
  local skills=()
  for dir in "${SCRIPT_DIR}"/*/; do
    if [[ -f "${dir}SKILL.md" ]]; then
      skills+=("$(basename "${dir}")")
    fi
  done
  echo "${skills[@]}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      TARGET_DIR="$2"
      shift 2
      ;;
    -c|--copy)
      MODE="copy"
      shift
      ;;
    -u|--uninstall)
      ACTION="uninstall"
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -s|--skill)
      SELECTED_SKILLS+=("$2")
      shift 2
      ;;
    -a|--all)
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option $1" >&2
      show_help
      exit 1
      ;;
  esac
done

ALL_AVAILABLE=($(discover_skills))
if [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
  SELECTED_SKILLS=("${ALL_AVAILABLE[@]}")
fi

# Detect target directory if not explicitly provided
if [[ -z "${TARGET_DIR}" ]]; then
  if [[ -d "${PWD}/.agents" || -f "${PWD}/AGENTS.md" ]]; then
    TARGET_DIR="${DEFAULT_PROJECT_DIR}"
  elif [[ -n "${HOME_DIR}" && -d "${HOME_DIR}/.gemini/config/skills" ]]; then
    TARGET_DIR="${HOME_DIR}/.gemini/config/skills"
  elif [[ -n "${HOME_DIR}" && -d "${HOME_DIR}/.claude/skills" ]]; then
    TARGET_DIR="${HOME_DIR}/.claude/skills"
  elif [[ -n "${HOME_DIR}" && -d "${HOME_DIR}/.cursor/skills" ]]; then
    TARGET_DIR="${HOME_DIR}/.cursor/skills"
  elif [[ -n "${HOME_DIR}" && -d "${HOME_DIR}/.codex/skills" ]]; then
    TARGET_DIR="${HOME_DIR}/.codex/skills"
  else
    TARGET_DIR="${DEFAULT_PROJECT_DIR}"
  fi
fi

echo "================================================================================"
echo "Craftsman Skills Manager"
echo "================================================================================"
echo "Action:       ${ACTION}"
echo "Mode:         ${MODE}"
echo "Dry Run:      ${DRY_RUN}"
echo "Target Dir:   ${TARGET_DIR}"
echo "Skills Count: ${#SELECTED_SKILLS[@]}"
echo "================================================================================"

# Execute Uninstall
if [[ "${ACTION}" == "uninstall" ]]; then
  if [[ ! -d "${TARGET_DIR}" ]]; then
    echo "Notice: Target directory does not exist: ${TARGET_DIR}. Nothing to uninstall."
    exit 0
  fi

  for skill in "${SELECTED_SKILLS[@]}"; do
    dest="${TARGET_DIR}/${skill}"
    if [[ -L "${dest}" || -d "${dest}" ]]; then
      echo "[REMOVE] ${dest}"
      if [[ "${DRY_RUN}" == false ]]; then
        rm -rf "${dest}"
      fi
    else
      echo "[SKIP] ${skill} not found in ${TARGET_DIR}"
    fi
  done
  echo "Uninstall complete."
  exit 0
fi

# Execute Install
if [[ "${DRY_RUN}" == false ]]; then
  mkdir -p "${TARGET_DIR}"
fi

installed_count=0

for skill in "${SELECTED_SKILLS[@]}"; do
  src="${SCRIPT_DIR}/${skill}"
  dest="${TARGET_DIR}/${skill}"

  if [[ ! -d "${src}" ]]; then
    echo "Warning: Source skill directory not found: ${src}. Skipping."
    continue
  fi

  # Avoid self-linking if source equals destination
  if [[ "$(cd -P "${src}" && pwd)" == "$(cd -P "${TARGET_DIR}" 2>/dev/null && pwd)/${skill}" ]]; then
    echo "[IDENTICAL] Source and target are identical for ${skill}. Skipping."
    continue
  fi

  if [[ -e "${dest}" || -L "${dest}" ]]; then
    if [[ -L "${dest}" ]]; then
      current_target="$(readlink "${dest}" || true)"
      if [[ "${current_target}" == "${src}" ]]; then
        echo "[UP-TO-DATE] Symlink already points to source: ${dest}"
        installed_count=$((installed_count + 1))
        continue
      fi
    fi
    echo "[REPLACE] Updating existing installation at: ${dest}"
    if [[ "${DRY_RUN}" == false ]]; then
      rm -rf "${dest}"
    fi
  fi

  if [[ "${MODE}" == "symlink" ]]; then
    echo "[SYMLINK] ${src} -> ${dest}"
    if [[ "${DRY_RUN}" == false ]]; then
      ln -s "${src}" "${dest}"
    fi
  else
    echo "[COPY] ${src} -> ${dest}"
    if [[ "${DRY_RUN}" == false ]]; then
      cp -R "${src}" "${dest}"
    fi
  fi

  installed_count=$((installed_count + 1))
done

echo "--------------------------------------------------------------------------------"
echo "Installation finished. ${installed_count} skills configured in: ${TARGET_DIR}"

if [[ "${DRY_RUN}" == false ]]; then
  echo "Verification: Checking destination validity..."
  for skill in "${SELECTED_SKILLS[@]}"; do
    if [[ -f "${TARGET_DIR}/${skill}/SKILL.md" ]]; then
      echo "  ✓ ${skill} (SKILL.md found)"
    fi
  done
fi
echo "================================================================================"
