//
//  FastHelp.swift
//  Ainco
//
//  Created by 苏文 on 2024/4/3.
//  Copyright © 2024 MadDog(A Jin). All rights reserved.
//

import SwiftUI

struct FastHelp: View {
    @Binding var Show: Bool  //当前步骤是否完成

    @State private var Lnow = 1 //当前步骤
    @State private var Lleft = 0    //当前指示左边位置
    @State private var Ltop = 39    //当前指示顶部位置
    let Lconunt = 10 //帮助步骤总数
    
    @State private var buttonText = "下一步"    //当前指示顶部位置
    
    var body: some View {
        VStack{
            HStack{
                HStack {
                    //如果大于5则离开了列表，隐藏该指示
                    if(Lnow<5){
                        Text("◀︎")
                            .font(.system(size: 39))
                            .foregroundColor(Color.accentColor)
                            .padding(.trailing, -20)
                            .padding(.top, -60)
                    }
                    //填充框
                    VStack{
                        HStack{
                            //内容
                            VStack{
                                //上部分内容
                                if(Lnow == 1){
                                    LMessage(title: "应用管理", tip: "一键卸载应用程序及其相关的数据、缓存等 🫕")
                                }else if(Lnow == 2){
                                    LMessage(title: "空间优化", tip: "优化Mac硬盘空间，清理应用缓存、日志等 🧹")
                                }else if(Lnow == 3){
                                    LMessage(title: "大件扫描", tip: "查找5MB以上的文件及内容一样的重复文件 🕳️")
                                }else if(Lnow == 4){
                                    LMessage(title: "实用工具", tip: "让您拥有超多称心如意的实用小公主 👸🏻")
                                }else if(Lnow == 5){
                                    LMessage(title: "智能窗口", tip: "“点击”此处可打开智能窗口，助您一臂之力 💪")
                                }else if(Lnow == 6){
                                    LMessage(title: "为了能够正常为您服务", tip: "如有弹出权限请求，请为我点“允许” 谢谢 🥰")
                                }else if(Lnow == 7){
                                    LMessage(title: "智能窗口“必开权限”", tip: "点下一步后会弹出系统设置，请您按下图操作")
                                }else if(Lnow == 8){
                                    LMessage(title: "马上就好", tip: "请在根据下图操作打开权限后继续 🫰")
                                }else if(Lnow == 9){
                                    LMessage(title: "我再啰嗦一句", tip: "如果您点击任何地方都没有反应，请重启电脑")
                                }else if(Lnow == 10){
                                    LMessage(title: "恭喜您上手了", tip: "祝你顺风顺水顺财神~祝你朝朝暮暮有人疼 💖")
                                }
                                //下部分内容
                                HStack{
                                    //跳过-暂时不允许跳过
                                    Button(action: {
                                        
                                    }) {
                                        Text("(\(Lnow)/\(Lconunt))")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                            .opacity(0.9)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Spacer()
                                    
                                    //大于1才显示上一步
                                    if(Lnow > 1){
                                        Button(action: {
                                            //如果等于5则恢复在列表的位置
                                            if(Lnow==5){
                                                Ltop = 129
                                                Lleft = 0
                                                Lnow = Lnow-1
                                            }else{
                                                //否则默认只减步骤
                                                Lnow = Lnow-1
                                                //如果小于5则属于列表区域网上爬
                                                if(Lnow<5){
                                                    Ltop = Ltop-30
                                                }
                                            }
                                        }) {
                                            Text("上一步")
                                                .frame(width: 60)
                                                .foregroundColor(Color.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .stroke(Color.white, lineWidth: 3) // 设置描边颜色和宽度
                                                )
                                                .background(Color.white.opacity(0.001))
                                                .cornerRadius(5)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    Button(action: {
                                        //如果已经到达步骤总数则没有任何反应
                                        if(Lnow==Lconunt){
                                            //修改显示状态
                                            Show = false
                                            //结束首次运行判断
                                            AData.shared.firstOpen = false
                                            return
                                        }
                                        Lnow = Lnow+1
                                        //如果大于等于5则变换到中间显示
                                        if(Lnow>=5){
                                            Ltop = -21
                                            Lleft = 30
                                        }else{
                                            //否则都是往下掉
                                            Ltop = Ltop+30
                                        }
                                        
                                        if(Lnow==6){
                                            //请求所需路径的权限 延迟让用户看到文字
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                getPath()
                                            }
                                        }
                                        if(Lnow==8){
                                            //请求APP管理权限
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                getAppPath()
                                            }
                                        }
                                        if(Lnow==9){
                                            //尝试写Ainco缓存目录-存在会自动失败
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                _ = shell("mkdir ~/Documents/AincoDownload && chmod 777 ~/Documents/AincoDownload")
                                            }
                                        }
                                        if(Lnow==Lconunt){
                                            buttonText = "好的"
                                        }
                                    }) {
                                        Text("\(buttonText)")
                                            .frame(width: 60)
                                            .foregroundColor(Color.accentColor)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 6)
                                            .background(Color.white)
                                            .cornerRadius(5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.leading, 33)
                                .padding(.top, 26)
                                .padding(.trailing, 30)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .frame(height:160)
                    .frame(width: 380)
                    
                    //大于等于5属于在中间位置，才把这个指标显示出来
                    if(Lnow>=5){
                        Text("▼")
                            .font(.system(size: 39))
                            .foregroundColor(Color.accentColor)
                            .padding(.leading, -68)
                            .padding(.top, 165)
                    }
                    
                    Spacer()
                }
                .padding(.leading, CGFloat(Lleft))
                .padding(.top, CGFloat(Ltop))
                Spacer()
            }
            if(Lnow==7 || Lnow==8){
                VStack{
                    if #available(macOS 13.0, *) {
                        Image("OpenApp")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 399)
                    } else {
                        Image("OpenFull")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 399)
                    }
                }
                .padding(.top, -30)
            }
            Spacer()
        }
        .background(Color("FastBackground").opacity(0.001))
        .frame(minHeight:600)
        .frame(minWidth: 730)
    }
}


//信息框
private struct LMessage: View {
    var title = ""
    var tip = ""
    
    var body: some View {
        //内容
        VStack{
            HStack{
                Text("\(title)")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(20)
                Spacer()
            }
            
            HStack{
                Text("\(tip)")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.top, -15)
                Spacer()
            }
        }
    }
}
