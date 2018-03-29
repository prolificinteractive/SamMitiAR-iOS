//
//  MarkdownElement.swift
//  Marker
//
//  Created by Htin Linn on 5/1/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Markdown element.
///
/// - em: Emphasis element.
/// - strong: Strong element.
/// - strikethrough: Strikethrough element.
/// - underline: Underline element.
/// - link: Link element.
enum MarkdownElement {
    
    case em(range: Range<Index>)
    case strong(range: Range<Index>)
    case strikethrough(range: Range<Index>)
    case underline(range: Range<Index>)
    case link(range: Range<Index>, urlString: String)
    
    /// Range of characters that the elements apply to.
    var range: Range<Index> {
        switch self {
        case .em(let range), .strong(let range), .strikethrough(let range), .underline(let range), .link(let range, _):
            return range
        }
    }

}
