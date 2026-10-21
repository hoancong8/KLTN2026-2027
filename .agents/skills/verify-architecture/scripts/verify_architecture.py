import os
import sys
import subprocess
import re
import argparse
import json

# Force UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

TROUBLESHOOTING_GUIDE = {
    "DOMAIN_IMPORTS_FLUTTER": (
        "Tầng Domain import thư viện Flutter UI ('package:flutter/').",
        "Xóa import Flutter khỏi Domain. Domain phải là Pure Dart. Nếu cần `@immutable`, dùng 'package:meta/meta.dart' hoặc 'package:equatable/equatable.dart'."
    ),
    "DOMAIN_IMPORTS_DIO": (
        "Tầng Domain import thư viện HTTP ('package:dio/').",
        "Xóa Dio khỏi Domain. Việc gọi HTTP thuộc về Remote Datasource trong tầng Data."
    ),
    "DOMAIN_IMPORTS_DTO": (
        "Tầng Domain import DTO từ tầng Data.",
        "Domain chỉ được làm việc với Entity. Sử dụng Mapper trong tầng Data để chuyển đổi DTO thành Entity."
    ),
    "UI_IMPORTS_DATASOURCE": (
        "Tầng UI import trực tiếp Datasource.",
        "UI chỉ được giao tiếp thông qua ViewModel (StateNotifier) và UseCases."
    ),
    "UI_IMPORTS_DIO": (
        "Tầng UI import trực tiếp thư viện Dio.",
        "UI không được tạo request HTTP trực tiếp."
    ),
    "UI_IMPORTS_DTO": (
        "Tầng UI import hoặc sử dụng DTO.",
        "UI chỉ được đọc dữ liệu từ Domain Entity đã được map."
    ),
    "DATASOURCE_MISSING_BASE": (
        "Remote Datasource Implementation không kế thừa 'BaseRemoteDatasource'.",
        "Khai báo 'class ...RemoteDatasourceImpl extends BaseRemoteDatasource implements ...RemoteDatasource'."
    ),
    "ZERO_EMOJI_VIOLATION": (
        "Mã nguồn hoặc comment chứa ký tự emoji vi phạm Zero Emoji Policy.",
        "Xóa các icon/emoji khỏi source code và sử dụng ASCII markers như [OK], [WARN], [ERROR]."
    ),
    "HEX_COLORS_OUTSIDE_THEME": (
        "Phát hiện hardcode mã màu hex Color(0x...) ngoài thư mục theme.",
        "Chuyển toàn bộ định nghĩa màu hex vào 'lib/app/theme/app_colors.dart' và sử dụng qua token context.colors hoặc AppColors."
    ),
    "L10N_KEY_MISMATCH": (
        "Tập khóa ngôn ngữ giữa 'app_vi.arb' và 'app_en.arb' bị lệch hoặc thiếu đồng bộ.",
        "Cập nhật cả hai file 'lib/l10n/app_vi.arb' và 'lib/l10n/app_en.arb' để có đầy đủ và khớp 100% các localization keys."
    ),
    "FLUTTER_ANALYZE_FAILURE": (
        "Lệnh 'flutter analyze' phát hiện warning hoặc linter error.",
        "Chạy 'flutter analyze' trong thư mục Flutter và sửa triệt để các cảnh báo linter."
    ),
    "FLUTTER_TEST_FAILURE": (
        "Bộ unit / widget test không vượt qua 100%.",
        "Chạy 'flutter test' để xem bài test nào bị fail và cập nhật logic hoặc test mock."
    )
}

def locate_flutter_dir(base_dir):
    if os.path.exists(os.path.join(base_dir, "pubspec.yaml")):
        return base_dir
    sub = os.path.join(base_dir, "KLTN2026-2027")
    if os.path.exists(os.path.join(sub, "pubspec.yaml")):
        return sub
    return base_dir

def check_architecture_boundaries(flutter_dir, strict_emoji=False):
    lib_dir = os.path.join(flutter_dir, "lib")
    if not os.path.exists(lib_dir):
        print(f"[ERROR] 'lib/' directory not found at: {flutter_dir}")
        return False, [], []

    errors = []
    warnings = []
    emoji_pattern = re.compile("[\U00010000-\U0010ffff\u2600-\u26ff\u2700-\u27bf]", flags=re.UNICODE)
    hex_color_pattern = re.compile(r"Color\(0x[0-9a-fA-F]+\)")

    for root, _, files in os.walk(lib_dir):
        for f in files:
            if not f.endswith(".dart"):
                continue
            file_path = os.path.join(root, f)
            rel_path = os.path.relpath(file_path, flutter_dir).replace("\\", "/")

            with open(file_path, "r", encoding="utf-8", errors="replace") as stream:
                content = stream.read()

            if emoji_pattern.search(content):
                item = ("ZERO_EMOJI_VIOLATION", f"{rel_path}: Chứa emoji trong source code.")
                if strict_emoji:
                    errors.append(item)
                else:
                    warnings.append(item)

            # 1. Hex Color Check (Must strictly live in lib/app/theme/)
            if not rel_path.startswith("lib/app/theme/") and not rel_path.endswith(".g.dart"):
                if hex_color_pattern.search(content):
                    errors.append(("HEX_COLORS_OUTSIDE_THEME", f"{rel_path}: Hardcode mã màu hex Color(0x...). Phải đưa vào AppColors."))

            # 2. Domain checks
            if rel_path.startswith("lib/domain/"):
                if "package:flutter/material.dart" in content or "package:flutter/widgets.dart" in content:
                    errors.append(("DOMAIN_IMPORTS_FLUTTER", f"{rel_path}: Import Flutter UI framework."))
                if "package:dio/" in content:
                    errors.append(("DOMAIN_IMPORTS_DIO", f"{rel_path}: Import Dio HTTP client."))
                if "/data/dto/" in content:
                    errors.append(("DOMAIN_IMPORTS_DTO", f"{rel_path}: Import DTO từ tầng Data."))

            # 3. UI checks
            if rel_path.startswith("lib/ui/"):
                if "/data/datasource/" in content:
                    errors.append(("UI_IMPORTS_DATASOURCE", f"{rel_path}: Import Datasource trực tiếp."))
                if "package:dio/" in content:
                    errors.append(("UI_IMPORTS_DIO", f"{rel_path}: Import Dio HTTP client trực tiếp."))
                if "/data/dto/" in content:
                    errors.append(("UI_IMPORTS_DTO", f"{rel_path}: Import DTO trong tầng UI."))

            # 4. Remote Datasource Impl checks
            if rel_path.startswith("lib/data/datasource/remote/implement/"):
                if "BaseRemoteDatasource" not in content:
                    errors.append(("DATASOURCE_MISSING_BASE", f"{rel_path}: Không kế thừa BaseRemoteDatasource."))

    # 5. Localization ARB Synchronization Check
    l10n_dir = os.path.join(flutter_dir, "lib", "l10n")
    vi_path = os.path.join(l10n_dir, "app_vi.arb")
    en_path = os.path.join(l10n_dir, "app_en.arb")

    if os.path.exists(vi_path) and os.path.exists(en_path):
        try:
            with open(vi_path, "r", encoding="utf-8") as vf:
                vi_json = json.load(vf)
            with open(en_path, "r", encoding="utf-8") as ef:
                en_json = json.load(ef)

            vi_keys = set(k for k in vi_json.keys() if not k.startswith("@"))
            en_keys = set(k for k in en_json.keys() if not k.startswith("@"))

            missing_in_en = vi_keys - en_keys
            missing_in_vi = en_keys - vi_keys

            if missing_in_en:
                errors.append(("L10N_KEY_MISMATCH", f"Các key có trong app_vi.arb nhưng thiếu trong app_en.arb: {sorted(list(missing_in_en))[:5]}... ({len(missing_in_en)} keys)"))
            if missing_in_vi:
                errors.append(("L10N_KEY_MISMATCH", f"Các key có trong app_en.arb nhưng thiếu trong app_vi.arb: {sorted(list(missing_in_vi))[:5]}... ({len(missing_in_vi)} keys)"))
        except Exception as e:
            errors.append(("L10N_KEY_MISMATCH", f"Lỗi đọc file l10n .arb: {e}"))

    return (len(errors) == 0), errors, warnings

def run_flutter_analyze(flutter_dir):
    print("[INFO] Running 'flutter analyze'...")
    try:
        res = subprocess.run(
            ["flutter", "analyze"],
            cwd=flutter_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=True
        )
        if res.returncode == 0:
            print("[OK] 'flutter analyze' completed with NO issues.")
            return True, res.stdout
        else:
            print("[FAIL] 'flutter analyze' found issues.")
            return False, res.stdout
    except Exception as e:
        return False, str(e)

def run_flutter_test(flutter_dir):
    print("[INFO] Running 'flutter test'...")
    try:
        res = subprocess.run(
            ["flutter", "test"],
            cwd=flutter_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=True
        )
        if res.returncode == 0:
            print("[OK] 'flutter test' completed: 100% tests PASSED.")
            return True, res.stdout
        else:
            print("[FAIL] 'flutter test' had failures.")
            return False, res.stdout
    except Exception as e:
        return False, str(e)

def main():
    parser = argparse.ArgumentParser(description="Flutter Architecture & Quality Verification")
    parser.add_argument("--strict-emoji", action="store_true", help="Fail build if any emoji is found in source code")
    args = parser.parse_args()

    base_dir = os.getcwd()
    flutter_dir = locate_flutter_dir(base_dir)

    print(f"==================================================")
    print(f" KLTN2026-2027 Architecture & Quality Verification")
    print(f" Flutter Project: {flutter_dir}")
    print(f"==================================================\n")

    # 1. Architectural Boundaries, Design Tokens & L10n
    print("[STEP 1/3] Verifying Clean Architecture boundaries, Design Tokens & L10n sync...")
    passed_arch, arch_errors, arch_warnings = check_architecture_boundaries(flutter_dir, strict_emoji=args.strict_emoji)

    if arch_warnings:
        print(f"[WARN] Found {len(arch_warnings)} warning(s):")
        for code, msg in arch_warnings:
            print(f"  - [{code}] {msg}")
        print()

    if passed_arch:
        print("[OK] Architecture boundaries, Design Tokens & L10n: 100% compliant.\n")
    else:
        print(f"[FAIL] Found {len(arch_errors)} architectural / token violation(s):")
        for code, msg in arch_errors:
            print(f"  - [{code}] {msg}")
            if code in TROUBLESHOOTING_GUIDE:
                problem, remedy = TROUBLESHOOTING_GUIDE[code]
                print(f"    -> Khắc phục: {remedy}")
        print()

    # 2. Flutter Analyze
    print("[STEP 2/3] Checking static analysis (flutter analyze)...")
    passed_analyze, analyze_output = run_flutter_analyze(flutter_dir)
    print()

    # 3. Flutter Test
    print("[STEP 3/3] Running automated tests (flutter test)...")
    passed_test, test_output = run_flutter_test(flutter_dir)
    print()

    all_passed = passed_arch and passed_analyze and passed_test

    print("==================================================")
    if all_passed:
        print("[SUCCESS] ALL ARCHITECTURAL, TOKEN AND QUALITY CHECKS PASSED!")
        print("==================================================")
        sys.exit(0)
    else:
        print("[FAILURE] QUALITY GATES FAILED. Please review errors above.")
        print("==================================================")
        sys.exit(1)

if __name__ == "__main__":
    main()
