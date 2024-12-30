//
//  PgyerTest.swift
//  IPATool
//
//  Created by liyang on 2024/12/28.
//

import Foundation

//let proj = ("ColTmpTest", "ExportOptions_coltmptest.plist", "")
let proj = ("TestMe_ios", "ExportOptions_realme.plist", "Real-Me")
//let proj = ("Collage", "ExportOptions_collage.plist", "")

private func archive(upload: Bool) {
    do {
        
        let projectPath = "/Users/liyang/Desktop/Program/Unbing/SourceTree/Project/" + proj.0
        let ipatoolPath = "/Users/liyang/Desktop/Program/Unbing/SourceTree/Github/IPATool/IPATool/"
        let exportOp = ipatoolPath + "Pgyer/Resource/" + proj.1
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
//        print("开始执行clean")
//        var output = ipaTool.clean()
//        if output.readData.count > 0 {
//            print("执行clean失败 error = \(output.readData)")
//            exit(-1)
//        }
        print("开始执行archive")
        var output = ipaTool.archive()
        if !FileManager.default.fileExists(atPath: ipaTool.xcarchive) {
            print("执行archive失败 error = \(output.readData)")
            exit(-1)
        }
        print("开始执行exportArchive")
        output = ipaTool.exportArchive()
        
        let productName = !proj.2.isEmpty ? proj.2 : ipaTool.scheme
        let ipaPath = ipaTool.exportIpaPath.appPath("\(productName).ipa")
        if !FileManager.default.fileExists(atPath: ipaPath) {
            print("执行失败exportArchive error =\(output.readData)")
            exit(-1)
        }
        print("导出ipa成功\(ipaTool.exportIpaPath)")
        guard upload else { return }
        print("开始上传蒲公英")
        ipaTool.updload(ipaPath)
    } catch {
        print(error)
    }
}

func pgyer_test() {
    archive(upload: true)
}
