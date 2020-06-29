//
//  IntercomPluginErrors.swift
//  intercom_plugin
//
//  Created by Lucas Eduardo on 28/06/20.
//

import Foundation

class IntercomPluginErrors {
    func invalidArgument(with argument: String?) -> FlutterError {
        return FlutterError(
            code: "NO_SUCH_ARGUMENT",
            message: "No such argument as \(String(describing: argument))",
            details: nil
        )
    }
}
