import Foundation

/// Type for providing a safely-typed structure view. 
public protocol StructureView {
    init?(_ structure: Structure)
    var structure: Structure { get }
}

extension Structure {
    public func view<T: StructureView>(as type: T.Type? = T.self) -> T? {
        T.init(self)
    }
}
