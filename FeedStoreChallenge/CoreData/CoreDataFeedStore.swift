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
		self.managedObjectContext.perform { [weak self] in
			guard let self = self else {return}
			
			let cache = ManagedCache(context: self.managedObjectContext)
			cache.timestamp = timestamp
		
			for item in feed {
				let feedImage = ManagedFeedImage(context: self.managedObjectContext)
				feedImage.id = item.id
				feedImage.imageDescription = item.description
				feedImage.imageLocation = item.location
				feedImage.imageURL = item.url
				cache.addToImages(feedImage)
			}
			
			completion(nil)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let request: NSFetchRequest<ManagedCache> = ManagedCache.fetchRequest()
		
		managedObjectContext.perform {
			do{
				let cache = try request.execute()
				
				guard cache.count > 0 else{
					completion(.empty)
					return
				}
				
				guard let firstCache = cache.last, let images = firstCache.images?.array as? [ManagedFeedImage], let timestamp = firstCache.timestamp else {
					completion(.failure(NSError(domain: "Error", code: 0)))
					return
				}
				
				let localFeedImages: [LocalFeedImage] = images.compactMap{
					guard let id = $0.id, let url = $0.imageURL else {return nil}
					return LocalFeedImage(id: id, description: $0.imageDescription, location: $0.imageLocation, url: url)
				}
				completion(.found(feed: localFeedImages, timestamp: timestamp))
			}
			catch{
				completion(.failure(error))
			}
		}
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
