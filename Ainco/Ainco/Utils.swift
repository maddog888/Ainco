//
//  Utils.swift
//  66
//
//  Created by 阿金 on 2023/3/25.
//

import SwiftUI
import Combine
import CryptoKit

//自定义超富文本
struct MacosTextView: NSViewRepresentable {
    var text: String
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.linkTextAttributes = [
            .foregroundColor: NSColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]

        // 将URL转换为规范格式
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return textView
        }
        let range = NSRange(location: 0, length: text.count)
        let matches = detector.matches(in: text, options: [], range: range)
        let attributedString = NSMutableAttributedString(string: text)
        for match in matches {
            guard let url = match.url else {
                continue
            }
            attributedString.addAttribute(.link, value: url, range: match.range)
        }

        textView.textStorage?.setAttributedString(attributedString)
        textView.insertionPointColor = .white // 将插入符号颜色设置为白色
        textView.textColor = NSColor.labelColor// 将文本颜色设置为白色
        textView.font = NSFont.systemFont(ofSize: 13)

        // 设置textView代理
        textView.delegate = context.coordinator
        
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
    }
    
    // 连接代表
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        
        func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
            if let url = link as? URL {
                open(url: "\(url)")
            }
            return true
        }
    }
}

//自定义按钮样式
struct CustomButton: View {
    var buttonText: String  //按钮显示文本
    var action: () -> Void  //按钮执行事件
    @Binding var buttonColor: String //按钮颜色
    @Binding var isRunning: Bool    //按钮状态
    var radius: CGFloat = 6  //按钮边角
    var max: Bool = false   //是否自适应最大
    
    var body: some View {
        //自动识别
        if buttonColor == "ai" {
            Text(buttonText)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(NSColor.labelColor))
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(Color("buttonBackground"))
                .cornerRadius(radius)
                .opacity(isRunning ? 0.5 : 1) // 当函数正在执行时禁用按钮
                .onTapGesture {
                    if !isRunning {
                        isRunning = true // 标记函数正在执行
                        action()
                    }
                }
        }else{
            if max {
                Text(buttonText)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(buttonColor == "ais" ? Color.accentColor : Color(hex: buttonColor))
                    .cornerRadius(radius)
                    .opacity(isRunning ? 0.5 : 1) // 当函数正在执行时禁用按钮
                    .onTapGesture {
                        if !isRunning {
                            isRunning = true // 标记函数正在执行
                            action()
                        }
                    }
            }else{
                Text(buttonText)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(buttonColor == "ais" ? Color.accentColor : Color(hex: buttonColor))
                    .cornerRadius(radius)
                    .opacity(isRunning ? 0.5 : 1) // 当函数正在执行时禁用按钮
                    .onTapGesture {
                        if !isRunning {
                            isRunning = true // 标记函数正在执行
                            action()
                        }
                    }
            }
            
        }
        
    }
}

//自定义进度条
struct CustomProgressBar: NSViewRepresentable {
    typealias NSViewType = NSProgressIndicator
    @Binding var progress: Double

    func makeNSView(context: NSViewRepresentableContext<CustomProgressBar>) -> NSProgressIndicator {
        let progressBar = NSProgressIndicator()
        progressBar.style = .bar
        progressBar.isIndeterminate = false
        progressBar.minValue = 0
        progressBar.maxValue = 1
        return progressBar
    }

    func updateNSView(_ progressBar: NSProgressIndicator, context: NSViewRepresentableContext<CustomProgressBar>) {
        progressBar.doubleValue = progress
    }
}

//自定义圆形进度条
struct CustomCircularProgressBar: View {
    @Binding var progress: Double
    @Binding var CColor: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: 6.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(hex: CColor))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear)
                
                Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
        }
    }
}

//系统图像扩展兼容低于11.0的系统
extension Image {
    init(systemNames systemName: String) {
        if #available(macOS 11.0, *) {
            self.init(systemName: systemName)
        } else {
            let _ = Optional(systemName)
            self.init(nsImage: NSImage())
        }
    }
}
//调整图片大小扩展
extension NSImage {
    func resize(to newSize: NSSize) -> NSImage? {
        // 计算缩放比例
        let scale = newSize.width / size.width
        
        // 创建目标矩形
        let newRect = NSRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        
        // 创建新图像
        let newImage = NSImage(size: newRect.size)
        
        // 设置绘制上下文
        newImage.lockFocus()
        defer { newImage.unlockFocus() }
        
        // 绘制图像
        draw(in: newRect, from: .zero, operation: .copy, fraction: 1.0)
        
        // 返回新图像
        return newImage
    }
}
//颜色扩展
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        
        self.init(red: r, green: g, blue: b)
    }
}

//在10.15上监听List代替Onchange方法扩展
extension View {
    func onChanges<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        return self.modifier(OnChangeModifier(value: value, action: action))
    }
}

//扩展
extension FileManager {
    func isDirectory(url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        guard fileExists(atPath: url.path, isDirectory: &isDirectory) else { return false }
        return isDirectory.boolValue
    }
}

//是否改变
struct OnChangeModifier<T: Equatable>: ViewModifier {
    let value: T
    let action: (T) -> Void
    @State private var oldValue: T? = nil

    func body(content: Content) -> some View {
        content.onAppear(perform: { self.oldValue = self.value })
            .onReceive(Just(value)) { newValue in
                guard self.oldValue != newValue else { return }
                self.oldValue = newValue
                self.action(newValue)
            }
    }
}

//帮助用户打开用户与群组设置
func appleUsers() {
    let systemPreferencesURL = URL(fileURLWithPath: "/System/Library/PreferencePanes/TouchID.prefPane")
    //"/System/Library/PreferencePanes/Accounts.prefPane")
    if NSWorkspace.shared.open(systemPreferencesURL) {
        let script = """
            tell application "System Preferences"
                reveal anchor "TouchID" of pane id "\(systemPreferencesURL.lastPathComponent)"
                activate
            end tell
            """
        if let scriptObject = NSAppleScript(source: script) {
            var errorDict: NSDictionary?
            scriptObject.executeAndReturnError(&errorDict)
            if errorDict != nil {
                print("Error opening TouchID preferences: \(errorDict!)")
            }
        } else {
            print("Error creating script object.")
        }
    } else {
        print("Error opening TouchID preferences.")
    }
}

//信息提示框
func showAlert(title: String, message: String! = "") {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .informational
    alert.addButton(withTitle: "好的")
    alert.runModal()
}

func ssp(text: String) -> String {
    //先处理反斜杠
    var rtext = text.replacingOccurrences(of: "\\", with: "\\\\")
    
    rtext = rtext.replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
    
    rtext = rtext.replacingOccurrences(of: "~", with: "\\~")
    rtext = rtext.replacingOccurrences(of: "`", with: "\\`")
    rtext = rtext.replacingOccurrences(of: "!", with: "\\!")
    rtext = rtext.replacingOccurrences(of: "@", with: "\\@")
    rtext = rtext.replacingOccurrences(of: "#", with: "\\#")
    rtext = rtext.replacingOccurrences(of: "$", with: "\\$")
    rtext = rtext.replacingOccurrences(of: "%", with: "\\%")
    rtext = rtext.replacingOccurrences(of: "&", with: "\\&")
    rtext = rtext.replacingOccurrences(of: "*", with: "\\*")
    rtext = rtext.replacingOccurrences(of: "(", with: "\\(")
    rtext = rtext.replacingOccurrences(of: ")", with: "\\)")
    rtext = rtext.replacingOccurrences(of: "=", with: "\\=")
    
    rtext = rtext.replacingOccurrences(of: "{", with: "\\{")
    rtext = rtext.replacingOccurrences(of: "[", with: "\\[")
    rtext = rtext.replacingOccurrences(of: "}", with: "\\}")
    rtext = rtext.replacingOccurrences(of: "]", with: "\\]")
    rtext = rtext.replacingOccurrences(of: "|", with: "\\|")
    
    rtext = rtext.replacingOccurrences(of: ":", with: "\\:")
    rtext = rtext.replacingOccurrences(of: ";", with: "\\;")
    rtext = rtext.replacingOccurrences(of: "'", with: "\\'")
    rtext = rtext.replacingOccurrences(of: "\"", with: "\\\"")
    rtext = rtext.replacingOccurrences(of: "<", with: "\\<")
    rtext = rtext.replacingOccurrences(of: ",", with: "\\,")
    rtext = rtext.replacingOccurrences(of: ">", with: "\\>")
    rtext = rtext.replacingOccurrences(of: "?", with: "\\?")
    
    rtext = rtext.replacingOccurrences(of: " ", with: "\\ ")

    
    return rtext
}

//移动文件到废纸篓
func mvFiles(Files: String, completion: @escaping (Int) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now()) {
        nshowPasswordDialog(title: "移除所选程序及文件。", msg: "请您确认是否将所选程序以及文件移动到废纸篓。", btn: "确认") { password in
            if password != "取消" {
                if Files == "" {
                    completion(1)
                }
                let process = Process()
                process.launchPath = "/bin/bash"
                process.arguments = ["-c", "echo \(password) | sudo -S mv \(Files)~/.Trash/"]
                process.launch()
                
                process.waitUntilExit()
                completion(0)
            }else{
                completion(-1)
            }
        }
    }
}

//递归扫描整个文件夹
func FileSize(at url: URL) -> UInt64 {
    if url.hasDirectoryPath || url.pathExtension == "app" {
        //文件夹或者.app的获取方式
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0
        
        guard let files = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        for case let fileURL as URL in files {
            do {
                let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                totalSize += UInt64(fileSize)
            } catch {
                print("Error: \(error)")
            }
        }
        if Int(totalSize) <= 0 {
            return UInt64(10)
        }
        return totalSize
    } else {
        //文件的获取方式
        return calculateFileSize(at: url)!
    }
}

//获取文件的大小
func calculateFileSize(at url: URL) -> UInt64? {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let fileSize = fileAttributes[.size] as? UInt64 else {
            return nil
        }
        if Int(fileSize) <= 0 {
            return UInt64(10)
        }
        return fileSize
    } catch {
        return nil
    }
}

//整数转大小
func toFileSize(size: Int) -> String {
    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
    byteCountFormatter.countStyle = .file
    return byteCountFormatter.string(fromByteCount: Int64(size))
}

//获取文件图标
func FindLogo(at url: String) -> NSImage? {
    let fileURL = URL(fileURLWithPath: url)
    return NSWorkspace.shared.icon(forFile: fileURL.path)
}

//获取序列号
func getSerialNumber() -> String? {
    let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    guard platformExpert > 0 else {
        return nil
    }
    defer { IOObjectRelease(platformExpert) }
    guard let cfDict = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0) else {
        return nil
    }
    return cfDict.takeRetainedValue() as? String
}

//终端执行
func shell(_ commands: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    //处理~
    var command = commands.replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
    
    task.standardOutput = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output.trimmingCharacters(in: .newlines)
}

//Get 请求
func requestWebData(urlString: String,completion: @escaping (_ webData: String?, _ error: Error?) -> Void) {
    
    let percentEncodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!//中文编码
    
    guard let url = URL(string: percentEncodedString) else {
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        DispatchQueue.main.async {
            if let error = error {
                completion(nil, error)
            } else if let data = data,
                      let webData = String(data: data, encoding: .utf8) {
                completion(webData, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: ["localizedDescription": "未返回数据"]))
            }
        }
    }.resume()
}


func fileExistsAtPath(filePath: String) -> Bool {
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: filePath)
}

//打开文件或地址
func open(url: String) {
    //采用线程
    DispatchQueue.global(qos: .userInitiated).async {
        //处理~
        let command = url.replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
        //判断是否为文件路径
        if FileManager.default.fileExists(atPath: command) {
            if fileExistsAtPath(filePath: command) {
                NSWorkspace.shared.openFile(command)
            }
        } else { //非文件路径则为网址
            let percentEncodedString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!  //对中文进行编码，以免解析奔溃
            NSWorkspace.shared.open(URL(string: percentEncodedString)!)
        }
    }
}

// 修复并运行程序
func startApp(aurl: String, onInputCompletion: @escaping (String) -> Void) -> String? {
    nshowPasswordDialog(title: "修复并运行此应用程序。", msg: "如果您对该程序不绝对相信，请谨慎修复并运行，以免增加Mac的安全风险。", btn: "确认运行") { password in
        if password != "取消" {
            //删除程序的com.apple.quarantine属性
            shell("echo \(password) | sudo -S xattr -d com.apple.quarantine \(ssp(text: aurl))")
            //获取Unix文件名
            let url = URL(fileURLWithPath: aurl)
            let fileName = (url.lastPathComponent as NSString).deletingPathExtension
            //运行
            let filePath = "\(aurl)/Contents/MacOS/\(fileName)"
            let fileURL = URL(fileURLWithPath: filePath)
            
            NSWorkspace.shared.open(fileURL)
            
            onInputCompletion("ok")
        }else{
            onInputCompletion("取消")
        }
    }
}

//查看软件服务协议
func openAg() {
    showAlert(title: "Ainco软件许可及服务协议：", message: "如果您未满18周岁，请在法定监护人陪同下阅读本协议及其他相关协议，在取得法定监护人的同意后，在法定监护人监护、指导下使用本软件。\n1、用户明确同意其使用Ainco软件的风险将完全由其自己承担，本软件开发者对用户不承担任何责任。本软件的使用是使用者本人操作思想的体现，使用本软件操作的一切行为都由使用者本人承担，与软件本身无关。用户在使用Ainco软件服务时，首先要认真学习操作方法。在完全掌握本软件的各项操作后方可开始使用。\n2、对于因不可抗力或本软件开发者不能控制的原因造成的网络服务中断或其它缺陷，本软件的开发者不承担任何责任。同时，本软件不承担Ainco软件，网络，计算机等外围设施给你造成的一切损失，若破解，盗版本软件所造成的一切后果由用户自己承担。同时还应承担法律责任。\n3、为了提供正常服务，本软件开发者会定期或不定期地对相关的设备进行检修或者维护而造成网络服务的中断，软件开发者尽力避免服务中断或将中断时间限制在最短时间内，在合理时间内的服务中断，软件开发者无需为此承担任何责任。如发生下列任何一种情形，软件开发者有权随时中断或终止向用户提供服务。而无需对用户或任何第三方承担任何责任：\n（1） 用户提供的资料不真实；\n（2） 用户违反服务条款的有关规定；\n（3） 用户在使用收费产品服务时未按规定向软件开发者支付相应的费用。\n4、用户在使用Ainco软件服务过程中，必须遵循以下原则：\n（1）遵守中国有关的法律和法规；\n（2）不得为任何非法目的而使用本软件；\n（3）遵守所有与服务有关的网络协议、规定和程序；\n5、您下载、安装、使用本软件等行为即视为您已阅读并同意受本协议的约束。本软件开发者有权在必要时修改本协议条款。您可以在本软件的最新版本中查阅相关协议条款。本协议条款变更后，如果您继续使用本软件，即视为您已接受修改后的协议。如果您不接受本协议或修改后的协议，应当立刻停止使用本软件。")
}

//sha 加密
func sha256Encrypt(_ input: String) -> String {
    if let inputData = input.data(using: .utf8) {
        let hashed = SHA256.hash(data: inputData)
        let encryptedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return encryptedString
    } else {
        return ""
    }
}

// 将字符串文件大小转换为字节数
func convertToBytes(_ sizeString: String) -> Int? {
    var multiplier = 1
    
    if sizeString.hasSuffix("GB") {
        multiplier = 1024 * 1024 * 1024
    } else if sizeString.hasSuffix("MB") {
        multiplier = 1024 * 1024
    } else if sizeString.hasSuffix("KB") {
        multiplier = 1024
    } else {
        return 0 // 无法解析的单位
    }
    
    if let numericValue = Double(sizeString.replacingOccurrences(of: " GB| MB| KB", with: "", options: .regularExpression)) {
        return Int(numericValue * Double(multiplier))
    }
    
    return 0 // 无法解析的数字部分
}

//时间戳转时间
func convertTimestampToDate(timestamp: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: date)
    return dateString
}


//新版密码输入框 2024 年 3 月 15 日 00:05
//构造输入密码弹窗的输入框
struct nPasswordModalView: View {
    
    @State var title: String //标题修改
    @State var msg: String //信息修改
    let btn: String //按钮标题
    
    let onInputCompletion: (String) -> Void
    
    @State private var password = AData.shared.password    //开机密码
    @State private var username = ProcessInfo().fullUserName    //获取当前登录的用户

    @State private var buttonColora = "ai" //按钮颜色
    @State private var isRunninga = false    //按钮状态
    
    @State private var buttonColorb = "4885ed" //按钮颜色
    @State private var isRunningb = false    //按钮状态
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 13).bold())
                .multilineTextAlignment(.center)
                .padding(2)
            Text(msg + "\n\n输入密码以允许此操作。")
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .padding(2)
            Spacer()
            Spacer()
            TextField("用户名", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .disabled(true)
            SecureField("密码", text: $password, onCommit: {
                // 按下回车键时执行的操作
                isRunningb = true
                query()
            })
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .disableAutocorrection(true) // 禁用密码框的自动填充功能
            Spacer()
            HStack{
                CustomButton(buttonText: "取消", action: {
                    onInputCompletion("取消")
                }, buttonColor: $buttonColora, isRunning: $isRunninga, radius: 5)
                
                CustomButton(buttonText: btn, action: query, buttonColor: $buttonColorb, isRunning: $isRunningb, radius: 5, max: true)
            }
        }
    }
    
    func query() {
        if password == "" {
            isRunningb = false
            onInputCompletion("错误")
            title = "密码验证失败”请重试。"
            msg = "无法支持开机密码为空，如需继续执行操作，请先前往设置给您的用户添加开机密码后操作，但别忘了重新设置回来喔！"
        }else{
            //避免卡顿回车键监听事件出现重复执行问题
            DispatchQueue.global(qos: .userInitiated).async {
                let bpassword = ssp(text: password)
                //判断当前状态
                let process = Process()
                process.launchPath = "/bin/bash"
                process.arguments = ["-c", "echo \(bpassword) | sudo -S -v && sudo -k"]
                
                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.launch()
                
                process.waitUntilExit()
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                
                if process.terminationStatus == 0 {
                    if(AData.shared.password == ""){
                        AData.shared.password = password
                    }
                    onInputCompletion(bpassword)
                }else{
                    isRunningb = false
                    onInputCompletion("错误")
                    title = "密码验证失败”请重试。"
                    msg = "当前用户开机密码不正确，如果您确认开机密码无误，可尝试将密码修改为纯数字后再试！"
                }
            }
        }
    }
}

//开机密码输入确认框
func nshowPasswordDialog(title: String, msg: String, btn: String, onInputCompletion: @escaping (String) -> Void) -> String? {
    //创建弹窗
    let alert = NSAlert()
    alert.messageText = ""
    let cancelButton = alert.addButton(withTitle: "取消")
    cancelButton.isHidden = true
    //获取输入框
    let passwordModal = nPasswordModalView(title: title, msg: msg, btn: btn, onInputCompletion: { password in
        if password == "取消" {
            NSApp.stopModal(withCode: NSApplication.ModalResponse.cancel)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                onInputCompletion("取消")
            }
            //NSApp.stopModal(withCode: NSApplication.ModalResponse.OK)
            //NSApp.stopModal(withCode: NSApplication.ModalResponse.cancel)
        }else if password == "错误" {
            // 执行弹窗抖动动画
            let contentView = alert.window.contentView
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.values = [
                NSValue(point: CGPoint(x: contentView!.frame.origin.x, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x + 6, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x - 6, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x + 6, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x - 6, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x - 5, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x + 5, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x - 5, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x + 5, y: contentView!.frame.origin.y)),
                NSValue(point: CGPoint(x: contentView!.frame.origin.x, y: contentView!.frame.origin.y))
            ]
            animation.keyTimes = [0.0, 0.15, 0.3, 0.15, 0.6, 1.0, 0.0, 0.1, 0.15, 0.3, 0.6, 1.0]
            animation.duration = 0.9
            contentView?.layer?.add(animation, forKey: "position")
        }else{
            NSApp.stopModal(withCode: NSApplication.ModalResponse.cancel)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                onInputCompletion(password)
            }
        }
    })
    alert.accessoryView = NSHostingView(rootView: passwordModal)
    alert.accessoryView?.frame = NSRect(x: 0, y: 0, width: 230, height: 220)
    
    alert.runModal()

    return ""
}

//加载图片
func loadImage(from imagePath: String) -> NSImage {
    guard let image = NSImage(contentsOfFile: ssp(text: imagePath)) else {
        return NSImage() // 返回空白图片，以免出现错误
    }
    return image
}

//写入宠物演示数据
func sendPet(){
    //解压宠物数据
    // Check if the directory exists
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let folderURL = documentsDirectory.appendingPathComponent("宠物数据")
        print(folderURL)
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDirectory) {
            print("宠物数据文件夹存在")
        } else {
            // Folder does not exist
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            guard let zipURL = Bundle.main.url(forResource: "test", withExtension: "zip") else {
                print("找不到压缩文件")
                return
            }
            let zipPath = zipURL.path
            let documents = "/Users/~/Documents/".replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
            shell("tar -xzf \(zipPath) -C \(documents)")
        }
    }
}

//请求辅助功能权限
func isAccessibilityEnabled() -> Bool {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    return AXIsProcessTrustedWithOptions(options)
}

//请求各个目录的访问权限
func getPath() {
    _ = shell("/usr/bin/mdfind 'kMDItemFSSize > 50000000000' -onlyin \"/Users/$(whoami)/Desktop\" -onlyin \"/Users/$(whoami)/Documents\" -onlyin \"/Users/$(whoami)/Music\" -onlyin \"/Users/$(whoami)/Movies\" -onlyin \"/Users/$(whoami)/Downloads\" -onlyin \"/Users/$(whoami)/Pictures\"")
}

//请求应用程序的管理权限
func getAppPath() {
    _ = shell("APP_NAME=$(find /Applications -maxdepth 1 -type d -name '*.app' | tail -n 1) && echo \"该文件由Ainco请求App管理权限时写入，如对当前App有影响可直接删除即可。\" > $APP_NAME/Ainco.txt ")
   //大于13.0 更新了APP管理
   if #available(macOS 13.0, *) {
       if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles") {
                  NSWorkspace.shared.open(url)
       }
   //小于13.0 需要开启全盘权限
   } else {
       if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                  NSWorkspace.shared.open(url)
       }
   }
}


//全局数据
class AData {
    static let shared = AData()
    
    var password: String = ""   //全局记录开机密码
    
    var firstOpen: Bool = false   //全局判断是否第一次打开
    
   
    private init() {}
}
