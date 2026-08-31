//
//  WebSearchTool.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import Foundation
import FoundationModels

/// Shared mutable flag — written by the tool, read by ContentView after generation.
final class SearchUsedFlag: @unchecked Sendable {
    nonisolated(unsafe) var value = false
}

struct WebSearchTool: Tool {
    let name = "searchWeb"
    let description = "Search recent news and current events."
    let searchUsedFlag: SearchUsedFlag

    @Generable
    struct Arguments {
        @Guide(description: "The search query")
        var query: String
    }

    func call(arguments: Arguments) async throws -> String {
        searchUsedFlag.value = true
        let encoded = arguments.query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://news.google.com/rss/search?q=\(encoded)") else {
            return "Unable to perform search."
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let xml = String(data: data, encoding: .utf8) else {
            return "No results found."
        }

        let items = parseRSSItems(from: xml, maxCount: 3)
        guard !items.isEmpty else {
            return "No results found for '\(arguments.query)'."
        }

        return items.enumerated().map { index, item in
            var lines = ["\(index + 1). \(item.title)"]
            if !item.description.isEmpty {
                lines.append(item.description)
            }
            if !item.link.isEmpty {
                lines.append("Source: \(item.link)")
            }
            return lines.joined(separator: "\n")
        }.joined(separator: "\n\n")
    }

    // MARK: - Private RSS Parsing

    private struct RSSItem {
        let title: String
        let link: String
        let description: String
    }

    private func parseRSSItems(from xml: String, maxCount: Int) -> [RSSItem] {
        guard let itemRegex = try? NSRegularExpression(
            pattern: "<item>(.*?)</item>",
            options: .dotMatchesLineSeparators
        ) else { return [] }

        let fullRange = NSRange(xml.startIndex..., in: xml)
        let matches = itemRegex.matches(in: xml, range: fullRange)

        return matches.prefix(maxCount).compactMap { match in
            guard let range = Range(match.range(at: 1), in: xml) else { return nil }
            let block = String(xml[range])
            let title = extractField("title", from: block)
            let link = extractField("link", from: block)
            let description = HTMLStripper.excerpt(extractField("description", from: block), maxLength: 100)
            guard !title.isEmpty else { return nil }
            return RSSItem(title: title, link: link, description: description)
        }
    }

    private func extractField(_ field: String, from xml: String) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: "<\(field)>(.*?)</\(field)>",
            options: .dotMatchesLineSeparators
        ),
        let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
        let range = Range(match.range(at: 1), in: xml) else { return "" }

        var content = String(xml[range])
        if content.hasPrefix("<![CDATA[") { content.removeFirst(9) }
        if content.hasSuffix("]]>") { content.removeLast(3) }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
