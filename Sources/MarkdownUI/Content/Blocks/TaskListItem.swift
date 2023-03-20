import Foundation
import Markdown

/// A Markdown task list item.
///
/// You can use task list items to compose task lists.
///
/// ```swift
/// Markdown {
///   Paragraph {
///     "Things to do:"
///   }
///   TaskList {
///     TaskListItem(isCompleted: true) {
///       Paragraph {
///         Strikethrough("A finished task")
///       }
///     }
///     TaskListItem {
///       "An unfinished task"
///     }
///     "Another unfinished task"
///   }
/// }
/// ```
public struct TaskListItem: Hashable {
  let isCompleted: Bool
  let blocks: [Block]
  let node: Markdown.ListItem?

  init(isCompleted: Bool, blocks: [Block], node: Markdown.ListItem?) {
    self.isCompleted = isCompleted
    self.blocks = blocks
    self.node = node
  }

  init(_ text: String) {
    self.init(isCompleted: false, blocks: [.paragraph([.text(text)])], node: nil)
  }

  public init(isCompleted: Bool = false, @MarkdownContentBuilder content: () -> MarkdownContent) {
    self.init(isCompleted: isCompleted, blocks: content().blocks, node: nil)
  }
}

extension Markdown.ListItem: Hashable {
  public static func == (lhs: Markdown.ListItem, rhs: Markdown.ListItem) -> Bool {
    return lhs.format() == rhs.format()
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(format())
  }
}
