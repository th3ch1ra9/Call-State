import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController nameController;
  int totalCallLogs = 0;
  int updatedCallLogsCount = 0;
  bool uploading = false;
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fetchCallLogs();
  }

  Future<void> fetchCallLogs() async {
    setState(() {
      uploading = true;
    });

    Iterable<CallLogEntry> callLogs = await CallLog.get();
    setState(() {
      _callLogs = callLogs.toList();
      totalCallLogs = _callLogs.length;
      uploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color cbackground = const Color(0xFF17202A);
    Color boxcolor = const Color.fromARGB(255, 45, 39, 39);
    Color txtColor = const Color(0xFFFFFFFF);
    TextStyle style = TextStyle(color: txtColor, fontWeight: FontWeight.w300, fontSize: 12);
    Color missColor = cbackground;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Call Log Service'),
        ),
        body: _callLogs.isEmpty
            ? Center(child: Text("NO Calllogs"))
            : Container(
                color: cbackground,
                child: ListView.builder(
                  itemCount: _callLogs.length,
                  itemBuilder: (context, index) {
                    final call = _callLogs[index];
                    if (call.callType.toString() == "CallType.outgoing") {
                      txtColor = const Color(0xFFFFFFFF);
                      missColor = const Color(0xFFF1C40F);
                    } else if (call.callType.toString() == "CallType.missed") {
                      txtColor = const Color(0xFFFFFFFF);
                      missColor = const Color(0xFFE74C3C);
                    } else if (call.callType.toString() == "CallType.incoming") {
                      txtColor = const Color(0xFFFFFFFF);
                      missColor = const Color(0xFF58D68D);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: boxcolor,
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name     ${call.name}",
                                    style: style,
                                  ),
                                  Text(
                                    "Number   ${call.number}",
                                    style: style,
                                  ),
                                  Text(
                                    "Duration  ${(call.duration! / 60).toStringAsFixed(3)} min",
                                    style: style,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SIM      ${call.simDisplayName}",
                                    style: style,
                                  ),
                                  Text(
                                    call.callType.toString().split('.').last,
                                    style: TextStyle(
                                        color: missColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
