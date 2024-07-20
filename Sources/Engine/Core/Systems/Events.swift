struct Event {
  enum EventName {
    case entityCreated(_ entity: Entity)
    case entityDestroyed(_ entity: Entity)
  }

  let name: EventName
}

struct EventQueue {
  private var events: [Event] = []
  private var subscribers: [ObjectIdentifier: (Event) -> Void] = [:]

  mutating func dispatch(_ event: Event) {
    print("Event dispatched: \(event.name)")
    events.append(event)
  }

  func process(_ handler: (Event) -> Void) async {
    for event in events {
      handler(event)
    }
  }

}
