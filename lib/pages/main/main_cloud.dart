import 'package:flutter/material.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/playlist/page_playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainCloudPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainCloudPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _NavigationLine(),
        _Header("Lista de reproducción recomendada", () {}),
        _SectionPlaylist(),
        _Header("Musica mas reciente", () {}),
        _SectionNewSongs(),
      ],
    );
  }
}

class _NavigationLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _ItemNavigator(Icons.radio, "Privado FM", () {
            notImplemented(context);
          }),
          _ItemNavigator(Icons.today, "Recomendado diariamente", () {
            Navigator.pushNamed(context, ROUTE_DAILY);
          }),
          _ItemNavigator(Icons.show_chart, "Tabla de clasificación", () {
            Navigator.pushNamed(context, ROUTE_LEADERBOARD);
          }),
        ],
      ),
    );
  }
}

///common header for section
class _Header extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 8)),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.w800),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  _Header(this.text, this.onTap);
}

class _ItemNavigator extends StatelessWidget {
  final IconData icon;

  final String text;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: <Widget>[
              Material(
                shape: CircleBorder(),
                elevation: 5,
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).primaryColor,
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Text(text),
            ],
          ),
        ));
  }

  _ItemNavigator(this.icon, this.text, this.onTap);
}

class _SectionPlaylist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedPlaylist(limit: 6),
      resultVerify: neteaseRepository.responseVerify,
      builder: (context, result) {
        List<Map> list = (result["result"] as List).cast();
        return GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 10 / 14,
          children: list.map<Widget>((p) {
            return _buildPlaylistItem(context, p);
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlaylistItem(BuildContext context, Map playlist) {
    GestureLongPressCallback onLongPress;

    String copyWrite = playlist["copywriter"];
    if (copyWrite != null && copyWrite.isNotEmpty) {
      onLongPress = () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  playlist["copywriter"],
                  style: Theme.of(context).textTheme.body2,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(
            playlist["id"],
          );
        }));
      },
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: AspectRatio(
                aspectRatio: 1,
                child: FadeInImage(
                  placeholder: AssetImage("assets/playlist_playlist.9.png"),
                  image: NeteaseImage(playlist["picUrl"]),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              playlist["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNewSongs extends StatelessWidget {
  Music _mapJsonToMusic(Map json) {
    Map<String, Object> song = json["song"];
    return mapJsonToMusic(song);
  }

  @override
  Widget build(BuildContext context) {
    return Loader<Map>(
      loadTask: () => neteaseRepository.personalizedNewSong(),
      resultVerify: neteaseRepository.responseVerify,
      builder: (context, result) {
        List<Music> songs = (result["result"] as List)
            .cast<Map>()
            .map(_mapJsonToMusic)
            .toList();
        return MusicList(
          musics: songs,
          token: 'playlist_main_newsong',
          onMusicTap: MusicList.defaultOnTap,
          leadingBuilder: MusicList.indexedLeadingBuilder,
          trailingBuilder: MusicList.defaultTrailingBuilder,
          child: Column(
            children: songs.map((m) => MusicTile(m)).toList(),
          ),
        );
      },
    );
  }
}
