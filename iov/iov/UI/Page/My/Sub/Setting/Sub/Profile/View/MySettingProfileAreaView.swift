//
//  MySettingProfileAreaView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import SwiftUI
import CoreLocation

struct MySettingProfileAreaView: View {
    @Environment(\.dismiss) private var dismiss
    @State var state: String = "province"
    @State var province: String = ""
    var action: ((_ city: String)->Void)?
    
    var body: some View {
        ZStack {
            switch state {
            case "province":
                Province(action: { province in
                    self.province = province
                    self.state = "city"
                })
            case "city":
                City(
                    province: $province,
                    action: { city in
                        action?(city)
                        dismiss()
                    },
                    backAction: {
                        self.state = "province"
                        self.province = ""
                    }
                )
            default:
                Province(action: { province in
                    self.province = province
                    self.state = "city"
                })
            }
        }
    }
}

private extension MySettingProfileAreaView {
    
    private struct Province: View {
        @StateObject var locationManager = LocationManager()
        @State private var locationArea = "点击重试"
        var action: ((_ province: String)->Void)?
        
        class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
            let manager = CLLocationManager()

            @Published var location: CLLocationCoordinate2D?

            override init() {
                super.init()
                manager.delegate = self
            }

            func requestLocation() {
                manager.requestLocation()
            }
            
            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                 print("error:: \(error.localizedDescription)")
            }
            
            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if status == .authorizedWhenInUse {
                    requestLocation()
                }
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                location = locations.first?.coordinate
            }
        }
        
        
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "地区")
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("当前位置")
                            .foregroundColor(.gray)
                        Button(action: {
                            self.locationManager.requestLocation()
                            if let location = self.locationManager.location {
                                locationArea = "\(location.latitude), \(location.longitude)"
                            }
                        }) {
                            VStack {
                                HStack {
                                    Image("location")
                                    Text(locationArea)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 10)
                                }
                                .padding(.bottom, 30)
                                .padding(.top, 20)
                                .modifier(BottomLineModifier())
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                            .frame(height: 50)
                        Text("国内其他区域")
                            .foregroundColor(.gray)
                        ForEach(Provinces.sorted(by: { $0.key < $1.key }), id: \.key) { province in
                            Button(action: {
                                action?(province.key)
                            }) {
                                VStack {
                                    HStack {
                                        Text(province.value)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 10)
                                    }
                                    .padding(.bottom, 20)
                                    .padding(.top, 20)
                                    Divider()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
    
    private struct City: View {
        @Binding var province: String
        var action: ((_ city: String)->Void)?
        var backAction: (()->Void)?
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "地区") {
                    backAction?()
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(Cities.sorted(by: { $0.key < $1.key }), id: \.key) { city in
                            if city.key.hasPrefix(province) {
                                Button(action: {
                                    action?(city.key)
                                }) {
                                    VStack {
                                        HStack {
                                            Text(city.value)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 10)
                                        }
                                        .padding(.bottom, 20)
                                        .padding(.top, 20)
                                        Divider()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Spacer()
                    }
                    .padding(20)
                }
                .edgesIgnoringSafeArea(.top)
            }
            .onAppear(perform: {

            })
        }
    }
}

struct MySettingProfileAreaView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileAreaView()
    }
}
