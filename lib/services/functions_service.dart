import 'package:cloud_functions/cloud_functions.dart';

/// Acesso às Cloud Functions do projeto.
///
/// As callables (`sendVerificationOtp`, `verifyOtp`, `createVaccineRecord`,
/// `updateVaccineStatus`) estão publicadas na região **southamerica-east1**.
/// Use SEMPRE este `instance` — `FirebaseFunctions.instance` (sem região)
/// resolve para `us-central1` e a chamada falha com `not-found`. Ver §4 / F1.1.
class FunctionsService {
  static const String region = 'southamerica-east1';

  static FirebaseFunctions get instance =>
      FirebaseFunctions.instanceFor(region: region);
}
