import Foundation
import RegexBuilder

struct HTMLStringDecoder {
    let pattern = Regex {
        "&"
        Capture {
            ChoiceOf {
                Regex {
                    "#"
                    Optionally {
                        "x"
                    }
                    OneOrMore {
                        .hexDigit
                    }
                }
                OneOrMore(.word)
            }
        }
        ";"
    }
    
    func decode(_ string: String) -> String {
        var result = ""
        var lastIndex = string.startIndex

        for match in string.matches(of: pattern) {
            // `range.lowerBound` までの通常テキストを追加
            result += string[lastIndex..<match.range.lowerBound]

            let entity = String(match.1)

            if let decoded = decodeEntity(entity) {
                result += decoded
            } else {
                // 不明なエンティティはそのまま追加
                result += String(string[match.range])
            }

            lastIndex = match.range.upperBound
        }

        // 残りの文字列を追加
        result += string[lastIndex...]
        return result
    }
    
    private func decodeEntity(_ entity: String) -> String? {
        if entity.hasPrefix("#x") || entity.hasPrefix("#X") {
            return decodeNumeric(entity.dropFirst(2), radix: 16)
        } else if entity.hasPrefix("#") {
            return decodeNumeric(entity.dropFirst(1), radix: 10)
        } else {
            return entiries[entity]
        }
    }

    private func decodeNumeric(_ digits: Substring, radix: Int) -> String? {
        guard let codePoint = UInt32(digits, radix: radix) else { return nil }
        guard let scalar = UnicodeScalar(codePoint) else { return nil }
        return String(scalar)
    }
}
