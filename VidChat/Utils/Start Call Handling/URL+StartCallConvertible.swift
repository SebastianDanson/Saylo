//
//  StartCallConvertible.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import Foundation

extension URL: StartCallConvertible {

    private struct Constants {
        static let URLScheme = "speakerbox"
    }

    var startCallHandle: String? {
        guard scheme == Constants.URLScheme else { return nil }

        return host
    }

}
