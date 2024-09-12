//
//  Launchpad.swift
//  Ainco
//
//  Created by 阿金 on 2023/5/8.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI

//启动台图标管理
struct Launchpad: View {
    
    @State private var appTitle: [String] = [] //APP标题
    
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("启动台图标整理")
                        Image(systemNames: "info.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 3)
                            .padding(.leading, -3)
                        Text("注意：移除图标并不会移除图标所属的程序，如果需要移除程序，请在'应用管理'中操作，此功能一般用于移除应用残留图标。")
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                            .padding(.leading, -10)
                        Spacer()
                        Button(action: {
                            LaunchpadAdmin()
                        }) {
                            Text("前往整理")
                        }
                        .padding(.leading, 5)
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                nshowPasswordDialog(title: "注意！！！", msg: "执行该操作会导致您现有的启动台图标位置被打乱，同时已经移除的图标也会被恢复并恢复桌面壁纸！\n您确定要执行此操作吗？", btn: "确认重置") { password in
                                    if password != "取消" {
                                        shell("echo \(password) | sudo -S mv $(echo \(password) | sudo -S find /private/var/folders -name com.apple.dock.launchpad 2>/dev/null) ~/.Trash/")
                                        shell("rm ~/Library/Application\\ Support/Dock/*.db; killall Dock")
                                        shell("defaults write com.apple.dock ResetLaunchPad -bool TRUE; killall Dock")
                                    }
                                }
                            }
                        }) {
                            Text("重置")
                        }
                    }
                    .padding(.horizontal)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.2)
            )
    }
    
    
    
    
    //开机密码输入确认框
    func LaunchpadAdmin(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            nshowPasswordDialog(title: "启动台整理。", msg: "查询并整理启动台图标数据", btn: "开始查询") { password in
                if password != "取消" {
                    let outputPipe = shell("echo \(password) | sudo -S sqlite3 $(echo \(password) | sudo -S find /private/var/folders -name com.apple.dock.launchpad 2>/dev/null)/db/db \"SELECT title FROM apps;\"")
                    
                    if outputPipe != "" {
                        let appPaths = outputPipe.components(separatedBy: "\n")
                        for path in appPaths {
                            if !path.isEmpty {
                                appTitle.append(path)
                            }
                        }
                        //创建弹窗
                        let alert = NSAlert()
                        alert.messageText = "启动台图标管理"
                        alert.addButton(withTitle: "好了👌🏻~我整理完成了")
                        
                        alert.accessoryView = NSHostingView(rootView: lList(titles: appTitle, password: password))
                        alert.accessoryView?.frame = NSRect(x: 0, y: 0, width: 300, height: 233)
                        alert.runModal()
                    }else{
                        //shell("echo \(password) | sudo -S mv $(echo \(password) | sudo -S find /private/var/folders -name com.apple.dock.launchpad 2>/dev/null) ~/.Trash/")
                        
                        //shell("rm ~/Library/Application\\ Support/Dock/*.db; killall Dock")
                        showAlert(title: "查询启动台数据失败，请重置后再试。")
                    }
                }
            }
        }
    }

    
}

struct lList: View {
    @State var titles: [String]
    var password: String
    
    @State private var showingAlert = false
    
    var body: some View {
        List(titles.indices, id: \.self) { index in
            HStack {
                Text(titles[index])
                Spacer()
                Button(action: {
                    shell("sqlite3 $(echo \(password) | sudo -S find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='\(titles[index])';\" && killall Dock")
                    titles.remove(at: index)
                }) {
                    Text("移除")
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 13))

        Button(action: {
            showingAlert = true
        }) {
            Text("一键恢复启动台图标原始状态")
                .frame(maxWidth: .infinity)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("注意！！！"), message: Text("执行该操作会导致您现有的启动台图标位置被打乱，同时已经移除的图标也会被恢复！\n您确定要执行此操作吗？"), primaryButton: .default(Text("确定")) {
                shell("defaults write com.apple.dock ResetLaunchPad -bool TRUE; killall Dock")
            }, secondaryButton: .cancel(Text("取消")))
        }
    }
}
