import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:assets_audio_player_example/asset_audio_player_icons.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audios = <Audio>[
    Audio("assets/audios/song1.mp3"),
    Audio("assets/audios/song2.mp3"),
    Audio("assets/audios/song3.mp3"),
  ];

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  _assetsAudioPlayer.open(Playlist(audios: this.audios));
                },
                child: Text("Playlist test"),
              ),
              RaisedButton(
                onPressed: () {
                  AssetsAudioPlayer.newPlayer().open(Audio("assets/audios/cat.wav"));
                },
                child: Text("Small Song in parallel"),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: _assetsAudioPlayer.current,
                    builder: (BuildContext context, AsyncSnapshot<Playing> snapshot) {
                      final Playing playing = snapshot.data;

                      return ListView.builder(
                        itemBuilder: (context, position) {
                          return ListTile(
                              title: Text(audios[position].path.split("/").last,
                                  style: TextStyle(
                                    color: audios[position].path == playing?.audio?.assetAudioPath ? Colors.blue : Colors.black,
                                  )),
                              onTap: () {
                                _assetsAudioPlayer.open(audios[position]);
                              });
                        },
                        itemCount: audios.length,
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  StreamBuilder(
                    stream: _assetsAudioPlayer.isLooping,
                    initialData: false,
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      return RaisedButton(
                        child: Text(snapshot.data ? "Looping" : "Not looping"),
                        onPressed: () {
                          _assetsAudioPlayer.toggleLoop();
                        },
                      );
                    },
                  ),
                  SizedBox(width: 20),
                  RaisedButton(
                    child: Text("Seek to 2:00"),
                    onPressed: () {
                      _assetsAudioPlayer.seek(Duration(minutes: 2));
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: _assetsAudioPlayer.currentPosition,
                    initialData: const Duration(),
                    builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                      Duration duration = snapshot.data;
                      return Text(durationToString(duration));
                    },
                  ),
                  Text(" - "),
                  StreamBuilder(
                    stream: _assetsAudioPlayer.current,
                    builder: (BuildContext context, AsyncSnapshot<Playing> snapshot) {
                      Duration duration = Duration();
                      if (snapshot.hasData) {
                        duration = snapshot.data.audio.duration;
                      }
                      return Text(durationToString(duration));
                    },
                  ),
                ],
              ),
              StreamBuilder(
                  stream: _assetsAudioPlayer.volume,
                  initialData: AssetsAudioPlayer.DEFAULT_VOLUME,
                  builder: (context, snapshot) {
                    final double volume = snapshot.data;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("volume : ${((volume * 100).round()) / 100.0}"),
                        Text(" - "),
                        Expanded(
                          child: Slider(
                            min: AssetsAudioPlayer.MIN_VOLUME,
                            max: AssetsAudioPlayer.MAX_VOLUME,
                            value: volume,
                            onChanged: (value) {
                              _assetsAudioPlayer.setVolume(value);
                            },
                          ),
                        )
                      ],
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    onPressed: () {
                      _assetsAudioPlayer.previous();
                    },
                    icon: Icon(AssetAudioPlayerIcons.to_start),
                  ),
                  StreamBuilder(
                    stream: _assetsAudioPlayer.isPlaying,
                    initialData: false,
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      return IconButton(
                        onPressed: () {
                          _assetsAudioPlayer.playOrPause();
                        },
                        icon: Icon(snapshot.data ? AssetAudioPlayerIcons.pause : AssetAudioPlayerIcons.play),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(AssetAudioPlayerIcons.to_end),
                    onPressed: () {
                      _assetsAudioPlayer.next();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
