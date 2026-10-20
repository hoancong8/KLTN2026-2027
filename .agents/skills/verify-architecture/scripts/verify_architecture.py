import os
import sys
import subprocess
import re
import argparse

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
        return False, []

    errors = []
    warnings = []
    emoji_pattern = re.compile("[\U00010000-\U0010ffff\u2600-\u26ff\u2700-\u27bf]", flags=re.UNICODE)

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

            # 1. Domain checks
            if rel_path.startswith("lib/domain/"):
                if "package:flutter/material.dart" in content or "package:flutter/widgets.dart" in content:
                    errors.append(("DOMAIN_IMPORTS_FLUTTER", f"{rel_path}: Import Flutter UI framework."))
                if "package:dio/" in content:
                    errors.append(("DOMAIN_IMPORTS_DIO", f"{rel_path}: Import Dio HTTP client."))
                if "/data/dto/" in content:
                    errors.append(("DOMAIN_IMPORTS_DTO", f"{rel_path}: Import DTO từ tầng Data."))

            # 2. UI checks
            if rel_path.startswith("lib/ui/"):
                if "/data/datasource/" in content:
                    errors.append(("UI_IMPORTS_DATASOURCE", f"{rel_path}: Import Datasource trực tiếp."))
                if "package:dio/" in content:
                    errors.append(("UI_IMPORTS_DIO", f"{rel_path}: Import Dio HTTP client trực tiếp."))
                if "/data/dto/" in content:
                    errors.append(("UI_IMPORTS_DTO", f"{rel_path}: Import DTO trong tầng UI."))

            # 3. Remote Datasource Impl checks
            if rel_path.startswith("lib/data/datasource/remote/implement/"):
                if "BaseRemoteDatasource" not in content:
                    errors.append(("DATASOURCE_MISSING_BASE", f"{rel_path}: Không kế thừa BaseRemoteDatasource."))

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

    # 1. Architectural Boundaries
    print("[STEP 1/3] Verifying Clean Architecture boundaries & Zero Emoji...")
    passed_arch, arch_errors, arch_warnings = check_architecture_boundaries(flutter_dir, strict_emoji=args.strict_emoji)

    if arch_warnings:
        print(f"[WARN] Found {len(arch_warnings)} warning(s):")
        for code, msg in arch_warnings:
            print(f"  - [{code}] {msg}")
        print()

    if passed_arch:
        print("[OK] Architecture boundaries and layer purity: 100% compliant.\n")
    else:
        print(f"[FAIL] Found {len(arch_errors)} architectural violation(s):")
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
        print("[SUCCESS] ALL ARCHITECTURAL AND QUALITY CHECKS PASSED!")
        print("==================================================")
        sys.exit(0)
    else:
        print("[FAILURE] QUALITY GATES FAILED. Please review errors above.")
        print("==================================================")
        sys.exit(1)

if __name__ == "__main__":
    main()
