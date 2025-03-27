//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Julia Martcenko on 24/03/2025.
//

import SwiftUI
import SwiftData
import CodeScanner
import UserNotifications

struct ProspectsView: View {
	enum FilterType{
		case none, contacted, uncontacted
	}

	enum SortType {
		case name, recent
	}

	@Environment(\.modelContext) var modelContext

	@State private var sortType: SortType = .name
	@State private var isShowingScaner = false
	@State private var selectedProspects = Set<Prospect>()

	let filter: FilterType

	var title: String {
		switch filter {
			case .none:
				"Everyone"
			case .contacted:
				"Contacted people"
			case .uncontacted:
				"Uncontacted people"
		}
	}

    var body: some View {
		NavigationStack {
			ProspectsListView(filter: filter, sortType: sortType, selectedProspects: $selectedProspects)
			.navigationTitle(title)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						toggleSorting()
					} label: {
						HStack {
							Image(systemName: sortType == .name ? "clock.arrow.circlepath" : "textformat.abc")
							Text(sortType == .name ? "Sort by Recent" : "Sort by Name")
						}
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Scan", systemImage: "qrcode.viewfinder") {
						isShowingScaner = true
					}
				}

				ToolbarItem(placement: .topBarLeading) {
					EditButton()
				}

				if selectedProspects.isEmpty == false {
					ToolbarItem(placement: .bottomBar) {
						Button("Delete selected", action: delete)
					}
				}
			}
			.sheet(isPresented: $isShowingScaner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
			}
		}
	}

	func handleScan(result: Result<ScanResult, ScanError>) {
		isShowingScaner = false

		switch result {
			case .success(let result):
				let details = result.string.components(separatedBy: "\n")
				guard details.count == 2 else { return }

				let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
				modelContext.insert(person)

			case .failure(let error):
				print("Scanning failed: \(error.localizedDescription)")
		}

	}

	private func toggleSorting() {
		sortType = (sortType == .name) ? .recent : .name
	}

	func delete() {
		for prospect in selectedProspects {
			modelContext.delete(prospect)
		}
	}
}

#Preview {
	ProspectsView(filter: .none)
		.modelContainer(for: Prospect.self)
}
