import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/ticket.dart';
import '../data/tickets_api.dart';
import '../data/tickets_repository.dart';

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return TicketsRepository(TicketsApi(dio));
});

final myTicketsProvider = FutureProvider<List<AppTicket>>((ref) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.listMyTickets();
});

final ticketDetailProvider =
    FutureProvider.family<AppTicket, String>((ref, ticketId) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  return repository.getTicket(ticketId);
});

final incomingTicketTransfersProvider =
    FutureProvider<List<TicketTransfer>>((ref) async {
  return ref.watch(ticketsRepositoryProvider).listIncomingTransfers();
});
