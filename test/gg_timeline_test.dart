// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_timeline/gg_timeline.dart';
import 'package:test/test.dart';

void main() {
  late GgTimeline<double> timeline;

  setUp(
    () {
      timeline = exampleGgTimeline();
      timeline.jumpToBeginning();
    },
  );

  group('GgTimeline', () {
    // #########################################################################
    group('initialization', () {
      test('should work fine', () {
        expect(timeline, isNotNull);
        expect(timeline.items.length, ExampleTimeline.numItems);
        expect(timeline.item(0.0), timeline.items.first);
        expect(timeline.item(0.0).validFrom, 0.0);
        expect(timeline.item(0.0).validTo, 1.0);
        expect(timeline.item(1.0).validFrom, 1.0);
        expect(timeline.item(1.0).validTo, 2.0);
        expect(timeline.seed, 0);
      });
    });

    group('currentItem, nextItem, jumpToOrBefore, jumpToBeginning', () {
      test('should set current item to the right one', () {
        expect(timeline.currentItem, timeline.items.first);
        expect(timeline.nextItem, timeline.items[1]);
        timeline.jumpToOrBefore(100);
        expect(timeline.currentItem, timeline.items.last);
        expect(timeline.nextItem, timeline.items.last);
        timeline.jumpToOrBefore(0.0);
        expect(timeline.currentItem, timeline.items.first);
        expect(timeline.nextItem, timeline.items[1]);
      });
    });

    group('tryToReplaceLastItem', () {
      test('should replace last item if time matches, otherwise not', () {
        expect(timeline.currentItem, timeline.items.first);
        timeline.jumpToOrBefore(100);

        const replacedData = 50.0;

        // Time does not match -> dont' replace
        var didReplace = timeline.tryToReplaceExistingItem(
          data: replacedData,
          timePosition: 123890,
        );

        expect(didReplace, isFalse);

        // Time does match -> replace
        didReplace = timeline.tryToReplaceExistingItem(
          data: 50,
          timePosition: timeline.items.last.validFrom,
        );

        expect(didReplace, isTrue);
        expect(timeline.items.last.data, replacedData);
      });
    });

    group('addOrReplaceItem', () {
      const data = 123.0;

      test('should replace an existing item with the same timePosition', () {
        final existingItem = timeline.currentItem;
        expect(existingItem, timeline.items.first);
        timeline.addOrReplaceItem(
            data: data, timePosition: existingItem.validFrom);
        expect(timeline.items.first.data, data);
      });

      test('should add an item if no item with same time position exists.', () {
        final validFrom = timeline.items.last.validFrom + 1;
        timeline.addOrReplaceItem(data: data, timePosition: validFrom);

        expect(timeline.items.last.data, data);
        expect(timeline.items.last.validFrom, validFrom);
      });

      test('should insert an item if no item with same time position exists.',
          () {
        // Check item count before
        final itemCountBefore = timeline.items.length;

        // Insert item in the middle between first and second item
        timeline.addOrReplaceItem(data: 0.5, timePosition: 0.5);
        expect(timeline.items.length, itemCountBefore + 1);

        final addedItem = timeline.item(0.5);
        expect(addedItem, timeline.items[1]);

        // Now the previous item should only endure to the inserted one
        expect(timeline.items.first.validTo, 0.5);
        expect(timeline.items.first.duration, 0.5);

        // The new item should last to the next one
        expect(addedItem.validFrom, 0.5);
        expect(addedItem.validTo, 1.0);
      });

      test('should update previous item\'s validTo value.', () {
        // Check the last item's validTo value
        final lastItemValidFrom = timeline.items.last.validFrom;
        final lastItemDuration = timeline.items.last.duration;
        expect(lastItemValidFrom, 19.0);
        expect(lastItemDuration, 0.0);

        // Add another item one second after last item
        const timeDifference = 1.0;
        final addedItemValidFrom = lastItemValidFrom + timeDifference;
        timeline.addOrReplaceItem(data: data, timePosition: addedItemValidFrom);
        final addedItem = timeline.items.last;

        // Did previously last items duration as well validTo increase?
        final secondLastItem = timeline.items[timeline.items.length - 2];
        expect(secondLastItem.validFrom, 19.0);
        expect(secondLastItem.duration, timeDifference);
        expect(secondLastItem.validTo, addedItem.validFrom);
      });
    });

    // #########################################################################
    group('futureItems(timePosition, n)', () {
      test('should return n items beginning at timePosition', () {
        const count = 2;
        final futureItems =
            timeline.futureItems(timePosition: 0.0, count: count);

        expect(futureItems.first, timeline.items.first);
        expect(futureItems.length, count);
      });

      test('should return available items if count is too big', () {
        const count = 10000;
        final futureItems =
            timeline.futureItems(timePosition: 0.0, count: count);

        expect(futureItems.first, timeline.items.first);
        expect(futureItems.length, timeline.items.length);
      });

      test(
          'should return available items if not enough items are available anymore',
          () {
        const count = 5;
        final futureItems = timeline.futureItems(
          timePosition: timeline.items.last.validFrom,
          count: count,
        );

        expect(futureItems.first, timeline.items.last);
        expect(futureItems.length, 1);
      });
    });

    // #########################################################################
    group('pastItems(timePosition, n)', () {
      test('should return n preceeding items beginning at timePosition', () {
        const count = 5;
        final referenceItem = timeline.items.last;
        final indexOfLastItem = timeline.items.length - 1;
        final firstItem = timeline.items[indexOfLastItem - count + 1];

        final pastItems = timeline.pastItems(
          timePosition: referenceItem.validFrom,
          count: count,
        );

        expect(pastItems, hasLength(count));
        expect(pastItems.first, firstItem);
        expect(pastItems.last, referenceItem);
      });

      test('should return less items if not enough items are available anymore',
          () {
        const count = 5;
        final referenceItem = timeline.items.first;
        final firstItem = referenceItem;

        final pastItems = timeline.pastItems(
          timePosition: referenceItem.validFrom,
          count: count,
        );

        expect(pastItems, hasLength(1));
        expect(pastItems.first, firstItem);
        expect(pastItems.last, firstItem);
      });
    });
  });
}
