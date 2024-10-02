//
//  MySettingProfileView.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
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
        @State private var image: UIImage? = nil
        @State private var showBirthday = false
        @State private var selectedDate = Date()
        @State var showImagePicker: Bool = false
        
        var body: some View {
            VStack {
                TopBackTitleBar(title: "个人资料")
                Spacer()
                    .frame(height: 50)
                VStack {
                    Button(action: { self.showImagePicker.toggle() }) {
                        AvatarImage(avatar: state.avatar, width: 80)
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        self.image = image
                        intent.onSelectAvatar(image: image)
                    }
                }
                VStack {
                    NavigationLink(destination: MySettingProfileNicknameView(nickname: state.nickname, action: { nickname in intent.onTapNicknameSaveButton(nickname: nickname) })
                        .navigationBarHidden(true)) {
                        MySettingProfileView.List(title: "昵称", value: state.nickname)
                    }
                    .buttonStyle(.plain)
                    NavigationLink(destination: MySettingProfileGenderView(selectedGender: state.gender, action: { gender in intent.onTapGenderSaveButton(gender: gender) })
                        .navigationBarHidden(true)) {
                        MySettingProfileView.List(title: "性别", value: genderStr(state.gender))
                    }
                    .buttonStyle(.plain)
                    Button(action: { showBirthday = true }) {
                        MySettingProfileView.List(title: "生日", value: dateToStr(date: state.birthday))
                    }
                    NavigationLink(destination: MySettingProfileAreaView(action: { city in
                        intent.onTapCity(city: city)})
                        .navigationBarHidden(true)) {
                        MySettingProfileView.List(title: "地区", value: state.area)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                Spacer()
            }
            .onAppear {
                selectedDate = state.birthday
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
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        Button(action: {
                            intent.onTapBirthdaySaveButton(date: selectedDate)
                            showBirthday = false
                        }) {
                            Text("保存")
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .background(Color.black)
                                .cornerRadius(22.5)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
                .padding(20)
                .presentationDetents([.height(350)])
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
