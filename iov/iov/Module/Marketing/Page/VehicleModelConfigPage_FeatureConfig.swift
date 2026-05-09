//
//  VehicleModelConfigPage_FeatureConfig.swift
//  iov
//
//  Created by hwyz_leo on 2024/10/6.
//

import SwiftUI
import Kingfisher

extension VehicleModelConfigPage {
    struct FeatureConfigView: View {
        @StateObject var container: MviContainer<VehicleModelConfigIntentProtocol, VehicleModelConfigModelStateProtocol>
        private var intent: VehicleModelConfigIntentProtocol { container.intent }
        private var state: VehicleModelConfigModelStateProtocol { container.model }
        
        let featureRange: FeatureCodeRangeVo
        @Binding var selectedFeature: FeatureCodeDetailVo?
        
        @State private var selectedTab = 0
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Ellipse()
                        .fill(RadialGradient(colors: [Color.white.opacity(0.1), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                        .frame(width: 300, height: 60)
                        .blur(radius: 20)
                        .offset(y: 20)
                    
                    if !featureRange.featureDetails.isEmpty {
                        TabView(selection: $selectedTab) {
                            ForEach(Array(featureRange.featureDetails.enumerated()), id: \.offset) { index, feature in
                                if !feature.featureImage.isEmpty {
                                    KFImage(URL(string: feature.featureImage[0])!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .tag(index)
                                } else {
                                    Image(systemName: "car")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                        .tag(index)
                                }
                            }
                        }
                        .frame(height: 240)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
                .padding(.top, 20)
                
                if let currentFeature = selectedFeature {
                    VStack(spacing: 8) {
                        Text(currentFeature.featureName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        Text(currentFeature.featurePrice == 0 ? LocalizedStringKey("included") : "￥\(currentFeature.featurePrice.formatted())")
                            .font(AppTheme.fonts.body)
                            .foregroundColor(AppTheme.colors.brandMain)
                        
                        if let desc = currentFeature.featureDesc, !desc.isEmpty {
                            Text(desc)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 24)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(featureRange.featureDetails.enumerated()), id: \.offset) { index, feature in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                    selectedFeature = feature
                                    intent.onTapFeature(familyCode: featureRange.familyCode, feature: feature)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if let param = feature.featureParam, !param.isEmpty, param.hasPrefix("#") {
                                        Circle()
                                            .fill(Color(hexStr: param))
                                            .frame(width: 16, height: 16)
                                    }
                                    
                                    Text(feature.featureName)
                                        .font(.system(size: 14, weight: selectedFeature?.featureCode == feature.featureCode ? .bold : .regular))
                                        .foregroundColor(selectedFeature?.featureCode == feature.featureCode ? .white : AppTheme.colors.fontPrimary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedFeature?.featureCode == feature.featureCode ? AppTheme.colors.brandMain : AppTheme.colors.cardBackground)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(AppTheme.colors.brandMain.opacity(0.3), lineWidth: selectedFeature?.featureCode == feature.featureCode ? 0 : 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 32)
                
                Spacer()
            }
            .onAppear {
                if selectedFeature == nil {
                    selectedFeature = state.selections[featureRange.familyCode]
                    syncSelectedIndex()
                }
                if selectedFeature == nil, let firstFeature = featureRange.featureDetails.first {
                    selectedFeature = firstFeature
                    intent.onTapFeature(familyCode: featureRange.familyCode, feature: firstFeature)
                }
            }
            .onChange(of: state.selections[featureRange.familyCode]) { newFeature in
                selectedFeature = newFeature
                syncSelectedIndex()
            }
        }
        
        private func syncSelectedIndex() {
            if let feature = selectedFeature,
               let index = featureRange.featureDetails.firstIndex(where: { $0.featureCode == feature.featureCode }) {
                selectedTab = index
            }
        }
    }
}