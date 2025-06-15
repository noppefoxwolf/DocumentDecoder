# DocumentDecoder

```swift
let html = "<html>...</html>"
let decoder = DocumentDecoder()
let node: HTMLNode = try decoder.decode(html)
let attributedText: AttributedString = try decoder.decode(html)
```
