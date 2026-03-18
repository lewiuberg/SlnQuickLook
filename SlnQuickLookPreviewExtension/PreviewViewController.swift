//
//  PreviewViewController.swift
//  SlnQuickLookPreviewExtension
//
//  Created by Lewi Uberg on 18/03/2026.
//

import Cocoa
import Quartz
import WebKit

class LineNumberTextView: NSTextView {
    override func writeSelection(to pboard: NSPasteboard, types: [NSPasteboard.PasteboardType]) -> Bool {
        guard let textStorage = self.textStorage else {
            return super.writeSelection(to: pboard, types: types)
        }
        
        let selectedRange = self.selectedRange()
        let selectedText = textStorage.attributedSubstring(from: selectedRange).string
        
        let lines = selectedText.components(separatedBy: .newlines)
        var cleanedLines: [String] = []
        
        for line in lines {
            if let match = line.range(of: "^\\s*\\d+\\s+", options: .regularExpression) {
                let cleanLine = String(line[match.upperBound...])
                cleanedLines.append(cleanLine)
            } else {
                cleanedLines.append(line)
            }
        }
        
        let cleanedText = cleanedLines.joined(separator: "\n")
        pboard.clearContents()
        pboard.setString(cleanedText, forType: .string)
        
        return true
    }
}

class PreviewViewController: NSViewController, QLPreviewingController {
    
    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
    }

    func preparePreviewOfFile(at url: URL) async throws {
        print("🔍 Preview requested for: \(url.lastPathComponent)")
        
        let data = try Data(contentsOf: url)
        let text = String(decoding: data, as: UTF8.self)
        
        print("📄 File size: \(data.count) bytes, text length: \(text.count)")
        
        await MainActor.run {
            print("🎨 Creating syntax-highlighted view")
            
            let isXML = url.pathExtension.lowercased() == "slnx" || text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<")
            
            let backgroundColor = NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
            
            let scrollView = NSScrollView(frame: self.view.bounds)
            scrollView.autoresizingMask = [.width, .height]
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = true
            scrollView.borderType = .noBorder
            scrollView.backgroundColor = backgroundColor
            
            let textView = LineNumberTextView(frame: scrollView.bounds)
            textView.autoresizingMask = []
            textView.isEditable = false
            textView.isSelectable = true
            textView.backgroundColor = backgroundColor
            textView.textContainerInset = NSSize(width: 10, height: 10)
            textView.isHorizontallyResizable = true
            textView.isVerticallyResizable = true
            textView.textContainer?.widthTracksTextView = false
            textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            
            let contentString = self.syntaxHighlightWithLineNumbers(text: text, isXML: isXML)
            textView.textStorage?.setAttributedString(contentString)
            
            scrollView.documentView = textView
            
            self.view.subviews.forEach { $0.removeFromSuperview() }
            self.view.addSubview(scrollView)
            
            print("✅ Preview loaded successfully")
        }
        
        print("✅ Preview preparation complete")
    }
    
    private func syntaxHighlightWithLineNumbers(text: String, isXML: Bool) -> NSAttributedString {
        let lines = text.components(separatedBy: .newlines)
        let attributedString = NSMutableAttributedString()
        
        let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let lineNumberColor = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let textColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        let tagColor = NSColor(red: 0.34, green: 0.68, blue: 0.53, alpha: 1.0)
        let attributeNameColor = NSColor(red: 0.61, green: 0.79, blue: 0.89, alpha: 1.0)
        let attributeValueColor = NSColor(red: 0.81, green: 0.65, blue: 0.49, alpha: 1.0)
        let stringColor = NSColor(red: 0.81, green: 0.65, blue: 0.49, alpha: 1.0)
        
        let maxLineNumber = lines.count
        let lineNumberWidth = "\(maxLineNumber)".count
        
        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let lineNumberStr = String(format: "%\(lineNumberWidth)d  ", lineNumber)
            
            let lineNumberAttr = NSAttributedString(
                string: lineNumberStr,
                attributes: [
                    .font: monoFont,
                    .foregroundColor: lineNumberColor
                ]
            )
            attributedString.append(lineNumberAttr)
            
            if isXML {
                let highlightedLine = highlightXMLLine(line, monoFont: monoFont, textColor: textColor, tagColor: tagColor, attributeNameColor: attributeNameColor, attributeValueColor: attributeValueColor, stringColor: stringColor)
                attributedString.append(highlightedLine)
            } else {
                let highlightedLine = highlightSlnLine(line, monoFont: monoFont, textColor: textColor, tagColor: tagColor, stringColor: stringColor)
                attributedString.append(highlightedLine)
            }
            
            if index < lines.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        return attributedString
    }
    
    private func syntaxHighlightContent(text: String, isXML: Bool) -> NSAttributedString {
        let lines = text.components(separatedBy: .newlines)
        let attributedString = NSMutableAttributedString()
        
        let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let textColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        let tagColor = NSColor(red: 0.34, green: 0.68, blue: 0.53, alpha: 1.0)
        let attributeNameColor = NSColor(red: 0.61, green: 0.79, blue: 0.89, alpha: 1.0)
        let attributeValueColor = NSColor(red: 0.81, green: 0.65, blue: 0.49, alpha: 1.0)
        let stringColor = NSColor(red: 0.81, green: 0.65, blue: 0.49, alpha: 1.0)
        
        for (index, line) in lines.enumerated() {
            if isXML {
                let highlightedLine = highlightXMLLine(line, monoFont: monoFont, textColor: textColor, tagColor: tagColor, attributeNameColor: attributeNameColor, attributeValueColor: attributeValueColor, stringColor: stringColor)
                attributedString.append(highlightedLine)
            } else {
                let highlightedLine = highlightSlnLine(line, monoFont: monoFont, textColor: textColor, tagColor: tagColor, stringColor: stringColor)
                attributedString.append(highlightedLine)
            }
            
            if index < lines.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        return attributedString
    }
    
    private func highlightXMLLine(_ line: String, monoFont: NSFont, textColor: NSColor, tagColor: NSColor, attributeNameColor: NSColor, attributeValueColor: NSColor, stringColor: NSColor) -> NSAttributedString {
        let result = NSMutableAttributedString()
        var currentIndex = line.startIndex
        
        while currentIndex < line.endIndex {
            if line[currentIndex] == "<" {
                if let tagEnd = line[currentIndex...].firstIndex(of: ">") {
                    let tagContent = String(line[currentIndex...tagEnd])
                    let highlightedTag = highlightXMLTag(tagContent, monoFont: monoFont, tagColor: tagColor, attributeNameColor: attributeNameColor, attributeValueColor: attributeValueColor, stringColor: stringColor)
                    result.append(highlightedTag)
                    currentIndex = line.index(after: tagEnd)
                } else {
                    result.append(NSAttributedString(string: String(line[currentIndex]), attributes: [.font: monoFont, .foregroundColor: textColor]))
                    currentIndex = line.index(after: currentIndex)
                }
            } else {
                result.append(NSAttributedString(string: String(line[currentIndex]), attributes: [.font: monoFont, .foregroundColor: textColor]))
                currentIndex = line.index(after: currentIndex)
            }
        }
        
        return result
    }
    
    private func highlightXMLTag(_ tag: String, monoFont: NSFont, tagColor: NSColor, attributeNameColor: NSColor, attributeValueColor: NSColor, stringColor: NSColor) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        result.append(NSAttributedString(string: "<", attributes: [.font: monoFont, .foregroundColor: tagColor]))
        
        let innerContent = tag.dropFirst().dropLast()
        var inQuotes = false
        var currentWord = ""
        var isFirstWord = true
        var lastWasEquals = false
        
        for char in innerContent {
            if char == "\"" {
                if !currentWord.isEmpty {
                    let color = lastWasEquals ? stringColor : (isFirstWord ? tagColor : attributeNameColor)
                    result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
                    currentWord = ""
                    isFirstWord = false
                    lastWasEquals = false
                }
                result.append(NSAttributedString(string: "\"", attributes: [.font: monoFont, .foregroundColor: stringColor]))
                inQuotes.toggle()
            } else if inQuotes {
                result.append(NSAttributedString(string: String(char), attributes: [.font: monoFont, .foregroundColor: stringColor]))
            } else if char == "=" {
                if !currentWord.isEmpty {
                    result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: isFirstWord ? tagColor : attributeNameColor]))
                    currentWord = ""
                    isFirstWord = false
                }
                result.append(NSAttributedString(string: "=", attributes: [.font: monoFont, .foregroundColor: tagColor]))
                lastWasEquals = true
            } else if char.isWhitespace || char == "/" {
                if !currentWord.isEmpty {
                    let color = isFirstWord ? tagColor : attributeNameColor
                    result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
                    currentWord = ""
                    isFirstWord = false
                    lastWasEquals = false
                }
                result.append(NSAttributedString(string: String(char), attributes: [.font: monoFont, .foregroundColor: tagColor]))
            } else {
                currentWord.append(char)
            }
        }
        
        if !currentWord.isEmpty {
            let color = isFirstWord ? tagColor : attributeNameColor
            result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
        }
        
        result.append(NSAttributedString(string: ">", attributes: [.font: monoFont, .foregroundColor: tagColor]))
        
        return result
    }
    
    private func highlightSlnLine(_ line: String, monoFont: NSFont, textColor: NSColor, tagColor: NSColor, stringColor: NSColor) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        let keywordColor = NSColor(red: 0.34, green: 0.68, blue: 0.53, alpha: 1.0)
        let commentColor = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        
        if trimmed.hasPrefix("#") {
            result.append(NSAttributedString(string: line, attributes: [.font: monoFont, .foregroundColor: commentColor]))
        } else if trimmed.hasPrefix("Project(") || trimmed.hasPrefix("EndProject") || 
                  trimmed.hasPrefix("Global") || trimmed.hasPrefix("EndGlobal") ||
                  trimmed.hasPrefix("GlobalSection") || trimmed.hasPrefix("EndGlobalSection") {
            
            var currentIndex = line.startIndex
            var inString = false
            var currentWord = ""
            
            while currentIndex < line.endIndex {
                let char = line[currentIndex]
                
                if char == "\"" {
                    if !currentWord.isEmpty {
                        let color = currentWord.hasPrefix("Project") || currentWord.hasPrefix("End") || currentWord.hasPrefix("Global") ? keywordColor : textColor
                        result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
                        currentWord = ""
                    }
                    inString.toggle()
                    result.append(NSAttributedString(string: "\"", attributes: [.font: monoFont, .foregroundColor: stringColor]))
                } else if inString {
                    result.append(NSAttributedString(string: String(char), attributes: [.font: monoFont, .foregroundColor: stringColor]))
                } else if char == "(" || char == ")" || char == "=" || char == "," || char.isWhitespace {
                    if !currentWord.isEmpty {
                        let color = currentWord.hasPrefix("Project") || currentWord.hasPrefix("End") || currentWord.hasPrefix("Global") ? keywordColor : textColor
                        result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
                        currentWord = ""
                    }
                    result.append(NSAttributedString(string: String(char), attributes: [.font: monoFont, .foregroundColor: textColor]))
                } else {
                    currentWord.append(char)
                }
                
                currentIndex = line.index(after: currentIndex)
            }
            
            if !currentWord.isEmpty {
                let color = currentWord.hasPrefix("Project") || currentWord.hasPrefix("End") || currentWord.hasPrefix("Global") ? keywordColor : textColor
                result.append(NSAttributedString(string: currentWord, attributes: [.font: monoFont, .foregroundColor: color]))
            }
        } else {
            result.append(NSAttributedString(string: line, attributes: [.font: monoFont, .foregroundColor: textColor]))
        }
        
        return result
    }
}
