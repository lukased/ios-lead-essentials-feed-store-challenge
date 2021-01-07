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
		
		managedObjectContext.performAndWait { [weak self] in
			guard let self = self else{return}
			
			do{
				let request: NSFetchRequest<ManagedCache> = ManagedCache.fetchRequest()
				let caches = try request.execute()
				
				for cache in caches{
					self.managedObjectContext.delete(cache)
				}
				
				self.saveChanges(completion: completion)
			}
			catch{
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { [weak self] (error) in
			guard let self = self else {return}
			
			self.managedObjectContext.performAndWait { [weak self] in
				guard let self = self else {return}
				
				let cache = ManagedCache(context: self.managedObjectContext)
				cache.timestamp = timestamp
				cache.images = NSOrderedSet(array: feed.mapToManagedFeedImages(in: self.managedObjectContext))
				
				self.saveChanges(completion: completion)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		managedObjectContext.perform {
			do{
				let request: NSFetchRequest<ManagedCache> = ManagedCache.fetchRequest()
				let caches = try request.execute()
				
				guard let cache = caches.first else{
					completion(.empty)
					return
				}
				
				let localCache = try cache.toLocal()
				completion(.found(feed: localCache.feed, timestamp: localCache.timestamp))
			}
			catch{
				completion(.failure(error))
			}
		}
	}
	
	
	private func saveChanges(completion: (Error?) ->()) {
		guard managedObjectContext.hasChanges else {
			completion(nil)
			return }
		do {
			try managedObjectContext.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
}


private extension Array where Element == LocalFeedImage {
	func mapToManagedFeedImages(in context: NSManagedObjectContext) -> [ManagedFeedImage] {
		return self.map { (localImage) -> ManagedFeedImage in
			let managedFeedImage = ManagedFeedImage(context: context)
			managedFeedImage.id = localImage.id
			managedFeedImage.imageDescription = localImage.description
			managedFeedImage.imageLocation = localImage.location
			managedFeedImage.imageURL = localImage.url
			return managedFeedImage
		}
	}
}


