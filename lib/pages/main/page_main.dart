import 'package:flutter/material.dart';
import 'package:quiet/pages/main/main_cloud.dart';
import 'package:quiet/pages/main/main_playlist.dart';
import 'package:quiet/pages/search/page_search.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProxyAnimation transitionAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              _AppDrawerHeader(),
              MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Expanded(
                    child: ListTileTheme(
                      style: ListTileStyle.drawer,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text("Configurar"),
                            onTap: () {
                              Navigator.pushNamed(context, ROUTE_SETTING);
                            },
                          ),
                          Divider(height: 0, indent: 16),
                          ListTile(
                            leading: Icon(Icons.format_quote),
                            title: Text("Star On GitHub"),
                            onTap: () {
                              launch(
                                  "https://github.com/boyan01/quiet-flutter");
                            },
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
              icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_arrow,
                  color: Theme.of(context).primaryIconTheme.color,
                  progress: transitionAnimation),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              }),
          title: Container(
            height: kToolbarHeight,
            width: 128,
            child: TabBar(
              controller: _tabController,
              indicator:
                  UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: <Widget>[
                Tab(child: Icon(Icons.music_note)),
                Tab(child: Icon(Icons.cloud)),
              ],
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                    context, NeteaseSearchPageRoute(transitionAnimation));
              },
              icon: Icon(Icons.search),
            )
          ],
        ),
        body: BoxWithBottomPlayerController(TabBarView(
          controller: _tabController,
          children: <Widget>[MainPlaylistPage(), MainCloudPage()],
        )),
      ),
    );
  }
}

///the header of drawer
class _AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UserAccount.of(context).isLogin) {
      return _buildHeader(context);
    } else {
      return _buildHeaderNotLogin(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    Map profile = UserAccount.of(context).user["profile"];
    return UserAccountsDrawerHeader(
      currentAccountPicture: InkResponse(
        onTap: () {
          if (UserAccount.of(context).isLogin) {
            debugPrint("work in process...");
          }
        },
        child: CircleAvatar(
          backgroundImage: NeteaseImage(profile["avatarUrl"]),
        ),
      ),
      accountName: Text(profile["nickname"]),
      accountEmail: null,
      otherAccountsPictures: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              if (await showConfirmDialog(context, Text('Confirmar cierre de sesión？'),
                  positiveLabel: 'Cerrar sesión')) {
                UserAccount.of(context, rebuildOnChange: false).logout();
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildHeaderNotLogin(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
      ),
      child: Container(
        constraints: BoxConstraints.expand(),
        child: DefaultTextStyle(
          style:
              Theme.of(context).primaryTextTheme.caption.copyWith(fontSize: 14),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Inicie sesión en Netease Cloud Music"),
                Text("Sincronización multi-terminal móvil y de computadora, disfrute de música masiva de alta calidad"),
                SizedBox(height: 8),
                FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .body1
                                .color
                                .withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, ROUTE_LOGIN);
                    },
                    textColor: Theme.of(context).primaryTextTheme.body1.color,
                    child: Text("Inicia sesión ahora"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
