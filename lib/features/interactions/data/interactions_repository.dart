import '../../../../core/network/dio_exception_mapper.dart';
import 'interactions_api.dart';
import 'models/interaction.dart';

class InteractionsRepository {
  final InteractionsApi api;
  const InteractionsRepository(this.api);
  Future<List<EventPoll>> polls(String id) async {
    try {
      return await api.polls(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<EventQuestion>> questions(String id) async {
    try {
      return await api.questions(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> vote(String id, List<String> options) async {
    try {
      await api.vote(id, options);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<PollResult>> results(String id) async {
    try {
      return await api.results(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> ask(String id, String text) async {
    try {
      await api.ask(id, text);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> upvote(String id) async {
    try {
      await api.upvote(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
