//
//  ActivityList.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import NextSyncKit
import SwiftUI

struct ActivityList: View {
    let account: AccountModel
    let previewSize: CGFloat = 32
    let spacing: CGFloat = 8
    let borderRadius: CGFloat = 4
    @ObservedObject var dataSource: ActivitiesDataSource

    init(account: AccountModel) {
        self.account = account
        self.dataSource = ActivitiesDataSource(account: account, previewSize: previewSize)
    }

    var body: some View {
        List {
            ForEach(dataSource.activities) { activity in
                HStack(spacing: spacing) {
                    previewImage(activity: activity)
                    Text(activity.subject)
                }
            }
        }
        .task { await dataSource.fetch() }
    }

    @ViewBuilder
    private func previewImage(activity: NKActivity) -> some View {
        if let previewImage = dataSource.previews[activity.idActivity] {
            previewImageWithModifiers(previewImage.resizable())
        } else {
            previewImageWithModifiers(Image(systemName: "bolt.fill"))
        }
    }

    @ViewBuilder
    private func previewImageWithModifiers(_ image: Image) -> some View {
        image
            .frame(width: previewSize, height: previewSize)
            .clipShape(RoundedRectangle(cornerRadius: borderRadius))
    }
}
