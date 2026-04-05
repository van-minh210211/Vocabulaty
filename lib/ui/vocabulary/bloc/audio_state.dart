part of 'audio_cubit.dart';


abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object> get props => [];
}
final class AudioInitial extends AudioState {}
final class AudioLoading extends AudioState {}
final class AudioLoaded extends AudioState{
  final String url;
  AudioLoaded({required this.url});
  @override
  List<Object> get props => [url];

}
