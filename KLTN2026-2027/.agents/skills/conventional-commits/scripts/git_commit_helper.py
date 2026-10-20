import os
import sys
import re
import subprocess
import argparse

# Force UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

VALID_TYPES = {
    "feat": "Thêm một tính năng mới hoặc một màn hình mới",
    "fix": "Sửa lỗi trong UI, dữ liệu hoặc logic",
    "refactor": "Tái cấu trúc mã nguồn mà không đổi hành vi",
    "perf": "Cải thiện hiệu năng xử lý hoặc tối ưu build widget",
    "style": "Chỉnh sửa định dạng code, xóa import thừa",
    "test": "Thêm mới hoặc chỉnh sửa các bài kiểm thử",
    "docs": "Thêm hoặc cập nhật tài liệu",
    "build": "Thay đổi cấu hình build, pubspec, gradle",
    "ci": "Thay đổi file cấu hình CI/CD (GitHub Actions)",
    "chore": "Bảo trì, cập nhật cấu hình công cụ (.gitignore)",
    "revert": "Hoàn tác một commit trước đó"
}

VALID_SCOPES = {
    "auth", "club", "session", "booking", "profile", "admin", "ui", "data", "domain",
    "l10n", "deps", "rules", "skills", "ci", "build", "chore", "test"
}

SCOPE_MAPPINGS = [
    (r"(?:lib/ui/screen/login|lib/ui/screen/change_password|lib/data/dto/auth|lib/domain/entities/auth)", "auth"),
    (r"(?:lib/ui/screen/club|lib/ui/screen/club_detail|lib/ui/screen/explore_clubs|lib/data/dto/club)", "club"),
    (r"(?:lib/ui/screen/home|lib/domain/entities/session|lib/data/dto/session)", "session"),
    (r"(?:lib/ui/screen/my_bookings|lib/domain/entities/venue|lib/domain/entities/court)", "booking"),
    (r"(?:lib/ui/screen/profile|lib/domain/entities/user_profile|lib/domain/entities/player_profile)", "profile"),
    (r"(?:lib/ui/screen/admin|lib/domain/entities/app_role)", "admin"),
    (r"lib/domain/", "domain"),
    (r"lib/data/", "data"),
    (r"lib/ui/", "ui"),
    (r"(?:lib/l10n/|l10n\.yaml)", "l10n"),
    (r"test/", "test"),
    (r"\.agents/skills/", "skills"),
    (r"\.agents/rules/", "rules"),
    (r"\.agents/", "rules"),
    (r"(AGENTS|GEMINI|ARCHITECTURE_RULES)\.md$", "rules"),
    (r"\.github/", "ci"),
    (r"pubspec\.(yaml|lock)$", "deps"),
    (r"\.(gitignore|gitattributes|metadata)$", "chore")
]

EMOJI_PATTERN = re.compile("[\U00010000-\U0010ffff\u2600-\u26ff\u2700-\u27bf]", flags=re.UNICODE)

def get_git_status():
    try:
        res = subprocess.run(
            ["git", "status", "--porcelain"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        lines = [line.strip() for line in res.stdout.splitlines() if line.strip()]
        files = []
        for line in lines:
            parts = line.split(maxsplit=1)
            if len(parts) == 2:
                files.append(parts[1])
        return files
    except Exception as e:
        print(f"[WARN] Unable to run git status: {e}")
        return []

def detect_scope(files):
    detected_scopes = set()
    for file_path in files:
        norm_path = file_path.replace("\\", "/")
        for pattern, scope in SCOPE_MAPPINGS:
            if re.search(pattern, norm_path):
                detected_scopes.add(scope)
                break
    if not detected_scopes:
        return "chore"
    if len(detected_scopes) == 1:
        return list(detected_scopes)[0]
    # Priority handling
    for prio in ["rules", "skills", "club", "session", "booking", "auth", "domain", "data", "ui", "l10n", "deps"]:
        if prio in detected_scopes:
            return prio
    return list(detected_scopes)[0]

def validate_message(msg: str):
    errors = []

    if EMOJI_PATTERN.search(msg):
        errors.append("Zero Emoji Policy: Thông điệp chứa ký tự emoji bị cấm.")

    first_line = msg.strip().splitlines()[0] if msg.strip() else ""
    if not first_line:
        errors.append("Thông điệp rỗng.")
        return False, errors

    pattern = r"^([a-z]+)(?:\(([a-z0-9_\-]+)\))?(!)?:\s+(.*)$"
    match = re.match(pattern, first_line)

    if not match:
        errors.append(f"Dòng tiêu đề không đúng định dạng Conventional Commits: '<type>(<scope>): <tiêu đề>'")
        return False, errors

    commit_type, scope, breaking, desc = match.groups()

    if commit_type not in VALID_TYPES:
        errors.append(f"Type '{commit_type}' không hợp lệ. Các type cho phép: {', '.join(VALID_TYPES.keys())}")

    if scope and scope not in VALID_SCOPES:
        errors.append(f"Scope '{scope}' không thuộc danh mục scope của dự án Flutter. Các scope cho phép: {', '.join(sorted(VALID_SCOPES))}")

    if desc.endswith("."):
        errors.append("Tiêu đề không được kết thúc bằng dấu chấm ('.').")

    if desc and desc[0].isupper():
        errors.append("Tiêu đề nên bắt đầu bằng chữ thường (ví dụ: 'thêm màn hình', không dùng 'Thêm màn hình').")

    if len(first_line) > 72:
        errors.append(f"Độ dài dòng tiêu đề ({len(first_line)} ký tự) vượt quá giới hạn 72 ký tự.")

    return (len(errors) == 0), errors

def main():
    parser = argparse.ArgumentParser(description="Conventional Commits Helper for Flutter KLTN2026-2027")
    parser.add_argument("--validate", help="Validate a commit message string")
    parser.add_argument("--suggest", action="store_true", help="Suggest commit type and scope based on git status")
    args = parser.parse_args()

    if args.validate:
        valid, errors = validate_message(args.validate)
        if valid:
            print("[OK] Thông điệp commit hợp lệ và tuân thủ đúng chuẩn Conventional Commits.")
            sys.exit(0)
        else:
            print("[FAIL] Thông điệp commit không hợp lệ:")
            for err in errors:
                print(f"  - {err}")
            sys.exit(1)

    if args.suggest:
        files = get_git_status()
        if not files:
            print("[INFO] Working tree clean. Không có tệp nào thay đổi.")
            sys.exit(0)
        scope = detect_scope(files)
        print(f"[SUGGESTION]")
        print(f"  Affected Files: {len(files)}")
        print(f"  Recommended Scope: '{scope}'")
        print(f"  Sample: feat({scope}): <mô tả thay đổi ngắn gọn bằng tiếng Việt có dấu>")
        sys.exit(0)

    parser.print_help()

if __name__ == "__main__":
    main()
