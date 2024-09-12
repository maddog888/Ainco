//  Created by 阿金 on 2023/3/25.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//

import SwiftUI
import Cocoa

struct ToolsView: View{
    @Binding var loading: Bool  //加载状态
    @Binding var bloading: Bool  //加载状态
    @Binding var cloading: Bool  //加载状态
    @Binding var dloading: Bool  //加载状态
    
    //let jsonURL = Bundle.main.url(forResource: "a", withExtension: "json")!
    //let modelCreator = TextModelCreator()
    
    var body: some View{
        VStack{
            ScrollView {
                Text("Mac 安全性")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 13)
                    .padding(.leading, 38)
                Spctl()//应用来源管理
                Text("辅助功能")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 38)
                    .padding(.top, 10)
                UrlShow(loading: $bloading)//路径栏显示状态
                Desktop(loading: $dloading)//桌面图标管理
                Finder(loading: $loading)//隐藏文件管理
                NetWorkR()//重置网络环境
                CloseUpdate()//消除系统更新小红点
                Launchpad()//启动台管理
                DockList(loading: $cloading)//启动台图标列数
                Reapps()//修复已损坏程序
                Repair()//修复Ainco
                
                Text("")    //用于占位
                //Spacer()
                //测试方法
                
                /*
                Button(action: {
                    /*
                    modelCreator.createTextModel(from: jsonURL) { model, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Text model created successfully!")
                        }
                    }
                     */
                }) {
                    Text("生成模型")
                }
                
                Button(action: {
                    modelCreator.getTextModel(inputText: "127") { model, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Text model created successfully!")
                        }
                    }
                }) {
                    Text("预测")
                }
                 */
            }
        }
        .frame(minHeight:600)
        .frame(width: 730)
    }

}
