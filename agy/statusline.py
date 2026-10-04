#!/usr/bin/env python3
"""
Custom StatusLine for Antigravity CLI (agy).
Cross-platform (Linux & Windows).

Layout:
Line 1 (atas) : 🦉 ⚡ <Tokens> (<Pct>%) │ 💎 <Quota>% (<Reset>) │  <GitBranch>
Line 2 (bawah): a modula project crafted with <3 by parikesitad-pm support by Gemini 3.8 • <effort>
"""

import sys
import json
import re
import os
import subprocess

# Ensure UTF-8 output on Windows terminals
if sys.platform == "win32" and hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

def strip_ansi(s: str) -> str:
    return re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", s)

def fmt_tokens(n) -> str:
    if not isinstance(n, (int, float)):
        return "0"
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}k"
    return str(int(n))

def get_git_info(cwd: str) -> str:
    if not cwd or not os.path.exists(cwd):
        return ""
    try:
        res = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=0.15
        )
        if res.returncode != 0:
            return ""
        branch = res.stdout.strip()
        if not branch or branch == "HEAD":
            return ""

        status_res = subprocess.run(
            ["git", "-C", cwd, "status", "--porcelain"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=0.15
        )
        is_dirty = bool(status_res.stdout.strip())
        return f"{branch}*" if is_dirty else branch
    except Exception:
        return ""

def format_quota(quota_dict: dict) -> tuple:
    """Returns (percentage_int, reset_time_str) or None."""
    if not isinstance(quota_dict, dict):
        return None
    # Prefer gemini-5h, fallback to 3p-5h or any 5h quota
    target = quota_dict.get("gemini-5h") or quota_dict.get("3p-5h")
    if not target:
        for k, v in quota_dict.items():
            if "5h" in k and isinstance(v, dict):
                target = v
                break
    if not target:
        return None

    rem_pct = int(target.get("remaining_fraction", 1.0) * 100)
    secs = target.get("reset_in_seconds", 0)
    h = secs // 3600
    m = (secs % 3600) // 60
    if h > 0:
        time_str = f"{h}j {m}m" if m > 0 else f"{h}j"
    else:
        time_str = f"{m}m" if m > 0 else "0m"

    return rem_pct, time_str

def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except Exception:
        data = {}

    width = data.get("terminal_width") or 104
    cwd = data.get("cwd") or os.getcwd()

    # ANSI Colors
    RESET = "\033[0m"
    DIM = "\033[38;5;244m"
    CYAN = "\033[38;5;81m"
    YELLOW = "\033[38;5;221m"
    MINT = "\033[38;5;48m"
    PINK = "\033[38;5;198m"
    BLUE = "\033[38;5;75m"
    PURPLE = "\033[38;5;141m"
    BOLD_WHITE = "\033[1;37m"

    # 1. Token Stats
    cw = data.get("context_window") or {}
    total_in = cw.get("total_input_tokens", 0)
    total_out = cw.get("total_output_tokens", 0)
    total_all = total_in + total_out
    all_str = fmt_tokens(total_all)
    pct = cw.get("used_percentage", 0.0)
    pct_str = f"{pct:.1f}%"

    # Line 1 parts
    parts = []

    # Owl + Token
    parts.append(f"🦉 {YELLOW}⚡{RESET} {CYAN}{all_str}{RESET} {DIM}({RESET}{YELLOW}{pct_str}{RESET}{DIM}){RESET}")

    # Quota
    quota_res = format_quota(data.get("quota") or {})
    if quota_res:
        rem_pct, time_str = quota_res
        q_color = MINT if rem_pct >= 50 else (YELLOW if rem_pct >= 20 else PINK)
        parts.append(f"{PURPLE}💎{RESET} {q_color}{rem_pct}%{RESET} {DIM}({time_str}){RESET}")

    # Git
    git_branch = get_git_info(cwd)
    if git_branch:
        parts.append(f"{MINT}{RESET} {CYAN}{git_branch}{RESET}")

    # Join Line 1 with separator
    sep = f" {DIM}│{RESET} "
    line1 = sep.join(parts)

    # Line 1 responsive truncation if terminal is very narrow
    if len(strip_ansi(line1)) > width:
        # Drop Git first, then Quota
        parts_compact = [parts[0]]
        if quota_res:
            rem_pct, _ = quota_res
            q_color = MINT if rem_pct >= 50 else (YELLOW if rem_pct >= 20 else PINK)
            parts_compact.append(f"{PURPLE}💎{RESET} {q_color}{rem_pct}%{RESET}")
        line1 = sep.join(parts_compact)
        if len(strip_ansi(line1)) > width:
            line1 = parts[0]

    # 2. Line 2: Branding (responsive to terminal width)
    model_info = data.get("model") or {}
    effort = model_info.get("effort") or "high"

    right_full = f"{BLUE}a modula project{RESET} {DIM}crafted with{RESET} {PINK}<3{RESET} {DIM}by{RESET} {BOLD_WHITE}parikesitad-pm{RESET} {DIM}support by{RESET} {YELLOW}Gemini 3.8{RESET} {DIM}•{RESET} {MINT}{effort}{RESET}"
    right_compact = f"{DIM}crafted with{RESET} {PINK}<3{RESET} {DIM}by{RESET} {BOLD_WHITE}parikesitad-pm{RESET} {DIM}•{RESET} {YELLOW}Gemini 3.8{RESET} {DIM}•{RESET} {MINT}{effort}{RESET}"
    right_minimal = f"{PINK}<3{RESET} {BOLD_WHITE}parikesitad-pm{RESET} {DIM}•{RESET} {YELLOW}Gemini 3.8{RESET}"

    if len(strip_ansi(right_full)) <= width:
        line2 = right_full
    elif len(strip_ansi(right_compact)) <= width:
        line2 = right_compact
    else:
        line2 = right_minimal

    sys.stdout.write(f"{line1}\n{line2}")
    sys.stdout.flush()

if __name__ == "__main__":
    main()
