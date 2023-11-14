//
//  AppDelegate.swift
//  nimble
//
//  Created by darius vallejo on 11/8/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let router = HomeCoordinator.start()
        let initialVC = router.entry
        KeychainManager.shared.testToken("lc8zrxONbxLm5nr2jaFOm9E26512AMuE8i1JtKj-mXI")
        window?.rootViewController = initialVC
        return true
    }
}
