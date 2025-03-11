//
//  NotificationsList.swift
//  NextSync
//
//  Created by Claudio Cambra on 27/2/25.
//

import NextSyncKit
import SDWebImageSwiftUI
import SwiftUI

struct NotificationsList: View {
    let account: AccountModel
    let timer = Timer.publish(every: 5, on: .current, in: .common).autoconnect()
    let formatter = RelativeDateTimeFormatter()

    var dataSource: NotificationsDataSource
    @State var now = Date()

    init(account: AccountModel) {
        self.account = account
        self.dataSource = NotificationsDataSource(account: account)
    }

    var body: some View {
        ZStack {
            if (dataSource.notifications.isEmpty && dataSource.loading) {
                ProgressView()
                    .frame(alignment: .center)
            }
            List {
                ForEach(dataSource.notifications) { notification in
                    VStack(alignment: .leading) {
                        HStack {
                            if let imageUrlString = notification.icon,
                               let imageUrl = URL(string: imageUrlString)
                            {
                                WebImage(url: imageUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(
                                    width: Measurements.smallIconDimension,
                                    height: Measurements.smallIconDimension
                                )
                            } else {
                                Image(systemName: "bell.fill")
                                    .frame(
                                        width: Measurements.smallIconDimension,
                                        height: Measurements.smallIconDimension
                                    )
                            }
                            Text(notification.app)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(formatter.localizedString(for: notification.date, relativeTo: now))
                                .font(.footnote)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                                .frame(alignment: .trailing)
                            Button {
                                Task { await dataSource.delete(notification: notification) }
                            } label: {
                                Image(systemName: "xmark.circle")
                            }
                            .frame(alignment: .trailing)
                        }
                        Text(notification.subject).bold()
                        Text(notification.message)
                    }
                }
            }
        }
        .task { await dataSource.fetch() }
        .onReceive(timer) { _ in now = Date() }
    }
}
