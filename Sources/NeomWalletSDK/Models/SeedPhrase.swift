public typealias SeedPhrase = [String]

public extension SeedPhrase {
    static var empty: SeedPhrase { [] }
    var isFull: Bool { count == 12 }
    
    func toString() -> String {
        self.joined(separator: " ")
    }

    
    func mixed() -> SeedPhrase {
        var array = self
        var mixed = SeedPhrase()
        
        while array.count > 0 {
            let idx = Int.random(in: 0 ..< array.count)
            mixed.append(array.remove(at: idx))
        }
        return mixed
        
    }
    
    mutating func appendPhrase(_ value: String) {
        guard !self.contains(value) else {
            return
        }
        self.append(value)
    }
    
    mutating func removePhrase(_ value: String) {
        guard self.contains(value) else {
            return
        }
        self.removeAll(where: { $0 == value })
    }
}
