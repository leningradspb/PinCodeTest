//
//  ErrorMessageForLAErrorCode.swift
//  PinCodeTest
//
//  Created by Eduard Sinyakov on 4/23/20.
//  Copyright © 2020 Eduard Siniakov. All rights reserved.
//

import Foundation

enum ErrorMessageForLAErrorCode: String {
    case appCancel = "Аутентификация была отменена приложением"
    case authenticationFailed = "Вы не смогли предоставить действительные учетные данные"
    case invalidContext = "The context is invalid"
    case passcodeNotSet = "Пароль на устройстве не установлен"
    case systemCancel = "Аутентификация была отменена системой"
    case biometryLockout = "Слишком много неудачных попыток"
    case biometryNotAvailable = "Биометрия недоступна на устройстве. Предоставьте приложению доступ к Face ID в настройках"
    case userCancel = "Вы отказались использовать биометрию. Введите PIN код"
    case userFallback = "Используйте пароль для входа"
    case defaultMessage = "Неизвестная ошибка. Попробуйте позже"
}
