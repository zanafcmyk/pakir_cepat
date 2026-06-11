import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parkir_cepat/app.dart';
import 'package:parkir_cepat/models/app_models.dart';

void main() {
  testWidgets('renders Parkir Cepat splash content', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ParkirCepatApp()));

    expect(find.text('Parkir Cepat'), findsOneWidget);
    expect(find.textContaining('Smart parking'), findsOneWidget);
  });

  test('calculates parking cost from vehicle tariff settings', () {
    final lot = AppState.seeded().lots.first.copyWith(
      tariffType: ParkingTariffType.progressive,
      motorRate: 4000,
      carRate: 10000,
      truckRate: 20000,
    );
    const car = Vehicle(
      id: 'veh-test',
      plateNumber: 'B 1010 TST',
      kind: VehicleKind.mobil,
      quantity: 1,
      durationHours: 3,
    );

    expect(calculateParkingCost(lot, car), 20000);
    expect(
      calculateParkingCost(
        lot.copyWith(tariffType: ParkingTariffType.flat),
        car,
      ),
      10000,
    );
    expect(
      calculateParkingCost(
        lot.copyWith(tariffType: ParkingTariffType.hourly),
        car,
      ),
      30000,
    );
    expect(
      calculateParkingCost(
        lot.copyWith(tariffType: ParkingTariffType.daily),
        car,
      ),
      10000,
    );
  });

  test('updates and deletes provider parking lots', () {
    final controller = AppController();
    final firstLot = controller.state.lots.first;

    controller.updateLot(
      id: firstLot.id,
      name: 'Plaza Sudirman Updated',
      address: 'Jl. Sudirman Baru',
      capacity: 88,
      price: 14000,
      mapEmbedUrl:
          'https://www.google.com/maps?q=-6.2087145,106.8224854&output=embed',
      latitude: -6.2087145,
      longitude: 106.8224854,
      tariffType: ParkingTariffType.flat,
      motorRate: 6000,
      carRate: 14000,
      truckRate: 25000,
    );

    expect(controller.state.lots.first.name, 'Plaza Sudirman Updated');
    expect(controller.state.lots.first.totalSlots, 88);
    expect(controller.state.lots.first.tariffType, ParkingTariffType.flat);

    controller.deleteLot(firstLot.id);

    expect(controller.state.lots.any((lot) => lot.id == firstLot.id), isFalse);
    expect(controller.state.lots, isNotEmpty);
  });

  test('tracks provider feedback and replies to complaints', () {
    final controller = AppController();
    final feedback = providerFeedbackFor(controller.state);

    expect(feedback, isNotEmpty);
    expect(averageFeedbackRating(feedback), greaterThan(0));
    expect(satisfactionScore(feedback), greaterThan(0));

    final complaint = feedback.firstWhere((item) => item.isComplaint);

    controller.replyToProviderFeedback(
      feedbackId: complaint.id,
      reply: 'Mohon maaf, tim kami sudah menyiapkan slot pengganti.',
    );

    final updated = controller.state.providerFeedback.firstWhere(
      (item) => item.id == complaint.id,
    );

    expect(updated.status, 'Dibalas');
    expect(updated.providerReply, contains('slot pengganti'));
  });
}
