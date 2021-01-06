//
//  ManagedCache+LocalMapping.swift
//  FeedStoreChallenge
//
//  Created by Lukas Bahrle Santana on 06/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension ManagedCache {
	
	enum ManagedCacheError: Swift.Error{
		case localFeedMappingFailed
	}
	
	func toLocal() throws -> (timestamp: Date, feed: [LocalFeedImage]) {
		
		guard let images = self.images?.array as? [ManagedFeedImage], let timestamp = self.timestamp else {
			throw ManagedCacheError.localFeedMappingFailed
		}
		
		let localFeedImages: [LocalFeedImage] = images.compactMap{
			guard let id = $0.id, let url = $0.imageURL else {return nil}
			return LocalFeedImage(id: id, description: $0.imageDescription, location: $0.imageLocation, url: url)
		}
		
		return (timestamp: timestamp, feed: localFeedImages)
	}
}
