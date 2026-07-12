import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_exception.dart';
import '../bootstrap/bootstrap_providers.dart';
import '../pos/pos_shell_screen.dart';
import 'terminal_controller.dart';

class TerminalSelectionScreen extends ConsumerWidget {
  const TerminalSelectionScreen({super.key});

  static const routePath = '/terminal';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(posBootstrapProvider);
    final terminalState = ref.watch(terminalContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select POS terminal'),
        actions: [
          IconButton(
            tooltip: 'Refresh bootstrap',
            onPressed: () => ref.invalidate(posBootstrapProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: bootstrap.when(
        data: (data) {
          final terminals = data.posTerminals;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                data.restaurant?.name ?? 'Restaurant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text('Branch: ${data.branch?.name ?? 'Current branch'}'),
              const SizedBox(height: 20),
              if (terminals.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No POS terminals are configured for this branch. Add one in SELFx Admin > POS terminals.',
                    ),
                  ),
                )
              else
                ...terminals.map(
                  (terminal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            terminal.code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(terminal.name),
                        subtitle: Text(
                          terminal.displayUrl ??
                              'Customer display sync token available',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: FilledButton(
                          onPressed: terminalState.isLoading
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(terminalContextProvider.notifier)
                                        .select(terminal);
                                    ref.invalidate(posBootstrapProvider);
                                    if (context.mounted) {
                                      context.go(PosShellScreen.routePath);
                                    }
                                  } on Object catch (error) {
                                    if (!context.mounted) return;
                                    final message = error is AppException
                                        ? error.message
                                        : error.toString();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  }
                                },
                          child: const Text('Use'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 42),
                const SizedBox(height: 12),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(posBootstrapProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
