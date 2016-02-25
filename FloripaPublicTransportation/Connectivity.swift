//
//  Connectivity.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/25/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation
import UIKit // UIAlertController
import SystemConfiguration // SCNetworkReachability

class Connectivity {
    /// - Returns: true/false if an internet connection is detected.
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }

    /// Shows an `UIAlertController` alerting the user that an internet connection is needed.
    /// - Parameter viewController: the view controller that will present an UIAlertController in case no internet connection is detected.
    class func popNoConnectionAlert(viewController: UIViewController)
    {
        let alert = UIAlertController(title: NSLocalizedString("No connection", comment: "The UIAlert title when no internet connection is detected"), message: NSLocalizedString("Please connect to the internet in order to find routes and their details.", comment: "The UIAlert message when no internet connection is detected"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "The UIAlert button when no internet connection is detected"), style: .Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}