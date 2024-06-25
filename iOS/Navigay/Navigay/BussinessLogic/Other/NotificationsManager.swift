import Foundation
import UserNotifications
import SwiftUI

protocol NotificationsManagerProtocol {
    func addAroundNotification(dates: [Date])
    func addFridaysNotification(userDate: Date)
    func addEventNotification(event: Event)
    func removeEventNotification(event: Event)
}

final class NotificationsManager: ObservableObject {
    
    @Published var urls: [URL] = []
    let center: UNUserNotificationCenter
    private let directory: URL

    init() {
        self.center = UNUserNotificationCenter.current()
        let manager = FileManager.default
        self.directory = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        requestNotificationAuthorization()
        center.removeAllDeliveredNotifications()
//        
//        self.folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Notifications")
//        checkFolder(url: folderURL)
        scanTheDirectory(directory)
    }
    
//    private func checkFolder(url: URL) {
//        if !FileManager.default.fileExists(atPath: url.path) {
//            do {
//                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//            } catch {
//                print("Failed to create folder: \(error.localizedDescription)")
//            }
//        }
//    }
    
    private func scanTheDirectory(_ url: URL) {
        urls.removeAll()
        let urls = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])) ?? []
        print("-------scanTheDirectory URLS--------")
        print(urls)
        print("---------------------")

        for url in urls {
            self.urls.append(url)
//            if let data = try? Data(contentsOf: url),
//               let image = UIImage(data: data) {
//                urls.append((image, url))
//            }
        }
    }
}

extension NotificationsManager: NotificationsManagerProtocol {
    
    func addAroundNotification(dates: [Date]) {
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
        removeObsoleteNotifications(dates: dates)
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
        if let eventDate = calendar.date(from: dateComponents),
           let finalDate = calendar.date(byAdding: .hour, value: -2, to: eventDate) {
            let finalDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalDate)
            if let url = event.smallPoster {
                Task {
                    guard let data = await ImageLoader.shared.loadData(urlString: url),
                        let image = UIImage(data: data) else {
                        print("no data")
                        createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
                        return
                    }
                    debugPrint("data.count: ", data.count)
                    
                    DispatchQueue.main.async {
                        var attachments: [UNNotificationAttachment]? = nil
                        let fileURL = self.directory.appendingPathComponent(identifier)
                        do {
                            try data.write(to: fileURL)
                            
//                           self.images.append((image, fileURL))
                            self.urls.append(fileURL)
                            
                            if let imageData = image.jpegData(compressionQuality: 1.0) {
                                let fileName = identifier + ".jpg"
                                let fileURL = self.directory.appendingPathComponent(fileName)
                                try imageData.write(to: fileURL)
                                let newAttachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
                                attachments = [newAttachment]
                                print("Notification attachment created: \(fileName)")
                            }
                            self.createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: attachments, dateComponents: finalDateComponents, identifier: identifier)
                        } catch {
                            print("Failed to save image data: \(error.localizedDescription)")
                            self.createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)
                        }
                    }
                }
                
            } else {
                createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: finalDateComponents, identifier: identifier)

            }
        } else {
            createCalendarNotification(title: event.name, body: "Don't miss! The event starts soon.", attachments: nil, dateComponents: dateComponents, identifier: identifier)
        }
        
    }
        
    func removeEventNotification(event: Event) {
        let identifier = "EventNotification\(event.id)"
        removeImageFromDisk(event: event)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

extension NotificationsManager {
    
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
            } else {
               // print("Notification \(content.title) added")
            }
        }
    }
    
    // let identifier = "EventNotification\(event.id)"
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
            } else {
            //    print("Notification \(content.title) added")
            }
        }
    }
    
//    private func scheduleNotification(with image: UIImage, event: Event, dateComponents: DateComponents) {
//        let identifier = "EventNotification\(event.id)"
//
//        let content = UNMutableNotificationContent()
//        content.title = event.name
//        content.body = "Don't miss! The event starts soon."
//        content.sound = UNNotificationSound.default
//        if let imageData = image.jpegData(compressionQuality: 1.0) {
//            let fileName = UUID().uuidString + ".jpg"
//
//            let fileURL = directory.appendingPathComponent(fileName)
//            do {
//                try imageData.write(to: fileURL)
//                let attachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: nil)
//                content.attachments = [attachment]
//                print("Notification attachment created: \(fileName)")
//            } catch {
//                print("Failed to create notification attachment: \(error.localizedDescription)")
//            }
//        }
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }

//    private func saveImage(from url: String, event: Event, dateComponents: DateComponents) {
//        Task {
//            guard let data = await ImageLoader.shared.loadData(urlString: url) else {
//                print("no data")
//                return }
//            debugPrint("data.count: ", data.count)
//            if let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    let fileURL = self.directory.appendingPathComponent(UUID().uuidString)
//                    do {
//                        try data.write(to: fileURL)
//                        event.posterDataUrl = fileURL
//                        self.images.append((image, fileURL))
//                        self.scheduleNotification(with: image, event: event, dateComponents: dateComponents)
//                    } catch {
//                        print("Failed to save image data: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//    }
//    
    private func removeObsoleteNotifications(dates: [Date]) {
        let calendar = Calendar.current
        let newIdentifiers = dates.map { date -> String in
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return "Around\(year)\(month)\(day)"
        }
        center.getPendingNotificationRequests { [weak self] requests in
            let oldIdentifiers = requests.filter { $0.identifier.starts(with: "Around") }.map { $0.identifier }
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
    
    private func removeImageFromDisk(event: Event) {
        print("----removeImageFromDisk----")
        guard let url = urls.first(where: {$0.absoluteString.contains("EventNotification\(event.id)")} )
        else {
            print("Error: url not fiund.")
            return
        }
        if FileManager.default.fileExists(atPath: url.path) {
            print("File exists at path: \(url.path)")
            do {
                try FileManager.default.removeItem(at: url)
                print("File \(url.path) deleted successfully.")
            } catch {
                print("Error deleting image: \(error.localizedDescription) /", error)
            }
        } else {
            print("File does not exist at: \(url.path)")
        }
    }
}

@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {
    
//    static func createAttachment(identifier: String, url: URL, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
//        do {
//            return try UNNotificationAttachment(identifier: identifier, url: url, options: options)
//        } catch {
//            // Обрабатываем ошибки
//            print("Error saving image to disk: \(error.localizedDescription)")
//            return nil
//        }
//    }
}
