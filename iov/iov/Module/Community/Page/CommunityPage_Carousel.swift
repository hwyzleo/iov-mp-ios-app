//
//  CommunityPage_Carousel.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension CommunityPage {
    /// CMS `BANNER_CAROUSEL`
    struct BannerCarousel: View {
        let state: ExploreBannerComponentViewState
        let action: (ExploreTargetViewState) -> Void

        @State private var currentIndex = 0

        private var count: Int { state.items.count }

        var body: some View {
            if count == 0 {
                EmptyView()
            } else {
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomLeading) {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                                Button(action: { action(item.target) }) {
                                    ZStack(alignment: .bottomLeading) {
                                        ExploreRemoteImage(image: item.image,
                                                           height: ExploreTheme.Layout.heroHeight,
                                                           cornerRadius: ExploreTheme.Radius.panel,
                                                           accessibilityLabel: item.title)

                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .black.opacity(0.78)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous))
                                        .allowsHitTesting(false)

                                        if let title = item.title, !title.isEmpty {
                                            Text(title)
                                                .font(ExploreTheme.Fonts.cardTitle)
                                                .foregroundColor(ExploreTheme.Colors.textPrimary)
                                                .lineLimit(2)
                                                .padding(16)
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                                .buttonStyle(ExploreCardButtonStyle())
                                .tag(index)
                                .accessibilityLabel(Text(item.title ?? NSLocalizedString("explore_image_unavailable", comment: "")))
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: ExploreTheme.Layout.heroHeight)
                        .clipShape(RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: ExploreTheme.Radius.panel, style: .continuous)
                                .strokeBorder(ExploreTheme.Colors.border, lineWidth: 1)
                        )

                        if count > 1 {
                            HStack(spacing: 6) {
                                ForEach(0..<count, id: \.self) { index in
                                    Capsule()
                                        .fill(currentIndex == index ? ExploreTheme.Colors.brand : Color.white.opacity(0.25))
                                        .frame(width: currentIndex == index ? 18 : 6, height: 4)
                                        .shadow(color: currentIndex == index ? ExploreTheme.Colors.brand.opacity(0.55) : .clear, radius: 4)
                                        .animation(.spring(), value: currentIndex)
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .onReceive(Timer.publish(every: TimeInterval(state.intervalSeconds), on: .main, in: .common).autoconnect()) { _ in
                    guard count > 1 else { return }
                    withAnimation {
                        currentIndex = (currentIndex + 1) % count
                    }
                }
                .onChange(of: count) { newCount in
                    if currentIndex >= newCount {
                        currentIndex = 0
                    }
                }
            }
        }
    }
}
