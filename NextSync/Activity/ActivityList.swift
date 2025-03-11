//
//  ActivityList.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import NextSyncKit
import SDWebImageSwiftUI
import SwiftUI

struct ActivityList: View {
    let account: AccountModel
    let timer = Timer.publish(every: 5, on: .current, in: .common).autoconnect()
    let formatter = RelativeDateTimeFormatter()

    var dataSource: ActivitiesDataSource
    @State var now = Date()

    init(account: AccountModel) {
        self.account = account
        self.dataSource = ActivitiesDataSource(
            account: account, previewSize: Measurements.previewDimension
        )
    }

    var body: some View {
        ZStack {
            if (dataSource.activities.isEmpty && dataSource.loading) {
                ProgressView()
                    .frame(alignment: .center)
            }
            List {
                Section {
                    ForEach(dataSource.activities) { activity in
                        HStack(spacing: Measurements.spacing) {
                            previewImage(activity: activity)
                            VStack(alignment: .leading) {
                                if activity.message.isEmpty {
                                    Text(activity.subject)
                                } else {
                                    Text(activity.message).bold()
                                    Text(activity.subject)
                                }
                                Text(formatter.localizedString(for: activity.date, relativeTo: now))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("Activity", systemImage: "bolt.fill")
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
        } else if !activity.icon.isEmpty, let iconUrl = URL(string: activity.icon) {
            previewImageWithModifiers(WebImage(url: iconUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            })
        } else {
            previewImageWithModifiers(Image(systemName: "bolt.fill"))
        }
    }

    @ViewBuilder
    private func previewImageWithModifiers(_ image: some View) -> some View {
        image
            .frame(width: Measurements.previewDimension, height: Measurements.previewDimension)
            .clipShape(RoundedRectangle(cornerRadius: Measurements.cornerRadius))
    }
}
