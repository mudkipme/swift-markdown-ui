import Foundation
import Markdown

enum Block: Hashable {
  case blockquote([Block])
  case taskList(tight: Bool, items: [TaskListItem])
  case bulletedList(tight: Bool, items: [ListItem])
  case numberedList(tight: Bool, start: Int, items: [ListItem])
  case codeBlock(info: String?, content: String)
  case htmlBlock(String)
  case paragraph([Inline])
  case heading(level: Int, text: [Inline])
  case table(columnAlignments: [Markdown.Table.ColumnAlignment?], rows: [[[Inline]]])
  case thematicBreak
}

extension Block {
  init?(node: BlockMarkup) {
    switch node {
    case let blockquote as Markdown.BlockQuote:
      self = .blockquote(blockquote.blockChildren.compactMap(Block.init(node:)))
    case let list as Markdown.UnorderedList where list.listItems.contains { $0.checkbox != nil }:
      self = .taskList(
        tight: true,
        items: list.listItems.compactMap(TaskListItem.init(node:))
      )
    case let list as Markdown.UnorderedList:
      self = .bulletedList(
        tight: true,
        items: list.listItems.compactMap(ListItem.init(node:))
      )
    case let list as Markdown.OrderedList:
      self = .numberedList(
        tight: true,
        start: Int(list.startIndex),
        items: list.listItems.compactMap(ListItem.init(node:))
      )
    case let codeBlock as Markdown.CodeBlock:
      self = .codeBlock(info: codeBlock.language, content: codeBlock.code)
    case let htmlBlock as Markdown.HTMLBlock:
      self = .htmlBlock(htmlBlock.rawHTML)
    case let paragraph as Markdown.Paragraph:
      self = .paragraph(paragraph.inlineChildren.compactMap(Inline.init(node:)))
    case let heading as Markdown.Heading:
      self = .heading(level: heading.level, text: heading.inlineChildren.compactMap(Inline.init(node:)))
    case let table as Markdown.Table:
      self = .table(
        columnAlignments: table.columnAlignments,
        rows: table.body.rows.compactMap { rowNode in
          return rowNode.cells.compactMap { cellNode in
            return cellNode.inlineChildren.compactMap(Inline.init(node:))
          }
        }
      )
    case is Markdown.ThematicBreak:
      self = .thematicBreak
    default:
      assertionFailure("Unknown block type '\(node.debugDescription())'")
      return nil
    }
  }

  var isParagraph: Bool {
    guard case .paragraph = self else { return false }
    return true
  }
}

extension Array where Element == Block {
  init(markdown: String) {
    let node = Document(parsing: markdown)
    let blocks = node.blockChildren.compactMap(Block.init(node:))

    self.init(blocks)
  }
}

extension ListItem {
  fileprivate init?(node: Markdown.ListItem) {
    self.init(blocks: .init(node.blockChildren.compactMap(Block.init(node:))))
  }
}

extension TaskListItem {
  fileprivate init?(node: Markdown.ListItem) {
    self.init(
      isCompleted: node.checkbox == .checked,
      blocks: .init(node.blockChildren.compactMap(Block.init(node:))),
      node: node
    )
  }
}
