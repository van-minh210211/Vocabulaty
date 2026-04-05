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
  late VocabulatyCubit listbook;
  late AudioCubit audio;
  late String url;

  @override
  void initState() {
    super.initState();
    listbook = VocabulatyCubit(Data());
    audio = AudioCubit();
    audio.loadAudio(url);
    listbook.book();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VocabulatyCubit>(create: (context) => listbook),
        BlocProvider<AudioCubit>(create: (context) => audio),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Vocabulary Dictionary")),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue.shade100),
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
                              const Icon(
                                Icons.bookmark_border,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Phonetics
                          BlocBuilder<AudioCubit, AudioState>(

                            builder: (context, state) {
                              return Row(
                                children: [
                                  if (wordData.phoneticText != null &&
                                      wordData.phoneticText!.isNotEmpty) ...[
                                    const Icon(
                                      Icons.volume_up,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text("UK: ${wordData.phoneticText}"),
                                    const SizedBox(width: 16),
                                  ],
                                  if (wordData.phoneticAmText != null &&
                                      wordData.phoneticAmText!.isNotEmpty) ...[
                                    const Icon(
                                      Icons.volume_up,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text("US: ${wordData.phoneticAmText}"),
                                  ],
                                ],
                              );
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),

                          // Senses (Definitions and Examples)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Definition
                                if (wordData.senses.isNotEmpty)
                                  Text(
                                    wordData.senses[0].definition ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),

                                // Examples
                              ],
                            ),
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
            return const Center(child: Text("Chưa có dữ liệu"));
          },
        ),
      ),
    );
  }
}
