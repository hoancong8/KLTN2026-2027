import os
import sys
import argparse
import re

# Force UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

def find_file(relative_paths):
    cwd = os.getcwd()
    for rel in relative_paths:
        p1 = os.path.join(cwd, rel)
        if os.path.exists(p1):
            return p1
        p2 = os.path.join(cwd, "KLTN2026-2027", rel)
        if os.path.exists(p2):
            return p2
    return None

def parse_fr_from_doc():
    doc_path = find_file(["docs/02_KHAO_SAT_VA_YEU_CAU.md"])
    if not doc_path:
        return {}

    with open(doc_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    fr_map = {}
    # Pattern: - **FR01**: <description>
    matches = re.findall(r"-\s+\*\*(FR\d+)\*\*:\s*(.*?)(?=\n-|\n\n|\Z)", content, flags=re.DOTALL)
    for fr_code, desc in matches:
        clean_desc = desc.strip().replace("\n", " ")
        fr_map[fr_code.upper()] = clean_desc

    return fr_map

def parse_uc_from_doc():
    doc_path = find_file(["docs/03_PHAN_TICH_HE_THONG_UC.md"])
    if not doc_path:
        return {}

    with open(doc_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    uc_map = {}
    # Matches markdown headers like: ### 1.1. UC01: ... or ### UC01: ...
    matches = re.findall(r"###\s+(?:[\d\.]+\s+)?(UC\d+):\s*(.*?)\n(.*?)(?=\n###|\Z)", content, flags=re.DOTALL)
    for uc_code, title, body in matches:
        uc_map[uc_code.upper()] = {
            "title": title.strip(),
            "summary": body.strip()[:300].replace("\n", " ") + "..."
        }
    return uc_map

def parse_clean_arch_api_mappings():
    doc_path = find_file(["docs_api_clean_arch.md", "KLTN2026-2027/docs_api_clean_arch.md"])
    if not doc_path:
        return []

    with open(doc_path, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    api_records = []
    current_section = "General"

    for line in lines:
        line_s = line.strip()
        if line_s.startswith("## "):
            current_section = line_s.lstrip("#").strip()
        elif line_s.startswith("|") and not line_s.startswith("| :---") and not line_s.startswith("| API Endpoint"):
            cols = [c.strip() for c in line_s.split("|")[1:-1]]
            if len(cols) >= 8:
                api_records.append({
                    "section": current_section,
                    "endpoint": cols[0].replace("<br>", " "),
                    "desc": cols[1].replace("<br>", " "),
                    "dto": cols[2].replace("<br>", " "),
                    "entity": cols[3].replace("<br>", " "),
                    "mapper": cols[4].replace("<br>", " "),
                    "datasource": cols[5].replace("<br>", " "),
                    "repo": cols[6].replace("<br>", " "),
                    "usecase_provider": cols[7].replace("<br>", " ")
                })

    return api_records

def list_all_fr():
    frs = parse_fr_from_doc()
    print("=" * 80)
    print(f" DANH SÁCH {len(frs)} YÊU CẦU CHỨC NĂNG (DỮ LIỆU ĐỘNG TỪ 02_KHAO_SAT_VA_YEU_CAU.md)")
    print("=" * 80)
    for code in sorted(frs.keys()):
        print(f"[{code}] {frs[code]}")
    print("=" * 80)

def show_fr(fr_code: str):
    code = fr_code.upper()
    frs = parse_fr_from_doc()
    if code not in frs:
        print(f"[ERROR] Không tìm thấy mã '{fr_code}' trong tài liệu đặc tả.")
        return

    print("\n" + "=" * 80)
    print(f" THÔNG TIN YÊU CẦU: [{code}]")
    print("=" * 80)
    print(f"Mô tả nghiệp vụ: {frs[code]}\n")

    # Dynamic cross-reference in clean arch API docs
    apis = parse_clean_arch_api_mappings()
    matched_apis = []
    keywords = [code]

    # Keyword extraction from description
    first_words = [w for w in re.findall(r"\w+", frs[code]) if len(w) > 4][:5]

    for api in apis:
        blob = f"{api['endpoint']} {api['desc']} {api['dto']} {api['usecase_provider']}".lower()
        if code.lower() in blob:
            matched_apis.append(api)
        else:
            for kw in first_words:
                if kw.lower() in blob and api not in matched_apis:
                    matched_apis.append(api)
                    break

    if matched_apis:
        print(f"CÁC API LIÊN QUAN TRONG CLEAN ARCHITECTURE ({len(matched_apis)} kết quả):")
        print("-" * 80)
        for api in matched_apis[:5]:
            print(f"Phân hệ:   {api['section']}")
            print(f"Endpoint:  {api['endpoint']}")
            print(f"Mô tả:     {api['desc']}")
            print(f"DTO / Map: {api['dto']} -> {api['entity']}")
            print(f"UseCase:   {api['usecase_provider']}")
            print("-" * 80)
    else:
        print("[INFO] Không có ánh xạ API trực tiếp (Chức năng có thể vận hành trên UI cục bộ hoặc cấu hình).")

    print("=" * 80 + "\n")

def show_uc(uc_code: str):
    code = uc_code.upper()
    ucs = parse_uc_from_doc()
    if code not in ucs:
        print(f"[ERROR] Không tìm thấy Use Case '{uc_code}' trong tài liệu.")
        return

    item = ucs[code]
    print("\n" + "=" * 80)
    print(f" USE CASE: [{code}] - {item['title']}")
    print("=" * 80)
    print(f"Nội dung tóm tắt: {item['summary']}")
    print("=" * 80 + "\n")

def search_all(query: str):
    q = query.lower()
    frs = parse_fr_from_doc()
    ucs = parse_uc_from_doc()
    apis = parse_clean_arch_api_mappings()

    print(f"\n================================================================================")
    print(f" KẾT QUẢ TÌM KIẾM ĐỘNG CHO TỪ KHÓA: '{query}'")
    print(f"================================================================================")

    print("\n--- 1. YÊU CẦU CHỨC NĂNG (FR) ---")
    matched_fr = 0
    for code, desc in frs.items():
        if q in code.lower() or q in desc.lower():
            print(f"  [{code}] {desc}")
            matched_fr += 1
    if matched_fr == 0:
        print("  (Không tìm thấy FR phù hợp)")

    print("\n--- 2. USE CASES (UC) ---")
    matched_uc = 0
    for code, item in ucs.items():
        if q in code.lower() or q in item['title'].lower() or q in item['summary'].lower():
            print(f"  [{code}] {item['title']}")
            matched_uc += 1
    if matched_uc == 0:
        print("  (Không tìm thấy Use Case phù hợp)")

    print("\n--- 3. CLEAN ARCHITECTURE API ENDPOINTS ---")
    matched_api = 0
    for api in apis:
        blob = f"{api['section']} {api['endpoint']} {api['desc']} {api['dto']} {api['usecase_provider']}".lower()
        if q in blob:
            print(f"  [{api['section']}] {api['endpoint']} -> {api['desc']} ({api['usecase_provider']})")
            matched_api += 1
    if matched_api == 0:
        print("  (Không tìm thấy API phù hợp)")

    print(f"================================================================================\n")

def main():
    parser = argparse.ArgumentParser(description="Dynamic System Spec & Clean Architecture API Alignment Tracer")
    parser.add_argument("--list-fr", action="store_true", help="List all Functional Requirements parsed dynamically from docs")
    parser.add_argument("--fr", help="Trace a Functional Requirement dynamically (e.g. FR01..FR23)")
    parser.add_argument("--uc", help="Trace a Use Case dynamically (e.g. UC01..UC20)")
    parser.add_argument("--search", help="Search across FR, UC, and Clean Architecture APIs dynamically")
    args = parser.parse_args()

    if args.list_fr:
        list_all_fr()
    elif args.fr:
        show_fr(args.fr)
    elif args.uc:
        show_uc(args.uc)
    elif args.search:
        search_all(args.search)
    else:
        list_all_fr()

if __name__ == "__main__":
    main()
