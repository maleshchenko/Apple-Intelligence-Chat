//
//  ArticleFetchTool.swift
//  Apple Intelligence Chat
//
//  Created by Mykola Aleshchenko on 31/8/26.
//

import Foundation
import FoundationModels

struct ArticleFetchTool: Tool {
    let name = "fetchArticle"
    let description = "Download and extract readable text from an article URL. Only use when search results lack enough detail to answer the question."

    @Generable
    struct Arguments {
        @Guide(description: "The full URL of the article to fetch")
        var url: String
    }

    func call(arguments: Arguments) async throws -> String {
        guard let url = URL(string: arguments.url) else {
            return "Invalid URL."
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let html = String(data: data, encoding: .utf8) else {
            return "Unable to read article content."
        }

        return HTMLStripper.excerpt(html, maxLength: 800)
    }
}
