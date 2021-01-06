//
//  NSPersistentContainer+Load.swift
//  FeedStoreChallenge
//
//  Created by Lukas Bahrle Santana on 06/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer{
	
	enum LoadError: Swift.Error {
		case loadPersistentStoresFailed(Error)
	}
	
	func loadPersistentStores(with storeURL:URL) throws {
		let description = NSPersistentStoreDescription()
		description.url = storeURL
		self.persistentStoreDescriptions = [description]

		var loadError: Swift.Error?
		
		self.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if error != nil {
				loadError = error
			}
		})
		
		if let error = loadError {
			throw LoadError.loadPersistentStoresFailed(error)
		}
	}
}
