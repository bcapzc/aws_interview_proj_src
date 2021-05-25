class LatencyData {
  List<LatencyItem> latencyQueue = [];

  void append(Duration newLatency) {
    if (isFull()) { latencyQueue.removeAt(0); }
    latencyQueue.add(LatencyItem(DateTime.now(), newLatency));
  }

  bool isFull() {
    if (latencyQueue.length >= 3) {
      return true;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    String str = "";
    latencyQueue.forEach((item) { str += item.toString() + "\n"; });
    return str;
  }
}

class LatencyItem {
  DateTime time;
  Duration latency;

  LatencyItem(this.time, this.latency);

  @override
  String toString() {
    return time.toString().substring(0, 19) + "   " +
        latency.inMilliseconds.toString() + "ms";
  }
}