//
//  ProspectsListView.swift
//  HotProspects
//
//  Created by Julia Martcenko on 27/03/2025.
//

import SwiftUI
import SwiftData

struct ProspectsListView: View {
	let filter: ProspectsView.FilterType
	let sortType: ProspectsView.SortType
	@Binding var selectedProspects: Set<Prospect>

	@Environment(\.modelContext) var modelContext
	@Query var prospects: [Prospect]

	init(filter: ProspectsView.FilterType, sortType: ProspectsView.SortType, selectedProspects: Binding<Set<Prospect>>) {
		self.filter = filter
		self.sortType = sortType
		self._selectedProspects = selectedProspects

		if filter == .none {
			if sortType == .name {
				_prospects = Query(sort: [SortDescriptor(\Prospect.name)])
			} else {
				_prospects = Query() // No sort descriptor for recent
			}
		} else {
			let showContactedOnly = filter == .contacted
			if sortType == .name {
				_prospects = Query(filter: #Predicate { $0.isContacted == showContactedOnly }, sort: [SortDescriptor(\Prospect.name)])
			} else {
				_prospects = Query(filter: #Predicate { $0.isContacted == showContactedOnly }) // No sorting applied
			}
		}
	}

    var body: some View {
		List(prospects, selection: $selectedProspects) { prospect in
			NavigationLink {
				EditView(prospect: prospect)
			} label: {
				HStack {
					VStack(alignment: .leading) {
						Text(prospect.name)
							.font(.headline)
						Text(prospect.emailAddress)
							.foregroundStyle(.secondary)
					}
					.swipeActions {
						Button("Delete", systemImage: "trash", role: .destructive) {
							modelContext.delete(prospect)
						}
						if prospect.isContacted {
							Button("Mark Uncontaceted", systemImage: "person.crop.circle.badge.xmark") {
								prospect.isContacted.toggle()
							}
							.tint(.blue)
						} else {
							Button("Mark Contacted", systemImage: "person.crop.circle.badge.checkmark") {
								prospect.isContacted.toggle()
							}
							.tint(.green)

							Button("Remind Me", systemImage: "bell") {
								addNotification(for: prospect)
							}
							.tint(.orange)
						}
					}
					.tag(prospect)

					Spacer()
					if filter == .none {
						Image(systemName: prospect.isContacted ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark")
							.foregroundStyle( prospect.isContacted ? .green : .blue)
					}
				}
			}
		}
    }

	func addNotification(for prospect: Prospect) {
		let center = UNUserNotificationCenter.current()

		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = "Contact \(prospect.name)"
			content.subtitle = prospect.emailAddress
			content.sound = UNNotificationSound.default

			var dateComponents = DateComponents()
			dateComponents.hour = 9

			let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			center.add(request)
		}

		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					} else if let error {
						print(error.localizedDescription)
					}
				}
			}
		}
	}
}

#Preview {
	struct PreviewContainer: View {
		@State private var selectedProspects = Set<Prospect>()

		var body: some View {
			ProspectsListView(filter: .none, sortType: .name, selectedProspects: $selectedProspects)
		}
	}

	return PreviewContainer()
}

//#Preview {
//	ProspectsListView(filter: .none, sortType: .name, selectedProspects: .constant())
//}
