GgTimeline allows you to manage arbitrary data like on a timeline.

## Features

- Arrange arbitrary data on a timeline
- Retrieve data values from arbitrary time positions
- Replace existing items on a timeline
- There is always a valid value on the timeline

## Usage

Derive your custom timeline class by extending `GgTimeline<T>`.

~~~dart
class ExampleTimeline extends GgTimeline<int> {
}
~~~

Implement the `seed` property providing an initial value. `GgTimeline` will add
the seed into the timeline at position 0. Thus timeline will always provide a
valid value.

~~~dart
  @override
  int get seed => 0;
~~~

Add additional items using `addOrReplaceItem(...)`:

~~~dart
  ExampleTimeline() {
    for (int i = 0; i < 20; i++) {
      addOrReplaceItem(
        data: i,
        validFrom: i.toDouble(),
      );
    }
  }
~~~

Now you can instantiate your timeline and retrieve values from arbitrary time positions:

~~~dart
final timeline = ExampleTimeline();
final firstItem = timeline.item(0.0);
final secondItem = timeline.item(1.0);
final lastItem = timeline.item(50.0);
~~~

You can also retrieve timeline items for positions in between:

~~~dart
final firstItem2 = timeline.item(0.5);
~~~

## Features and bugs

Please file feature requests and bugs at [GitHub](https://github.com/inlavigo/gg_timeline).
