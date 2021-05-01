//
//  Constants.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-26.
//

import Foundation

struct Constants {
    static let appName = "Logo Palette"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "paletteCell"
    static let segueIdentifier = "confirmationModal"
    static let registerSegue = "registerToMain"
    static let loginSegue = "loginToMain"
    
    struct FStore {
        static let userCollection = "user palettes"
        static let originalCollection = "original palettes"
    }
}
