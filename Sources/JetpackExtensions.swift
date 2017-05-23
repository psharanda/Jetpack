import Foundation

/// Describes a provider of reactive extensions.
///
/// - note: `JetpackExtensionsProvider` does not indicate whether a type is
///         reactive. It is intended for extensions to types that are not owned
///         by the module in order to avoid name collisions and return type
///         ambiguities.
public protocol JetpackExtensionsProvider: class {}

extension JetpackExtensionsProvider {
	/// A proxy which hosts reactive extensions for `self`.
	public var jx: JetpackExtensions<Self> {
		return JetpackExtensions(self)
	}
    
    public static var jx: JetpackExtensions<Self>.Type {
        return JetpackExtensions<Self>.self
    }
}

/// A proxy which hosts reactive extensions of `Base`.
public struct JetpackExtensions<Base> {
	/// The `Base` instance the extensions would be invoked with.
	public let base: Base

	// Construct a proxy.
	//
	// - parameters:
	//   - base: The object to be proxied.
	fileprivate init(_ base: Base) {
		self.base = base
	}
}
