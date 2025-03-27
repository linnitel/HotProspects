//
//  Prospect.swift
//  HotProspects
//
//  Created by Julia Martcenko on 24/03/2025.
//

import SwiftData
import Foundation

@Model
class Prospect {
	var id: UUID
	var name: String
	var emailAddress: String
	var isContacted: Bool

	init(name: String, emailAddress: String, isContacted: Bool) {
		self.id = UUID()
		self.name = name
		self.emailAddress = emailAddress
		self.isContacted = isContacted
	}
}
