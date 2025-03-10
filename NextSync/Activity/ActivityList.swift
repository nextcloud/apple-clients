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
    let timer = Timer.publish(every: 5, on: .current, in: .common).autoconnect()
    let formatter = RelativeDateTimeFormatter()

    var dataSource: ActivitiesDataSource
    @State var now = Date()

    init(account: AccountModel) {
        self.account = account
        self.dataSource = ActivitiesDataSource(account: account, previewSize: previewSize)
    }

    var body: some View {
        ZStack {
            if (dataSource.activities.isEmpty && dataSource.loading) {
                ProgressView()
                    .frame(alignment: .center)
            }
            List {
                ForEach(dataSource.activities) { activity in
                    HStack(spacing: spacing) {
                        previewImage(activity: activity)
                        VStack(alignment: .leading) {
                            Text(activity.subject)
                            Text(formatter.localizedString(for: activity.date, relativeTo: now))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .task { await dataSource.fetch() }
        .onReceive(timer) { _ in now = Date() }
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
