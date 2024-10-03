//
//  ServiceView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import Kingfisher

struct ServicePage: View {
    
    @StateObject var container: MviContainer<ServiceIntentProtocol, ServiceModelStateProtocol>
    private var intent: ServiceIntentProtocol { container.intent }
    private var state: ServiceModelStateProtocol { container.model }
    
    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                Content(intent: intent, state: state)
            case let .error(text):
                ErrorTip(text: text)
            }
        }
        .onAppear {
            if state.contentBlocks.count == 0 {
                intent.viewOnAppear()
            }
        }
        .modifier(ServiceRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

extension ServicePage {
    
    struct Content: View {
        let intent: ServiceIntentProtocol
        var state: ServiceModelStateProtocol
        
        var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        Text("充电服务")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    ZStack {
                        KFImage(URL(string: "https://pic.imgdb.cn/item/65f69fcc9f345e8d03da5fc4.png")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(5)
                        VStack {
                            Spacer()
                                .frame(height: 20)
                            HStack {
                                Spacer()
                                    .frame(width: 10)
                                Text("自营充电中心")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                        .frame(height: 10)
                    HStack {
                        ZStack {
                            KFImage(URL(string: "https://pic.imgdb.cn/item/65f6a0a49f345e8d03df1867.png")!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .cornerRadius(5)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("超充服务")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                        .frame(width: 5)
                                }
                                Spacer()
                                    .frame(height: 5)
                            }
                        }
                        Spacer()
                            .frame(width: 10)
                        ZStack {
                            KFImage(URL(string: "https://pic.imgdb.cn/item/65f6a0f69f345e8d03e0d85a.png")!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .cornerRadius(5)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                        .frame(width: 5)
                                    Text("家充服务")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                    .frame(height: 5)
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    Divider()
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("购车服务")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    ZStack {
                        KFImage(URL(string: "https://pic.imgdb.cn/item/65f6a1749f345e8d03e3b789.png")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(5)
                        VStack {
                            Spacer()
                                .frame(height: 20)
                            HStack {
                                Spacer()
                                    .frame(width: 10)
                                Text("选购车型")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        VStack {
                            Image(systemName: "yensign.circle")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("金融服务")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("参数配置")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "licenseplate")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("牌照指标")
                                .font(.system(size: 14))
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "checkmark.shield")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("车辆保障")
                                .font(.system(size: 14))
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    Divider()
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("用车服务")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    ZStack {
                        KFImage(URL(string: "https://pic.imgdb.cn/item/65f6a0369f345e8d03dcb099.png")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(5)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                    .frame(width: 10)
                                Text("用车问题随时咨询")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 60)
                        }
                    }
                    Spacer()
                        .frame(height: 10)
                    HStack {
                        VStack {
                            Image(systemName: "house.and.flag")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("服务网点")
                                .font(.system(size: 14))
                        }
                        .padding(10)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: 0xdddfdf))
                        .cornerRadius(5)
                        Spacer()
                            .frame(width: 10)
                        VStack {
                            Image(systemName: "truck.pickup.side")
                                .font(.system(size: 25))
                            Spacer()
                                .frame(height: 5)
                            Text("无忧救援")
                                .font(.system(size: 14))
                        }
                        .padding(10)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: 0xdddfdf))
                        .cornerRadius(5)
                    }
                    Spacer()
                        .frame(height: 20)
                    Divider()
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("售后服务")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        VStack {
                            Image(systemName: "checkmark.shield")
                                .font(.system(size: 25))
                        }
                        .frame(width: 50)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("车主权益")
                                    .font(.system(size: 18))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 5)
                            Text("道路救援 家用充电桩 流量无忧方案")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        VStack {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 20))
                        }
                        .frame(width: 50)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("维修保养")
                                    .font(.system(size: 18))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                                .frame(height: 5)
                            Text("保养提醒 远程诊断 便捷服务")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        let container = ServicePage.buildContainer()
        ScrollView {
            ServicePage.Content(intent: container.intent, state: container.model)
        }
    }
}
