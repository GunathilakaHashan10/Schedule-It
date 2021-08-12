import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../helpers/helper.dart';
import '../providers/connectivity_provider.dart';
import '../providers/appVersion_provider.dart';
import '../widgets/app_drawer.dart';
import 'schedule_screen.dart';
import 'no_connection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _dateTime = DateTime.now();
  List<DateTime> _dateTimes = [];
  int _pageIndex = 0;
  bool _isInit = true;
  bool _isOutdated = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 14; i++) {
      _dateTimes.add(DateTime.now().subtract(Duration(days: 0 - i)));
    }
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<AppVersionProvider>(context, listen: false)
          .isAppOutdated()
          .then((version) {
        if (version != 'v1.0.3') {
          setState(() {
            _appVersion = version;
            _isOutdated = true;
          });
        } else {
          setState(() {
            _isOutdated = false;
          });
        }
      }).catchError((_) {
        setState(() {
          _isOutdated = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _setDateTimeAndPageIndex(int index) {
    setState(() {
      _dateTime = _dateTimes[index];
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: 0);
    final PreferredSizeWidget appBar = AppBar(
      title: RichText(
        softWrap: true,
        text: TextSpan(children: [
          TextSpan(
            text: Helper.isDateTimeEqual(DateTime.now(), _dateTime)
                ? 'Today,'
                : '${DateFormat.EEEE().format(_dateTime)},',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
                fontSize: 19),
          ),
          TextSpan(
            text: ' ${DateFormat.yMMMMd().format(_dateTime)}',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 19),
          ),
        ]),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
    );

    void nextPage() {
      pageController.animateToPage(pageController.page!.toInt() + 1,
          duration: Duration(milliseconds: 10), curve: Curves.easeIn);
    }

    void previousPage() {
      pageController.animateToPage(pageController.page!.toInt() - 1,
          duration: Duration(milliseconds: 10), curve: Curves.easeIn);
    }

    void homePage() {
      pageController.animateToPage(0,
          duration: Duration(milliseconds: 10), curve: Curves.easeIn);
    }

    return Consumer<ConnectivityProvider>(builder: (context, connectivity, _) {
      if (connectivity.isOnline != null) {
        return connectivity.isOnline!
            ? _isOutdated
                ? Scaffold(
                    body: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height,
                      child: Helper.appUpdateAlertDialog(context, _appVersion),
                    ),
                  )
                : Scaffold(
                    appBar: appBar,
                    body: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      onPageChanged: (value) {
                        _setDateTimeAndPageIndex(value);
                      },
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _dateTimes.length,
                      itemBuilder: (ctx, index) => ScheduleScreen(
                          dateTime: _dateTimes[index],
                          appBarHeight: appBar.preferredSize.height),
                    ),
                    floatingActionButton: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _pageIndex != 0
                                    ? MaterialButton(
                                        clipBehavior: Clip.antiAlias,
                                        elevation: 2.0,
                                        color: Colors.white,
                                        padding: EdgeInsets.all(10.0),
                                        shape: CircleBorder(),
                                        child: Icon(Icons.today,
                                            color:
                                                Theme.of(context).accentColor),
                                        onPressed: homePage,
                                      )
                                    : const SizedBox(),
                                MaterialButton(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2.0,
                                  color: Colors.white,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0)),
                                  ),
                                  child: Icon(Icons.navigate_before,
                                      color: Colors.black87),
                                  onPressed: previousPage,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MaterialButton(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2.0,
                                  color: Colors.white,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0)),
                                  ),
                                  child: Icon(Icons.navigate_next,
                                      color: Colors.black87),
                                  onPressed: nextPage,
                                ),
                                Container(
                                  width: 50.0,
                                  height: 50.0,
                                  child: FloatingActionButton(
                                    elevation: 2.0,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => Helper.showAddNewTask(
                                        context: context,
                                        isEditing: false,
                                        date: _dateTime),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          )
                        ],
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    drawer: AppDrawer(),
                  )
            : NoConnectionScreen();
      }
      return Scaffold(
        appBar: appBar,
        body: Container(
          color: Colors.white,
          height: (MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).padding.top),
          child: Center(
            child: Helper.loadingIndicator(context),
          ),
        ),
        drawer: AppDrawer(),
      );
    });
  }
}
