// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_typedefs/gg_typedefs.dart';

import 'gg_timeline_item.dart';

// #############################################################################
/// A timeline of data of type T
abstract class GgTimeline<T> {
  GgTimeline() {
    _init();
  }

  /// Returns the initial item. The seed will be initially put on t = 0.
  T get seed;

  /// Returns all items
  List<GgTimelineItem<T>> get items => _items;

  // ...........................................................................
  /// Returns the item for a given time
  GgTimelineItem<T> item(GgSeconds timePosition) {
    jumpToOrBefore(timePosition);
    return _currentItem;
  }

  // ...........................................................................
  /// Returns n future items starting at the given time position.
  Iterable<GgTimelineItem<T>> futureItems({
    required GgSeconds timePosition,
    required int count,
  }) {
    jumpToOrBefore(timePosition);

    bool hasEnoughItems = _indexOfCurrentItem + count <= _items.length;

    final endIndex = hasEnoughItems ? _indexOfCurrentItem + count : null;

    return _items.sublist(_indexOfCurrentItem, endIndex);
  }

  // ...........................................................................
  /// Returns n past items starting at the given time position.
  Iterable<GgTimelineItem<T>> pastItems({
    required GgSeconds timePosition,
    required int count,
  }) {
    jumpToOrBefore(timePosition);

    bool hasEnoughItems = _indexOfCurrentItem >= count - 1;
    final startIndex = hasEnoughItems ? _indexOfCurrentItem - count + 1 : 0;
    final endIndex = _indexOfCurrentItem;

    return _items.sublist(startIndex, endIndex + 1);
  }

  // ######################
  // Protected
  // ######################

  // ...........................................................................
  void jumpToBeginning() {
    _currentItem = items.first;
    _indexOfCurrentItem = 0;
  }

  // ...........................................................................
  void jumpToOrBefore(GgSeconds timePosition) {
    if (timePosition >= _currentItem.validFrom &&
        timePosition < _currentItem.validTo) {
      return;
    }

    final startIndex = _indexOfCurrentItem;

    // Find or item in future
    var index = startIndex;
    if (timePosition > _currentItem.validFrom) {
      while (++index < items.length) {
        final snapShot = items[index];
        if (snapShot.validFrom > timePosition) {
          break;
        }
        _indexOfCurrentItem = index;
        _currentItem = snapShot;
      }
    }

    // Find item in past
    else {
      while (--index >= 0) {
        final snapShot = items[index];
        _indexOfCurrentItem = index;
        _currentItem = snapShot;

        if (snapShot.validFrom <= timePosition) {
          break;
        }
      }
    }
  }

  // ...........................................................................
  /// Returns the current item
  GgTimelineItem<T> get currentItem => _currentItem;

  // ...........................................................................
  /// Returns the next item.
  /// Returns the last item when no following item is available
  GgTimelineItem<T> get nextItem => _indexOfCurrentItem == _items.length - 1
      ? _currentItem
      : _items[_indexOfCurrentItem + 1];

  // ...........................................................................
  bool tryToReplaceExistingItem({
    required T data,
    required GgSeconds timePosition,
  }) {
    if (timePosition == _currentItem.validFrom) {
      _currentItem = _currentItem.copyWith(data: data);
      _items[_indexOfCurrentItem] = _currentItem;
      return true;
    }

    return false;
  }

  // ...........................................................................
  void addOrReplaceItem({
    required T data,
    required GgSeconds validFrom,
  }) {
    jumpToOrBefore(validFrom);

    // Just replace last item when possible
    if (tryToReplaceExistingItem(
      data: data,
      timePosition: validFrom,
    )) {
      return;
    }

    // Update validTo at previousItem
    _currentItem = _currentItem.copyWith(validTo: validFrom);
    _items[_indexOfCurrentItem] = _currentItem;

    // Estimate validTo value
    final validTo = _currentItem == _items.last
        ? validFrom
        : _items[_indexOfCurrentItem + 1].validFrom;

    // Insert a new item
    final newItem = createItem(
      data: data,
      validFrom: validFrom,
      validTo: validTo,
    );

    _items.insert(_indexOfCurrentItem + 1, newItem);
  }

  // ...........................................................................
  GgTimelineItem<T> createItem({
    required T data,
    required GgSeconds validFrom,
    required GgSeconds validTo,
  }) =>
      GgTimelineItem<T>(
        validFrom: validFrom,
        validTo: validTo,
        data: data,
      );

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final _items = <GgTimelineItem<T>>[];
  var _indexOfCurrentItem = 0;
  late GgTimelineItem<T> _currentItem;

  // ...........................................................................
  void _init() {
    _initInitialItem();
  }

  // ...........................................................................
  void _initInitialItem() {
    _currentItem = createItem(
      data: seed,
      validFrom: 0.0,
      validTo: 0.0,
    );

    _indexOfCurrentItem = 0;
    _items.add(_currentItem);
  }
}

// #############################################################################
class ExampleTimeline extends GgTimeline<double> {
  ExampleTimeline() {
    _addFurtherItems();
  }

  // ...........................................................................
  @override
  double get seed => 0.0;

  static const int numItems = 20;

  // ...........................................................................
  void _addFurtherItems() {
    for (int i = 0; i < numItems; i++) {
      addOrReplaceItem(
        data: i.toDouble(),
        validFrom: i.toDouble(),
      );
    }
  }
}

GgTimeline<double> exampleGgTimeline() => ExampleTimeline();
