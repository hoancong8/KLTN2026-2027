import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/domain/entities/permission_group.dart';

class PermissionTreeView extends StatefulWidget {
  final List<PermissionGroup> allGroups;
  final Set<String> selectedPermissions;
  final ValueChanged<Set<String>> onSelectionChanged;

  const PermissionTreeView({
    super.key,
    required this.allGroups,
    required this.selectedPermissions,
    required this.onSelectionChanged,
  });

  @override
  State<PermissionTreeView> createState() => _PermissionTreeViewState();
}

class _PermissionTreeViewState extends State<PermissionTreeView> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedNodeNames = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _expandAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _expandAll() {
    void traverse(PermissionGroup g) {
      _expandedNodeNames.add(g.name);
      for (final child in g.children) {
        traverse(child);
      }
    }

    for (final group in widget.allGroups) {
      traverse(group);
    }
  }

  void _collapseAll() {
    setState(() {
      _expandedNodeNames.clear();
    });
  }

  void _selectAll() {
    final allNames = <String>{};
    for (final g in widget.allGroups) {
      allNames.addAll(g.allPermissionNames);
    }
    widget.onSelectionChanged(allNames);
  }

  void _unselectAll() {
    widget.onSelectionChanged({});
  }

  void _togglePermission(String name) {
    final newSet = Set<String>.from(widget.selectedPermissions);
    if (newSet.contains(name)) {
      newSet.remove(name);
    } else {
      newSet.add(name);
    }
    widget.onSelectionChanged(newSet);
  }

  void _toggleGroup(PermissionGroup group, bool select) {
    final newSet = Set<String>.from(widget.selectedPermissions);
    final groupPermNames = group.allPermissionNames;
    if (select) {
      newSet.addAll(groupPermNames);
    } else {
      newSet.removeAll(groupPermNames);
    }
    widget.onSelectionChanged(newSet);
  }

  bool? _getGroupCheckState(PermissionGroup group) {
    final perms = group.allPermissionNames;
    if (perms.isEmpty) return false;
    final selectedCount = perms.where((p) => widget.selectedPermissions.contains(p)).length;
    if (selectedCount == 0) return false;
    if (selectedCount == perms.length) return true;
    return null; // Indeterminate
  }

  bool _isGroupMatchingSearch(PermissionGroup group, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    if (group.name.toLowerCase().contains(q) || group.displayName.toLowerCase().contains(q)) {
      return true;
    }
    if (group.permissions.any((p) => p.name.toLowerCase().contains(q) || p.displayName.toLowerCase().contains(q))) {
      return true;
    }
    return group.children.any((c) => _isGroupMatchingSearch(c, query));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ô tìm kiếm quyền
        TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
              if (_searchQuery.isNotEmpty) {
                _expandAll();
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Tìm quyền...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColor.cMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16, color: AppColor.cMuted),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.cDivider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.cDivider),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Thanh nút thao tác nhanh (Chọn tất cả, Bỏ chọn, Mở rộng, Thu gọn)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionButton('Chọn tất cả', _selectAll),
            _buildActionButton('Bỏ chọn tất cả', _unselectAll),
            _buildActionButton('Mở rộng', () => setState(() => _expandAll())),
            _buildActionButton('Thu gọn', _collapseAll),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColor.cDivider),
        const SizedBox(height: 10),

        // 3. Cây phân quyền Tree View
        Expanded(
          child: widget.allGroups.isEmpty
              ? const Center(
                  child: Text('Đang tải danh sách quyền...', style: TextStyle(color: AppColor.cMuted)),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: widget.allGroups
                      .where((g) => _isGroupMatchingSearch(g, _searchQuery))
                      .map((g) => _buildGroupNode(g, level: 0))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.cDivider),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNode(PermissionGroup group, {required int level}) {
    final isExpanded = _expandedNodeNames.contains(group.name);
    final checkState = _getGroupCheckState(group);
    final hasChildren = group.children.isNotEmpty || group.permissions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 20.0, top: 4, bottom: 4),
          child: Row(
            children: [
              // Nút mũi tên mở rộng / thu gọn
              if (hasChildren)
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedNodeNames.remove(group.name);
                      } else {
                        _expandedNodeNames.add(group.name);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isExpanded ? Icons.arrow_drop_down_rounded : Icons.arrow_right_rounded,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                )
              else
                const SizedBox(width: 24),

              // Checkbox nhóm cha
              _buildCustomCheckbox(
                value: checkState,
                onChanged: (val) {
                  _toggleGroup(group, val ?? false);
                },
              ),
              const SizedBox(width: 6),

              // Icon & Tên nhóm
              const Icon(Icons.folder_outlined, size: 16, color: Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.displayName.isNotEmpty ? group.displayName : group.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cTitle,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Nhánh con (Children & Leaf Permissions)
        if (isExpanded) ...[
          // Nhóm con cấp sâu hơn
          ...group.children
              .where((c) => _isGroupMatchingSearch(c, _searchQuery))
              .map((c) => _buildGroupNode(c, level: level + 1)),

          // Danh sách quyền lá (Leaf Permissions)
          ...group.permissions
              .where((p) {
                if (_searchQuery.isEmpty) return true;
                final q = _searchQuery.toLowerCase();
                return p.name.toLowerCase().contains(q) || p.displayName.toLowerCase().contains(q);
              })
              .map((p) => _buildPermissionLeafNode(p, level: level + 1)),
        ],
      ],
    );
  }

  Widget _buildPermissionLeafNode(PermissionItem item, {required int level}) {
    final isChecked = widget.selectedPermissions.contains(item.name);

    return Padding(
      padding: EdgeInsets.only(left: level * 20.0 + 24, top: 2, bottom: 2),
      child: Row(
        children: [
          _buildCustomCheckbox(
            value: isChecked,
            onChanged: (val) => _togglePermission(item.name),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.displayName.isNotEmpty ? item.displayName : item.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
                color: isChecked ? const Color(0xFF111827) : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () {
        if (value == null || !value) {
          onChanged(true);
        } else {
          onChanged(false);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: (value == true || value == null) ? AppColor.cMain : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: (value == true || value == null) ? AppColor.cMain : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: value == true
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : value == null
                ? const Icon(Icons.remove_rounded, size: 14, color: Colors.white)
                : null,
      ),
    );
  }
}
