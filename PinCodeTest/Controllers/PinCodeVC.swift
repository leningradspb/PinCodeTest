//
//  PinCodeVC.swift
//  PinCodeTest
//
//  Created by Eduard Sinyakov on 4/23/20.
//  Copyright © 2020 Eduard Siniakov. All rights reserved.
//

import UIKit
import LocalAuthentication

class PinCodeVC: UIViewController {

	private let keyChainService = KeyChainService()
	private let finalTappedNumbersCount = 4
	private var repeatPinCode = String()
	private var counter = 0
	private var logOutCounter = 0

	var pinCode = String()
	var isRepeatNeeded = true
	var pinEntered: (() -> ())?
	var showMain: (() -> ())?
	var pinInstalled: (() -> ())?

	@IBOutlet weak var pinLabel: UILabel!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet var enteredPinCollection: [UIButton]!
	@IBOutlet weak var biometrics: UIButton!

	@IBAction func numberTapped(_ sender: UIButton) {
		updateEnteredPinCollectionByTapped(button: sender)
	}

	@IBAction func useBiometricsTapped(_ sender: UIButton) {
		useBiometrics()
	}

	@IBAction func deleteTapped(_ sender: UIButton) {
		onDelete()
	}

	private var keyChainCode: String? {
		keyChainService.get(key: KeyChainService.Keys.pinCode)
	}

	var pinLabelText: String? {
		didSet {
			return errorLabel.text = pinLabelText
		}
	}

	var isBiometricsHidden: Bool? {
		didSet {
			return biometrics.isHidden = isBiometricsHidden ?? true
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		useBiometrics()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		errorLabel.isHidden = true
	}

	func useBiometrics() {
		let context = LAContext()
		let faceID = "faceID"
		let reason = "Приложите палец"

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			let face = LABiometryType.faceID
			if context.biometryType == face {
				biometrics.setImage(UIImage(named: faceID), for: .normal)
			}

			// touch or face action
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, evaluateError in
				guard let self = self else { return }

				if success {
					DispatchQueue.main.async {

						//							if self.isInSettings {
						//								self.notUsePinCode?()
						//								//self.removeFromSuperview()
						//							} else {
						//								self.pinEntered?()
						//								//self.removeFromSuperview()
						//								print("success")
						//							}
					}
				} else {

					guard let error = evaluateError as NSError? else { return }
					let message = self.showErrorMessageForLAErrorCode(errorCode: error.code)
					DispatchQueue.main.async {
						self.errorLabel.text = message
					}

				}
			}
		} else {
			DispatchQueue.main.async {
				//self.isBiometricsHidden = true
			}
		}
	}

	func toRepeatPinCode() {
		counter = 0
		pinLabel.text = PinCodeMessage.repeatPinCode.rawValue
		for index in 0..<enteredPinCollection.count {
			enteredPinCollection[index].setTitle("", for: .normal)
		}
	}

	func setErrorPin() {
		logOutCounter += 1
		let maxEnterPinCodeAttempts = 3
		let availableAttempts = maxEnterPinCodeAttempts - logOutCounter
		self.errorLabel.text = PinCodeMessage.availableAttempts.rawValue + String(availableAttempts)
		counter = 0
		pinCode = String()
		for index in 0..<enteredPinCollection.count {
			enteredPinCollection[index].setTitle("", for: .normal)
		}
		if availableAttempts == 0 {
			showMain?()
			self.dismiss(animated: true, completion: nil)
			// logOut()
		}
	}

	private func updateEnteredPinCollectionByTapped(button: UIButton) {
		let number = button.titleLabel?.text ?? ""


		counter += 1
		//self.hideMessage()
		if pinCode.count != finalTappedNumbersCount {
			enteredPinCollection[counter - 1].setTitle(number, for: .normal)
			pinCode += number
		} else {
			enteredPinCollection[counter - 1].setTitle(number, for: .normal)
			repeatPinCode += number
		}

		updateUI()
	}

	private func onDelete() {
		if counter != 0 && pinCode.count != finalTappedNumbersCount {
			counter -= 1
			enteredPinCollection[counter].setTitle("", for: .normal)
			pinCode.removeLast()

		} else if counter != 0 && repeatPinCode.count != finalTappedNumbersCount {
			counter -= 1
			enteredPinCollection[counter].setTitle("", for: .normal)
			repeatPinCode.removeLast()
		}
	}

	private func updateUI() {
		if counter == finalTappedNumbersCount && !isRepeatNeeded {
			pinEntered?()
			self.dismiss(animated: true, completion: nil)
		} else if counter == finalTappedNumbersCount && isRepeatNeeded && repeatPinCode.isEmpty {
			toRepeatPinCode()
		} else if counter == finalTappedNumbersCount && isRepeatNeeded && pinCode == repeatPinCode {
			UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isUsePinCode.rawValue)
			self.dismiss(animated: true, completion: nil)
		} else if counter == finalTappedNumbersCount && !isRepeatNeeded && pinCode != keyChainCode {
			setErrorPin()
		} else if counter == finalTappedNumbersCount && !isRepeatNeeded && pinCode == keyChainCode {
			pinEntered?()
			self.dismiss(animated: true, completion: nil)
		} else if pinCode == repeatPinCode && counter == 4 {
			keyChainService.set(key: repeatPinCode, value: KeyChainService.Keys.pinCode)
			pinInstalled?()
			self.dismiss(animated: true, completion: nil)
		}
	}

	private func showErrorMessageForLAErrorCode( errorCode: Int) -> String {

		var message = ""
		// MARK: - LAContext error handler
		switch errorCode {
		case LAError.appCancel.rawValue:
			message = ErrorMessageForLAErrorCode.appCancel.rawValue

		case LAError.authenticationFailed.rawValue:
			message = ErrorMessageForLAErrorCode.authenticationFailed.rawValue

		case LAError.invalidContext.rawValue:
			message = ErrorMessageForLAErrorCode.invalidContext.rawValue

		case LAError.passcodeNotSet.rawValue:
			message = ErrorMessageForLAErrorCode.passcodeNotSet.rawValue

		case LAError.systemCancel.rawValue:
			message = ErrorMessageForLAErrorCode.systemCancel.rawValue

		case LAError.biometryLockout.rawValue:
			message = ErrorMessageForLAErrorCode.biometryLockout.rawValue

		case LAError.biometryNotAvailable.rawValue:
			message = ErrorMessageForLAErrorCode.biometryNotAvailable.rawValue
			DispatchQueue.main.async {
				self.isBiometricsHidden = true
			}
		case LAError.userCancel.rawValue:
			message = ErrorMessageForLAErrorCode.userCancel.rawValue

		case LAError.userFallback.rawValue:
			message = ErrorMessageForLAErrorCode.userFallback.rawValue

		default:
			message = ErrorMessageForLAErrorCode.defaultMessage.rawValue

		}
		return message
	}

}
