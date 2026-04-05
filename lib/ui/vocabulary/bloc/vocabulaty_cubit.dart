import 'package:bloc/bloc.dart';
import 'package:crawl/data/databook.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../bookmodel.dart';

part 'vocabulaty_state.dart';

class VocabulatyCubit extends Cubit<VocabulatyState> {
  final Data _words;
  VocabulatyCubit(this._words) : super(VocabulatyInitial());

  Future book ()async {
    try{
       final rederbook = await _words.loadAllDataJson();
       emit(VocabulatyLoaded(words: rederbook));
    }
    catch (e){
      emit(VocabulatyError(message: e.toString()));
    }
  }

}
