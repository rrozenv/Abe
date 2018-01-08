
import Foundation

public enum Notifications {
    public static let sessionStarted = "CurrentUserNotifications.sessionStarted"
    public static let sessionEnded = "CurrentUserNotifications.sessionEnded"
    public static let userUpdated = "CurrentUserNotifications.userUpdated"
    public static let projectSaved = "CurrentUserNotifications.projectSaved"
}

extension Notification.Name {
    public static let sessionStarted = Notification.Name(rawValue: Notifications.sessionStarted)
    public static let sessionEnded = Notification.Name(rawValue: Notifications.sessionEnded)
    public static let userUpdated = Notification.Name(rawValue: Notifications.userUpdated)
}
