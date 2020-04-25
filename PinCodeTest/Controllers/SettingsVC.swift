//
//  SettingsVC.swift
//  PinCodeTest
//
//  Created by Eduard Sinyakov on 4/23/20.
//  Copyright © 2020 Eduard Siniakov. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
	private let settingsToShowPinCode = "settingsToShowPinCode"
	private let userDefaults = UserDefaults.standard

	@IBOutlet weak var pinSwitch: UISwitch!
	
	@IBAction func switchTapped(_ sender: UISwitch) {
		checkIsSwitchOn(sender: sender)
	}

	private var isSwitchOn: Bool {
		userDefaults.bool(forKey: UserDefaultsKeys.isUsePinCode.rawValue)
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		pinSwitch.isOn = isSwitchOn
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == settingsToShowPinCode {
			if let pinCode = segue.destination as? PinCodeVC {
				pinCode.isRepeatNeeded = true
				pinCode.pinInstalled = { [weak self] in
					guard let self = self else { return }
					self.userDefaults.set(true, forKey: UserDefaultsKeys.isUsePinCode.rawValue)
				}
			}
		}
	}

	private func checkIsSwitchOn(sender: UISwitch) {
		if sender.isOn {
			self.performSegue(withIdentifier: settingsToShowPinCode, sender: self)
		} else {
			userDefaults.set(false, forKey: UserDefaultsKeys.isUsePinCode.rawValue)
		}
	}
}
