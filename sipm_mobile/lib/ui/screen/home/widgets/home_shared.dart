import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/ui/screen/profile/profile_screen.dart';

import '../../../../app/provider/localization_provider.dart';

class CompanyHeader extends ConsumerWidget {
  const CompanyHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final l10n = ref.watch(localizationProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project TPV',
          style: t.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColor.cTitle,
          ),
        ),
        Text(l10n.translate('ParentCompany'), style: t.bodySmall?.copyWith(color: AppColor.cMuted)),
      ],
    );
  }
}

class SimpleSearchDelegate extends SearchDelegate<String> {
  final LocalizationNotifier l10n;

  SimpleSearchDelegate(this.l10n) : super(searchFieldLabel: l10n.translate('Search'));
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        l10n.translate('ResultsFor', args: {'query': query}),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final source = [
      l10n.translate('Home'),
      l10n.translate('Projects'),
      l10n.translate('Finance'),
      l10n.translate('Report'),
      l10n.translate('Setting')
    ];
    final suggestions =
    source.where((e) {
      return e.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestions[i]),
          onTap: () {
            query = suggestions[i];
            showResults(context);
          },
        );
      },
    );
  }
}

Widget buildProfileButton(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    },
    borderRadius: BorderRadius.circular(999),
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColor.cMain.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.cDivider),
      ),
      child: const Icon(Icons.person, size: 18),
    ),
  );
}