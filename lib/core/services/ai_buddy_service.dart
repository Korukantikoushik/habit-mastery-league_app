class AIBuddyService {
  String getMessage(int streak, double score) {
    if (streak >= 7) {
      return "🔥 You're unstoppable! Keep the streak alive!";
    } else if (score > 70) {
      return "💪 Great consistency! You're building momentum.";
    } else if (score > 40) {
      return "📈 You're improving! Stay consistent.";
    } else {
      return "🚀 Start small. Consistency beats perfection.";
    }
  }
}
