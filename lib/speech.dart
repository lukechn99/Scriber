import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:scriber/textio.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:scriber/viewRecords.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  String textmessage;
  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'voice': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'subscribe': HighlightedWord(
      onTap: () => print('subscribe'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'comment': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  double _time = 0.0;
  int unknownpatients = 0;
  TextIo model;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    model = new TextIo();
    model.readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(seconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// assuming first two words are the first and last
  /// names of the patient
  void store(String textmessage) {
    List name = textmessage.split(" ");
    String patient = "";
    if (name.length < 2) {
      // create unique identifier for unknown patient
      patient = "Unknown patient" + unknownpatients.toString();
      unknownpatients += 1;
    } else {
      patient = name[0] + " " + name[1];
    }
    Map<String, dynamic> document = {
      "title": patient,
      "content": textmessage,
    };
    model.addToList(document);
  }

  void record(SpeechRecognitionResult result) {
    setState(() {
      textmessage = "${result.recognizedWords}";
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: record,
            //   (val) => setState(() {
            //   _text = val.recognizedWords;
            //   // if (_text != null) {
            //   //   textmessage += _text;
            //   // }
            //   if (val.hasConfidenceRating && val.confidence > 0) {
            //     _confidence = val.confidence;
            //   }
            // }),
            listenFor: Duration(seconds: 20),
            cancelOnError: true);
      }
    } else {
      setState(() => _isListening = false);
      store(textmessage);
      _speech.stop();
    }
  }
}
