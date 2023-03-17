import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

  // start scanning for nearby devices
  void scanDevices() {
    flutterBlue.scan().listen((scanResult) {
      if (!devicesList.contains(scanResult.device)) {
        setState(() {
          devicesList.add(scanResult.device);
        });
      }
    });
  }

  // connect to selected device
  void connectToDevice(BluetoothDevice device) async {
    // establish a connection to the device
    await device.connect();

    print('Connected to ${device.name}');

    // discover services offered by the device
    List<BluetoothService> services = await device.discoverServices();

    // find the service you want to use
    BluetoothService service = services.firstWhere(
            (s) => s.uuid.toString() == '00001101-0000-1000-8000-00805f9b34fb');

    // find the characteristic you want to use
    BluetoothCharacteristic characteristic = service.characteristics
        .firstWhere((c) => c.uuid.toString() == '00001101-0000-1000-8000-00805f9b34fb');

    // send data to the connected device
    await characteristic.write(utf8.encode('Hello, world!'));

    // receive data from the connected device
    characteristic.value.listen((data) {
      print('Received: ${utf8.decode(data)}');
    });

    // close the connection
    await device.disconnect();
  }

  @override
  void initState() {
    super.initState();
    scanDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bluetooth Demo'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (BuildContext context, int index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () {
              connectToDevice(device);
            },
          );
        },
      ),
    );
  }
}
