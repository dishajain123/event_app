import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../application/teams_providers.dart';

/// [_submit] is unchanged — same `createTeam` repository call, same
/// `pushReplacement` to the roster on success.
class CreateTeamScreen extends ConsumerStatefulWidget {
  final String eventId;
  const CreateTeamScreen({super.key, required this.eventId});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _nameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a team name.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(teamsRepositoryProvider);
      final team =
          await repository.createTeam(eventId: widget.eventId, name: name);
      if (mounted) context.pushReplacement(RoutePaths.teamRosterPath(team.id));
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentViolet],
                    ),
                    shape: BoxShape.circle),
                child: const Icon(Icons.groups_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                  controller: _nameController,
                  label: 'Team name',
                  hint: 'Give your team a name',
                  autofocus: true),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Create team',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _submitting,
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}