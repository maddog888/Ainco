//
//  CacheView.swift
//  Ainco
//
//  Created by 阿金 on 2023/4/29.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//


import SwiftUI

struct CacheView: View {
    @Binding var showScanView: Bool  //显示状态
    @Binding var progress: Double   //进度条

    @Binding var Files: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> //对应关联文件
    @Binding var TypesSize: Dictionary<Int,Int> //类型总大小
    
    @Binding var FilesSize: Int //文件总大小
    
    @Binding var selectedType: Set<Int>   //当前选中项

    @Binding var isRunningb: Bool    //清理按钮状态
    
    @State private var buttonColor = "f8d84a" //按钮颜色
    @State private var buttonColorb = "ais" //重扫按钮颜色
    
    @State private var isRunning = false    //按钮状态
    
    @State private var selectedFiles = Set<Int>()   //文件选中项
    
    @State private var tips = "" //顶部提示
    
    var FilesType: [[String]] = [
        [
            "/System/Applications/App Store.app", //图标
            "应用程序缓存" //名字
        ],
        [
            "/System/Applications/TextEdit.app",
            "应用程序日志"
        ]
        /*,
        [
            "/System/Applications/Launchpad.app",
            "应用程序残留"
        ]
         */
    ]
    

    
    var body: some View {
        //输出主体内容
        VStack{
            if showScanView {
                Text("✨")
                    .font(.system(size: 100))
                    .padding(.bottom, -10)

                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            
                        Text("空间优化")
                            .font(.system(size: 26))
                    }
                    Text("查找并清理您Mac上的应用缓存、日志文件，释放磁盘空间。")
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
                        tips = ""
                        if let firstElement = selectedType.first,
                           let files = Files[firstElement] {
                            selectedFiles = Set(files.keys.sorted())
                        }
                    }
                    
                }
                .frame(width: 320)
                
                Spacer()
                
                if let firstElement = selectedType.first,
                    let files = Files[firstElement] {
                    VStack{
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
                            }
                        }
                    }
                    .padding(.leading, -8)
                }else{
                    List(){}
                    .padding(.leading, -8)
                }
                
            }
            
            HStack {
                Spacer()
                HStack {
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
                            CustomButton(buttonText: "重新扫描优化", action: rescan, buttonColor: $buttonColorb, isRunning: $isRunningb)
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
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file

        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //Cache 文件夹下的所有文件 后期需要增加Containers 里面的个别 Cache
            let fileManager = FileManager.default
            let cacheDirURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileURLs = try! fileManager.contentsOfDirectory(at: cacheDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            var i = 0;
            
            Files[0] = [:]
            
            var CachesSize = 0
            
            for fileURL in fileURLs {
                //获取文件总大小
                let fileSize = FileSize(at: fileURL)
                
                let urlString = fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")

                //处理掉中文转义的文件名
                let url = URL(fileURLWithPath: urlString)
                if let unescapedPath = url.path.removingPercentEncoding {
                    Files[0]![i] = [
                        0: "\(unescapedPath)",
                        1: "\(byteCountFormatter.string(fromByteCount: Int64(fileSize)))"
                    ]
                    
                    i += 1
                    
                    CachesSize += Int(fileSize)
                }
                
                count += 1
                DispatchQueue.main.async {
                    progress = Double(count) / Double(total)
                }
                
            }
            
            TypesSize[0] = CachesSize
            FilesSize += CachesSize

            //Logs 文件夹下的所有文件 后期需要增加Containers 里面的个别 Logs
            let logDirURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Logs")
            let logURLs = try! fileManager.contentsOfDirectory(at: logDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            i = 0;
            
            Files[1] = [:]
            
            var LogsSize = 0
            
            for fileURL in logURLs {
                //获取文件总大小
                let fileSize = FileSize(at: fileURL)
                
                let urlString = fileURL.absoluteString.replacingOccurrences(of: "file://", with: "")
                
                //处理掉中文转义的文件名
                let url = URL(fileURLWithPath: urlString)
                if let unescapedPath = url.path.removingPercentEncoding {
                    Files[1]![i] = [
                        0: "\(unescapedPath)",
                        1: "\(byteCountFormatter.string(fromByteCount: Int64(fileSize)))"
                    ]
                    
                    i += 1
                    
                    LogsSize += Int(fileSize)
                }

                
            }
            
            TypesSize[1] = LogsSize
            FilesSize += LogsSize
            
            //根据大小进行排序
            var filesArray = Files[0]?.map { $0.value } ?? []  // 转换为可变数组
            filesArray.sort { (dict1, dict2) -> Bool in
                if let value1 = dict1[1], let intValue1 = convertToBytes(value1),
                   let value2 = dict2[1], let intValue2 = convertToBytes(value2)
                {
                    return intValue1 > intValue2
                }
                return false
            }
            Files[0] = filesArray.enumerated().reduce(into: [:]) { (dict, element) in
                dict[element.offset] = element.element
            }
            filesArray = Files[1]?.map { $0.value } ?? []  // 转换为可变数组
            filesArray.sort { (dict1, dict2) -> Bool in
                if let value1 = dict1[1], let intValue1 = convertToBytes(value1),
                   let value2 = dict2[1], let intValue2 = convertToBytes(value2)
                {
                    return intValue1 > intValue2
                }
                return false
            }
            Files[1] = filesArray.enumerated().reduce(into: [:]) { (dict, element) in
                dict[element.offset] = element.element
            }
            //重新排序完成

            //获取应用残留
            
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
    
    
}
