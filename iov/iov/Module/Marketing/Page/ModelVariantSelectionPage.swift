//
//  ModelVariantSelectionPage.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI
import Kingfisher

/// 车型版本选择页
struct ModelVariantSelectionPage: View {
    @StateObject var container: MviContainer<ModelVariantSelectionIntentProtocol, ModelVariantSelectionModelStateProtocol>
    private var intent: ModelVariantSelectionIntentProtocol { container.intent }
    private var state: ModelVariantSelectionModelStateProtocol { container.model }

    var body: some View {
        ZStack {
            switch state.contentState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            case .content:
                VStack(spacing: 0) {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("select_variant"))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(state.models, id: \.modelCode) { model in
                                ModelSection(
                                    model: model,
                                    onTapVariant: { variant in
                                        intent.onTapVariant(model: model, variant: variant)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, AppTheme.layout.margin)
                        .padding(.top, 16)
                        .padding(.bottom, 34)
                    }
                    .scrollIndicators(.hidden)
                }
            case let .error(text):
                VStack(spacing: 0) {
                    TopBackTitleBar(titleLocal: LocalizedStringKey("select_variant"))
                    ErrorTip(text: text)
                }
            }
        }
        .background(AppTheme.colors.background.ignoresSafeArea())
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MarketingRouter(subjects: state.routerSubject))
    }
}

// MARK: - Model Section

extension ModelVariantSelectionPage {
    struct ModelSection: View {
        let model: ConfiguratorResult.ModelItem
        let onTapVariant: (ConfiguratorResult.VariantItem) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text(model.modelName)
                        .font(AppTheme.fonts.title1)
                        .foregroundColor(AppTheme.colors.fontPrimary)
                    
                    if let marketingCopy = model.marketingCopy, !marketingCopy.isEmpty {
                        Text(marketingCopy)
                            .font(AppTheme.fonts.subtext)
                            .foregroundColor(AppTheme.colors.fontTertiary)
                    }
                }
                
                ForEach(model.variants, id: \.variantCode) { variant in
                    VariantCard(
                        variant: variant,
                        onTap: { onTapVariant(variant) }
                    )
                }
            }
        }
    }
    
    struct VariantCard: View {
        let variant: ConfiguratorResult.VariantItem
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    if let imageUrl = variant.marketingImage, !imageUrl.isEmpty {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 80)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(variant.variantName)
                            .font(AppTheme.fonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.colors.fontPrimary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("￥")
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.brandMain)
                            Text(variant.variantPrice.formatted())
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.colors.brandMain)
                        }
                        
                        if let marketingCopy = variant.marketingCopy, !marketingCopy.isEmpty {
                            Text(marketingCopy)
                                .font(AppTheme.fonts.subtext)
                                .foregroundColor(AppTheme.colors.fontSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.colors.fontTertiary)
                }
                .padding(16)
                .background(AppTheme.colors.cardBackground)
                .cornerRadius(AppTheme.layout.radiusMedium)
            }
            .buttonStyle(.plain)
        }
    }
}
