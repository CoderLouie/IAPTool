//
//  main.swift
//  IPATool
//
//  Created by liyang on 2024/12/4.
//

import Foundation

//let proj = ("ColTmpTest", "ExportOptions_coltmptest")
let proj = ("TestMe_ios", "ExportOptions_realme")
//let proj = ("Collage", "ExportOptions")

do {
    
    let projectPath = "/Users/liyang/Desktop/Program/Unbing/SourceTree/Project/" + proj.0
    let ipatoolPath = "/Users/liyang/Desktop/Program/2024/Github/IPATools/IPATools/"
    let exportOp = ipatoolPath + proj.1 + ".plist"
    let pgyer_api_key = "2854841da9b34bc369b95ec171afd5af"
    let ipaTool = try IpaTool(projectPath: projectPath,
                              configuration: .release,
                              exportOptionsPlist: exportOp,
                              pgyerKey: pgyer_api_key)
    
    /*
     var output = ipaTool.podInstall()
     print(output.readData)
     exit(-1)
     print(ipaTool)
     print("执行clean")
     */
    print("开始执行clean")
    var output = ipaTool.clean()
    if output.readData.count > 0 {
        print("执行clean失败 error = \(output.readData)")
        exit(-1)
    }
    print("开始执行archive")
    output = ipaTool.archive()
    if !FileManager.default.fileExists(atPath: ipaTool.xcarchive) {
        print("执行archive失败 error = \(output.readData)")
        exit(-1)
    }
    print("开始执行exportArchive")
    output = ipaTool.exportArchive()
    
    if !FileManager.default.fileExists(atPath: ipaTool.exportIpaPath.appPath("\(ipaTool.scheme).ipa")) {
        print("执行失败exportArchive error =\(output.readData)")
        exit(-1)
    }
    print("导出ipa成功\(ipaTool.exportIpaPath)")
    print("开始上传蒲公英")
    ipaTool.update()
} catch {
    print(error)
}

