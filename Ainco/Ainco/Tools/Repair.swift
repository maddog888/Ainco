//
//  Repair.swift
//  Ainco
//
//  Created by 苏文 on 2024/4/11.
//  Copyright © 2024 MadDog(A Jin). All rights reserved.
//

import SwiftUI

struct Repair: View {
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("使用问题修复")
                        Spacer()
                        Button(action: {
                            getPath()
                            if #available(macOS 13.0, *) {
                                _=shell("open \"x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders\"")
                            } else {
                                _=shell("open \"x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles\"")
                            }
                            showAlert(title: "请在打开的设置中授权Ainco相应的权限。")
                        }) {
                            Text("修复文件夹权限")
                        }
                        
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                nshowPasswordDialog(title: "修复缓存目录权限。", msg: "修复缓存目录无法正常写入文件等问题。", btn: "修复") { password in
                                    if password != "取消" {
                                        let documents = "/Users/~/Documents/AincoDownload".replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
                                        
                                        let process = Process()
                                        process.launchPath = "/bin/bash"
                                        process.arguments = ["-c", "echo \(password) | sudo -S chmod -R 777 \(documents)"]
                                        process.launch()
                                        
                                        process.waitUntilExit()
                                        if process.terminationStatus==0{
                                            showAlert(title: "设置已生效。")
                                        }else{
                                            showAlert(title: "未知错误，请重试。")
                                        }
                                    }
                                }
                            }
                        }) {
                            Text("修复缓存目录权限")
                        }
                        
                        Button(action: {
                            let documents = "/Users/~/Documents/".replacingOccurrences(of: "Users/~", with: "Users/\(NSUserName())")
                            shell("rm -rf \(documents)宠物数据")
                            sendPet()
                            showAlert(title: "重置成功")
                        }) {
                            Text("重置宠物数据")
                        }
                        
                        Button(action: {
                            if(!isAccessibilityEnabled()){
                                _ = shell("osascript -e 'tell application \"System Events\" to keystroke \" \" using {command down}'")
                            }
                            showAlert(title: "权限请求已发起，请授权Ainco相应的权限。")
                        }) {
                            Text("修复远程控制权限")
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
}
