//
//  MainWindowView.swift
//  66
//
//  Created by 阿金 on 2023/3/14.
//  主页面文件

import SwiftUI
import IOKit.ps

struct MainWindowView: View{
    //列表数据
    //let listTitle = [" 智能扫描", " 应用管理", " 空间优化", " 扫描大件", " 网络管理"," 实用工具"]
    //let listImage = ["laptopcomputer", "square.stack.3d.up.fill", "externaldrive", "cube.fill", "network", "briefcase"] //wand.and.stars
    
    let listTitle = [" 智能扫描", " 应用管理", " 空间优化", " 扫描大件", " 实用工具"]
    let listImage = ["laptopcomputer", "square.stack.3d.up.fill", "externaldrive", "cube.fill", "briefcase"] //wand.and.stars
    
    @State private var selection: Int?  //当前菜单选中项
    @State private var modelName = ""   //电脑名称
    @State private var memory: UInt64?   //电脑物理内存
    @State private var osVersion = ""   //电脑系统版本
    @State private var chipAndYear = "" //电脑芯片
    @State private var health = "" //电池健康
    @State private var diskSize = "" //硬盘容量
    @State private var diskP = 0.0 //硬盘百分比
    @State private var Tip = "" //推荐系统
    //当前程序版本号
    @State private var Version = "0.0" //版本号
    
    //新手入门
    @State private var ShowFastHelp = false  //显示状态

    /* 智能扫描*/
    @State private var SshowScanView = true  //显示状态
    
    @State private var buttonColor = "6bd45f" //按钮颜色
    @State private var isRunning = false    //按钮状态
    
    //
    @State private var BigbuttonColor = "f8d84a" //按钮颜色
    @State private var BigisRunning = false
    @State private var CacheisRunning = false
    
    /* 应用管理*/
    @State private var showScanView = true  //显示状态
    @State private var progress = 0.0   //进度条
    @State private var appURLs: [URL] = []//APP路径
    @State private var appIcons: [NSImage] = []    //APP_LOGO
    @State private var appNames: [String] = [] //APP名字
    @State private var appInfos: Dictionary<Int,Dictionary<Int,String>> = Dictionary.init() //APP信息
    //0:来源,1:大小,2:安装时间,3:最后一次打开时间
    @State private var appFiles: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> = Dictionary.init() //APP关联文件
    @State private var appCount = 0 //总APP数
    @State private var selectedApps = Set<Int>()   //当前选中项
    @State private var mvState = true  //移除按钮状态
    
    
    /* 空间优化*/
    @State private var CshowScanView = true //显示状态
    @State private var Cprogress = 0.0   //进度条
    @State private var CFiles: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> = Dictionary.init()   //对应关联文件
    @State private var CTypeSize: Dictionary<Int,Int> = Dictionary.init()   //类型总大小
    @State private var CFilesSize = 0 //文件总大小
    @State private var CselectedType = Set<Int>()   //当前选中项
    @State private var CisRunning = true    //清理按钮状态
    
    /* 扫描大件*/
    @State private var BshowScanView = true //显示状态
    @State private var Bprogress = 0.0   //进度条
    @State private var BFiles: Dictionary<Int,Dictionary<Int,Dictionary<Int,String>>> = Dictionary.init()   //对应关联文件
    @State private var BTypeSize: Dictionary<Int,Int> = Dictionary.init()   //类型总大小
    @State private var BFilesSize = 0 //文件总大小
    @State private var BselectedType = Set<Int>()   //当前选中项
    @State private var BisRunning = true    //清理按钮状态
    
    /* 网络管理*/

    
    /* 实用工具*/
    @State private var Tloading = true  //加载状态
    @State private var bTloading = true  //加载状态
    @State private var cTloading = true  //加载状态
    @State private var dTloading = true  //加载状态
    
    var body: some View {
        //应用管理
        let AppViews = AppView(showScanView: $showScanView, progress: $progress, appURLs: $appURLs, appIcons: $appIcons, appNames: $appNames, appInfos: $appInfos, appFiles: $appFiles, appCount: $appCount, selectedApps: $selectedApps, isRunningb: $mvState)
        //空间优化
        let CacheViews = CacheView(showScanView: $CshowScanView, progress: $Cprogress, Files: $CFiles, TypesSize: $CTypeSize, FilesSize: $CFilesSize, selectedType: $CselectedType, isRunningb: $CisRunning)
        //扫描大件
        let BigFilesViews = BigFilesView(showScanView: $BshowScanView, progress: $Bprogress, Files: $BFiles, TypesSize: $BTypeSize, FilesSize: $BFilesSize, selectedType: $BselectedType, isRunningb: $BisRunning)
        
        //let NetAdmin = NetAdmin()
        
        //开始页面
        let StartScan = ZStack{
            VStack {
                if SshowScanView {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
//                            NSApplication.shared.mainWindow?.miniaturize(nil)   //缩小主窗口
                            //controller.showWindow(nil)
//                            _ = goAinco()
                        }
                    
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            
                            Text("智能扫描")
                                .font(.system(size: 26))
                        }
                        Text("全面检查Mac上的硬盘、诊断电池健康以及系统建议。")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15))
                    }
                    .contentShape(Rectangle())
                    .padding(.top, 15)
                    .padding(.bottom, 20)

                    CustomButton(buttonText: "开始扫描", action: {
                        CacheViews.run()
                        BigFilesViews.run()
                        getInfo()
                    }, buttonColor: $buttonColor, isRunning: $isRunning)
                    
                }else{
                    //结果
                    ScanList
                }
            }
            .frame(minHeight:600)
            .frame(width: 730)
            
            //快速帮助页面 后者添加，可起到覆盖前面页面的作用
            if(ShowFastHelp){
                FastHelp(Show: $ShowFastHelp)
            }
        }
        .frame(minHeight:600)
        .frame(width: 730)
        
        //输出主体内容
        return NavigationView {
            //左侧菜单栏
            VStack {
                //选择菜单
                //0..<listTitle.count 也可以实现
                List(listTitle.indices, id: \.self, selection: $selection) { index in
                    if index == 0 {
                        NavigationLink(destination: StartScan, tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                    } else if index == 1 {
                        NavigationLink(destination: AppViews, tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                    } else if index == 2 {
                        NavigationLink(destination: CacheViews, tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                    } else if index == 3 {
                        NavigationLink(destination: BigFilesViews, tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                    } else if index == 4 {
                        NavigationLink(destination: ToolsView(loading: $Tloading, bloading: $bTloading, cloading: $cTloading, dloading: $dTloading), tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                        /*
                        NavigationLink(destination: NetAdmin, tag: index, selection: $selection) {
                            SidebarItem(imageName: self.listImage[index], text: "\(self.listTitle[index])")
                        }
                         */
                    }
                    
                }
                .onAppear() {
                    //为了确保绝对选中，延迟0.1秒
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selection = 0 //创建完成后，默认选中第一项
                        
                        //设置当前版本号
                        Version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
                        
                        //如果获取到版本号就检测更新
                        if Version != "0.0" {
                            getUpdate(code: 0)
                        }
                    }
                    //判断到如果是首次打开则执行以下操作
                    if(AData.shared.firstOpen){
                        //显示新手入门
                        ShowFastHelp = true
                        
                        //主要用于请求权限
                        /*
                        AppViews.run()
                        CacheViews.run()
                        BigFilesViews.run()
                         */
                        
                    }
                }
            }
            .padding(.horizontal)//水平居中
            .padding(.leading, -13)//左边贴一点
            .padding(.top, 50)//顶部距离
            .listStyle(SidebarListStyle())//列表样式
            .frame(width: 200)//宽度
        }
        .navigationViewStyle(DefaultNavigationViewStyle())
        .overlay(
            VStack {
                Spacer()
                //
                HStack{
                    Text("Ainco Ver: \(Version)")
                    Button(action: openAg) {Text("软件协议").underline()}
                    .buttonStyle(BorderlessButtonStyle())
                }
                HStack{
                    
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://github.com/maddog888/Ainco")!)
                    }) {
                        Text("Ainco源码")
                    }
                    
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://support.qq.com/products/593319/#label=default")!)
                    }) {
                        Text("💌 社区")
                    }
                    
                }
                HStack {
                    Button(action: {
                        getUpdate(code: 1)
                    }) {
                        Text("检查更新")
                    }
                    
                    Button(action: {
                        selection = 0   //选中第一项
                        ShowFastHelp = true //显示新手入门
                    }) {
                        Text("📖 快速帮助")
                    }
                }
            }
            .padding(.bottom, 20)
            .padding(.leading,-453)
        )
    }
    
    //列表视图
    var ScanList: some View {
        VStack{
            //返回主页
            HStack{
                Button(action: {
                    SshowScanView = true
                }) {
                    Text("←")
                        .font(.system(size: 13))
                }
                Spacer()
            }
            .padding(.top, -60)
            .padding(.leading, 39)
            .padding(.bottom, -60)
            
            VStack{
                Image(nsImage: NSImage(named: NSImage.computerName)!)
                    .resizable()
                    .frame(width: 233, height: 233)
                    .padding(.bottom, -28)
                
                Text("\(modelName)")
                    .font(.system(size: 23))
                    .padding(.bottom, 6)
                
                Text("芯片 \(chipAndYear)   内存 \(memory!)GB   电池·\(health)")
                    .font(.system(size: 15))
                    .padding(.bottom, 1)
                Text("macOS \(osVersion)")
                    .font(.system(size: 15))
                    .padding(.bottom, 1)
                HStack{
                    Text("Ainco 建议使用系统:")
                    //如果是2020年以后的都是M系列芯片Apple自研
                    if chipAndYear.contains("Apple") {
                        if chipAndYear.contains("M1") {
                            Button(action: {
                                NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/tw/app/macos-big-sur/id1526878132?mt=12")!)
                            }) {
                                Text("macOS Big Sur 11")
                            }
                            
                            Button(action: {
                                NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/app/macos-ventura/id1638787999?mt=12")!)
                            }) {
                                Text("macOS Ventura 13")
                            }
                        }else if chipAndYear.contains("M2") {
                            Button(action: {
                                NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/app/macos-ventura/id1638787999?mt=12")!)
                            }) {
                                Text("macOS Ventura 13")
                            }
                            Button(action: {
                                NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/app/macos-sonoma/id6450717509?mt=12")!)
                            }) {
                                Text("macOS Sonoma 14 或其他更高版本")
                            }
                        }else{
                            Button(action: {
                                NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/app/macos-sonoma/id6450717509?mt=12")!)
                            }) {
                                Text("macOS Sonoma 14 或其他更高版本")
                            }
                        }
                    }else{
                        //let version = getMajorVersion(modelName)
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/tw/app/macos-catalina/id1466841314?mt=12")!)
                        }) {
                            Text("macOS Catalina 10.15")
                        }
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "macappstores://apps.apple.com/tw/app/macos-big-sur/id1526878132?mt=12")!)
                        }) {
                            Text("macOS Big Sur 11 以下或相对较早的版本")
                        }
                    }
                }
                
                //底部信息
                VStack{
                    //硬盘信息
                    HStack{
                        Text("存储")
                            .font(.system(size: 11))
                            .padding(.bottom, 1)
                        CustomProgressBar(progress: $diskP)
                            .frame(width: 160)
                        Text("· 可用\(diskSize)")
                            .font(.system(size: 12))
                            .padding(.bottom, 1)
                    }
                    .frame(width: 398)
                    //硬盘清理
                    HStack {
                        CustomButton(buttonText: "✨ 可优化 \(toFileSize(size: CFilesSize))", action: {
                            selection = 2
                            CacheisRunning = false
                        }, buttonColor: $buttonColor, isRunning: $CacheisRunning)
                        
                        CustomButton(buttonText: "📦 大文件 \(toFileSize(size: BFilesSize))", action: {
                            selection = 3
                            BigisRunning = false
                        }, buttonColor: $BigbuttonColor, isRunning: $BigisRunning)
                    }
                }
                .padding(.top, 30)
                
            }
            .padding(.top, -30)
        }
    }
    
    //加载电脑基础信息
    private func getInfo() {
        // 获取电脑名称
        modelName = shell("sysctl hw.model").replacingOccurrences(of: "hw.model: ", with: "")
        // 获取内存信息
        memory = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024 // GB
        // 获取 macOS 版本
        osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        // 获取芯片
        chipAndYear = shell("sysctl machdep.cpu.brand_string").replacingOccurrences(of: "machdep.cpu.brand_string:", with: "")
        //电池健康
        health = Battery.getBatteryHealthAndPercentage()
        //电脑硬盘容量
        let diskr = Disk.getFreeDiskSpace()
        
        if let disktets = diskr?.diskSize {
            diskSize = disktets
        }
        
        if let disktets = diskr?.diskP {
            diskP = disktets
        }
        SshowScanView = false
        isRunning = false
    }
    
    
    //获取电脑版本号
    private func getMajorVersion(_ model: String) -> Int? {
        guard let range = model.range(of: #"\d+,"#, options: .regularExpression) else {
            return nil
        }
        let yearString = String(model[range]) // 获取类似 "10," 的子串
        let components = yearString.split(separator: ",").compactMap { str -> Int? in
            return Int(str)
        }
        guard let majorVersion = components.first else {
            return nil
        }
        
        return majorVersion
    }
    
    private func getUpdate(code: Int) {
        requestWebData(urlString: "https://m.weibo.cn/comments/hotflow?id=4898370361491579&mid=4898370361491579&max_id_type=0") { (webData, error) in
            if let error = error {
                showAlert(title: "检测更新失败，请稍后重试。\n\(error.localizedDescription)")
            } else if let webData = webData {
                // 在这里对网页数据进行解析和处理
                if let jsonData = webData.data(using: .utf8),//设置编码
                    let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),//尝试Json解析
                    let jsonDict = jsonObject as? [String: Any] {
                    //获取第一个data
                    if let dataDict = jsonDict["data"] as? [String: Any],
                       //第二个data
                       let dataArray = dataDict["data"] as? [Any],
                       !dataArray.isEmpty,
                       let firstComment = dataArray.first as? [String: Any] {
                        //获取第一个text中的内容
                           if let text = firstComment["text"] as? String {
                               let components = text.components(separatedBy: "$")
                               if components.count == 2 {
                                   let before = components[0] // 获取 $ 前面的内容
                                   let after = components[1] // 获取 $ 后面的内容
                                   //替换拦截符
                                   let updateUrl = after.replacingOccurrences(of: "€", with: "")
                                  
                                   if code == 1 {
                                       if before > Version {
                                           NSWorkspace.shared.open(URL(string: updateUrl)!)
                                       }else{
                                           showAlert(title: "当前已是最新版本。")
                                       }
                                   }else{
                                       if before > Version {
                                           showAlert(title: "发现更新的版本", message: "Ainco并不会强制更新，但建议您退出当前版本，在弹出的网页中下载最新版本后替换使用。")
                                           NSWorkspace.shared.open(URL(string: updateUrl)!)
                                       }
                                   }
                               } else {
                                   //showAlert(title: "检测更新失败，请检查网络后重试。")
                               }
                           }
                    }
                    
                }
            }
        }
    }

}

//分别判断不同系统的列表兼容性
private struct SidebarItem: View {
    var imageName: String?
    var text: LocalizedStringKey

    var body: some View {
        //如果 有图片信息则判断输出，没有则直接输出文字
        if let imageName = imageName {
            //判断系统版本大于11.0的则执行Label 否则使用HStack
            if #available(macOS 11.0, *) {
                Label(
                    title: { Text(text) },
                    icon: { Image(systemName: imageName).font(.system(size: 16)) }
                )
            } else {
                HStack {
                    Text(text)
                }
            }
        } else {
            Text(text)
        }
    }
}


//获取电池健康
private class Battery {
    static func getBatteryHealthAndPercentage() -> String {
        let powerSourcesInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        let powerSourcesList = IOPSCopyPowerSourcesList(powerSourcesInfo)?.takeRetainedValue() as? [CFTypeRef]

        for source in powerSourcesList ?? [] {
            if let powerSourceInfo = IOPSGetPowerSourceDescription(powerSourcesInfo, source)?.takeUnretainedValue() as? [String: Any] {
                if let health = powerSourceInfo["BatteryHealth"] as? String {
                    if health == "Good" {
                        return "健康"
                    } else if health == "Fair" {
                        return "一般"
                    } else if health == "Poor" {
                        return "不良"
                    } else if health == "Critical" {
                        return "危险"
                    } else {
                        return "未知"
                    }
                }
            }
        }
        
        return "未知"
    }
}

//获取硬盘可用空间
private class Disk {
    static func getFreeDiskSpace() -> (diskSize: String, diskP: Double)? {
        var total = "*"
        var free = "*"
        
        var totalSpaceInGB = 100.0
        var freeSpaceInGB = 100.0
        
        var p = Double(1)
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: "/")
            //总容量
            if let totalSize = systemAttributes[.systemSize] as? NSNumber {
                totalSpaceInGB = Double(totalSize.uint64Value) / 1_000_000_000
                total = "\(String(format: "%.2f", totalSpaceInGB)) GB"
            }
            //剩余容量
            if let freeSize = systemAttributes[.systemFreeSize] as? NSNumber {
                freeSpaceInGB = Double(freeSize.uint64Value) / 1_000_000_000
                free = "\(String(format: "%.2f", freeSpaceInGB)) GB"
            }
            p = 1 - ((freeSpaceInGB / totalSpaceInGB) * 100) / 100
        } catch {
            return ("读取失败",1)
        }
        
        return ("\(free) / 共\(total)",p)
    }
}
