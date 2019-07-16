//
//  MyActivities.swift
//  DontBeBored
//
//  Created by reztsov on 7/22/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI

struct MyActivities: View {

    @EnvironmentObject var store: ActivityStore
    @State var showingSheet = false
    @State var selectedActivity: Activity? = nil

    @State
    var activitiesCompleted = [Activity]()

    @State
    var activitiesInProgress = [Activity]()

    @FetchRequest(fetchRequest: ActivityData.allActivitiesFetchRequest()) var results: FetchedResults<ActivityData>

    var body: some View {

        let _ = results.publisher
            .receive(on: RunLoop.main)
            .filter { $0.isCompleted }
            .map { Activity(managedObject: $0) }
            .collect()
            .assign(to: \.activitiesCompleted, on: self)

        let _  = results.publisher
            .receive(on: RunLoop.main)
            .filter { $0.isInProgress }
            .map { Activity(managedObject: $0) }
            .collect()
            .assign(to: \.activitiesInProgress, on: self)

        return NavigationView {
            List {
                if activitiesInProgress.count > 0 {
                    inProgressSection
                }

                if activitiesCompleted.count > 0 {
                    completedSection
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("My activities"))
            .actionSheet(isPresented: $showingSheet,
                         content: actionSheet)
        }
    }

    private func actionSheet() -> ActionSheet {
        var isInProgress = false

        if activitiesInProgress.contains(self.selectedActivity!) {
            isInProgress = true
        }

        return ActionSheet(title: Text("Actions"),
                    message: nil,
                    buttons: [
                        ActionSheet.Button.default(Text("Mark as \((!isInProgress) ? "Incomplete" : "Complete")"))
                        {
                            self.store.toggleCompleted(self.selectedActivity!)
                            self.showingSheet.toggle()
                        },
                        ActionSheet.Button.cancel({
                            self.showingSheet.toggle()
                        })
            ]
        )
    }

    private var completedSection: some View {
        Section(header: Text("Completed")) {
            ForEach(activitiesCompleted) { activity in
                Button(action: {
                    self.selectedActivity = activity
                    self.showingSheet = true
                }) {
                    Text(activity.activity).foregroundColor(.secondary).strikethrough()
                }

            }.onDelete { indexSet in
                self.store.delete(self.activitiesCompleted.remove(at: indexSet.first!))
            }
        }
    }

    private var inProgressSection: some View {
        Section(header: Text("In Progress")) {
            ForEach(activitiesInProgress) { activity in
                Button(action: {
                    self.selectedActivity = activity
                    self.showingSheet = true
                }) {
                    HStack {
                        Text(activity.activity).foregroundColor(.secondary)
                    }
                }
            }.onDelete { indexSet in
                self.store.delete(self.activitiesInProgress.remove(at: indexSet.first!))
            }
        }
    }
}

#if DEBUG
struct MyActivities_Previews: PreviewProvider {
    static var previews: some View {
        MyActivities()
    }
}
#endif
