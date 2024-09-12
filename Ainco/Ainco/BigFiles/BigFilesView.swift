//
//  BigFilesView.swift
//  Ainco
//
//  Created by 阿金 on 2023/4/29.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI
import CommonCrypto

struct BigFilesView: View {
    @Binding var showScanView: Bool  //显示状态
    @Binding var progress: Double   //进度条

    @Binding var Files: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> //对应关联文件
    @Binding var TypesSize: Dictionary<Int,Int> //类型总大小
    
    @Binding var FilesSize: Int //文件总大小
    
    @Binding var selectedType: Set<Int>   //当前选中项

    @Binding var isRunningb: Bool    //清理按钮状态
    
    @State private var buttonColor = "8B4513" //按钮颜色
    @State private var buttonColorb = "ais" //重扫按钮颜色
    
    @State private var isRunning = false    //按钮状态
    
    @State private var selectedFiles = Set<Int>()   //文件选中项
    
    @State private var tips = "" //顶部提示
    
    var FilesType: [[String]] = [
        [
            "/System/Applications/Dictionary.app", //图标
            "5 MB 到 500 MB" //名字
        ],
        [
            "/System/Applications/Books.app",
            "500 MB 到 1 GB"
        ]
        ,
        [
            "/System/Applications/Utilities/Activity Monitor.app",
            "1 GB 以上"
        ]
    ]
    
    var body: some View {
        //输出主体内容
        VStack{
            if showScanView {
                Text("📦")
                    .font(.system(size: 100))
                    .padding(.bottom, -10)

                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Circle()
                            .fill(Color(hex: buttonColor))
                            .frame(width: 10, height: 10)
                            
                        Text("扫描大件")
                            .font(.system(size: 26))
                    }
                    Text("查找并移除您Mac上的大文件及重复文件，释放磁盘空间。")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                }
                .contentShape(Rectangle())
                .padding(.top, 15)
                .padding(.bottom, 20)
        
                if progress>0.00 {
                    CustomCircularProgressBar(progress: $progress, CColor: $buttonColor)
                        .frame(width: 60, height: 60)
                } else{
                    CustomButton(buttonText: "开始扫描", action: run, buttonColor: $buttonColor, isRunning: $isRunning)
                }
                

            } else {
                appList
            }
        }
        .frame(minHeight:600)
        .frame(width: 730)
    }
    
    //列表视图
    var appList: some View {
        VStack {
            HStack {
                List(FilesType.indices, id: \.self, selection: $selectedType) { index in
                    HStack {
                        Toggle(isOn: Binding<Bool>(
                            get: { self.selectedType.contains(index) },
                            set: { isSelected in
                                if isSelected {
                                    self.selectedType.insert(index)
                                } else {
                                    self.selectedType.remove(index)
                                }
                            })) {
                                EmptyView()
                            }
                            .toggleStyle(.checkbox)
                        
                        if FilesType[index][0] == "废纸篓" {
                            Image(nsImage: NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kTrashIcon))))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }else{
                            Image(nsImage: NSWorkspace.shared.icon(forFile: "\(FilesType[index][0])"))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        
                        Text(FilesType[index][1])
                            .padding(.leading, 10)
                        Spacer()
                        if let appInfo = TypesSize[index] {
                            if appInfo == 0 {
                                Text("🔆").padding(.leading, 10)
                            }else{
                                Text(toFileSize(size: appInfo))
                                    .padding(.leading, 10)
                            }
                        } else {
                            Text("未知")
                                .padding(.leading, 10)
                        }
                        
                    }
                }.onChanges(of: selectedType) { _ in
                    selectedFiles = Set<Int>()
                    
                    if selectedType.count > 1 {
                        tips = "⚠️注意：多选的情况下，无论下方文件是否选中都会被删除！！！"
                        if let firstElement = selectedType.first,
                           let files = Files[firstElement] {
                            selectedFiles = Set(files.keys.sorted())
                        }
                    }else{
                        tips = "下方列表中背景为灰色的项目为重复文件，相同文件在该项目上方。"
                    }
                    
                }
                .frame(width: 320)
                
                Spacer()
                
                if let firstElement = selectedType.first,
                    let files = Files[firstElement] {
                    VStack {
                        if tips != "" {
                            VStack{
                                Text(tips)
                                    .font(.system(size: 13))
                                    .padding(.top, 8)
                            }.background(Color("Background").frame(width: 410, height: 42))
                        }
                        
                        List(files.keys.sorted(), id: \.self, selection: $selectedFiles) { fileTypeId in
                            HStack {
                                Button(action: {}, label: {
                                    EmptyView()
                                })
                                .buttonStyle(BorderlessButtonStyle())
                                .frame(width: 0, height: 0)
                                .contextMenu {
                                    Button(action: {
                                        if let appPath = files[fileTypeId]?[0] {
                                            let workspace = NSWorkspace.shared
                                            var isDirectory: ObjCBool = true
                                            
                                            if FileManager.default.fileExists(atPath: appPath, isDirectory: &isDirectory) {
                                                workspace.activateFileViewerSelecting([URL(fileURLWithPath: appPath)])
                                            }
                                        }
                                    }, label: {
                                        HStack {
                                            Text("查看文件所在位置")
                                        }
                                    })
                                    Button(action: {
                                        if selectedFiles.count > 0 {
                                            selectedFiles = Set<Int>()
                                        }else{
                                            selectedFiles = Set(files.keys.sorted())
                                        }
                                    }, label: {
                                        HStack {
                                            Text("全选/反选")
                                        }
                                    })
                                }
                                
                                Toggle(isOn: Binding<Bool>(
                                    get: { self.selectedFiles.contains(fileTypeId) },
                                    set: { isSelected in
                                        if isSelected {
                                            self.selectedFiles.insert(fileTypeId)
                                        } else {
                                            self.selectedFiles.remove(fileTypeId)
                                        }
                                    })) {
                                        EmptyView()
                                    }
                                    .toggleStyle(.checkbox)

                                if let image = FindLogo(at: files[fileTypeId]?[0] ?? "") {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                }
                                Text(files[fileTypeId]?[0] ?? "Unknown")
                                    .padding(.leading, 10)
                                Spacer()
                                Text(files[fileTypeId]?[1] ?? "未知")
                                    .padding(.leading, 10)
                            }.background(
                                Color(files[fileTypeId]?[2] != "" ? .gray : .clear)
                                .cornerRadius(8) // 可选：添加圆角
                                .opacity(0.5)
                            )
                            
                        }
                    }.padding(.leading, -8)
                }else{
                    List(){}
                    .padding(.leading, -8)
                }
            }
            
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Text("扫描发现")
                            .font(.system(size: 18))
                        Text("可优化大小共")
                            .font(.system(size: 12))
                    }
                    VStack {
                        Text("\(toFileSize(size: FilesSize))")
                            .font(.system(size: 32))
                    }
                    .padding(.trailing, 10)
                    VStack{
                        if selectedType == [] {
                            CustomButton(buttonText: "重新扫描大件", action: rescan, buttonColor: $buttonColorb, isRunning: $isRunningb)
                                .frame(width: 123)
                        }else{
                            CustomButton(buttonText: "移除所选文件", action: uninstall, buttonColor: $buttonColor, isRunning: $isRunningb)
                                .frame(width: 123)
                        }
                        Text("放心~会先移动到废纸篓🗑")
                            .font(.system(size: 9))
                        Text("(完了您再决定到底删不删)")
                            .font(.system(size: 9))
                    }
                    .padding(.trailing, 30)
                }
                .padding(.leading, 20)

            }
            .frame(height: 80)
            .frame(width: 728)
            .background(Color("Background"))
            .padding(.top, -7)
        }
        
    }

    //扫描
    func run() {
        //Thread.sleep(forTimeInterval: updateInterval) 延迟
        isRunning = true    //隐藏按钮显示进度条
        let total = 100 //进度条默认大小
        //如果进度条不是0.00就不重复跑了
        if progress>0.00 {
            return
        }
       
        var count = 0

        var pis = 50.00 //进度条开始值
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file

        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                progress = 0.01
            }
            
            
            var ai = 0
            var bi = 0
            var ci = 0
            
            var asize = 0
            var bsize = 0
            var csize = 0
            
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/mdfind")
            task.arguments = ["kMDItemFSSize > 5000000", "-onlyin", "/Users/\(NSUserName())/Desktop", "-onlyin", "/Users/\(NSUserName())/Documents", "-onlyin", "/Users/\(NSUserName())/Music", "-onlyin", "/Users/\(NSUserName())/Movies", "-onlyin", "/Users/\(NSUserName())/Downloads",  "-onlyin", "/Users/\(NSUserName())/Pictures"]
            
            
            let outputPipe = Pipe()
            task.standardOutput = outputPipe

            Files[0] = [:]
            Files[1] = [:]
            Files[2] = [:]
            
            do {
                try task.run()
                task.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: .utf8) {
                    let fileURLs = output.components(separatedBy: "\n").compactMap {
                        URL(fileURLWithPath: $0)
                    }
                    for fileURL in fileURLs {
                        do {
                            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                            if let fileSize = fileAttributes[.size] as? Int64 {
                                // 对符合条件且大小大于 5MB 的文件进行处理 5242880
                                if fileSize > 5000000 ,fileSize < 500000000 {
                                    Files[0]![ai] = [
                                        0: "\(fileURL.path)",
                                        1: "\(fileSize)",
                                        2: ""
                                    ]

                                    ai += 1
                                    
                                    asize += Int(fileSize)
                                }else if fileSize > 500000000 ,fileSize < 1024000000 {
                                    Files[1]![bi] = [
                                        0: "\(fileURL.path)",
                                        1: "\(fileSize)",
                                        2: ""
                                    ]
                                    
                                    bi += 1
                                    
                                    bsize += Int(fileSize)
                                }else if fileSize > 1024000000 {
                                    Files[2]![ci] = [
                                        0: "\(fileURL.path)",
                                        1: "\(fileSize)",
                                        2: ""
                                    ]
                                    
                                    ci += 1
                                    
                                    csize += Int(fileSize)
                                }
                            }
                        } catch {
                            print("Error getting file attributes for \(fileURL.path): \(error)")
                        }
                        
                        count += 1
                    }
                    
                    DispatchQueue.main.async {
                        progress = 0.5
                    }
                    //通过已知文件数量换算剩下的百分之 50 的没次增加值
                    let newc = Double(50) / Double(count)
                    
                    TypesSize[0] = asize
                    TypesSize[1] = bsize
                    TypesSize[2] = csize
                    
                    FilesSize = asize + bsize + csize
                    
                    //根据大小进行排序
                    let cFKeys = Files.keys.sorted()
                    for keys in cFKeys {
                        var filesArray = Files[keys]?.map { $0.value } ?? []  // 转换为可变数组
                        //根据大小排序
                        filesArray.sort { (dict1, dict2) -> Bool in
                            if let value1 = dict1[1], let intValue1 = Int64(value1),
                               let value2 = dict2[1], let intValue2 = Int64(value2)
                            {
                                return intValue1 > intValue2
                            }
                            return false
                        }
                        Files[keys] = filesArray.enumerated().reduce(into: [:]) { (dict, element) in
                            dict[element.offset] = element.element
                        }
                    }
                    //重新排序完成
                    
                    //开始查重
                    var firstFile = ""
                    var nowFile = ""
                    
                    var firstSize = Int64(0)
                    var nowSize = Int64(0)

                    let sortedKeys = Files.keys.sorted()

                    for keys in sortedKeys {
                        let sortedKey = Files[keys]!.keys.sorted()
                        for key in sortedKey {
                            let filename = Files[keys]![key]![0]
                            let filesize = Int64(Files[keys]![key]![1]!)
                            if firstFile == "" {
                                firstFile = filename!
                                firstSize = filesize!
                            }else{
                                nowFile = filename!
                                nowSize = filesize!
                                if firstSize == nowSize {
                                    //compareFileSimilarity
                                    if cmp(fileURLa: firstFile, fileURLb: nowFile) {
                                        Files[keys]![key]![2] = "1"
                                    }
                                }
                                firstFile = filename!
                                firstSize = filesize!
                            }
                            
                            //顺便把大小转换为 文本
                            Files[keys]![key]![1] = "\(byteCountFormatter.string(fromByteCount: filesize!))"

                            pis += newc
                            
                            DispatchQueue.main.async {
                                progress = Double(pis) / Double(total)
                            }
                        }
                    }
                    //结束查重
                }
            } catch {
                print(error.localizedDescription)
            }
            
            isRunning = false
            isRunningb = false
            showScanView = false    //隐藏扫描页面

            selectedType = Set<Int>([0])//默认选中第一项
            
        }
       
        
    }
    
    //重新扫描
    private func rescan() {
        progress = 0.0
        
        showScanView = true
        
        isRunningb = true
        
        Files = Dictionary.init()
        
        TypesSize = Dictionary.init()
        
        FilesSize = 0
        
        selectedType = []
        
        run()
    }
    
    private func uninstall(){
        var UFiles = ""

        let sortedSelection = selectedType.sorted().reversed()
        //对需要移除的文件进行叠加处理
        for ind in sortedSelection {
            //处理文件 如果只是选中了一个则可选关联文件 多个则统一全部移除
            if selectedType.count == 1 {
                //获取所选程序关联文件所选项
                let FileSelection = selectedFiles.sorted().reversed()
                for File in FileSelection {
                    if let unwrappedStr = Files[ind]?[File]?[0] {
                        UFiles += "\(unwrappedStr.replacingOccurrences(of: " ", with: "\\ ")) "
                    }
                }
            }else{
                if let appUrls = Files[ind] {
                    for (_, subDict1) in appUrls {
                        if let unwrappedStr = subDict1[0] {
                            let file = unwrappedStr.replacingOccurrences(of: " ", with: "\\ ")
                            UFiles += "\(file) "
                        }
                    }
                }
            }
        }

        if UFiles != "" {
            mvFiles(Files: UFiles) { s in
                if s == 0 {
                    rescan()
                } else if s == 1 {
                    showAlert(title: "未知错误，请重试。")
                }
                isRunningb = false
            }
        }else{
            showAlert(title: "请先勾选您需要移除的文件。")
            isRunningb = false
        }
    }
    
    // 通过 md5 手段查重
    func compareFileSimilarity(fileURLa: String, fileURLb: String) -> Bool {
        
        let md5_1 = calculateMD5s(at: fileURLa)
        let md5_2 = calculateMD5s(at: fileURLb)
        
        if md5_1 == md5_2 {
            return true // 文件完全相同
        } else {
            return false // 文件不同
        }
        
        
        /*md5
        let fileURL1 = URL(fileURLWithPath: fileURLa)
        let fileURL2 = URL(fileURLWithPath: fileURLb)
        guard let data1 = try? Data(contentsOf: fileURL1),
              let data2 = try? Data(contentsOf: fileURL2) else {
            return false
        }
        
        let md5_1 = calculateMD5(forData: data1)
        let md5_2 = calculateMD5(forData: data2)
        
        if md5_1 == md5_2 {
            return true // 文件完全相同
        } else {
            return false // 文件不同
        }
         */
    }
    
    //优化版
    func calculateMD5s(at path: String) -> String {
        let fileHandle = FileHandle(forReadingAtPath: path) // 替换为实际文件路径
        defer {
            fileHandle?.closeFile()
        }
        
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        let chunkSize = 4096
        var offset = 0
        
        while autoreleasepool(invoking: {
            fileHandle?.seek(toFileOffset: UInt64(offset))
            
            guard let chunkData = fileHandle?.readData(ofLength: chunkSize), !chunkData.isEmpty else {
                return false
            }
            
            chunkData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                _ = CC_MD5_Update(&context, bytes.baseAddress, CC_LONG(chunkData.count))
            }
            
            offset += chunkData.count
            
            return true
        }) {}
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Final(&digest, &context)
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    func calculateMD5(at data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    
    //对比两个内容的相似度 - 封存
    func calculateJaccardSimilarity(fileContent1: String, fileContent2: String) -> Float {
        let unit1 = Set(fileContent1.split(separator: " ")) // 使用空格进行单词划分，可以根据需要更改分割符号
        let unit2 = Set(fileContent2.split(separator: " "))
        
        let intersection = unit1.intersection(unit2)
        let union = unit1.union(unit2)
        
        let similarity = Float(intersection.count) / Float(union.count)
        return similarity
    }
    
    
    //终端cmp方法比较
    func cmp(fileURLa: String, fileURLb: String) -> Bool {
        var cmp = shell("cmp \(fileURLa) \(fileURLb)")
        if(cmp != ""){
            return false
        }
        return true
    }

}
