//
//  RandomActivityView.swift
//  DontBeBored
//
//  Created by reztsov on 7/22/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI

struct RandomActivityView: View {
    @ObservedObject var activitiesService: ActivitiesService
    @EnvironmentObject var store: ActivityStore

    @State private var draggedViewState = DraggableActivity.DragState.inactive
    @State private var isFilterPresented = false
    @State private var willEndPosition: CGSize? = nil
    @State private var filter: Filter? = nil
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .soft)

    private var activity: Activity? {
        return activitiesService.activity
    }

    private func scaleResistance() -> Double {
        Double(abs(willEndPosition?.width ?? draggedViewState.translation.width) / 6300)
    }

    private func dragResistance() -> CGFloat {
        abs(willEndPosition?.width ?? draggedViewState.translation.width) / 12
    }

    private func leftZoneResistance() -> CGFloat {
        -draggedViewState.translation.width / 1000
    }

    private func rightZoneResistance() -> CGFloat {
        draggedViewState.translation.width / 1000
    }

    private func draggableCoverEndGestureHandler(handler: DraggableActivity.EndState) {
        if handler == .left || handler == .right {
            hapticFeedback.impactOccurred(intensity: 0.8)
            if handler == .left {
                // handle deletion
            } else if handler == .right {
                if let activity = activity {
                    store.add(activity)
                }
            }

            self.willEndPosition = nil
            fetchActivity(force: true)
        }
    }

    private var actionsButtons: some View {
        ZStack(alignment: .center) {
            if self.activity != nil {
                Circle()
                    .strokeBorder(Color.pink, lineWidth: 1)
                    .background(Image(systemName: "xmark")
                        .font(Font.largeTitle.weight(.bold))
                        .foregroundColor(.pink))
                    .frame(width: 60, height: 60)
                    .offset(x: -70, y: 0)
                    .opacity(self.draggedViewState.isDragging ? 0.5 + Double(self.leftZoneResistance()) : 0)
                    .animation(.spring())

                Circle()
                    .strokeBorder(Color.green, lineWidth: 1)
                    .background(Image(systemName: "rectangle.stack.badge.plus")
                        .font(Font.title.weight(.regular))
                        .foregroundColor(.green))
                    .frame(width: 60, height: 60)
                    .opacity(self.draggedViewState.isDragging ? 0.5 + Double(self.rightZoneResistance()) : 0)
                    .animation(.spring())
                    .offset(x: 70, y: 0)
            }
        }
    }

    private func onFiltersDismiss() {
        if self.filter != nil {
            self.fetchActivity(force: true)
        }
    }

    private var filterButton: some View {
        BorderButton(text: "Filters",
                     systemImageName: "list.bullet",
                     color: .gold,
                     isOn: false) {
                        self.isFilterPresented = true
        }
    }

    private func fetchActivity(force: Bool = false) {
        guard activity == nil || force else {
            return
        }
        self.activitiesService.fetchActivity(endpoint: createActivityEndpoint)
    }

    private var createActivityEndpoint: APIService.Endpoint {
        guard let filter = filter else {
            return APIService.Endpoint.randomEvent
        }

        switch filter {
        case .type: return APIService.Endpoint.findByType(filter)
        }
    }

    var body: some View {
        ZStack(alignment: Alignment.center) {
            ActivityCard()
                .opacity(0.1 + Double(scaleResistance()))
                .animation(.linear(duration: 0.5))


            if !activitiesService.isLoading {
                DraggableActivity(
                    activity: activity,
                    gestureViewState: self.$draggedViewState,
                    onTapGesture: {

                },
                    willEndGesture: { position in
                        self.willEndPosition = position
                },
                    endGestureHandler: { handler in
                        self.draggableCoverEndGestureHandler(handler: handler)
                })
            }

            GeometryReader { geometry in
                self.filterButton
                    .position(x: geometry.frame(in: .local).midX,
                              y: geometry.frame(in: .local).minY + geometry.safeAreaInsets.top + 40)
                    .frame(height: 50)
                    .sheet(
                        isPresented: self.$isFilterPresented,
                        onDismiss: self.onFiltersDismiss,
                        content: { ActivityFilterView(filter: self.$filter, onDismiss: self.onFiltersDismiss)
                    })
                self.actionsButtons
                    .position(x: geometry.frame(in: .local).midX,
                              y: geometry.frame(in: .local).maxY - geometry.safeAreaInsets.bottom - 20.0)
            }
        }
        .onAppear {
            self.hapticFeedback.prepare()
            self.fetchActivity(force: false)
        }
    }
}

#if DEBUG
struct RandomActivityView_Previews: PreviewProvider {
    static var previews: some View {
        RandomActivityView(activitiesService: ActivitiesService())
    }
}
#endif
