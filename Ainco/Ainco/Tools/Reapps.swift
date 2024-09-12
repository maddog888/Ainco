//  Created by 阿金 on 2023/3/28.
//  Copyright © 2023 MadDog(A Jin). All rights reserved.
//
import SwiftUI

//修复APP
struct Reapps: View {

    @State var title = "将程序拖到此处即可"   //状态
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 680, height: 50)
                .foregroundColor(.gray.opacity(0.06))
                .cornerRadius(8)
                .overlay(
                    VStack {
                        HStack {
                            Text("修复并运行已损坏的应用程序")
                            Image(systemNames: "info.circle")
                                .foregroundColor(.gray)
                                .padding(.trailing, 3)
                                .padding(.leading, -3)
                            Text("以.app结尾的文件，包括但不仅限于部分签名失效的应用程序，同时可用于应用多开。(如修复无运行请尝试手动运行！)")
                                .foregroundColor(.gray)
                                .font(.system(size: 11))
                                .padding(.leading, -10)
                            Spacer()
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 138, height: 38)
                                .cornerRadius(8)
                                .onDrop(of: ["public.file-url"], isTargeted: nil) { (info) -> Bool in
                                    guard let item = info.first else { return false }
                                    item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                                        if let error = error {
                                            title = "Error: \(error.localizedDescription)"
                                        } else if let urlData = urlData as? Data,
                                                  let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                                            if url.pathExtension == "app" {
                                                reA(aurl: url.path)
                                            } else {
                                                title = "非应用程序.app文件"
                                            }
                                        }
                                    }
                                    return true
                                }
                                .overlay(
                                    VStack {
                                        Text("+").foregroundColor(.gray.opacity(0.5))
                                            .bold()
                                        Text(title).foregroundColor(.gray.opacity(0.5))
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.2)
                                )
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
    }
    
    //拖动事件
    private func reA(aurl: String) {
        //解决运行奔溃问题
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startApp(aurl: aurl) {ret in}
        }
    }
}
