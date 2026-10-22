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

def to_snake_case(name: str) -> str:
    s = re.sub(r'(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', s).lower().strip('_')

def to_pascal_case(name: str) -> str:
    return "".join(word.capitalize() for word in name.replace("-", "_").split("_"))

def validate_flutter_feature(path: str) -> bool:
    if not os.path.exists(path):
        print(f"[ERROR] Path not found: {path}")
        return False

    errors = []
    files_to_check = []

    if os.path.isfile(path):
        files_to_check.append(path)
    else:
        for root, _, files in os.walk(path):
            for f in files:
                if f.endswith(".dart"):
                    files_to_check.append(os.path.join(root, f))

    emoji_pattern = re.compile("[\U00010000-\U0010ffff\u2600-\u26ff\u2700-\u27bf]", flags=re.UNICODE)

    for file_path in files_to_check:
        norm_path = file_path.replace("\\", "/")
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()

        # Zero Emoji check
        if emoji_pattern.search(content):
            errors.append(f"Zero Emoji: {norm_path} contains forbidden emojis.")

        # Domain layer boundary checks
        if "/domain/" in norm_path:
            if "package:flutter/" in content:
                errors.append(f"Domain Boundary: {norm_path} imports Flutter UI ('package:flutter/'). Domain must be pure Dart.")
            if "package:dio/" in content:
                errors.append(f"Domain Boundary: {norm_path} imports Dio ('package:dio/'). Domain must not depend on HTTP clients.")
            if "/data/dto/" in content:
                errors.append(f"Domain Boundary: {norm_path} imports DTO. Domain must only know Entities.")

        # UI layer boundary checks
        if "/ui/" in norm_path:
            if "/data/datasource/" in content:
                errors.append(f"UI Boundary: {norm_path} imports Datasource directly. UI must communicate via ViewModel and UseCases.")
            if "package:dio/" in content:
                errors.append(f"UI Boundary: {norm_path} imports Dio directly.")
            if "/data/dto/" in content:
                errors.append(f"UI Boundary: {norm_path} imports DTO. UI must only consume Domain Entities.")

        # Datasource implementation checks
        if "/data/datasource/remote/implement/" in norm_path:
            if "BaseRemoteDatasource" not in content:
                errors.append(f"Datasource: {norm_path} must extend 'BaseRemoteDatasource'.")
            if "handleResponse" not in content and "handleListResponse" not in content:
                errors.append(f"Datasource: {norm_path} does not use 'handleResponse' or 'handleListResponse'.")

        # DTO defensive parsing checks
        if "/data/dto/" in norm_path and "_response_dto.dart" in norm_path:
            if "fromJson" in content:
                if "_parseInt" not in content and "_parseString" not in content and "_parseBool" not in content:
                    errors.append(f"DTO Defensive Parsing: {norm_path} seems to lack defensive parser helpers (_parseInt, _parseString, etc.).")

    if errors:
        for err in errors:
            print(f"[FAIL] {err}")
        return False

    print(f"[OK] Path '{path}' passed all Clean Architecture boundary checks.")
    return True

def scaffold_feature(feature_name: str, base_dir: str):
    snake = to_snake_case(feature_name)
    pascal = to_pascal_case(feature_name)

    # Detect if we are in root or subfolder
    if os.path.exists(os.path.join(base_dir, "lib")):
        target_lib = os.path.join(base_dir, "lib")
    elif os.path.exists(os.path.join(base_dir, "KLTN2026-2027", "lib")):
        target_lib = os.path.join(base_dir, "KLTN2026-2027", "lib")
    else:
        target_lib = os.path.join(base_dir, "lib")

    print(f"[INFO] Scaffolding Clean Architecture feature: '{pascal}' ({snake})")
    print(f"[INFO] Target lib directory: {target_lib}")

    templates = {
        # 1. Domain Entity
        f"domain/entities/{snake}/{snake}.dart": f"""import 'package:equatable/equatable.dart';

class {pascal} extends Equatable {{
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  const {pascal}({{
    required this.id,
    required this.name,
    required this.isActive,
    this.createdAt,
  }});

  @override
  List<Object?> get props => [id, name, isActive, createdAt];
}}
""",
        # 2. Domain Repository Contract
        f"domain/repositories/{snake}_repository.dart": f"""import '../entities/{snake}/{snake}.dart';

abstract class {pascal}Repository {{
  Future<List<{pascal}>> get{pascal}List();
  Future<{pascal}> get{pascal}Detail(String id);
}}
""",
        # 3. Domain UseCase
        f"domain/usecases/{snake}/get_{snake}_list_usecase.dart": f"""import '../../app/usecase.dart';
import '../../entities/{snake}/{snake}.dart';
import '../../repositories/{snake}_repository.dart';

class Get{pascal}ListUseCase implements UseCase<List<{pascal}>> {{
  final {pascal}Repository repository;

  Get{pascal}ListUseCase(this.repository);

  @override
  Future<List<{pascal}>> execute() {{
    return repository.get{pascal}List();
  }}
}}
""",
        # 4. Data DTO
        f"data/dto/{snake}/{snake}_response_dto.dart": f"""class {pascal}ResponseDto {{
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  const {pascal}ResponseDto({{
    required this.id,
    required this.name,
    required this.isActive,
    this.createdAt,
  }});

  factory {pascal}ResponseDto.fromJson(Map<String, dynamic> json) {{
    return {pascal}ResponseDto(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      isActive: _parseBool(json['isActive']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }}

  static String _parseString(dynamic value) {{
    if (value == null) return '';
    return value.toString();
  }}

  static bool _parseBool(dynamic value) {{
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }}
}}
""",
        # 5. Data Mapper
        f"data/mapper/{snake}_mapper.dart": f"""import '../../domain/entities/{snake}/{snake}.dart';
import '../dto/{snake}/{snake}_response_dto.dart';

class {pascal}Mapper {{
  static {pascal} toEntity({pascal}ResponseDto dto) {{
    return {pascal}(
      id: dto.id,
      name: dto.name,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
    );
  }}
}}
""",
        # 6. Data Remote Datasource Interface
        f"data/datasource/remote/abstract/{snake}_remote_datasource.dart": f"""import '../../../dto/{snake}/{snake}_response_dto.dart';

abstract class {pascal}RemoteDatasource {{
  Future<List<{pascal}ResponseDto>> get{pascal}List();
  Future<{pascal}ResponseDto> get{pascal}Detail(String id);
}}
""",
        # 7. Data Remote Datasource Implementation
        f"data/datasource/remote/implement/{snake}_remote_datasource_impl.dart": f"""import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/{snake}/{snake}_response_dto.dart';
import '../abstract/{snake}_remote_datasource.dart';
import '../base_remote_datasource.dart';

class {pascal}RemoteDatasourceImpl extends BaseRemoteDatasource implements {pascal}RemoteDatasource {{
  final Dio dio;

  {pascal}RemoteDatasourceImpl(this.dio);

  @override
  Future<List<{pascal}ResponseDto>> get{pascal}List() async {{
    try {{
      final res = await dio.get('${{AppConfig.baseUrl}}/api/v1/{snake}s');
      return handleListResponse(res, (json) => {pascal}ResponseDto.fromJson(json));
    }} catch (e) {{
      throw handleError(e);
    }}
  }}

  @override
  Future<{pascal}ResponseDto> get{pascal}Detail(String id) async {{
    try {{
      final res = await dio.get('${{AppConfig.baseUrl}}/api/v1/{snake}s/$id');
      return handleResponse(res, (json) => {pascal}ResponseDto.fromJson(json));
    }} catch (e) {{
      throw handleError(e);
    }}
  }}
}}
""",
        # 8. Data Repository Implementation
        f"data/repositories/{snake}_repository_impl.dart": f"""import '../../domain/entities/{snake}/{snake}.dart';
import '../../domain/repositories/{snake}_repository.dart';
import '../datasource/remote/abstract/{snake}_remote_datasource.dart';
import '../mapper/{snake}_mapper.dart';

class {pascal}RepositoryImpl implements {pascal}Repository {{
  final {pascal}RemoteDatasource remoteDatasource;

  {pascal}RepositoryImpl(this.remoteDatasource);

  @override
  Future<List<{pascal}>> get{pascal}List() async {{
    final dtos = await remoteDatasource.get{pascal}List();
    return dtos.map({pascal}Mapper.toEntity).toList();
  }}

  @override
  Future<{pascal}> get{pascal}Detail(String id) async {{
    final dto = await remoteDatasource.get{pascal}Detail(id);
    return {pascal}Mapper.toEntity(dto);
  }}
}}
""",
        # 9. UI State
        f"ui/screen/{snake}/{snake}_vm/{snake}_state.dart": f"""import 'package:equatable/equatable.dart';
import '../../../../domain/entities/{snake}/{snake}.dart';
import '../../../../domain/exceptions/app_exception.dart';

class {pascal}State extends Equatable {{
  final bool isLoading;
  final List<{pascal}> items;
  final AppException? error;

  const {pascal}State({{
    this.isLoading = false,
    this.items = const [],
    this.error,
  }});

  {pascal}State copyWith({{
    bool? isLoading,
    List<{pascal}>? items,
    AppException? error,
  }}) {{
    return {pascal}State(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }}

  @override
  List<Object?> get props => [isLoading, items, error];
}}
""",
        # 10. UI ViewModel
        f"ui/screen/{snake}/{snake}_vm/{snake}_vm.dart": f"""import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/{snake}/get_{snake}_list_usecase.dart';
import '{snake}_state.dart';

class {pascal}ViewModel extends StateNotifier<{pascal}State> {{
  final Get{pascal}ListUseCase _get{pascal}ListUseCase;

  {pascal}ViewModel(this._get{pascal}ListUseCase) : super(const {pascal}State()) {{
    load{pascal}List();
  }}

  Future<void> load{pascal}List() async {{
    state = state.copyWith(isLoading: true, error: null);
    try {{
      final items = await _get{pascal}ListUseCase.execute();
      state = state.copyWith(isLoading: false, items: items);
    }} on AppException catch (e) {{
      state = state.copyWith(isLoading: false, error: e);
    }} catch (e) {{
      state = state.copyWith(isLoading: false, error: UnknownAppException(e.toString()));
    }}
  }}
}}
""",
        # 11. UI Screen Entrypoint
        f"ui/screen/{snake}/{snake}_screen.dart": f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import 'widgets/{snake}_mobile.dart';
import 'widgets/{snake}_tablet.dart';

class {pascal}Screen extends ConsumerWidget {{
  const {pascal}Screen({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return const ResponsiveLayout(
      mobile: {pascal}Mobile(),
      tablet: {pascal}Tablet(),
    );
  }}
}}
""",
        # 12. UI Widgets
        f"ui/screen/{snake}/widgets/{snake}_mobile.dart": f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';

class {pascal}Mobile extends ConsumerWidget {{
  const {pascal}Mobile({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{pascal}')),
      body: const Center(child: Text('{pascal} Mobile View')),
    );
  }}
}}
""",
        f"ui/screen/{snake}/widgets/{snake}_tablet.dart": f"""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';

class {pascal}Tablet extends ConsumerWidget {{
  const {pascal}Tablet({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{pascal} Tablet')),
      body: const Center(child: Text('{pascal} Tablet View (Master-Detail)')),
    );
  }}
}}
"""
    }

    created_count = 0
    for rel_path, content in templates.items():
        full_path = os.path.join(target_lib, rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        if not os.path.exists(full_path):
            with open(full_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"  + Created: {os.path.relpath(full_path, base_dir)}")
            created_count += 1
        else:
            print(f"  - Exists:  {os.path.relpath(full_path, base_dir)}")

    print(f"\n[OK] Scaffolding complete. {created_count} file(s) generated.")
    print("\n[NEXT STEPS]:")
    print(f"1. Register providers in 'lib/app/provider.dart':")
    print(f"   final {snake}RemoteDatasourceProvider = Provider<{pascal}RemoteDatasource>((ref) => {pascal}RemoteDatasourceImpl(ref.watch(dioProvider)));")
    print(f"   final {snake}RepositoryProvider = Provider<{pascal}Repository>((ref) => {pascal}RepositoryImpl(ref.watch({snake}RemoteDatasourceProvider)));")
    print(f"   final get{pascal}ListUseCaseProvider = Provider<Get{pascal}ListUseCase>((ref) => Get{pascal}ListUseCase(ref.watch({snake}RepositoryProvider)));")
    print(f"   final {snake}ViewModelProvider = StateNotifierProvider.autoDispose<{pascal}ViewModel, {pascal}State>((ref) => {pascal}ViewModel(ref.watch(get{pascal}ListUseCaseProvider)));")
    print(f"2. Add route in 'lib/app/routes.dart'.")
    print(f"3. Add localized keys in 'lib/l10n/app_vi.arb' & 'app_en.arb'.")

def main():
    parser = argparse.ArgumentParser(description="Clean Architecture Flutter Feature Builder & Validator")
    parser.add_argument("--name", help="Feature name in PascalCase or snake_case (e.g. Tournament, ClubMember)")
    parser.add_argument("--validate", help="Validate Clean Architecture boundary on file or directory")
    args = parser.parse_args()

    base_dir = os.getcwd()

    if args.validate:
        success = validate_flutter_feature(args.validate)
        sys.exit(0 if success else 1)
    elif args.name:
        scaffold_feature(args.name, base_dir)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
