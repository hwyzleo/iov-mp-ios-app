//
//  LoginView+Build.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import SwiftUI

extension LoginPage {
    
    static func buildMobileLogin(
        loginService: LoginServiceProtocol = ServiceContainer.loginService,
        sessionRepository: AuthSessionRepositoryProtocol = AuthEnvironment.shared.sessionRepository,
        authState: LoginAuthPublishing = AppGlobalState.shared,
        profileRefresher: LoginProfileRefreshing = TspLoginProfileRefresher()
    ) -> some View {
        let container = makeContainer(
            loginService: loginService,
            sessionRepository: sessionRepository,
            authState: authState,
            profileRefresher: profileRefresher
        )
        let view = LoginPage(container: container)
        return view
    }
    
    static func buildMobileVerifyCode(
        loginService: LoginServiceProtocol = ServiceContainer.loginService,
        sessionRepository: AuthSessionRepositoryProtocol = AuthEnvironment.shared.sessionRepository,
        authState: LoginAuthPublishing = AppGlobalState.shared,
        profileRefresher: LoginProfileRefreshing = TspLoginProfileRefresher()
    ) -> some View {
        let model = LoginModel()
        model.updateAgree(true)
        model.updateMobile("138 0000 0000")
        model.completeSendingCode(
            countryRegionCode: "+86",
            mobile: "138 0000 0000",
            resendAvailableAt: Date().addingTimeInterval(LoginModel.resendInterval)
        )
        let intent = LoginIntent(
            model: model,
            loginService: loginService,
            sessionRepository: sessionRepository,
            authState: authState,
            profileRefresher: profileRefresher
        )
        let container = MviContainer(
            intent: intent as LoginIntentProtocol,
            model: model as LoginModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
        let view = LoginPage(container: container)
        return view
    }
    
    // MARK: - Private
    
    private static func makeContainer(
        loginService: LoginServiceProtocol,
        sessionRepository: AuthSessionRepositoryProtocol,
        authState: LoginAuthPublishing,
        profileRefresher: LoginProfileRefreshing
    ) -> MviContainer<LoginIntentProtocol, LoginModelStateProtocol> {
        let model = LoginModel()
        let intent = LoginIntent(
            model: model,
            loginService: loginService,
            sessionRepository: sessionRepository,
            authState: authState,
            profileRefresher: profileRefresher
        )
        return MviContainer(
            intent: intent as LoginIntentProtocol,
            model: model as LoginModelStateProtocol,
            modelChangePublisher: model.objectWillChange
        )
    }
    
}
