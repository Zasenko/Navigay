import UserNotifications
import SwiftUI

protocol NotificationsManagerProtocol {
    func addAroundNotification(dates: [Date])
    func addFridaysNotification(userDate: Date)
    func addEventNotification(event: Event)
    func removeEventNotification(event: Event)
}

final class NotificationsManager {
        
    // MARK: - Private Properties

    private let center: UNUserNotificationCenter
    private let directory: URL?
    private let fileManager: FileManager

    // MARK: - Init

    init() {
        self.center = UNUserNotificationCenter.current()
        self.fileManager = .default
        if let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Notifications"),
           fileManager.checkFolder(url: directory) {
            self.directory = directory
            let urls = fileManager.scanDirectory(url: directory)
            debugPrint("----- FileManager Notifications urls ------")
            debugPrint(urls)
     //       for url in urls {
               // self.urls.append(url)
    //            if let data = try? Data(contentsOf: url),
    //               let image = UIImage(data: data) {
    //                urls.append((image, url))
    //            }
    //        }
        } else {
            self.directory = nil
        }
        requestNotificationAuthorization()
        center.removeAllDeliveredNotifications()
    }
}

// MARK: - NotificationsManagerProtocol

extension NotificationsManager: NotificationsManagerProtocol {
    
    func addAroundNotification(dates: [Date]) {
        removeObsoleteNotifications(dates: dates)
        let calendar = Calendar.current
        for date in dates {
            guard let year = calendar.dateComponents([.year], from: date).year,
                  let month = calendar.dateComponents([.month], from: date).month,
                  let day = calendar.dateComponents([.day], from: date).day else {
                continue
            }
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour =  12 /// 24-hour format
            dateComponents.minute = 30
            createCalendarNotification(title: "Daily Event Reminder", body: "Today events are happening around you. Check them out!", attachments: nil, dateComponents: dateComponents, identifier: "AroundNotification\(year)\(month)\(day)")
        }
        removeFridaysNotifications()
    }
    
    func addFridaysNotification(userDate: Date) {
        removeDaylyNotifications()
        var dateComponents = DateComponents()
        dateComponents.weekday = 6 /// 6 is Friday in the Gregorian calendar
        dateComponents.hour = 12
        dateComponents.minute = 30
        createCalendarNotification(title: "Weekend Event Reminder", body: "Find out what's happening around you this weekend!", attachments: nil, dateComponents: dateComponents, identifier: "FridayNotification")
    }
    
    func addEventNotification(event: Event) {
        let identifier = "EventNotification\(event.id)"
        let calendar = Calendar.current
        guard let year = calendar.dateComponents([.year], from: event.startDate).year,
              let month = calendar.dateComponents([.month], from: event.startDate).month,
              let day = calendar.dateComponents([.day], from: event.startDate).day else { return }
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        if let startTime = event.startTime {
            dateComponents.hour = calendar.dateComponents([.hour], from: startTime).hour
            dateComponents.minute = calendar.dateComponents([.minute], from: startTime).minute
        } else {
            dateComponents.hour = 10
            dateComponents.minute = 0
        }
//        if let eventDate = calendar.date(from: dateComponents),
//           let finalDate = calendar.date(byAdding: .hour, value: -2, to: eventDate) {
//            let finalDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalDate)
//            if let url = event.smallPoster,
//               let directory {
//                Task {
//                    guard let data = await ImageLoader.shared.loadData(urlString: url),
//                        let _ = UIImage(data: data) else {
//                        createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        if let fileURL = self.fileManager.saveImage(data: data, directory: directory, identifier: identifier) {
//                            do {
//                                let newAttachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
//                                self.createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: [newAttachment], dateComponents: finalDateComponents, identifier: identifier)
//                            } catch {
//                                print("Error creating notification attachment: \(error.localizedDescription)")
//                                self.createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
//                            }
//                        } else {
//                            self.createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
//                        }
//                    }
//                }
//            } else {
//                createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
//            }
//        } else {
            createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: dateComponents, identifier: identifier)
      //  }
    }
        
    func removeEventNotification(event: Event) {
        let identifier = "EventNotification\(event.id)"
//        if let directory {
//            fileManager.removeImageFromDisk(directory: directory, identifier: identifier)
//        }
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

extension NotificationsManager {
    
    // MARK: - Private Functions
    
    private func requestNotificationAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("Notification access granted.")
                    } else {
                        print("Notification access denied.\(String(describing: error?.localizedDescription))")
                    }
                }
                return
            case .denied:
                print("Notification access denied")
                return
            case .authorized:
                print("Notification access granted.")
                return
            default:
                return
            }
        }
    }
    
    private func createTimeIntervalLocalNotification(title: String, body: String, timeInterval: Double, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:  timeInterval, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func createCalendarNotification(title: String, body: String, attachments: [UNNotificationAttachment]?, dateComponents: DateComponents, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        if let attachments {
            content.attachments = attachments
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
 
    private func removeObsoleteNotifications(dates: [Date]) {
        let calendar = Calendar.current
        let newIdentifiers = dates.map { date -> String in
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return "AroundNotification\(year)\(month)\(day)"
        }
        center.getPendingNotificationRequests { [weak self] requests in
            let oldIdentifiers = requests.filter { $0.identifier.starts(with: "AroundNotification") }.map { $0.identifier }
            let identifiersToRemove = oldIdentifiers.filter { !newIdentifiers.contains($0) }
            self?.center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    private func removeDaylyNotifications() {
        center.getPendingNotificationRequests { [weak self] requests in
            let notifications = requests.filter { $0.identifier.starts(with: "AroundNotification") }.map { $0.identifier }
            self?.center.removePendingNotificationRequests(withIdentifiers: notifications)
        }
    }
    
    private func removeFridaysNotifications() {
        center.getPendingNotificationRequests { [weak self] requests in
            let notifications = requests.filter { $0.identifier.starts(with: "FridayNotification") }.map { $0.identifier }
            self?.center.removePendingNotificationRequests(withIdentifiers: notifications)
        }
    }
}
