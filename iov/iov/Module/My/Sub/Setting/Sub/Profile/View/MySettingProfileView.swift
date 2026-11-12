//
//  MySettingProfileView.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

struct MySettingProfileView: View {
    @StateObject var container: MviContainer<MySettingProfileIntentProtocol, MySettingProfileModelStateProtocol>
    private var intent: MySettingProfileIntentProtocol { container.intent }
    private var state: MySettingProfileModelStateProtocol { container.model }
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.colors.background)
        .safeAreaInset(edge: .top) {
            TopBackTitleBar(title: "个人资料")
                .background(AppTheme.colors.background)
        }
        .onAppear {
            intent.viewOnAppear()
        }
        .modifier(MySettingProfileRouter(
            subjects: state.routerSubject,
            intent: intent
        ))
    }
}

// MARK: - Views

private extension MySettingProfileView {
    
    private struct Content: View {
        let intent: MySettingProfileIntentProtocol
        let state: MySettingProfileModelStateProtocol
        @State private var showBirthday = false
        @State private var selectedDate = Date()
        @State var showAvatarFlow: Bool = false
        @State var showPhotoPermissionAlert: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppTheme.layout.spacing) {
                        VStack(spacing: 20) {
                            Button(action: {
                                guard state.avatarOperation != .uploading else { return }
                                AvatarPhotoPermission.requestIfNeeded { granted in
                                    if granted {
                                        self.showAvatarFlow = true
                                    } else {
                                        self.showPhotoPermissionAlert = true
                                    }
                                }
                            }) {
                                ZStack {
                                    AvatarImage(avatar: state.avatar, width: 80)
                                    if state.avatarOperation == .uploading {
                                        Circle()
                                            .fill(Color.black.opacity(0.45))
                                            .frame(width: 80, height: 80)
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(state.avatarOperation == .uploading)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: MySettingProfileNicknameView(nickname: state.nickname, action: { nickname in intent.onTapNicknameSaveButton(nickname: nickname) })
                                .navigationBarHidden(true)) {
                                MySettingProfileView.List(title: "昵称", value: state.nickname)
                            }
                            .buttonStyle(.plain)
                            NavigationLink(destination: MySettingProfileBioView(bio: state.bio, action: { bio in intent.onTapBioSaveButton(bio: bio) })
                                .navigationBarHidden(true)) {
                                MySettingProfileView.List(title: "签名", value: state.bio)
                            }
                            .buttonStyle(.plain)
                            NavigationLink(destination: MySettingProfileGenderView(selectedGender: state.gender, action: { gender in intent.onTapGenderSaveButton(gender: gender) })
                                .navigationBarHidden(true)) {
                                MySettingProfileView.List(title: "性别", value: genderStr(state.gender))
                            }
                            .buttonStyle(.plain)
                            Button(action: { showBirthday = true }) {
                                MySettingProfileView.List(title: "生日", value: state.birthday != nil ? dateToStr(date: state.birthday!) : "")
                            }
                            .buttonStyle(.plain)
                            NavigationLink(destination: MySettingProfileAreaView(action: { city in
                                intent.onTapCity(city: city)})
                                .navigationBarHidden(true)) {
                                MySettingProfileView.List(title: "用车城市", value: cityStr(state.city.isEmpty ? state.area : state.city))
                            }
                            .buttonStyle(.plain)

                        }
                        .appCardStyle()
                    }
                    .padding(.horizontal, AppTheme.layout.margin)
                    .padding(.top, 20)
                }
            }
            .onAppear {
                selectedDate = state.birthday ?? Date()
            }
            .sheet(isPresented: $showBirthday) {
                VStack {
                    TopCloseTitleBar(title: "生日") {
                        showBirthday = false
                    }
                    VStack(alignment: .center) {
                        DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark) // 强制深色模式以匹配主题
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        
                        RoundedCornerButton(nameLocal: LocalizedStringKey("confirm"), color: .black, bgColor: AppTheme.colors.brandMain) {
                            intent.onTapBirthdaySaveButton(date: selectedDate)
                            showBirthday = false
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                }
                .padding(20)
                .background(AppTheme.colors.background)
                .presentationDetents([.height(380)])
            }
            .alert("无法访问相册", isPresented: $showPhotoPermissionAlert) {
                Button("取消", role: .cancel) {}
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("请在系统设置中允许访问相册")
            }
            .sheet(isPresented: $showAvatarFlow) {
                AvatarFlowView(
                    onCropConfirmed: { input in
                        showAvatarFlow = false
                        intent.onConfirmAvatarCrop(input)
                    },
                    onCancel: {
                        showAvatarFlow = false
                        intent.onCancelAvatarCrop()
                    }
                )
            }
        }
    }
    
}


// MARK: - 头像选择/裁剪流程

/// 相册选择 → 裁剪确认（仅相册入口，IOS-APP-DSN-CR-003 US-003-1）
private struct AvatarFlowView: View {
    var onCropConfirmed: (AvatarCropInput) -> Void
    var onCancel: () -> Void

    @State private var pickedImage: UIImage?

    var body: some View {
        Group {
            if let pickedImage = pickedImage {
                AvatarCropView(
                    image: pickedImage,
                    onCancel: onCancel,
                    onConfirm: onCropConfirmed
                )
            } else {
                ImagePicker(sourceType: .photoLibrary, dismissOnPick: false) { image in
                    pickedImage = image
                }
            }
        }
    }
}

struct MySettingProfileView_Previews: PreviewProvider {
    @StateObject static var appGlobalState = AppGlobalState.shared
    static var previews: some View {
        MySettingProfileView(container: MySettingProfileView.buildContainer())
            .environmentObject(appGlobalState)
    }
}
