//
//  NetWorkR.swift
//  Ainco
//
//  Created by 阿金 on 2023/7/16.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI

//重置网络环境
struct NetWorkR: View {
    
    var body: some View {
        Rectangle()
            .frame(width: 680, height: 50)
            .foregroundColor(.gray.opacity(0.06))
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Text("修复网络环境")
                        Image(systemNames: "info.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 3)
                            .padding(.leading, -3)
                        Text("一键修复上网异常，针对WiFi网络异常问题，关闭所有网络代理，重置DNS环境。")
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                            .padding(.leading, -10)
                        Spacer()
                        Button(action: {
                            shell("networksetup -setwebproxystate Wi-Fi off && networksetup -setsecurewebproxystate Wi-Fi off && networksetup -setsocksfirewallproxystate Wi-Fi off && networksetup -setdnsservers Wi-Fi empty && networksetup -setdnsservers Wi-Fi 223.5.5.5 223.6.6.6")
                            showAlert(title: "重置成功")
                        }) {
                            Text("重置网络环境")
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


