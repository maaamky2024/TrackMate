final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme?
    
    private let context = PersistenceController.shared.container.viewContext
    
    private init() {
        loadCurrentTheme()
    }
    
    func loadCurrentTheme() {
        let request = NSFetchRequest<Theme>(entityName: "Theme")
        request.predicate = NSPredicate(format: "isSelected == true")
        request.fetchLimit = 1
        
        currentTheme = try? context.fetch(request))?.first
    }
    
    func selectedTheme(_ theme: Theme) {
        let fetch = NSFetchRequest<Theme>(entityName: "Theme")
        let allThemes = (try? context.fetch(fetch)) ?? []
        
        for t in allThemes {
            t.isSelected = false
        }
        
        theme.isSelected = true
        
        try? context.save()
        currentTheme = theme
        objectWillChange.send()
    }
    
    func color(_ name: String) -> Color {
        guard let prefix = currentTheme?.assetPrefix else {
            return Color(name)
        }
        return Color("\(prefix)/\(name)")
    }
    
    
}
