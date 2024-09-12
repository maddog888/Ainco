//  Created by 阿金 on 2023/3/28.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI

//应用来源管理
struct Spctl: View {
    
    @State private var buttonColora = "e65d4c" //按钮颜色
    @State private var isRunninga = false    //按钮状态
    
    @State private var buttonColorb = "58be6a" //按钮颜色
    @State private var isRunningb = false    //按钮状态
    
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 90)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    Text("此功能将辅助您设置Mac允许从哪些位置安装应用程序")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 18)
                    HStack {
                        CustomButton(buttonText: "允许Mac安装非App Store及未认证的应用程序", action: openSpctl, buttonColor: $buttonColora, isRunning: $isRunninga, radius: 5)//允许
                        
                        CustomButton(buttonText: "仅允许Mac安装App Store及已认证的应用程序", action: closeSpctl, buttonColor: $buttonColorb, isRunning: $isRunningb, radius: 5)//不允许
                    }
                    .padding(.horizontal)
                }
                .padding(.top, -10)
                .padding(.bottom, -10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.2)
            )
    }
    
    private func openSpctl() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            nshowPasswordDialog(title: "开启“任何来源”将降低Mac的安全性。", msg: "设置允许您的Mac安装非App Store及未认证的应用程序。", btn: "更改设置") { password in
                if password != "取消" {
                    let process = Process()
                    process.launchPath = "/bin/bash"
                    process.arguments = ["-c", "echo \(password) | sudo -S spctl --master-disable"]
                    process.launch()
                    
                    process.waitUntilExit()
                    if process.terminationStatus==0{
                        showAlert(title: "设置已生效。")
                    }else{
                        showAlert(title: "未知错误，请重试。")
                    }
                }
                isRunninga = false
            }
        }
    }
    
    private func closeSpctl() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            nshowPasswordDialog(title: "关闭“任何来源”可提高Mac的安全性。", msg: "设置您的Mac仅能安装App Store及已认证的应用程序。", btn: "更改设置") { password in
                if password != "取消" {
                    let process = Process()
                    process.launchPath = "/bin/bash"
                    process.arguments = ["-c", "echo \(password) | sudo -S spctl --master-enable"]
                    process.launch()
                    
                    process.waitUntilExit()
                    if process.terminationStatus==0{
                        showAlert(title: "设置已生效。")
                    }else{
                        showAlert(title: "未知错误，请重试。")
                    }
                }
                isRunningb = false
            }
        }
    }

}

