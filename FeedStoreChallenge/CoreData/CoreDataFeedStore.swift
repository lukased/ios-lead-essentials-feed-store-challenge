//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Lukas Bahrle Santana on 06/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore{
	
	private let persistentContainer: FeedCachePersistentContainer
	private let dataModelName = "FeedCache"
	private lazy var managedObjectContext: NSManagedObjectContext = {
		persistentContainer.newBackgroundContext()
	}()
	
	public init(storeURL url: URL) throws{
		self.persistentContainer = FeedCachePersistentContainer(name: dataModelName)
		
		try self.persistentContainer.loadPersistentStores(with: url)
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}


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
