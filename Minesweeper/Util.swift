//
//  Util.swift
//  Minesweeper
//
//  Created by Cameron Goddard on 5/30/22.
//

import Foundation
import SpriteKit
import NaturalLanguage
import Defaults

class Util {
    static let scale = CGFloat(1.5)
    
    // TODO: Consider moving these default themes to be actual files
    static let normalClassicTheme = Theme(
        name: "Classic",
        desc: "The original Minesweeper theme",
        isDefault: true,
        isFavorite: Defaults[.favorites].contains("Classic"),
        spriteSheetTexture: SKTexture(imageNamed: "default_spritesheet"),
        backgroundColor: NSColor(red: 61, green: 61, blue: 61, alpha: 1)
    )
    static let classic95Theme = Theme(
        name: "Classic 95",
        desc: "The default theme from Windows 95",
        isDefault: true,
        isFavorite: Defaults[.favorites].contains("Classic 95"),
        spriteSheetTexture: SKTexture(imageNamed: "default_spritesheet_95"),
        backgroundColor: NSColor(red: 61, green: 61, blue: 61, alpha: 1)
    )
    static let darkClassicTheme = Theme(
        name: "Classic Dark",
        isDefault: true,
        isFavorite: Defaults[.favorites].contains("Classic Dark"),
        mode: "Dark",
        spriteSheetTexture: SKTexture(imageNamed: "default_dark_spritesheet"),
        backgroundColor: NSColor(red: 173, green: 173, blue: 173, alpha: 1)
    )
    
    static let defaultThemes = [normalClassicTheme, darkClassicTheme, classic95Theme]
    static var themes = defaultThemes
    static var currentTheme = normalClassicTheme //todo
    //var currentTheme : Theme
    static var difficulties = ["Beginner": [8, 8, 10], "Intermediate": [16, 16, 40], "Hard": [16, 30, 99], "Custom": [8, 8, 1]]
    
    static func convertLocation(name: String) -> Array<Int> {
        let coords = name.components(separatedBy: ",")
        let r = Int(String(coords[0]))!
        let c = Int(String(coords[1]))!
        return [r, c]
    }
    
    static func textureLookup(value: Value) -> SKTexture {
        switch value {
        case .Mine:
            return Util.currentTheme.tiles.mine
        case .MineRed:
            return Util.currentTheme.tiles.mineRed
        case .MineWrong:
            return Util.currentTheme.tiles.mineWrong
        case .One:
            return Util.currentTheme.tiles.one
        case .Two:
            return Util.currentTheme.tiles.two
        case .Three:
            return Util.currentTheme.tiles.three
        case .Four:
            return Util.currentTheme.tiles.four
        case .Five:
            return Util.currentTheme.tiles.five
        case .Six:
            return Util.currentTheme.tiles.six
        case .Seven:
            return Util.currentTheme.tiles.seven
        case .Eight:
            return Util.currentTheme.tiles.eight
        default:
            return Util.currentTheme.tiles.empty
        }
    }
    
    static func readThemes() throws {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let msSupportURL = appSupportURL.appendingPathComponent("Minesweeper Desktop")
        var isDir = ObjCBool(true)
        
        let items = try fileManager.contentsOfDirectory(atPath: msSupportURL.path)
        
        for item in items {
            if item == ".DS_Store" { continue }
            if item == "Themes" {
                let absoluteThemesPath = msSupportURL.appendingPathComponent(item)
                let themes = try fileManager.contentsOfDirectory(atPath: absoluteThemesPath.path)
                for theme in themes {
                    if theme == ".DS_Store" { continue }
                        
                    let absoluteThemePath = absoluteThemesPath.appendingPathComponent(theme)
                    let image = NSImage(contentsOf: absoluteThemePath)!
                    let name = absoluteThemePath.deletingPathExtension().lastPathComponent
                    let isFavorite = Defaults[.favorites].contains(name)
                    print("\(name): \(isFavorite)")
                    let theme = Theme(
                        name: Util.toTheme(name: name),
                        isFavorite: isFavorite,
                        spriteSheetTexture: SKTexture(image: image),
                        backgroundColor: NSColor(red: 61, green: 61, blue: 61, alpha: 1)
                    )
                    Util.themes.append(theme)
                }
            }
        }
    }
    
    // make nonstatic
    static func theme(withName: String) -> Theme {
        for theme in themes {
            if theme.name == withName {
                return theme
            }
        }
        return themes[0]
    }
    
    static func toTheme(name: String) -> String {
        let spaced = name.components(separatedBy: "_").joined(separator: " ")
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = spaced
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        var ret = [String]()
        
        tagger.enumerateTags(in: spaced.startIndex..<spaced.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag {
                if tag == .preposition {
                    ret.append("\(spaced[tokenRange])")
                } else {
                    ret.append("\(spaced[tokenRange])".capitalized)
                }
            }
            return true
        }
        
        return ret.joined(separator: " ")
        
    }
}

extension Defaults.Keys {
    static let favorites = Key<Array<String>>("favorites", default: ["Classic", "Classic Dark", "Classic 95"])
}
