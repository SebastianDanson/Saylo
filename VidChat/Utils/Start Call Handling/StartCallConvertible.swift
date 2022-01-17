//
//  StartCallConvertible.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

protocol StartCallConvertible {

    var startCallHandle: String? { get }
    var video: Bool? { get }

}

extension StartCallConvertible {

    var video: Bool? {
        return nil
    }

}
