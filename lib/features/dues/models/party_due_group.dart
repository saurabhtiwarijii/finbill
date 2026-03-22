/// Groups multiple due entries belonging to the same party.
///
/// Used purely for UI grouping — not persisted to Firestore.
class PartyDueGroup {
  final String partyName;
  final String phoneNumber;
  final double totalAmount;
  final List<Map<String, dynamic>> dues;

  PartyDueGroup({
    required this.partyName,
    this.phoneNumber = '',
    required this.totalAmount,
    required this.dues,
  });
}
