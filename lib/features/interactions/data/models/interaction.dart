class PollOption {
  final String id, label;
  const PollOption({required this.id, required this.label});
  factory PollOption.fromJson(Map<String, dynamic> json) =>
      PollOption(id: json['id'] as String, label: json['label'] as String);
}

class EventPoll {
  final String id, eventId, title, status;
  final String? description;
  final List<PollOption> options;
  const EventPoll(
      {required this.id,
      required this.eventId,
      required this.title,
      required this.status,
      required this.description,
      required this.options});
  factory EventPoll.fromJson(Map<String, dynamic> json) => EventPoll(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      options: ((json['options'] as List<dynamic>?) ?? [])
          .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList());
}

class EventQuestion {
  final String id, question, status;
  final String? answer, displayName;
  final int upvotes;
  const EventQuestion(
      {required this.id,
      required this.question,
      required this.status,
      required this.answer,
      required this.displayName,
      required this.upvotes});
  factory EventQuestion.fromJson(Map<String, dynamic> json) => EventQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      status: json['status'] as String,
      answer: json['answer_text'] as String?,
      displayName: json['display_name'] as String?,
      upvotes: json['upvotes'] as int? ?? 0);
}

class PollResult {
  final String optionId, label;
  final int votes;
  final double percentage;
  const PollResult(
      {required this.optionId,
      required this.label,
      required this.votes,
      required this.percentage});
  factory PollResult.fromJson(Map<String, dynamic> json) => PollResult(
      optionId: json['option_id'] as String,
      label: json['label'] as String,
      votes: json['votes'] as int,
      percentage: (json['percentage'] as num).toDouble());
}
