//  Created by 阿金 on 2023/3/14.
//  主页面文件


import SwiftUI

//清除更新提示
struct CloseUpdate: View {

    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("消除系统更新小红点通知")
                        Image(systemNames: "info.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 3)
                            .padding(.leading, -3)
                        Text("一键消除小红点，却不会屏蔽更新，如再出现时可再消除或更新即可。")
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                            .padding(.leading, -10)
                        Spacer()
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                nshowPasswordDialog(title: "消除系统设置小红点。", msg: "整个过程大约3~5秒，过程可能会出现卡顿，包括网络中断，请耐心等待处理完成即可。", btn: "马上消除") { password in
                                    if password != "取消" {
                                        let process = Process()
                                        process.launchPath = "/bin/bash"
                                        process.arguments = ["-c", "echo \(password) | sudo -S date 010100002012 && softwareupdate -l && echo \(password) | sudo -S systemsetup -setusingnetworktime off && echo \(password) | sudo -S systemsetup -setusingnetworktime on"]
                                        process.launch()
                                        
                                        process.waitUntilExit()
                                        //无论上面的代码是否生效都执行下面这段
                                        shell("defaults delete com.apple.systempreferences AttentionPrefBundleIDs && defaults write com.apple.systempreferences AttentionPrefBundleIDs -dict-add \"com.apple.preferences.extensions.ExtensionManager\" '{ \"com.apple.preferences.extensions.ExtensionManager\" = 0; }' && killall Dock")
                                        
                                        showAlert(title: "设置已生效。")
                                    }
                                }
                            }
                        }) {
                            Text("使用小红点消失术")
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

