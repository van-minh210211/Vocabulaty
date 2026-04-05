part of 'vocabulaty_cubit.dart';

@immutable
abstract class VocabulatyState extends Equatable  {
  const VocabulatyState();

  @override
  List<Object> get props => [];
}

final class VocabulatyInitial extends VocabulatyState {}
final class VocabulatyLoading extends VocabulatyState {}
final class VocabulatyLoaded extends VocabulatyState {
  final List<DataBook> words;

   VocabulatyLoaded({required this.words});
   VocabulatyLoaded copyWith({List<DataBook>? words}) {
     return VocabulatyLoaded(words: words ?? this.words);
   }

  @override
  List<Object> get props => [words];
}
final class VocabulatyError extends VocabulatyState {
  final String message;

  const VocabulatyError({required this.message});

  @override
  List<Object> get props => [message];
}


