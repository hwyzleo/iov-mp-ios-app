//
//  MySettingProfileAreaView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
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
                }, confirmAction: action)
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
                }, confirmAction: action)
            }
        }
    }
}

private extension MySettingProfileAreaView {
    
    private struct Province: View {
        @Environment(\.dismiss) private var dismiss
        @StateObject var locationManager = LocationManager()
        @State private var locationArea = "点击重试"
        var action: ((_ province: String)->Void)?
        var confirmAction: ((_ city: String)->Void)?
        
        class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
            let manager = CLLocationManager()
            let geocoder = CLGeocoder()

            @Published var location: CLLocationCoordinate2D?
            @Published var cityName: String?
            @Published var cityCode: String?

            override init() {
                super.init()
                manager.delegate = self
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            }

            func requestLocation() {
                let status = manager.authorizationStatus
                if status == .notDetermined {
                    manager.requestWhenInUseAuthorization()
                } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                    manager.requestLocation()
                } else {
                    print("Location unauthorized")
                }
            }
            
            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                 print("error:: \(error.localizedDescription)")
            }
            
            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    manager.requestLocation()
                }
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                guard let location = locations.first else { return }
                self.location = location.coordinate
                
                // 逆地理编码获取城市
                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                    if let city = placemarks?.first?.locality {
                        DispatchQueue.main.async {
                            self?.cityName = city
                            // 查找对应的城市码
                            if let code = Cities.first(where: { $0.value == city })?.key {
                                self?.cityCode = code
                            } else if let code = Provinces.first(where: { $0.value == city })?.key {
                                // 针对直辖市的情况，可能在Provinces里
                                self?.cityCode = code
                            }
                        }
                    }
                }
            }
        }
        
        
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(title: "选择城市")
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.layout.spacing) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("当前位置")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                            
                            Button(action: {
                                if let cityCode = locationManager.cityCode {
                                    confirmAction?(cityCode)
                                    dismiss()
                                } else {
                                    self.locationManager.requestLocation()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(AppTheme.colors.brandMain)
                                    Text(locationManager.cityName ?? locationArea)
                                        .font(AppTheme.fonts.body)
                                        .foregroundColor(AppTheme.colors.fontPrimary)
                                    Spacer()
                                    if locationManager.cityName != nil {
                                        Text("确认")
                                            .font(AppTheme.fonts.subtext)
                                            .foregroundColor(AppTheme.colors.brandMain)
                                    }
                                }
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(.plain)
                            .onChange(of: locationManager.cityName) { newValue in
                                if let city = newValue {
                                    locationArea = city
                                }
                            }
                        }
                        .appCardStyle()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("其他区域")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                            
                            VStack(spacing: 0) {
                                ForEach(Provinces.sorted(by: { $0.key < $1.key }), id: \.key) { province in
                                    Button(action: {
                                        action?(province.key)
                                    }) {
                                        HStack {
                                            Text(province.value)
                                                .font(AppTheme.fonts.body)
                                                .foregroundColor(AppTheme.colors.fontPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.colors.fontTertiary)
                                        }
                                        .padding(.vertical, 16)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if province.key != Provinces.sorted(by: { $0.key < $1.key }).last?.key {
                                        Divider()
                                    }
                                }
                            }
                            .appCardStyle()
                        }
                    }
                    .padding(AppTheme.layout.margin)
                }
            }
            .appBackground()
        }
    }
    
    private struct City: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var province: String
        var action: ((_ city: String)->Void)?
        var backAction: (()->Void)?
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer().frame(height: kStatusBarHeight)
                TopBackTitleBar(title: "选择城市") {
                    backAction?()
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("城市")
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontSecondary)
                        
                        VStack(spacing: 0) {
                            let filteredCities = Cities.sorted(by: { $0.key < $1.key }).filter { $0.key.hasPrefix(province) }
                            ForEach(filteredCities, id: \.key) { city in
                                Button(action: {
                                    action?(city.key)
                                }) {
                                    HStack {
                                        Text(city.value)
                                            .font(AppTheme.fonts.body)
                                            .foregroundColor(AppTheme.colors.fontPrimary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if city.key != filteredCities.last?.key {
                                    Divider()
                                }
                            }
                        }
                        .appCardStyle()
                    }
                    .padding(AppTheme.layout.margin)
                }
            }
            .appBackground()
        }
    }
}

struct MySettingProfileAreaView_Previews: PreviewProvider {
    static var previews: some View {
        MySettingProfileAreaView()
    }
}
