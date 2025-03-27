//
//  EditView.swift
//  HotProspects
//
//  Created by Julia Martcenko on 25/03/2025.
//

import SwiftUI
import SwiftData

struct EditView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss

	var prospect: Prospect
	@State var name: String
	@State var emailAddress: String

	init(prospect: Prospect) {
		self.prospect = prospect
		_name = State(initialValue: prospect.name)
		_emailAddress = State(initialValue: prospect.emailAddress)
	}

    var body: some View {
		NavigationStack {
			Form {
				TextField("Name", text: $name)
					.textContentType(.name)
					.font(.title)
				TextField("EmailAddress", text: $emailAddress)
					.textContentType(.emailAddress)
					.font(.title)
			}
			.navigationBarTitle("Edit")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						saveProspect()
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
		}
    }

	func saveProspect() {
		prospect.name = name
		prospect.emailAddress = emailAddress
		try? modelContext.save()
		dismiss()
	}
}

#Preview {
	EditView(prospect: Prospect(name: "Some name", emailAddress: "Some address", isContacted: false))
}
