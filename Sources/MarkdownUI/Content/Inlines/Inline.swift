import Foundation
import Markdown

enum Inline: Hashable {
  case text(String)
  case softBreak
  case lineBreak
  case code(String)
  case html(String)
  case emphasis([Inline])
  case strong([Inline])
  case strikethrough([Inline])
  case link(destination: String, children: [Inline])
  case image(source: String, children: [Inline])
}

extension Inline {
  init?(node: InlineMarkup) {
    switch node {
    case let text as Markdown.Text:
      self = .text(text.plainText)
    case is Markdown.SoftBreak:
      self = .softBreak
    case is Markdown.LineBreak:
      self = .lineBreak
    case let code as Markdown.InlineCode:
      self = .code(code.code)
    case let html as Markdown.InlineHTML:
      self = .html(html.rawHTML)
    case let emphasis as Markdown.Emphasis:
      self = .emphasis(emphasis.inlineChildren.compactMap(Inline.init(node:)))
    case let strong as Markdown.Strong:
      self = .strong(strong.inlineChildren.compactMap(Inline.init(node:)))
    case let strikethrough as Markdown.Strikethrough:
      self = .strikethrough(strikethrough.inlineChildren.compactMap(Inline.init(node:)))
    case let link as Markdown.Link:
      self = .link(
        destination: link.destination ?? "",
        children: link.inlineChildren.compactMap(Inline.init(node:))
      )
    case let image as Markdown.Image:
      self = .image(
        source: image.source ?? "",
        children: image.inlineChildren.compactMap(Inline.init(node:))
      )
    default:
      assertionFailure("Unknown inline type '\(node.debugDescription())'")
      return nil
    }
  }

  var text: String {
    switch self {
    case .text(let content):
      return content
    case .softBreak:
      return " "
    case .lineBreak:
      return "\n"
    case .code(let content):
      return content
    case .html(let content):
      return content
    case .emphasis(let children):
      return children.text
    case .strong(let children):
      return children.text
    case .strikethrough(let children):
      return children.text
    case .link(_, let children):
      return children.text
    case .image(_, let children):
      return children.text
    }
  }
}

extension Array where Element == Inline {
  var text: String {
    map(\.text).joined()
  }
}

extension Inline {
  struct Image: Hashable {
    var source: String?
    var alt: String
    var destination: String?
  }

  var image: Image? {
    switch self {
    case let .image(source, children):
      return .init(source: source, alt: children.text)
    case let .link(destination, children) where children.count == 1:
      guard case let .some(.image(source, children)) = children.first else {
        return nil
      }
      return .init(source: source, alt: children.text, destination: destination)
    default:
      return nil
    }
  }
}
