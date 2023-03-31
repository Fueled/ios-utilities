//
//  FormFocusField.swift
//  iOS_DEMO
//
//  Created by Abhishek Thapliyal on 28/03/23.
//

import Foundation

public enum FormFocusField {
	case firstName
	case lastName
	case fullName
	case password
	case retypePassword
	case address
	case postalCode
	case phoneNumber
	case state
	case city
}

public enum RegexPatterns {
	case empty
	case emailId
	case alphaNumeric
	case allNumeric(minCharCount: Int, maxCharCount: Int?)
	case phoneNumber
	case custom(pattern: String)

	public var pattern: String {
		switch self {
		case .empty:
			return "^[A-Za-z]+$"
		case .emailId:
			return "^\\w+([\\.-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,3})+$"
		case .alphaNumeric:
			return "^[A-Za-z0-9]+$"
		case .allNumeric(let minCharCount, let maxCharCount):
			if maxCharCount == nil {
				return "^\\d{\(minCharCount),}$"
			}

			if let maxCharCount {
				return "^[0-9]{\(minCharCount),\(maxCharCount)}$"
			}
			return ""
		case .phoneNumber:
			return "^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]\\d{3}[\\s.-]\\d{4}$"
		case .custom(let pattern):
			return pattern
		}
	}
}
