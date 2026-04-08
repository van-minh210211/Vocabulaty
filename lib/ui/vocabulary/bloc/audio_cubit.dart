import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;

  AudioCubit() : super(AudioInitial()) {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        emit(AudioInitial());
      }
    });
  }

  Future<void> playAudio(String? url) async {
    if (url == null || url.isEmpty) {
      emit(const AudioError("Link âm thanh không hợp lệ"));
      return;
    }

    if (state is AudioPlaying && (state as AudioPlaying).url == url) {
      await _audioPlayer.stop();
      emit(AudioInitial());
      return;
    }

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }

      emit(AudioLoading(url));
      await _audioPlayer.setUrl(url);
      
      emit(AudioPlaying(url));
      _audioPlayer.play();
      
    } catch (e) {
      emit(AudioError("Lỗi phát âm thanh: $e"));
      emit(AudioInitial());
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
