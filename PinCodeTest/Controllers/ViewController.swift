//
//  ViewController.swift
//  PinCodeTest
//
//  Created by Eduard Sinyakov on 4/23/20.
//  Copyright © 2020 Eduard Siniakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var status: UILabel!
	private let contentToPinCode = "contentToPinCode"

	private var isShowPinCode: Bool {
		UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUsePinCode.rawValue)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func viewWillLayoutSubviews() {
		checkUsagePinCode()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == contentToPinCode {
			if let pinCode = segue.destination as? PinCodeVC {
				pinCode.isRepeatNeeded = false
				pinCode.pinEntered = { [weak self] in
					guard let self = self else { return }
					self.showEnteredContent()
				}
			}
		}
	}

	private func checkUsagePinCode() {
		if isShowPinCode {
			showPinCode()
		} else {
			//load content or log in page
			showNotEnteredContent()
		}

	}

	private func showPinCode() {
		self.performSegue(withIdentifier: contentToPinCode, sender: self)
    }

	private func showEnteredContent() {
		status.text = "Вход выполнен"
		status.textColor = .white
		view.backgroundColor = .green
	}

	private func showNotEnteredContent() {
		status.text = "Вход не выполнен"
		status.textColor = .black
		view.backgroundColor = .orange
	}

}

