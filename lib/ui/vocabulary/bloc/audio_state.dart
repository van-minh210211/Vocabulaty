part of 'audio_cubit.dart';

abstract class AudioState extends Equatable {
  const AudioState();
  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {
  final String url;
  const AudioLoading(this.url);
  @override
  List<Object?> get props => [url];
}

class AudioPlaying extends AudioState {
  final String url;
  const AudioPlaying(this.url);
  @override
  List<Object?> get props => [url];
}

class AudioError extends AudioState {
  final String message;
  const AudioError(this.message);
  @override
  List<Object?> get props => [message];
}
