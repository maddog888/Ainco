//
//  DockList.swift
//  Ainco
//
//  Created by 阿金 on 2023/7/16.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI

//启动台列数设置
struct DockList: View {
    @Binding var loading: Bool  //加载状态
    
    @State private var ShowLoading = true    //是否显示加载状态
    
    @State private var value: Double = 7
    
    @State private var i = 0
    
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("启动台图标列数")
                        Image(systemNames: "info.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 3)
                            .padding(.leading, -3)
                        Text("放大或缩小显示效果。")
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                            .padding(.leading, -10)
                        
                        Spacer()
                        Spacer()
                        if ShowLoading {
                            Text("🔆")
                        }else{
                            Slider(value: $value, in: 2...15, step: 1)
                                .padding(.trailing)
                                .onChanges(of: value) { _ in
                                    if i >= 1 {
                                        print("设置")
                                        shell("defaults write com.apple.dock springboard-columns -int \(Int(value)) && killall Dock")
                                    }
                                    i = 1
                                }
                            
                            Text("\(Int(value))")
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
                        if let num = shell("defaults read com.apple.dock springboard-columns") as? String {
                            if let dou = Double(num) {
                                value = dou
                            }
                        }
                        loading = true  //允许重新加载
                        ShowLoading = false //但是家宅状态应该修改为否
                    }
                }
            }
    }
    
}
