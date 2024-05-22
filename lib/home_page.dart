
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starxpand/starxpand.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<StarXpandPrinter> printerList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _findPrinters();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return _buildPrinterItemWidget(printerList[index]);
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.transparent,
                  height: 6,
                  thickness: 6,
                ),
                itemCount: printerList.length,
              ),
            ),
            TextButton(
              onPressed: () {
                _findPrinters();
              },
              child: const Text(
                "获取打印机",
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ///  打印机item Widget
  Widget _buildPrinterItemWidget(StarXpandPrinter printer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(4),),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDBDBDB).withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ]
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('打印机名字：'),
              Text(printer?.model.label ?? '未知'),
            ],
          ),
          Row(
            children: [
              const Text('打印机id：'),
              Text(printer?.identifier ?? '未知'),
            ],
          ),
          Row(
            children: [
              const Text('连接方式：'),
              Text(printer?.interface.name ?? '未知'),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  _printAction(printer);
                },
                child: const Text(
                  "测试打印",
                ),
              ),

              TextButton(
                onPressed: () {
                  _openDrawer(printer);
                },
                child: const Text(
                  "Open Drawer",
                ),
              ),

              // TextButton(
              //   onPressed: () {
              //     _startInputListener(printer);
              //   },
              //   child: const Text(
              //     "Input Listener",
              //   ),
              // ),
            ],
          )
          ,
        ],
      ),
    );
  }

  ///  获取打印机
  Future<void> _findPrinters() async {
    if (!(await fetchUsbPermission())) {
      showToast('获取usb权限失败');
      return;
    }
    if (!(await fetchToothPermission())) {
      showToast('获取蓝牙权限失败');
      return;
    }
    try {
      var ps = await StarXpand.findPrinters(
        timeout: 8000,
        callback: (payload) {
          debugPrint('printer: $payload');
          showToast(payload.toString());
        },
      );
      debugPrint('${ps.length}');
      if (ps.isEmpty) {
        showToast('未找到附近的设备');
      } else {
        showToast('找到设备了');
      }
      setState(() {
        printerList = ps;
      });
    } catch (e) {
      showToast(e.toString());
    }
  }


  ///  打印内容
  _printAction(StarXpandPrinter printer) async {
    var doc = StarXpandDocument();
    var printDoc = StarXpandDocumentPrint();

    final ByteData data = await rootBundle.load('assets/test.jpg');
    Uint8List imageData = data.buffer.asUint8List();
    printDoc.actionPrintImage(imageData, 350);

    printDoc.actionCut(StarXpandCutType.partial);

    doc.addPrint(printDoc);
    doc.addDrawer(StarXpandDocumentDrawer());
    try {
      bool printState = await StarXpand.printDocument(printer, doc);
      if (printState) {
        showToast('打印成功');
      } else {
        showToast('打印失败');
      }
    } catch (e) {
      showToast(e.toString());
    }
  }


  ///  打开钱箱
  _openDrawer(StarXpandPrinter printer) async {
    try {
      bool isOpen = await StarXpand.openDrawer(printer);
      if (isOpen) {
        showToast('打开钱箱成功');
      } else {
        showToast('打开钱箱失败');
      }
    } catch (e) {
      showToast(e.toString());
    }
  }
}

///  获取usb权限
Future<bool> fetchUsbPermission() async {
  try {
    // 请求 USB 权限
    bool hasPermission = await UsbPermissionHandler.requestUsbPermission();
    return hasPermission;
  } on PlatformException catch (e) {
    // 请求 USB 权限时发生错误
    print('Failed to request USB permission: ${e.message}');
    return false;
  }
}

///  获取蓝牙权限
Future<bool> fetchToothPermission() async {
  try {
    // 请求 USB 权限
    bool hasPermission = await UsbPermissionHandler.requestToothUsbPermission();
    return hasPermission;
  } on PlatformException catch (e) {
    // 请求 USB 权限时发生错误
    print('Failed to request USB permission: ${e.message}');
    return false;
  }
}

showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

class UsbPermissionHandler {
  static Future<bool> requestUsbPermission() async {
    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus == PermissionStatus.granted) {
      return true;
    } else {
      // 如果权限请求失败
      return false;
    }
  }

  static Future<bool> requestToothUsbPermission() async {
    PermissionStatus storageStatus = await Permission.bluetooth.request();
    PermissionStatus bluetoothScanStatus =
        await Permission.bluetoothScan.request();
    // PermissionStatus bluetoothAdvertiseStatus = await Permission.bluetoothAdvertise.request();
    // PermissionStatus bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    // PermissionStatus manageExternalStorageStatus = await Permission.manageExternalStorage.request();
    if (storageStatus == PermissionStatus.granted) {
      return true;
    } else {
      // 如果权限请求失败
      return false;
    }
  }
}