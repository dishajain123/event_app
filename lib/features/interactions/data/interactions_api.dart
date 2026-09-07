import 'package:dio/dio.dart';
import 'models/interaction.dart';

class InteractionsApi {
  final Dio _dio;
  const InteractionsApi(this._dio);
  Future<List<EventPoll>> polls(String eventId) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/interactions/events/$eventId/polls',
        queryParameters: {'page': 1, 'page_size': 25});
    return ((r.data?['items'] as List<dynamic>?) ?? [])
        .map((e) => EventPoll.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventQuestion>> questions(String eventId) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/interactions/events/$eventId/questions',
        queryParameters: {'page': 1, 'page_size': 25});
    return ((r.data?['items'] as List<dynamic>?) ?? [])
        .map((e) => EventQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> vote(String pollId, List<String> optionIds) =>
      _dio.post('/interactions/polls/$pollId/vote',
          data: {'option_ids': optionIds});
  Future<List<PollResult>> results(String pollId) async {
    final r =
        await _dio.get<List<dynamic>>('/interactions/polls/$pollId/results');
    return (r.data ?? [])
        .map((e) => PollResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> ask(String eventId, String question, {bool anonymous = false}) =>
      _dio.post('/interactions/events/$eventId/questions',
          data: {'question': question, 'anonymous': anonymous});
  Future<void> upvote(String questionId) =>
      _dio.post('/interactions/questions/$questionId/upvote');
}
