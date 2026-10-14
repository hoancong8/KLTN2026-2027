// lib/domain/entities/session/session_detail.dart

import 'guest_recruitment.dart';
import 'session.dart';
import 'session_booking.dart';

class SessionDetail {
  final Session session;
  final List<SessionBooking> confirmedPlayers;
  final List<SessionBooking> waitingQueue;
  final GuestRecruitment? activeRecruitment;

  const SessionDetail({
    required this.session,
    required this.confirmedPlayers,
    required this.waitingQueue,
    this.activeRecruitment,
  });
}
