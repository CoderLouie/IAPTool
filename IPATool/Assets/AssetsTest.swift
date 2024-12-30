//
//  AssetsTest.swift
//  IPATool
//
//  Created by liyang on 2024/12/28.
//

import Foundation


fileprivate enum Assets {
    private static var inputPath = "/Users/liyang/Desktop/Program/2024/02/Assets.xcassets"
    private static var outputPath = "/Users/liyang/Desktop/Program/2024/02/extract"
    
    //
    static func main() throws {
        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)
        let mgr = FileManager.default
        
        var needRemove: [URL] = []
        func allResFiles(at dir: URL) throws -> [URL] {
            let keys: [URLResourceKey] = [.isDirectoryKey]
            let contents = try mgr.contentsOfDirectory(at: dir, includingPropertiesForKeys: keys)
            if contents.isEmpty { return [] }
            if dir.pathExtension == "imageset" {
                var files = contents.filter { uri in
                    let ext = uri.lastPathComponent
                    return ext.hasSuffix(".png") || ext.hasSuffix("jpg")
                }
                let allPng = files.allSatisfy {
                    $0.lastPathComponent.hasSuffix(".png")
                }
                let allJpg = files.allSatisfy {
                    $0.lastPathComponent.hasSuffix(".jpg")
                }
                
                if !allPng && !allJpg {
                    print("\(dir.path) 包含不同种类资源图!!!")
                    return []
                }
//                try mgr.removeItem(at: dir)
                if !files.isEmpty {
                    needRemove.append(dir)
                    let foldName = dir.deletingPathExtension().lastPathComponent
                    for (i, f) in files.enumerated() {
                        var filename = f.deletingPathExtension().lastPathComponent
                        if filename.contains("@") {
                            filename = String(filename.dropLast(3))
                        }
                        if !filename.hasPrefix(foldName) {
//                            print("\(f.path) 名字被改!!!")
                            let newname = f.lastPathComponent.replacingOccurrences(of: filename, with: foldName)
                            let newurl = dir.appendingPathComponent(newname)
                            try mgr.moveItem(at: f, to: newurl)
                            files[i] = newurl
                        }
                    }
                }
//                print("移除 \(dir.path)")
                return files
            }
            var result: [URL] = []
            for c in contents {
                let values = try c.resourceValues(forKeys: Set(keys))
                let ext = c.pathExtension.lowercased()
                if let v = values.allValues[.isDirectoryKey] as? Bool, v {
                    if !ext.isEmpty, ext != "imageset" { continue }
                    try result.append(contentsOf: allResFiles(at: c))
                } else {
                    if ext == "png" || ext == "jpg" {
                        result.append(c)
                    }
                }
            }
            return result
        }
        let resourceFiles = try allResFiles(at: inputURL)
        guard !resourceFiles.isEmpty else { return }
//        return ();
        
        if mgr.fileExists(atPath: outputPath) {
            try mgr.removeItem(atPath: outputPath)
        }
        try mgr.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
        
        let infos = resourceFiles.map { ($0.lastPathComponent.lowercased(), $0) }
        
        let pngs = infos.filter { $0.0.hasSuffix("png") }
        let png2x = pngs.filter { $0.0.contains("@2x") }.map(\.1)
        let png3x = pngs.filter { $0.0.contains("@3x") }.map(\.1)
        
        let jpgs = infos.filter { $0.0.hasSuffix("jpg") }
        let jpg2x = jpgs.filter { $0.0.contains("@2x") }.map(\.1)
        let jpg3x = jpgs.filter { $0.0.contains("@3x") }.map(\.1)
        
        let svgs = infos.filter { $0.0.hasSuffix("svg") }.map(\.1)
        
        let photos = [("png/2x/", png2x), ("png/3x/", png3x),
                      ("jpg/2x/", jpg2x), ("jpg/3x/", jpg3x),
                      ("svg/", svgs)]
        for p in photos {
            if p.1.isEmpty { continue }
            let dstURL = outputURL.appendingPathComponent(p.0)
            try mgr.createDirectory(at: dstURL, withIntermediateDirectories: true)
            for p in p.1 {
                try mgr.copyItem(at: p, to: dstURL.appendingPathComponent(p.lastPathComponent))
            }
        }
        for uri in needRemove {
            try mgr.removeItem(at: uri)
        }
    }
}


func assets_test() {
    do {
        try Assets.main()
    } catch {
        print("发生错误 \(error)")
    }
}
