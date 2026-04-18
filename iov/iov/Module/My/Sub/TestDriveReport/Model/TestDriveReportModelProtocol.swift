//
//  TestDriveReportModelProtocol.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

import Foundation

// MARK: - View State

protocol TestDriveReportModelStateProtocol {
    var contentState: TestDriveReportTypes.Model.ContentState { get }
    var routerSubject: TestDriveReportRouter.Subjects { get }
}

// MARK: - Intent Action

protocol TestDriveReportModelActionProtocol: MviModelActionProtocol {
}

// MARK: - Route

protocol TestDriveReportModelRouterProtocol: MviModelRouterProtocol {
}
