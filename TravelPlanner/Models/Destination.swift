//
//  Destination.swift
//  TravelPlanner
//
//  Created by Devon Connelly on 2025-04-14.
//

import Foundation

struct DestinationDTO: Codable {
    let id: Int
    let name: String
    let category: String
    let image: String
    let description: String
}
