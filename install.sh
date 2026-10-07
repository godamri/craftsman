#!/usr/bin/env bash
# ==============================================================================
# Craftsman Skills Installer & IDE Integration Engine
# Bash 3.2+ compatible, non-destructive, ownership-aware lifecycle manager.
# Staged replacement with a documented failure window.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd -P "${PWD}" && pwd)"

STAGE_TEMP_DIRS=()
cleanup_staging() {
  if [[ ${#STAGE_TEMP_DIRS[@]} -gt 0 ]]; then
    for dir in "${STAGE_TEMP_DIRS[@]}"; do [[ -n "${dir}" && -d "${dir}" ]] && rm -rf "${dir}" || true; done
  fi
}
trap cleanup_staging EXIT INT TERM HUP

MARKER_START="<!-- craftsman:start -->"
MARKER_END="<!-- craftsman:end -->"
CANONICAL_ROUTING_PAYLOAD="## Craftsman Engineering Ecosystem

This project enforces engineering discipline through canonical skills located in .agents/skills/.
Always resolve skill paths relative to the repository root.

Before executing modifications, inspect the applicable skill:
- **Execution & Verification**: .agents/skills/execution-craftsman/SKILL.md (Milestone delivery, falsification, regression gates)
- **Scope Discipline**: .agents/skills/scope-guard-craftsman/SKILL.md (Smallest justified change, zero gold-plating)
- **Architecture & Boundaries**: .agents/skills/architecture-craftsman/SKILL.md (State ownership, failure domains)
- **Database & Concurrency**: .agents/skills/database-craftsman/SKILL.md (Transactions, locking, non-blocking DDL)
- **Security & Authorization**: .agents/skills/security-craftsman/SKILL.md (Fail-closed checks, input sanitization)
- **Web & Interface Design**: .agents/skills/web-design-craftsman/SKILL.md (Content-first design, visual hierarchy, light-first default)
- **Digital Artifact Generation**: .agents/skills/gen-craftsman/SKILL.md (Autonomous artifact creation, technical video storytelling)
- **Language Crafts**: .agents/skills/{go,python,react,rust}-craftsman/SKILL.md
- **Infrastructure & Quality**: .agents/skills/{devops,qa,distributed-systems,business}-craftsman/SKILL.md
- **Intake & Skill Orchestration**: .agents/skills/wizard-craftsman/SKILL.md (Transforms ambiguous or multi-domain requests into bounded execution contracts)
- **Adversarial Review** (explicit invocation only — invoke via /contra): .agents/skills/contra-craftsman/SKILL.md (Challenges reasoning, assumptions, scope, and production claims when explicitly requested)

Rules for Agents:
1. Read the relevant SKILL.md before generating architectural or implementation plans.
2. Comply with all prohibitions and release gates defined in the referenced skill.
3. contra-craftsman is INACTIVE unless explicitly invoked with /contra. Do NOT activate it automatically."

generate_payload() {
  local t="${1:-shared}"
  [[ "${t}" == "cursor" ]] && printf -- "---\ndescription: Craftsman Engineering Ecosystem Rules\nglobs: *\nalwaysApply: true\n---\n\n"
  printf -- "%s\n%s\n%s\n" "${MARKER_START}" "${CANONICAL_ROUTING_PAYLOAD}" "${MARKER_END}"
}

generate_receipt() {
  printf -- "{\n  \"schema_version\": 1,\n  \"craftsman\": {\n    \"skill\": \"%s\",\n    \"mode\": \"copy_fallback\"\n  }\n}\n" "$1"
}

show_help() {
  printf -- "Craftsman Skills Installer\nUsage: ./install.sh [options]\nOptions:\n  -t, --target <path>   Target directory (default: .agents/skills)\n  -c, --copy            Copy directories instead of creating symlinks\n  -u, --uninstall       Safely remove installed Craftsman artifacts\n  -d, --dry-run         Print planned actions without modifying filesystem\n  -s, --skill <name>    Install specific skill (repeatable, incompatible with --ide)\n  -a, --all             Install all skills (default behavior)\n      --ide <platform>  Configure IDE (all, cursor, copilot, claude, cline, windsurf, agents)\n  -h, --help            Show this help message\n"
}

discover_skills() {
  local d sk=()
  for d in "${SCRIPT_DIR}"/*/; do [[ -f "${d}SKILL.md" ]] && sk+=("$(basename "${d}")"); done
  [[ ${#sk[@]} -gt 0 ]] && echo "${sk[@]}"
}

lexical_normalize_path() {
  local path="$1"
  while [[ "${path}" == *"//"* ]]; do path="${path//\/\///}"; done
  local oIFS="${IFS}"; IFS="/"; local parts=() part stack=() p
  for part in ${path}; do parts+=("${part}"); done
  IFS="${oIFS}"
  if [[ ${#parts[@]} -gt 0 ]]; then
    for p in "${parts[@]}"; do
      if [[ -z "${p}" || "${p}" == "." ]]; then continue
      elif [[ "${p}" == ".." ]]; then
        if [[ ${#stack[@]} -gt 0 ]]; then
          unset "stack[$((${#stack[@]} - 1))]"
          if [[ ${#stack[@]} -gt 0 ]]; then stack=("${stack[@]}"); else stack=(); fi
        fi
      else stack+=("${p}"); fi
    done
  fi
  local res=""
  if [[ ${#stack[@]} -gt 0 ]]; then for p in "${stack[@]}"; do res="${res}/${p}"; done; fi
  echo "${res:-/}"
}

compute_relative_path() {
  local from to oIFS f_parts=() t_parts=() p i=0 j k rel=""
  from="$(lexical_normalize_path "$1")"; to="$(lexical_normalize_path "$2")"
  oIFS="${IFS}"; IFS="/"
  for p in ${from}; do f_parts+=("${p}"); done
  for p in ${to}; do t_parts+=("${p}"); done
  IFS="${oIFS}"
  while [[ $i -lt ${#f_parts[@]} && $i -lt ${#t_parts[@]} && "${f_parts[$i]}" == "${t_parts[$i]}" ]]; do i=$((i + 1)); done
  j=$i; while [[ $j -lt ${#f_parts[@]} ]]; do rel="${rel}../"; j=$((j + 1)); done
  k=$i; while [[ $k -lt ${#t_parts[@]} ]]; do rel="${rel}${t_parts[$k]}/"; k=$((k + 1)); done
  rel="${rel%/}"; echo "${rel:-.}"
}

verify_symlink_ownership() {
  local dest="$1" exp="$2" raw ref d_dir full p_abs rd re nd ne
  [[ ! -L "${dest}" ]] && return 1
  raw="$(readlink "${dest}")" || return 2
  if [[ -e "${dest}" ]]; then
    ref="${raw}"
    [[ "${raw}" != /* ]] && { d_dir="$(cd -P "$(dirname "${dest}")" 2>/dev/null && pwd)" || return 2; ref="${d_dir}/${raw}"; }
    rd="$(cd -P "$(dirname "${ref}")" 2>/dev/null && pwd)/$(basename "${ref}")" || return 2
    re="$(cd -P "$(dirname "${exp}")" 2>/dev/null && pwd)/$(basename "${exp}")" || return 2
    [[ -n "${rd}" && "${rd}" == "${re}" ]] && return 0 || return 1
  else
    full="${raw}"
    [[ "${raw}" != /* ]] && { p_abs="$(cd -P "$(dirname "${dest}")" 2>/dev/null && pwd)" || return 2; [[ -z "${p_abs}" ]] && return 2; full="${p_abs}/${raw}"; }
    nd="$(lexical_normalize_path "${full}")"; ne="$(lexical_normalize_path "${exp}")"
    [[ -n "${nd}" && "${nd}" == "${ne}" ]] && return 0 || return 1
  fi
}

verify_receipt() {
  local f="$1" sk="$2"
  [[ ! -f "${f}" || ! "${sk}" =~ ^[a-z0-9-]+$ ]] && return 1
  [[ "$(cat "${f}")" == "$(generate_receipt "${sk}")" ]]
}

verify_frontmatter() {
  local f="$1" nm="$2"
  [[ ! -f "${f}" ]] && return 1
  awk -v nm="${nm}" '
    BEGIN { in_fm=0; found=0 }
    NR==1 && /^---[[:space:]]*$/ { in_fm=1; next }
    in_fm && /^---[[:space:]]*$/ { exit !found }
    in_fm && /^name:[[:space:]]*[a-z0-9-]+[[:space:]]*$/ {
      val=$0; sub(/^name:[[:space:]]*/, "", val); sub(/[[:space:]]*$/, "", val);
      if (val == nm) found=1
    }
    END { if (!in_fm) exit 1; exit !found }
  ' "${f}"
}

inventory_tree() {
  local dir="$1" outfile="$2"
  (
    cd -P "${dir}" 2>/dev/null || exit 1
    > "${outfile}"
    while IFS= read -r p; do
      [[ -z "${p}" || "${p}" == "./.craftsman-receipt.json" ]] && continue
      local rel="${p#./}"
      if [[ -L "${p}" ]]; then echo "L:${rel}->$(readlink "${p}")" >> "${outfile}"
      elif [[ -d "${p}" ]]; then echo "D:${rel}" >> "${outfile}"
      elif [[ -f "${p}" ]]; then echo "F:${rel}" >> "${outfile}"
      else echo "X:${rel}" >> "${outfile}"
      fi
    done < <(find . -mindepth 1 | LC_ALL=C sort)
  ) || return 1
}

verify_copy_fallback_integrity() {
  local src="$1" dest="$2" skill="$3" line rel rf tdir s_inv d_inv
  rf="${dest}/.craftsman-receipt.json"
  verify_receipt "${rf}" "${skill}" || return 1
  verify_frontmatter "${dest}/SKILL.md" "${skill}" || return 1

  tdir="$(mktemp -d "${TMPDIR:-/tmp}/craftsman-inv.XXXXXX")" || return 1
  s_inv="${tdir}/s.inv"; d_inv="${tdir}/d.inv"
  if ! inventory_tree "${src}" "${s_inv}" || ! inventory_tree "${dest}" "${d_inv}" || \
     grep -q "^X:" "${s_inv}" || grep -q "^X:" "${d_inv}" || ! cmp -s "${s_inv}" "${d_inv}"; then
    rm -rf "${tdir}"; return 1
  fi
  while IFS= read -r line; do
    if [[ "${line}" == F:* ]]; then
      rel="${line#F:}"
      if ! cmp -s "${src}/${rel}" "${dest}/${rel}"; then rm -rf "${tdir}"; return 1; fi
    fi
  done < "${s_inv}"
  rm -rf "${tdir}"
  return 0
}

# Staged replacement with a documented failure window (non-atomic mv)
stage_and_install_copy() {
  local src="$1" dest="$2" skill="$3" dry="$4" st_p st_d
  [[ "${dry}" == true ]] && { echo "[DRY-RUN COPY] ${src} -> ${dest}"; return 0; }
  st_p="$(mktemp -d "${TMPDIR:-/tmp}/craftsman-stage.XXXXXX")" || return 1
  STAGE_TEMP_DIRS+=("${st_p}")
  st_d="${st_p}/${skill}"
  cp -R "${src}" "${st_d}"; generate_receipt "${skill}" > "${st_d}/.craftsman-receipt.json"
  verify_copy_fallback_integrity "${src}" "${st_d}" "${skill}" || { rm -rf "${st_p}"; return 1; }
  if [[ -e "${dest}" || -L "${dest}" ]]; then
    if [[ -L "${dest}" ]]; then
      verify_symlink_ownership "${dest}" "${src}" || { echo "Error: Destination ${dest} is foreign symlink." >&2; rm -rf "${st_p}"; exit 1; }
      rm -f "${dest}"
    elif [[ -d "${dest}" ]]; then
      verify_copy_fallback_integrity "${src}" "${dest}" "${skill}" || { echo "Error: Destination ${dest} is modified or foreign." >&2; rm -rf "${st_p}"; exit 1; }
      rm -rf "${dest}"
    else
      echo "Error: Destination ${dest} has unverified type." >&2; rm -rf "${st_p}"; exit 1
    fi
  fi
  mkdir -p "$(dirname "${dest}")"; mv "${st_d}" "${dest}"; rm -rf "${st_p}"
}

analyze_marker_state() {
  local f="$1"
  [[ ! -f "${f}" ]] && { echo "ABSENT"; return 0; }
  awk '
    $0 ~ /<!-- craftsman:start -->/ { sc++; sl=NR }
    $0 ~ /<!-- craftsman:end -->/ { ec++; el=NR }
    END {
      if (sc == 0 && ec == 0) print "CLEAN"
      else if (sc == 1 && ec == 1 && sl < el) print "VALID"
      else print "MALFORMED"
    }
  ' "${f}"
}

apply_marker_file() {
  local file="$1" type="$2" dry="$3" st tmp blk
  st="$(analyze_marker_state "${file}")"
  [[ "${st}" == "MALFORMED" ]] && { echo "Error: File ${file} contains malformed markers." >&2; exit 1; }
  [[ "${st}" == "CLEAN" && "${type}" != "shared" ]] && { echo "Error: Dedicated rule ${file} is foreign." >&2; exit 1; }
  [[ "${dry}" == true ]] && { echo "[DRY-RUN] Update ${file}"; return 0; }

  mkdir -p "$(dirname "${file}")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/craftsman-m.XXXXXX")"
  if [[ "${st}" == "ABSENT" ]]; then
    generate_payload "${type}" > "${tmp}"
  elif [[ "${st}" == "CLEAN" ]]; then
    cat "${file}" > "${tmp}"
    [[ -s "${file}" && "$(tail -c 1 "${file}" | wc -l)" -eq 0 ]] && echo "" >> "${tmp}"
    printf "\n" >> "${tmp}"; generate_payload "${type}" >> "${tmp}"
  elif [[ "${st}" == "VALID" ]]; then
    blk="$(mktemp "${TMPDIR:-/tmp}/craftsman-b.XXXXXX")"
    generate_payload "${type}" > "${blk}"
    awk -v blk_f="${blk}" '
      /<!-- craftsman:start -->/ { in_b=1; while ((getline l < blk_f) > 0) print l; close(blk_f); next }
      /<!-- craftsman:end -->/ { in_b=0; next }
      !in_b { print $0 }
    ' "${file}" > "${tmp}"
    rm -f "${blk}"
  fi
  mv "${tmp}" "${file}"
}

remove_marker_file() {
  local file="$1" is_ded="$2" dry="$3" st tmp
  [[ ! -f "${file}" ]] && return 0
  st="$(analyze_marker_state "${file}")"
  [[ "${st}" == "MALFORMED" ]] && { echo "Error: File ${file} contains malformed markers." >&2; exit 1; }
  [[ "${st}" != "VALID" ]] && return 0
  [[ "${dry}" == true ]] && { echo "[DRY-RUN] Remove ${file}"; return 0; }
  if [[ "${is_ded}" == true ]]; then
    rm -f "${file}"; rmdir "$(dirname "${file}")" 2>/dev/null || true
  else
    tmp="$(mktemp "${TMPDIR:-/tmp}/craftsman-s.XXXXXX")"
    awk '/<!-- craftsman:start -->/ { in_b=1; next } /<!-- craftsman:end -->/ { in_b=0; next } !in_b { print $0 }' "${file}" > "${tmp}"
    mv "${tmp}" "${file}"
  fi
}

manage_adapters() {
  local act="$1" ad="$2" dry="$3" def="$4"; shift 4
  local skill_list=("$@") a s link exp dp rel
  for a in ${ad}; do
    for s in "${skill_list[@]}"; do
      link="${PROJECT_ROOT}/${a}/skills/${s}"; exp="${def}/${s}"
      if [[ "${act}" == "uninstall" ]]; then
        if [[ -L "${link}" ]] && verify_symlink_ownership "${link}" "${exp}"; then
          if [[ "${dry}" == true ]]; then
            echo "[DRY-RUN UNLINK] ${link}"
          else
            rm -f "${link}"
          fi
        fi
      else
        if [[ "${dry}" == false ]]; then
          mkdir -p "$(dirname "${link}")"
        fi
        if [[ -d "$(dirname "${link}")" ]]; then
          dp="$(cd -P "$(dirname "${link}")" && pwd)"
        else
          dp="$(lexical_normalize_path "$(dirname "${link}")")"
        fi
        rel="$(compute_relative_path "${dp}" "${exp}")"
        if [[ -L "${link}" ]]; then
          verify_symlink_ownership "${link}" "${exp}" || { echo "Error: Adapter ${link} is foreign symlink." >&2; exit 1; }
        elif [[ -e "${link}" ]]; then
          echo "Error: Adapter path ${link} is foreign file/dir." >&2; exit 1
        fi
        if [[ "${dry}" == false ]]; then
          mkdir -p "${PROJECT_ROOT}/${a}/skills"
          rm -f "${link}" 2>/dev/null || true
          ln -s "${rel}" "${link}"
        fi
      fi
    done
    if [[ "${act}" == "uninstall" && "${dry}" == false ]]; then
      rmdir "${PROJECT_ROOT}/${a}/skills" 2>/dev/null || true
    fi
  done
}

dispatch_ide() {
  local act="$1" ide="$2" dry="$3" def="$4"; shift 4
  local skills=("$@") p
  case "${ide}" in
    cursor)   [[ "${act}" == "install" ]] && apply_marker_file "${PROJECT_ROOT}/.cursor/rules/craftsman.mdc" "cursor" "${dry}" || remove_marker_file "${PROJECT_ROOT}/.cursor/rules/craftsman.mdc" true "${dry}" ;;
    windsurf) [[ "${act}" == "install" ]] && apply_marker_file "${PROJECT_ROOT}/.windsurf/rules/craftsman.md" "windsurf" "${dry}" || remove_marker_file "${PROJECT_ROOT}/.windsurf/rules/craftsman.md" true "${dry}" ;;
    copilot)  [[ "${act}" == "install" ]] && apply_marker_file "${PROJECT_ROOT}/.github/copilot-instructions.md" "shared" "${dry}" || remove_marker_file "${PROJECT_ROOT}/.github/copilot-instructions.md" false "${dry}" ;;
    agents)   [[ "${act}" == "install" ]] && apply_marker_file "${PROJECT_ROOT}/AGENTS.md" "shared" "${dry}" || remove_marker_file "${PROJECT_ROOT}/AGENTS.md" false "${dry}" ;;
    claude)   manage_adapters "${act}" ".claude" "${dry}" "${def}" "${skills[@]}" ;;
    cline)    manage_adapters "${act}" ".cline" "${dry}" "${def}" "${skills[@]}" ;;
    all)      for p in cursor windsurf copilot agents claude cline; do dispatch_ide "${act}" "${p}" "${dry}" "${def}" "${skills[@]}"; done ;;
  esac
}

has_active_ide_integration() {
  local skill="$1" def="$2" f ad link
  for f in "${PROJECT_ROOT}/.cursor/rules/craftsman.mdc" "${PROJECT_ROOT}/.windsurf/rules/craftsman.md" \
           "${PROJECT_ROOT}/AGENTS.md" "${PROJECT_ROOT}/.github/copilot-instructions.md"; do
    [[ -f "${f}" && "$(analyze_marker_state "${f}")" == "VALID" ]] && return 0
  done
  for ad in .claude .cline; do
    link="${PROJECT_ROOT}/${ad}/skills/${skill}"
    [[ -L "${link}" ]] && verify_symlink_ownership "${link}" "${def}/${skill}" && return 0
  done
  return 1
}

install_skill() {
  local src="$1" dest="$2" skill="$3" mode="$4" dry="$5" dp rel
  if [[ "${mode}" == "copy" ]]; then
    [[ -d "${dest}" && ! -L "${dest}" ]] && verify_copy_fallback_integrity "${src}" "${dest}" "${skill}" && { echo "[UP-TO-DATE COPY] ${dest}"; return 0; }
    stage_and_install_copy "${src}" "${dest}" "${skill}" "${dry}"
  else
    if [[ "${dry}" == false ]]; then
      mkdir -p "$(dirname "${dest}")"
    fi
    if [[ -d "$(dirname "${dest}")" ]]; then
      dp="$(cd -P "$(dirname "${dest}")" && pwd)"
    else
      dp="$(lexical_normalize_path "$(dirname "${dest}")")"
    fi
    rel="$(compute_relative_path "${dp}" "${src}")"
    if [[ -L "${dest}" ]]; then
      verify_symlink_ownership "${dest}" "${src}" || { echo "Error: Destination ${dest} is a foreign symlink." >&2; exit 1; }
      if [[ ! -e "${dest}" ]]; then
        echo "[HEAL SYMLINK] ${rel} -> ${dest}"
        if [[ "${dry}" == false ]]; then
          rm -f "${dest}"
          ln -s "${rel}" "${dest}"
        fi
      else
        echo "[UP-TO-DATE SYMLINK] ${dest}"
      fi
    elif [[ -e "${dest}" ]]; then
      if [[ -d "${dest}" ]] && verify_copy_fallback_integrity "${src}" "${dest}" "${skill}"; then
        echo "[UPGRADE TO SYMLINK] ${dest}"
        if [[ "${dry}" == false ]]; then
          rm -rf "${dest}"
          ln -s "${rel}" "${dest}"
        fi
      else
        echo "Error: Destination ${dest} is a foreign directory or file." >&2; exit 1
      fi
    else
      echo "[SYMLINK] ${rel} -> ${dest}"
      if [[ "${dry}" == false ]]; then
        ln -s "${rel}" "${dest}"
      fi
    fi
  fi
}

main() {
  local ACTION="install" MODE="symlink" DRY_RUN=false TARGET_DIR="" SELECTED_SKILLS=() IDE_INTEGRATION=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--target) [[ $# -lt 2 || "$2" == -* ]] && { echo "Error: --target requires path." >&2; exit 1; }; TARGET_DIR="$2"; shift 2 ;;
      -c|--copy) MODE="copy"; shift ;;
      -u|--uninstall) ACTION="uninstall"; shift ;;
      -d|--dry-run) DRY_RUN=true; shift ;;
      -s|--skill) [[ $# -lt 2 || "$2" == -* ]] && { echo "Error: --skill requires name." >&2; exit 1; }; SELECTED_SKILLS+=("$2"); shift 2 ;;
      -a|--all) shift ;;
      --ide) [[ $# -lt 2 || "$2" == -* ]] && { echo "Error: --ide requires platform." >&2; exit 1; }; IDE_INTEGRATION="$2"; shift 2 ;;
      -h|--help) show_help; exit 0 ;;
      *) echo "Error: Unknown option $1" >&2; show_help; exit 1 ;;
    esac
  done

  local ALL_AVAILABLE=($(discover_skills))
  if [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
    local skill avail valid
    for skill in "${SELECTED_SKILLS[@]}"; do
      valid=false
      for avail in "${ALL_AVAILABLE[@]}"; do [[ "${skill}" == "${avail}" ]] && { valid=true; break; }; done
      [[ "${valid}" == false ]] && { echo "Error: Unknown skill '${skill}' requested." >&2; exit 1; }
    done
  else
    SELECTED_SKILLS=("${ALL_AVAILABLE[@]}")
  fi

  if [[ -n "${IDE_INTEGRATION}" ]]; then
    case "${IDE_INTEGRATION}" in
      cursor|copilot|windsurf|claude|cline|agents|all) ;;
      *) echo "Error: Invalid IDE platform '${IDE_INTEGRATION}'." >&2; exit 1 ;;
    esac
  fi

  local DEFAULT_PROJECT_DIR="${PROJECT_ROOT}/.agents/skills" IS_CUSTOM_TARGET=false
  if [[ -n "${TARGET_DIR}" ]]; then
    [[ "${TARGET_DIR}" != /* ]] && TARGET_DIR="${PROJECT_ROOT}/${TARGET_DIR}"
    TARGET_DIR="$(lexical_normalize_path "${TARGET_DIR}")"
    [[ "${TARGET_DIR}" != "$(lexical_normalize_path "${DEFAULT_PROJECT_DIR}")" ]] && IS_CUSTOM_TARGET=true
  else
    TARGET_DIR="${DEFAULT_PROJECT_DIR}"
  fi

  if [[ ${#SELECTED_SKILLS[@]} -ne ${#ALL_AVAILABLE[@]} && -n "${IDE_INTEGRATION}" ]]; then
    echo "Error: --skill cannot be combined with --ide." >&2; exit 1
  fi
  if [[ "${IS_CUSTOM_TARGET}" == true && -n "${IDE_INTEGRATION}" ]]; then
    echo "Error: --ide integrations require the canonical project deployment target (.agents/skills)." >&2; exit 1
  fi

  if [[ "${ACTION}" == "uninstall" ]]; then
    if [[ -n "${IDE_INTEGRATION}" ]]; then
      dispatch_ide "uninstall" "${IDE_INTEGRATION}" "${DRY_RUN}" "${DEFAULT_PROJECT_DIR}" "${SELECTED_SKILLS[@]}"
      echo "IDE uninstallation complete."; exit 0
    fi
    if [[ ${#SELECTED_SKILLS[@]} -ne ${#ALL_AVAILABLE[@]} ]]; then
      for skill in "${SELECTED_SKILLS[@]}"; do
        if has_active_ide_integration "${skill}" "${DEFAULT_PROJECT_DIR}"; then
          echo "Error: Cannot remove single skill '${skill}' while active Craftsman IDE integrations exist in this workspace. Run './install.sh --uninstall --ide all' first." >&2
          exit 1
        fi
      done
    fi
    [[ ! -d "${TARGET_DIR}" && ! -L "${TARGET_DIR}" ]] && { echo "Notice: Target directory does not exist: ${TARGET_DIR}. Nothing to uninstall."; exit 0; }
    for skill in "${SELECTED_SKILLS[@]}"; do
      local dest="${TARGET_DIR}/${skill}" src="${SCRIPT_DIR}/${skill}"
      if [[ -L "${dest}" ]]; then
        verify_symlink_ownership "${dest}" "${src}" || { echo "Error: Symlink at ${dest} is foreign." >&2; exit 1; }
        echo "[REMOVE SYMLINK] ${dest}"
        if [[ "${DRY_RUN}" == false ]]; then
          rm -f "${dest}"
        fi
      elif [[ -d "${dest}" ]]; then
        verify_copy_fallback_integrity "${src}" "${dest}" "${skill}" || { echo "Error: Directory at ${dest} is foreign or modified." >&2; exit 1; }
        echo "[REMOVE COPY] ${dest}"
        if [[ "${DRY_RUN}" == false ]]; then
          rm -rf "${dest}"
        fi
      fi
    done
    if [[ "${DRY_RUN}" == false ]]; then
      rmdir "${TARGET_DIR}" 2>/dev/null || true
    fi
    echo "Canonical uninstallation complete."; exit 0
  fi

  printf -- "================================================================================\nCraftsman Skills Manager\n================================================================================\nSource SSOT:  %s\nTarget Dir:   %s\nMode:         %s\nDry Run:      %s\nSkills:       %s\n" \
    "${SCRIPT_DIR}" "${TARGET_DIR}" "${MODE}" "${DRY_RUN}" "${#SELECTED_SKILLS[@]}"
  if [[ -n "${IDE_INTEGRATION}" ]]; then
    printf -- "IDE:          %s\n" "${IDE_INTEGRATION}"
  fi
  printf -- "================================================================================\n"

  local installed_count=0
  if [[ "${DRY_RUN}" == false ]]; then
    mkdir -p "${TARGET_DIR}"
  fi
  for skill in "${SELECTED_SKILLS[@]}"; do
    local src="${SCRIPT_DIR}/${skill}" dest="${TARGET_DIR}/${skill}"
    if [[ "$(cd -P "${src}" 2>/dev/null && pwd)" == "$(cd -P "${TARGET_DIR}" 2>/dev/null && pwd)/${skill}" ]]; then
      echo "[IDENTICAL] Source and target are identical for ${skill}. Skipping."; continue
    fi
    install_skill "${src}" "${dest}" "${skill}" "${MODE}" "${DRY_RUN}"
    installed_count=$((installed_count + 1))
  done

  if [[ -n "${IDE_INTEGRATION}" ]]; then
    dispatch_ide "install" "${IDE_INTEGRATION}" "${DRY_RUN}" "${DEFAULT_PROJECT_DIR}" "${SELECTED_SKILLS[@]}"
  fi

  echo "--------------------------------------------------------------------------------"
  echo "Installation finished. ${installed_count} skills configured in: ${TARGET_DIR}"
  echo "================================================================================"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
