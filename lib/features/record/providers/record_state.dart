sealed class RecordState {
  const RecordState();
}

final class Idle extends RecordState { 
  final String transcript;
  const Idle({this.transcript = ''}); 
}
final class Recording extends RecordState {
  final String transcript;
  const Recording({this.transcript = ''});
}
final class Transcribing extends RecordState { const Transcribing(); }
final class AiProcessing extends RecordState { const AiProcessing(); }
final class Saving extends RecordState { const Saving(); }
final class Completed extends RecordState { const Completed(); }

final class Viewing extends RecordState {
  final int noteId;
  const Viewing(this.noteId);
}

final class ErrorState extends RecordState {
  final String message;
  const ErrorState(this.message);
}
