//
//  Error.swift
//  SnackBoard
//
//  Created by Timothy Moose on 8/7/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

/**
 The `SnackBoardError` enum contains the errors thrown by SnackBoard.
 */
enum SnackBoardError: Error {
    case cannotLoadViewFromNib(nibName: String)
    case noRootViewController
}
