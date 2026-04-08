import 'package:crawl/ui/vocabulary/bloc/vocabulaty_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/databook.dart';
import 'bloc/audio_cubit.dart';

class VocabulatyScreen extends StatefulWidget {
  const VocabulatyScreen({super.key});

  @override
  State<VocabulatyScreen> createState() => _VocabulatyScreenState();
}

class _VocabulatyScreenState extends State<VocabulatyScreen> {
  late VocabulatyCubit vocabulatyCubit;

  @override
  void initState() {
    super.initState();
    vocabulatyCubit = VocabulatyCubit(Data());
    vocabulatyCubit.book();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VocabulatyCubit>(create: (context) => vocabulatyCubit),
        BlocProvider<AudioCubit>(create: (context) => AudioCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Oxford Dictionary"),
          centerTitle: true,
        ),
        body: BlocBuilder<VocabulatyCubit, VocabulatyState>(
          builder: (context, state) {
            if (state is VocabulatyLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VocabulatyLoaded) {
              return ListView.builder(
                itemCount: state.words.length,
                itemBuilder: (context, index) {
                  final wordData = state.words[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Word and POS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      wordData.word ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      wordData.pos ?? "",
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.bookmark_border, color: Colors.blue),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Phonetics with Audio interaction
                          BlocBuilder<AudioCubit, AudioState>(
                            builder: (audioContext, audioState) {
                              return Row(
                                children: [
                                  // UK Audio Button
                                  if (wordData.phonetic != null && wordData.phonetic!.isNotEmpty)
                                    InkWell(
                                      onTap: () => audioContext.read<AudioCubit>().playAudio(wordData.phonetic),
                                      child: Row(
                                        children: [
                                          Icon(
                                            (audioState is AudioLoading && audioState.url == wordData.phonetic)
                                                ? Icons.hourglass_top
                                                : Icons.volume_up,
                                            color: Colors.blue,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("UK: ${wordData.phoneticText ?? ''}"),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  // US Audio Button
                                  if (wordData.phoneticAm != null && wordData.phoneticAm!.isNotEmpty)
                                    InkWell(
                                      onTap: () => audioContext.read<AudioCubit>().playAudio(wordData.phoneticAm),
                                      child: Row(
                                        children: [
                                          Icon(
                                            (audioState is AudioLoading && audioState.url == wordData.phoneticAm)
                                                ? Icons.hourglass_top
                                                : Icons.volume_up,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("US: ${wordData.phoneticAmText ?? ''}"),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),

                          // Senses (Full list of Definitions and Examples)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (wordData.senses ?? []).map<Widget>((sense) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ${sense.definition ?? ""}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (sense.examples != null && sense.examples!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 18.0, top: 4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: sense.examples!.map<Widget>((ex) {
                                            return Text(
                                              "- $ex",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey.shade700,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is VocabulatyError) {
              return Center(child: Text("Lỗi: ${state.message}"));
            }
            return const Center(child: Text("Đang tải dữ liệu..."));
          },
        ),
      ),
    );
  }
}
