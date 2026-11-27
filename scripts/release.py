#!/usr/bin/env python3
"""Bump package version across typst.toml, templates, and docs, then commit and tag."""

import argparse
import datetime
import os
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
REPO_URL = "https://github.com/beauloxe/typst-nure-template"


def run(cmd: list[str], *, cwd: Path, env: dict[str, str] | None = None, capture: bool = False) -> str:
    res = subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=capture)
    if res.returncode != 0:
        if capture and res.stderr:
            sys.stderr.write(res.stderr)
        sys.exit(res.returncode)
    return res.stdout.strip() if capture else ""


def replace_patterns(path: Path, replacements: list[tuple[str, str]]) -> None:
    text = path.read_text(encoding="utf-8")
    updated = text
    for old, new in replacements:
        updated = updated.replace(old, new)
    if updated == text:
        sys.exit(f"error: no version references updated in {path}")
    path.write_text(updated, encoding="utf-8")


def update_changelog(path: Path, old_ver: str, new_ver: str) -> bool:
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8")
    if re.search(rf"^## \[{re.escape(new_ver)}\]", text, re.M):
        return False
    if "## [Unreleased]" not in text:
        sys.exit(f"error: {path} has neither '## [{new_ver}]' nor '## [Unreleased]'")

    today = datetime.date.today().isoformat()
    updated = text.replace("## [Unreleased]", f"## [Unreleased]\n\n## [{new_ver}] - {today}", 1)
    old_unreleased = f"[Unreleased]: {REPO_URL}/compare/v{old_ver}...HEAD"
    new_links = (
        f"[Unreleased]: {REPO_URL}/compare/v{new_ver}...HEAD\n"
        f"[{new_ver}]: {REPO_URL}/compare/v{old_ver}...v{new_ver}"
    )
    if old_unreleased in updated:
        updated = updated.replace(old_unreleased, new_links, 1)
    path.write_text(updated, encoding="utf-8")
    return True


def find_typst_cmd() -> list[str] | None:
    if shutil.which("typst"):
        return ["typst"]
    if shutil.which("mise"):
        return ["mise", "x", "typst", "--", "typst"]
    return None


def verify_compilation(root: Path, new_ver: str) -> None:
    typst_cmd = find_typst_cmd()
    if not typst_cmd:
        print("warning: typst not found in PATH; skipping local compile verification", file=sys.stderr)
        return

    print(f"Verifying compilation with {' '.join(typst_cmd)}...")
    tracked_tests = run(["git", "ls-files", "tests/*.typ"], cwd=root, capture=True).splitlines()

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        for ns in ("local", "vendor"):
            pkg_dir = tmp_path / "packages" / ns / "nure"
            pkg_dir.mkdir(parents=True)
            (pkg_dir / new_ver).symlink_to(root)

        env = {**os.environ, "TYPST_PACKAGE_PATH": str(tmp_path / "packages")}

        for test in tracked_tests:
            run([*typst_cmd, "compile", "--root", ".", test, str(tmp_path / f"{Path(test).stem}.pdf")], cwd=root)

        for tmpl in sorted((root / "template/default").glob("*.typ")):
            run([*typst_cmd, "compile", str(tmpl), str(tmp_path / f"default-{tmpl.stem}.pdf")], cwd=root, env=env)

        run([*typst_cmd, "compile", "template/mise/src/main.typ", str(tmp_path / "mise.pdf")], cwd=root, env=env)

    print("All tracked tests and templates compiled cleanly.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("version", help="New strict SemVer version (X.Y.Z, without 'v' prefix)")
    parser.add_argument("--no-commit", action="store_true", help="Update files and verify without committing or tagging")
    args = parser.parse_args()

    new_ver: str = args.version
    if not SEMVER_RE.fullmatch(new_ver):
        sys.exit(f"error: version '{new_ver}' must match strict SemVer X.Y.Z (no 'v' prefix or prerelease suffix)")

    root = Path(run(["git", "rev-parse", "--show-toplevel"], cwd=Path.cwd(), capture=True))

    if (
        subprocess.run(["git", "diff", "--quiet"], cwd=root).returncode != 0
        or subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=root).returncode != 0
    ):
        sys.exit("error: working tree has uncommitted changes to tracked files; commit or stash them first")

    if subprocess.run(["git", "rev-parse", "-q", "--verify", f"refs/tags/v{new_ver}"], cwd=root, stdout=subprocess.DEVNULL).returncode == 0:
        sys.exit(f"error: tag v{new_ver} already exists")

    old_ver: str = tomllib.loads((root / "typst.toml").read_text(encoding="utf-8"))["package"]["version"]
    if old_ver == new_ver:
        sys.exit(f"error: typst.toml is already at version {new_ver}")

    print(f"Bumping version: {old_ver} -> {new_ver}")

    targets: dict[Path, list[tuple[str, str]]] = {
        root / "typst.toml": [(f'version = "{old_ver}"', f'version = "{new_ver}"')],
        root / "template/mise/.mise/config.toml": [
            (f'version = "{old_ver}"', f'version = "{new_ver}"'),
            (f'strip_components=0]@{old_ver}"', f'strip_components=0]@{new_ver}"'),
        ],
        root / "template/mise/src/main.typ": [(f'@vendor/nure:{old_ver}"', f'@vendor/nure:{new_ver}"')],
        root / "README.md": [
            (f"-b v{old_ver}", f"-b v{new_ver}"),
            (f'@vendor/nure:{old_ver}"', f'@vendor/nure:{new_ver}"'),
        ],
        root / "docs/install.md": [
            (f"-b v{old_ver}", f"-b v{new_ver}"),
            (f"local/nure/{old_ver}", f"local/nure/{new_ver}"),
            (f"local\\nure\\{old_ver}", f"local\\nure\\{new_ver}"),
            (f"(`{old_ver}`)", f"(`{new_ver}`)"),
            (f'version = "{old_ver}"', f'version = "{new_ver}"'),
            (f'strip_components=0]@{old_ver}"', f'strip_components=0]@{new_ver}"'),
            (f"@local/nure:{old_ver}", f"@local/nure:{new_ver}"),
            (f"@vendor/nure:{old_ver}", f"@vendor/nure:{new_ver}"),
        ],
    }

    for tmpl in sorted((root / "template/default").glob("*.typ")):
        targets[tmpl] = [(f'@local/nure:{old_ver}"', f'@local/nure:{new_ver}"')]

    for doc in ("docs/lab.md", "docs/coursework.md", "docs/reference.md"):
        targets[root / doc] = [
            (f"@local/nure:{old_ver}", f"@local/nure:{new_ver}"),
            (f"@vendor/nure:{old_ver}", f"@vendor/nure:{new_ver}"),
        ]

    for path, reps in targets.items():
        replace_patterns(path, reps)

    changelog = root / "CHANGELOG.md"
    changelog_updated = update_changelog(changelog, old_ver, new_ver)

    verify_compilation(root, new_ver)

    if args.no_commit:
        print("Updated files (--no-commit). Review with: git diff")
        return

    rel_files = [str(p.relative_to(root)) for p in targets]
    if changelog_updated:
        rel_files.append("CHANGELOG.md")
    run(["git", "add", "--", *rel_files], cwd=root)
    run(["git", "commit", "-m", f"chore(release): v{new_ver}"], cwd=root)
    run(["git", "tag", "-a", f"v{new_ver}", "-m", f"Release v{new_ver}"], cwd=root)
    print(f"\nCreated commit and annotated tag v{new_ver}.\nNext step: git push origin main v{new_ver}")


if __name__ == "__main__":
    main()
