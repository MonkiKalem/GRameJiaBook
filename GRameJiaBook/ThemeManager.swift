import UIKit

enum Theme: String {
    case light
    case dark
    case system
}

class ThemeManager {
    
    static let shared = ThemeManager()
    
    private init() {}
    
    // Define colors for light and dark modes
    var primaryColor: UIColor {
        switch currentTheme {
        case .light:
            return UIColor.systemBlue
        case .dark:
            return UIColor.systemOrange
        case .system:
            return UIColor.systemBlue // Default system color
        }
    }
    
    var backgroundColor: UIColor {
        switch currentTheme {
        case .light:
            return UIColor.white
        case .dark:
            return UIColor.black
        case .system:
            return UIColor.systemBackground
        }
    }
    
    var buttonTextColor: UIColor {
        switch currentTheme {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        case .system:
            return UIColor.label
        }
    }
    
    var currentTheme: Theme {
        let savedTheme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        return Theme(rawValue: savedTheme) ?? .system
    }

    func applyTheme() {
        // Update tint color for the entire app
        UINavigationBar.appearance().tintColor = primaryColor
        UITabBar.appearance().tintColor = primaryColor
        UIButton.appearance().tintColor = primaryColor
        UISegmentedControl.appearance().tintColor = primaryColor
        
        // Update background color for all views
        UIView.appearance().backgroundColor = backgroundColor
        
        // Customization for buttons
        UIButton.appearance().setTitleColor(buttonTextColor, for: .normal)
        UIButton.appearance().setTitleColor(buttonTextColor.withAlphaComponent(0.7), for: .highlighted)
    }
}
