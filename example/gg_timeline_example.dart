import 'package:gg_timeline/gg_timeline.dart';

void printIndented(String prefix, dynamic message) =>
    print('  $prefix\t$message');

void main() {
  print('Instantiate an example timeline.');
  final timeline = ExampleTimeline();

  print('The timeline has always 20 items.');
  printIndented('length:', timeline.items.length); // 20

  print('Timeline items cover a time range.');
  printIndented('validFrom: ', timeline.item(0.0).validFrom); // 0.0
  printIndented('validTo: ', timeline.item(0.0).validTo); // 1.0

  print('Use "item(time)" to get the item valid for a given time.');
  printIndented('validFrom: ', timeline.item(0.5).validFrom); // 0.0
  printIndented('validTo: ', timeline.item(0.5).validTo); // 1.0

  print('Use "addOrReplaceItem(time)" to insert additional items:');
  timeline.addOrReplaceItem(data: 0.5, timePosition: 0.5);
  printIndented('data: ', timeline.item(0.5).data); // 0.5
  printIndented('validFrom: ', timeline.item(0.5).validFrom); // 0.5
  printIndented('validTo: ', timeline.item(0.5).validTo); // 1.0

  print('Inserting an element changes the previous element\'s duration:');
  printIndented('validTo: ', timeline.item(0.0).validTo); // 0.5
}
