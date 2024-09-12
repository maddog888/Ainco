//
//  AppDelegate.swift
//  66
//
//  Created by 阿金 on 2023/3/14.
//

import SwiftUI
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // 添加一个菜单栏图标
    var statusItem: NSStatusItem!
    
    //显示状态
    var ws: Bool!
    
    //主窗口
    var mainView: MyWindowController?
    
    
    //休息提醒
    var restRr: restReminder?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {// 程序启动完成后运行
        //判断是否在映像中运行
        let appBundleURL = Bundle.main.bundleURL
        let appInstallPath = appBundleURL.deletingLastPathComponent().path
        
        if appInstallPath.contains("/Volumes") {
            // 在 Volumes 中运行，将自身拷贝到应用程序文件夹
            copyToApplicationsFolder()
            return
        }
        //判断是否为首次运行，提示用户协议
        if let filePath = Bundle.main.path(forResource: "AincoAg", ofType: "txt") {
            openAg()
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch let error as NSError {
                print("文件删除失败：\(error.localizedDescription)")
            }
            AData.shared.firstOpen = true   //标记全局变量为首次打开
            //写入宠物演示数据
            sendPet()
            //首次运行 主页面窗口
            do {
                // 可能抛出异常的代码
                let mainfirst = try MyWindowController()
                //关闭
                mainfirst.close()
            } catch {
                // 处理异常
            }
            //休息提醒-默认不打开就是0
            UserDefaults.standard.set(0, forKey: "RestReminder")
        }

        
        ws = true   //标记创建已存在
        
        NewWindows()    //创建主窗口
        
       
        // 创建状态栏菜单栏项
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // 设置状态栏菜单栏图标
        if let button = statusItem.button {
            let image = NSImage(named: NSImage.Name("menu"))
            image?.isTemplate = true
            image?.size = NSSize(width: 18, height: 18)
            button.image = image

            // 设置鼠标左右键事件响应
            //#selector(NewWindows) // 我希望鼠标左键执行这个
            button.action = #selector(mouseClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        //休息提醒
        if(UserDefaults.standard.integer(forKey: "RestReminder") > 0){
            restRr = restReminder()
            restRr?.run(m: UserDefaults.standard.integer(forKey: "RestReminder"))
        }
        
    
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        //当用户关闭窗口后不退出
        NSApp.setActivationPolicy(.accessory)
        ws = true
        return false
    }
    
    //如果应用重复打开
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NewWindows()
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    //复制自身到应用程序文件夹中
    func copyToApplicationsFolder() {
        let fileManager = FileManager.default
        let appBundleURL = Bundle.main.bundleURL
        let appFileName = appBundleURL.lastPathComponent
        let appFolderPath = "/Applications/\(appFileName)"

        // 检查应用程序是否已经在应用程序文件夹中
        if fileManager.fileExists(atPath: appFolderPath) {
            showAlert(title: "请根据提示将Ainco拖动到应用程序文件夹中完成安装替换后再运行。")
            NSApplication.shared.terminate(self)
        }else{
            // 拷贝应用程序到应用程序文件夹
            do {
                try fileManager.copyItem(at: appBundleURL, to: URL(fileURLWithPath: appFolderPath))

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    open(url: "/Applications/Ainco.app")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NSApplication.shared.terminate(self)
                    }
                }
            } catch {
                showAlert(title: "请根据提示将Ainco拖动到应用程序文件夹中完成安装后再运行。")
                NSApplication.shared.terminate(self)
            }
        }
    }

    @objc func mouseClick(_ sender: AnyObject?) {
        //判断鼠标左键还是鼠标右键
        if let event = NSApplication.shared.currentEvent {
            //如果是右键才显示右键菜单其余都是打开ai菜单
            if event.type.rawValue == 4 {
                showMenu(sender)
            }else{
                //showAI(sender)
                showAI(sender)
            }
            //清空状态
            statusItem?.menu = nil
        }
    }
    
    @objc func NewWindows() {
        if ws {
            mainView = MyWindowController()
            // 监听主窗口关闭的通知
            NotificationCenter.default.addObserver(self, selector: #selector(mainClose), name: NSWindow.willCloseNotification, object: mainView?.window)
            
            mainView?.showWindow(nil)
            ws = false
        }
        //显示
        mainView?.showWindow(nil)
    }
    
    //如果监听到主窗口被关闭
    @objc func mainClose() {
        ws = true
        //运行新建新的主窗口
    }
    
    @objc func showAI(_ sender: AnyObject?) {
        // 创建和配置菜单项
        let menu = NSMenu()
        // 设置菜单的最小宽度
        menu.minimumWidth = 300
        
        // 创建菜单项
        let dmenuItem = NSMenuItem(title: "显示Ainco", action: #selector(NewWindows), keyEquivalent: "")
        menu.addItem(dmenuItem)
        
        //休息提醒
        let RestmenuItem = NSMenuItem(title: "休息提醒", action: #selector(Restset), keyEquivalent: "")
        // 根据条件设置菜单项的状态
        RestmenuItem.state = UserDefaults.standard.integer(forKey: "RestReminder") > 0 ? .on : .off
        menu.addItem(RestmenuItem)
    
        
        
        //退出
        let quitMenuItem = NSMenuItem(title: "退出Ainco", action: #selector(quit(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        // 显示菜单
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil) // 单击以显示菜单
    }

    @objc func showMenu(_ sender: AnyObject?) {
        // 创建和配置菜单项
        let menu = NSMenu()
        let menuItem = NSMenuItem(title: "显示Ainco", action: #selector(NewWindows), keyEquivalent: "")
        menu.addItem(menuItem)
        let quitMenuItem = NSMenuItem(title: "退出Ainco", action: #selector(quit(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        
        // 显示菜单
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil) // 单击以显示菜单
    }

    
    @objc func quit(_ sender: AnyObject?) {
        NSApplication.shared.terminate(self)
    }

    
    //休息
    @objc func Restset(_ sender: AnyObject?) {
        if(UserDefaults.standard.integer(forKey: "RestReminder") > 0){
            UserDefaults.standard.set(0, forKey: "RestReminder")
            restRr?.close()
        }else{
            UserDefaults.standard.set(45, forKey: "RestReminder")
            restRr?.run(m: UserDefaults.standard.integer(forKey: "RestReminder"))
        }
        showAI(nil) // 重新加载菜单以更新打钩状态
    }
    
    //UserDefaults.standard.bool(forKey: "comm")

}


class MyWindowController: NSWindowController {
    //创建不同的窗口
    convenience init() {
        self.init(window: nil)
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 930, height: 600),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                //.resizable,
                .fullSizeContentView,
                .borderless
            ], backing: .buffered, defer: false)
        
        // 配置窗口属性
        self.window?.titlebarAppearsTransparent = true
        self.window?.titleVisibility = .hidden
        self.window?.center()
        self.window?.isMovableByWindowBackground = true
        self.window?.setFrameAutosaveName("Ainco")
        let contentView = MainWindowView()
        self.window?.contentView = NSHostingView(rootView: contentView)
        
        // 设置窗口代理
        //self.window?.delegate = self
        NSApp.setActivationPolicy(.regular)
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}

//休息提醒
class restReminder {
    
    private var timer: Timer?
    
    func run(m: Int){
        self.timer = Timer.scheduledTimer(withTimeInterval: Double(m) * 60, repeats: true) { timer in
            if(UserDefaults.standard.integer(forKey: "RestReminder") > 0){
                self.show(m: m)
            }
        }
    }
    
    func close(){
        self.timer?.invalidate()
    }
    
    func show(m: Int){
        _ = shell("osascript -e 'display notification \"您已经持续工作了\(m)分钟，请您先去喝口水或者来一组开合跳放松一下吧！\" with title \"长时间工作提醒\" sound name \"Ping\"'")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            Screen()
        }
        //如果中途被设置为关闭，则终止
        if(UserDefaults.standard.integer(forKey: "RestReminder") <= 0){
            self.close()
        }
    }
    
    
}

// 进入屏幕保护程序
func Screen() {
    _ = shell("open /System/Library/CoreServices/ScreenSaverEngine.app")
}

