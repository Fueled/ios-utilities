//
//  Subject+SendResult.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 3/31/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

extension Subject {
	func send(result: Result<Output, Failure>) {
		switch result {
		case .failure(let error):
			self.send(completion: .failure(error))
		case .success(let value):
			self.send(value)
			self.send(completion: .finished)
		}
	}
}
