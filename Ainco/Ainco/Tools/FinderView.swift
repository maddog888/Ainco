//  Created by 阿金 on 2023/3/28.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI

//是否显示隐藏文件管理
struct Finder: View {
    @Binding var loading: Bool  //加载状态
    
    @State private var isToggleOn = false    //显示状态0，为并没有开启全部文件显示
    @State private var tip = "系统及部分程序会产生 隐藏文件（包括但不限于缓存），强迫症请不要打开。"

    @State private var ShowLoading = true    //是否显示加载状态
    
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("显示Mac所有文件")
                        Image(systemNames: "info.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 3)
                            .padding(.leading, -3)
                        Text(tip)
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                            .padding(.leading, -10)
                        Spacer()
                        if ShowLoading {
                            Text("🔆")
                        }else{
                            Toggle("", isOn: Binding(
                                    get: { self.isToggleOn },
                                    set: { self.isToggleOn = $0; self.toggleChanged() }
                                ))
                                .toggleStyle(SwitchToggleStyle())
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.2)
            )
            .onAppear() {
                if loading {
                    loading = false //防止重复加载
                    DispatchQueue.global(qos: .userInitiated).async {
                        //判断当前状态
                        let process = Process()
                        process.launchPath = "/bin/bash"
                        process.arguments = ["-c", "defaults read com.apple.finder AppleShowAllFiles"]
                        let outputPipe = Pipe()
                        process.standardOutput = outputPipe
                        process.launch()

                        process.waitUntilExit()

                        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

                        if process.terminationStatus == 0 {
                            if let str = outputString {
                                if str.contains("1") {
                                    isToggleOn = true
                                    tip = "您所看到的半透明.开头的文件为 隐藏文件，请谨慎操作这类文件，比如把这个开关关闭。"
                                }
                            }
                        }
                        loading = true  //允许重新加载
                        ShowLoading = false //但是家宅状态应该修改为否
                    }
                }
            }
    }
    
    //显示隐藏的所有文件
    private func open() {
        shell("defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder")
        tip = "您所看到的半透明.开头的文件为 隐藏文件，请谨慎操作这类文件，比如把这个开关关闭。"
    }
    
    //不显示隐藏的文件
    private func close() {
        shell("defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder")
        tip = "系统及部分程序会产生 隐藏文件（包括但不限于缓存），强迫症请不要打开。"
    }
    
    //点击执行事件
    private func toggleChanged() {
        if isToggleOn {
            open()
        } else {
            close()
        }
    }
}

