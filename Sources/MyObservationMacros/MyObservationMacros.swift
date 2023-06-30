import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension DeclSyntax {
    var storedProperty: (TokenSyntax, ExprSyntax)? {
        guard let v = self.as(VariableDeclSyntax.self) else { return nil }
        let binding = v.bindings.first!
        guard let id = binding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
        guard !id.identifier.text.hasPrefix("_") else {
            return nil
        }
        guard let value = binding.initializer?.value else {
            // TODO show diagnostics
            return nil
        }
        return (id.identifier, value)
    }
}

struct MyObservableMacro: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let storedProperties: [DeclSyntax] = declaration.memberBlock.members.compactMap {
            guard let (name, value) = $0.decl.storedProperty else { return nil }
            return "var _\(name) = \(value)"
        }
        return [
            "var _registrar = Registrar()"
        ] + storedProperties
    }
}
