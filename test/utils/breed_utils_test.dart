import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/utils/breed_utils.dart';

void main() {
  test('fetchDogBreeds returns a non-empty list', () async {
    final breeds = await BreedUtils.fetchDogBreeds();
    expect(breeds, isNotEmpty);
  });
}
