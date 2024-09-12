//  Created by 阿金 on 2023/3/14.
//  主页面文件

import SwiftUI

struct AppView: View {
    @Binding var showScanView: Bool  //显示状态
    @Binding var progress: Double   //进度条
    @Binding var appURLs: [URL] //APP路径
    @Binding var appIcons: [NSImage]    //APP_LOGO
    @Binding var appNames: [String] //APP名字
    @Binding var appInfos: Dictionary<Int,Dictionary<Int,String>> //APP信息
    @Binding var appFiles: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> //APP关联文件
    
    @Binding var appCount: Int //总APP数
    @Binding var selectedApps: Set<Int>   //当前选中项

    @Binding var isRunningb: Bool    //卸载按钮状态
    
    @State private var buttonColor = "eb4e3d" //按钮颜色
    @State private var buttonColorb = "ais" //按钮颜色
    @State private var isRunning = false    //按钮状态
    
    @State private var selectedFiles = Set<Int>()   //文件选中项
    
    var body: some View {
        //输出主体内容
        VStack{
            if showScanView {
                Text("🗂")
                    .font(.system(size: 100))
                    .padding(.bottom, -10)

                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            
                        Text("应用程序管理")
                            .font(.system(size: 26))
                    }
                    Text("扫描Mac上的所有应用程序及其相关文件。")
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
                    CustomButton(buttonText: "扫描应用", action: run, buttonColor: $buttonColor, isRunning: $isRunning)
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
                List(appIcons.indices, id: \.self, selection: $selectedApps) { index in
                    HStack {
                        
                        Button(action: {}, label: {
                            EmptyView()
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 0, height: 0)
                        .contextMenu {
                            Button(action: {
                                let appPath = appURLs[index].deletingLastPathComponent()
                                let workspace = NSWorkspace.shared
                                var isDirectory: ObjCBool = true

                                if FileManager.default.fileExists(atPath: appPath.path, isDirectory: &isDirectory) {
                                    workspace.activateFileViewerSelecting([appURLs[index]])
                                }
                            }, label: {
                                HStack {
                                    Text("查看程序所在位置")
                                }
                            })
                        }
                        
                        Toggle(isOn: Binding<Bool>(
                            get: { self.selectedApps.contains(index) },
                            set: { isSelected in
                                if isSelected {
                                    self.selectedApps.insert(index)
                                } else {
                                    self.selectedApps.remove(index)
                                }
                            })) {
                                EmptyView()
                            }
                            .toggleStyle(.checkbox)
                        
                        Image(nsImage: appIcons[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text(appNames[index])
                            .padding(.leading, 10)
                        Spacer()
                        if let appInfo = appInfos[index]?[1] {
                            if appInfo == "检测中..." {
                                Text("🔆").padding(.leading, 10)
                            }else{
                                Text(appInfo)
                                    .padding(.leading, 10)
                            }
                        } else {
                            Text("")
                                .padding(.leading, 10)
                        }
                        
                    }
                }.onChanges(of: selectedApps) { _ in
                    selectedFiles = Set<Int>()
                    if let firstElement = selectedApps.first,
                       let files = appFiles[firstElement] {
                        selectedFiles = Set(files.keys.sorted())
                        
                        //print(appFiles[firstElement])
                    }
                }
                
                Spacer()
                
                if let firstElement = selectedApps.first,
                    let files = appFiles[firstElement] {
                    //, selection: $selectedFiles
                    List(files.keys.sorted(), id: \.self) { fileTypeId in
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
                    .padding(.leading, -8)
                }else{
                    List(){}
                    .padding(.leading, -8)
                }
                
            }

            //Spacer()
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        if let firstElement = selectedApps.first {
                            if let appFrom = appInfos[firstElement]?[0] {
                                Text("应用来源: \(appFrom)")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }else{
                                Text("应用来源:未知")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }
                            if let appSize = appInfos[firstElement]?[1] {
                                Text("应用大小: \(appSize)")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }else{
                                Text("应用大小:未知")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }
                        }else{
                            Text("应用来源:未知")
                                .font(.system(size: 12))
                                .padding(.bottom, 6)
                            Text("应用大小:未知")
                                .font(.system(size: 12))
                                .padding(.bottom, 6)
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        if let firstElement = selectedApps.first {
                            if let appInstall = appInfos[firstElement]?[2] {
                                Text("应用安装时间:\(appInstall)")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }else{
                                Text("应用安装时间:未知")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }
                            if let appLast = appInfos[firstElement]?[3] {
                                Text("最后一次运行:\(appLast)")
                                    .font(.system(size: 12))
                                    .padding(.bottom, 6)
                            }else{
                                Text("最后一次运行:未知")
                                    .font(.system(size: 12))
                            }
                        }else{
                            Text("应用安装时间:未知")
                                .font(.system(size: 12))
                                .padding(.bottom, 6)
                            Text("最后一次运行:未知")
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.leading, 15)
                .padding(.trailing, 20)
                
                //分割
                
                HStack {
                    VStack {
                        Text("扫描发现")
                            .font(.system(size: 18))
                        Text("应用程序总共")
                            .font(.system(size: 12))
                    }
                    VStack {
                        Text("\(appCount)")
                            .font(.system(size: 32))
                    }
                    Spacer()
                    VStack{
                        if selectedApps == [] {
                            CustomButton(buttonText: "重新扫描应用", action: rescan, buttonColor: $buttonColorb, isRunning: $isRunningb)
                        }else{
                            CustomButton(buttonText: "移除\(selectedApps.count)个项目", action: uninstall, buttonColor: $buttonColor, isRunning: $isRunningb)
                        }
                        Text("放心~会先移动到废纸篓🗑")
                            .font(.system(size: 9))
                        Text("(完了您再决定到底删不删)")
                            .font(.system(size: 9))
                    }
                    .padding(.trailing, 30)
                }
                .frame(width: 310)
                .padding(.leading, 20)
                
                
            }
            .frame(height: 80)
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
        
        /*
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationDirectory, in: .localDomainMask).first!
        //获取application中的所有程序
        appURLs = try! fileManager.contentsOfDirectory(at: urls, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
         */
        
        var count = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/mdfind")
            task.arguments = ["kMDItemContentType == 'com.apple.application-bundle'", "-onlyin", "/Users/\(NSUserName())/Desktop", "-onlyin", "/Users/\(NSUserName())/Applications", "-onlyin", "/Applications"]

            let outputPipe = Pipe()
            task.standardOutput = outputPipe

            do {
                try task.run()
                task.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: .utf8) {
                    let appPaths = output.components(separatedBy: "\n")
                    for path in appPaths {
                        if !path.isEmpty {
                            appURLs.append(URL(fileURLWithPath: path))
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }

            var i = 0
            for appURL in appURLs {
                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                let name = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appURL.lastPathComponent)?.deletingPathExtension().lastPathComponent ?? appURL.lastPathComponent
                
                appIcons.append(icon)
                appNames.append(name)
                
                appInfos[i] =  [
                    0: "检测中...",
                    1: "检测中...",
                    2: "检测中...",
                    3: "检测中..."
                ]
                
                i += 1
                count += 1
                DispatchQueue.main.async {
                    progress = Double(count) / Double(total)
                }
                
            }
            
            
            appCount = appIcons.count
            isRunning = false
            isRunningb = true
            showScanView = false    //隐藏扫描页面
            
            DispatchQueue.global(qos: .userInitiated).async {
                getAppS()
            }
            
        }
       
        
    }
    
    //重新扫描
    private func rescan() {
        progress = 0.0
        showScanView = true
        
        appURLs = []//APP路径
        appIcons = []    //APP_LOGO
        appNames = [] //APP名字
        appInfos = Dictionary.init() //APP大小
        appCount = 0 //总APP数
        
        isRunningb = true
        
        selectedApps.removeAll()
        selectedFiles.removeAll()
 
        run()
    }
    
    //开始获取APP详细信息
    private func getAppS() {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        
        
        var i = 0
        var abundleIdentifier = "未知"
        var acreationDate = "未知"
        var amodificationDate = "未知"
        
        let fileManager = FileManager.default
        
        appURLs.forEach { (appUrl: URL) in
            //默认值
            abundleIdentifier = "未知来源"
            acreationDate = "未知"
            amodificationDate = "未知"
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: appUrl.path)
                //  获取应用程序来源
                let receiptUrl = appUrl.appendingPathComponent("Contents/_MASReceipt/receipt")
                if fileManager.fileExists(atPath: receiptUrl.path) {
                    abundleIdentifier = "App Store"
                } /* else {
                   let appBundle = Bundle(url: appUrl)
                   if let bundleIdentifier = appBundle?.bundleIdentifier {
                       abundleIdentifier = "外部安装"
                       print("Source application identifier for '\(appUrl.lastPathComponent)': \(bundleIdentifier)")
                   }
                }*/

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                if let creationDate = attributes[.creationDate] as? Date {
                    // 应用程序创建时间
                    acreationDate = dateFormatter.string(from: creationDate)
                }
                if let modificationDate = attributes[.modificationDate] as? Date {
                    // 应用程序修改时间/最后一次访问时间
                    amodificationDate = dateFormatter.string(from: modificationDate)
                }
            } catch {
                // 处理错误
            }
            
            //获取应用程序总大小
            let fileSize = FileSize(at: appUrl)
            
            appInfos[i] = [
                0: "\(abundleIdentifier)",
                1: "\(byteCountFormatter.string(fromByteCount: Int64(fileSize)))",
                2: "\(acreationDate)",
                3: "\(amodificationDate)"
            ]
            
            
            
            if let appBundle = Bundle(url: appUrl) {
                guard let bundleIdentifier = appBundle.bundleIdentifier else {
                    print("Bundle Identifier not found.")
                    i += 1
                    return
                }
                let preferencesPath = "\(NSHomeDirectory())/Library/Preferences/\(bundleIdentifier).plist"
                // 使用 preferencesPath 进行进一步操作
                
                var gli = 0 //数据计数
                //先给予赋值，否则下面无法直接使用appFiles[i]?[0]
                appFiles[i] = [:]
                
                if FileManager.default.fileExists(atPath: preferencesPath) {
                    appFiles[i]?[gli] = [
                        0: "\(preferencesPath)",
                        1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:preferencesPath)))))"
                    ]
                    gli += 1
                }

                let PreferencesDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Preferences/")
                let PreferencesDirectoryContents = try? FileManager.default.contentsOfDirectory(atPath: PreferencesDirectoryURL.path)

                if let PreferencesDirectoryContents = PreferencesDirectoryContents {
                    for directoryName in PreferencesDirectoryContents {
                        let directoryPath = "\(PreferencesDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }
                
                
                let cacheDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Caches/")
                let cacheDirectoryContents = try? FileManager.default.contentsOfDirectory(atPath: cacheDirectoryURL.path)

                if let cacheDirectoryContents = cacheDirectoryContents {
                    for directoryName in cacheDirectoryContents {
                        let directoryPath = "\(cacheDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }
                
                let SupportDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Application Support/")
                let SupportDirectoryContents = try? FileManager.default.contentsOfDirectory(atPath: SupportDirectoryURL.path)

                if let SupportDirectoryContents = SupportDirectoryContents {
                    for directoryName in SupportDirectoryContents {
                        let directoryPath = "\(SupportDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }

                
                let SDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Saved Application State/")
                let SContents = try? FileManager.default.contentsOfDirectory(atPath: SDirectoryURL.path)

                if let SDirectoryContents = SContents {
                    for directoryName in SDirectoryContents {
                        let directoryPath = "\(SDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }

                let ScriptsDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Application Scripts/")
                let ScriptsContents = try? FileManager.default.contentsOfDirectory(atPath: ScriptsDirectoryURL.path)

                if let ScriptsDirectoryContents = ScriptsContents {
                    for directoryName in ScriptsDirectoryContents {
                        let directoryPath = "\(ScriptsDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }
                
                let CDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Containers/")
                let CContents = try? FileManager.default.contentsOfDirectory(atPath: CDirectoryURL.path)

                if let CDirectoryContents = CContents {
                    for directoryName in CDirectoryContents {
                        let directoryPath = "\(CDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }
                
                //日志文件放在最后
                let LogsDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Logs/")
                let LogsDirectoryContents = try? FileManager.default.contentsOfDirectory(atPath: LogsDirectoryURL.path)

                if let LogsDirectoryContents = LogsDirectoryContents {
                    for directoryName in LogsDirectoryContents {
                        let directoryPath = "\(LogsDirectoryURL.path)/\(directoryName)"
                        if directoryName.contains(bundleIdentifier) && FileManager.default.isDirectory(url: URL(fileURLWithPath: directoryPath)) {
                            appFiles[i]?[gli] = [
                                0: "\(directoryPath)",
                                1: "\(byteCountFormatter.string(fromByteCount: Int64(FileSize(at: URL(fileURLWithPath:directoryPath)))))"
                            ]
                            gli += 1
                        }
                    }
                }
                
                //根据大小进行排序
                var filesArray = appFiles[i]?.map { $0.value } ?? []  // 转换为可变数组
                filesArray.sort { (dict1, dict2) -> Bool in
                    if let value1 = dict1[1], let intValue1 = convertToBytes(value1),
                       let value2 = dict2[1], let intValue2 = convertToBytes(value2)
                    {
                        return intValue1 > intValue2
                    }
                    return false
                }
                appFiles[i] = filesArray.enumerated().reduce(into: [:]) { (dict, element) in
                    dict[element.offset] = element.element
                }
                //重写排序完成
                
            } else {
                print("Bundle does not exist.")
            }
            
            //扫描完第一个的就可以默认选中了
            if i == 0 {
                selectedApps = Set<Int>([0])//默认选中第一项
            }
            i += 1
        }

        isRunningb = false  //开放按钮
        selectedApps = Set<Int>()   //取消选中以免误删
    }
    
    private func uninstall(){
        var Files = ""
        let sortedSelection = selectedApps.sorted().reversed()
        
        
        //对需要移除的文件进行叠加处理
        for ind in sortedSelection {
            
            //处理掉file:// 仅限.app 文件
            let a = "\(appURLs[ind]) "  //空格是为了保留最后一个/ 不被处理掉
            let index = a.index(a.startIndex, offsetBy: 7) // 获取第3个字符的位置
            let b = String(a[index...]) // 截取字符串从第3个字符到结尾
            //处理掉中文转义的文件名
            var url = URL(fileURLWithPath: b)
            
            //优化只删除.app 文件问题 如果在实用工具中的应用则只删除到实用工具的文件夹，不然则删除到应用程序的文件夹，如果路径中包含app/Contents说明是在.app 中的应用，或Scripting 属于程序文件夹中的脚本应用，则不执行该处理，只删除指定.app
            var parentURL = url.deletingLastPathComponent()
            var testUrl = parentURL
            parentURL.deleteLastPathComponent()
            while parentURL.path != "/Applications" && parentURL.path != "/Applications/Utilities" && !parentURL.path.contains("app/Contents") && !parentURL.path.contains("Scripting") {
                testUrl = parentURL
                parentURL.deleteLastPathComponent()
                
                //避免出现死循环
                if testUrl.path == "/" {
                    testUrl = url.deletingLastPathComponent()   //恢复原始的路径
                    break   //跳出循环
                }
            }
            url = URL(fileURLWithPath: "\(testUrl.path)/ ")
            //处理完成
            
            if let unescapedPath = url.path.removingPercentEncoding {
                let lasta = "\(unescapedPath)Ainco结束"
                let lastb = lasta.replacingOccurrences(of: " Ainco结束", with: "")
                
                //空格转义
                var lastc = lastb.replacingOccurrences(of: " ", with: "\\ ")
                //括号转义
                lastc = lastc.replacingOccurrences(of: "(", with: "\\(")
                lastc = lastc.replacingOccurrences(of: ")", with: "\\)")
                lastc = lastc.replacingOccurrences(of: "[", with: "\\[")
                lastc = lastc.replacingOccurrences(of: "]", with: "\\]")
                
                Files += "\(lastc) "
            }
            
            //处理关联文件 如果只是选中了一个则可选关联文件 多个则统一全部移除
            if selectedApps.count == 1 {
                //获取所选程序关联文件所选项
                let FileSelection = selectedFiles.sorted().reversed()
                for File in FileSelection {
                    if let unwrappedStr = appFiles[ind]?[File]?[0] {
                        Files += "\(unwrappedStr.replacingOccurrences(of: " ", with: "\\ ")) "
                    }
                }
            }else{
                if let appUrls = appFiles[ind] {
                    for (_, subDict1) in appUrls {
                        if let unwrappedStr = subDict1[0] {
                            let file = unwrappedStr.replacingOccurrences(of: " ", with: "\\ ")
                            Files += "\(file) "
                        }
                    }
                }
            }
        }

        if Files != "" {
            mvFiles(Files: Files) { s in
                if s == 0 {
                    reMove()
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
    
    private func reMove() {
        let sortedSelection = selectedApps.sorted().reversed()
        for index in sortedSelection {
            appIcons.remove(at: index)
            appNames.remove(at: index)
            
            appURLs.remove(at: index)
            
            //删除关联文件并重新排序
            appFiles.removeValue(forKey: index)
            let cFKeys = appFiles.keys.sorted()

            var sortedAppFiles = Dictionary<Int, Dictionary<Int, Dictionary<Int, String>>>()

            for (newIndex, key) in cFKeys.enumerated() {
                if let value = appFiles[key] {
                    sortedAppFiles[newIndex] = value
                }
            }
            appFiles = sortedAppFiles
            //
            //删除应用信息并重新排序
            appInfos.removeValue(forKey: index)
            let IFKeys = appInfos.keys.sorted()

            var sortedappInfos = Dictionary<Int,Dictionary<Int,String>>()

            for (newIndex, key) in IFKeys.enumerated() {
                if let value = appInfos[key] {
                    sortedappInfos[newIndex] = value
                }
            }
            appInfos = sortedappInfos
            //
        }
        self.selectedApps = Set<Int>()
        selectedApps = Set<Int>()
        appCount = appIcons.count
    }
    
}
