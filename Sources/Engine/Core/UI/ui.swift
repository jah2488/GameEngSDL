import Foundation

protocol UIComponent {
  func render() -> String
}

struct Text: UIComponent {
  let content: String

  func render() -> String {
    return content
  }
}

struct Button: UIComponent {
  let label: String

  func render() -> String {
    return "[ \(label) ]"
  }
}

struct VStack: UIComponent {
  let components: [UIComponent]

  func render() -> String {
    return components.map { $0.render() }.joined(separator: "\n")
  }
}

@resultBuilder
struct UIBuilder {
  static func buildBlock(_ components: UIComponent...) -> [UIComponent] {
    return components
  }

  static func buildIf(_ component: UIComponent?) -> UIComponent? {
    return component
  }

  static func buildEither(first: UIComponent) -> UIComponent {
    return first
  }

  static func buildEither(second: UIComponent) -> UIComponent {
    return second
  }
}

func ui(@UIBuilder content: () -> [UIComponent]) -> UIComponent {
  return VStack(components: content())
}
