//
//  DraggableActivity.swift
//  DontBeBored
//
//  Created by reztsov on 7/23/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI
import os

struct DraggableActivity: View {
    let log = OSLog(subsystem: "com.nixsolutions.dontBeBored.UI", category: "UI")

    // MARK: - Drag State
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize, predictedLocation: CGPoint)

        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let data):
                return data.translation
            }
        }

        var predictedLocation: CGPoint {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let data):
                return data.predictedLocation
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }

    enum EndState {
        case left, right, cancelled
    }

    // MARK: - Internal vars
    @State private var predictedEndLocation: CGPoint? = nil
    @State private var hasMoved = false
    @State private var delayedIsActive = false
    @GestureState private var dragState = DragState.inactive
    private let hapticFeedback = UISelectionFeedbackGenerator()

    // MARK: - Internal consts
    private let minimumLongPressDuration = 0.01
    private let shadowSize: CGFloat = 4
    private let shadowRadius: CGFloat = 16

    // MARK: - Constructor vars
    var activity: Activity?
    @Binding var gestureViewState: DragState
    let onTapGesture: () -> Void
    let willEndGesture: (CGSize) -> Void
    let endGestureHandler: (EndState) -> Void

    // MARK: - Viewd functions
    private func computedOffset() -> CGSize {
        if let location = predictedEndLocation {
            return CGSize(width: location.x,
                          height: 0)
        }

        return CGSize(
            width: dragState.isActive ? dragState.translation.width : 0,
            height: 0
        )
    }

    private func computeAngle() -> Angle {
        if let location = predictedEndLocation {
            return Angle(degrees: Double(location.x / 15))
        }
        return Angle(degrees: Double(dragState.translation.width / 15))
    }

    private var coverSpringAnimation: Animation {
        Animation.interpolatingSpring(mass: 1, stiffness: 150, damping: 30, initialVelocity: 5)
    }

    var body: some View {
        let id = OSSignpostID(log: log)

        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                case .first(true):

                    os_signpost(.begin,
                                log: self.log,
                                name: "DragView",
                                signpostID: id)
                    state = .pressing
                    self.hapticFeedback.selectionChanged()
                case .second(true, let drag):

                    state = .dragging(translation: drag?.translation ?? .zero, predictedLocation: drag?.predictedEndLocation ?? .zero)
                default:
                    print("Ended")
                    state = .inactive
                }
            }.onChanged { value in
                self.delayedIsActive = true
                if self.dragState.translation.width == 0.0 {
                    self.hasMoved = false
                    self.gestureViewState = .pressing
                } else {
                    self.hasMoved = true
                    self.gestureViewState = .dragging(translation: self.dragState.translation,
                                                      predictedLocation: self.dragState.predictedLocation)
                }
            }.onEnded { value in
                print("Ended")
                os_signpost(.end,
                            log: self.log,
                            name: "DragView",
                            signpostID: id)
                let endLocation = self.gestureViewState.predictedLocation
                if endLocation.x < 0 {
                    self.predictedEndLocation = endLocation
                    self.willEndGesture(self.gestureViewState.translation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.endGestureHandler(.left)
                        self.predictedEndLocation = nil
                        self.delayedIsActive = false
                        self.hasMoved = false
                    }
                } else if endLocation.x > UIScreen.main.bounds.width - 50 {
                    self.predictedEndLocation = endLocation
                    self.willEndGesture(self.gestureViewState.translation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.endGestureHandler(.right)
                        self.predictedEndLocation = nil
                        self.delayedIsActive = false
                        self.hasMoved = false
                    }
                } else {
                    self.endGestureHandler(.cancelled)
                }
                self.gestureViewState = .inactive
            }

        return ActivityCard(activity: activity)
        .opacity(predictedEndLocation != nil ? 0 : 1)
        .animation(predictedEndLocation == nil && !delayedIsActive ? .easeOut(duration: 1.1) : nil)
        .rotationEffect(computeAngle())
        .scaleEffect(dragState.isActive ? 1.03: 1.0)
        .shadow(color: .secondary,
                radius: dragState.isActive ? shadowRadius : 0,
                x: dragState.isActive ? shadowSize : 0,
                y: dragState.isActive ? shadowSize : 0)
        .animation(predictedEndLocation == nil && delayedIsActive ? coverSpringAnimation : nil)
        .offset(computedOffset())
        .animation(predictedEndLocation == nil && !delayedIsActive ? nil : coverSpringAnimation)
        .gesture(longPressDrag)
        .simultaneousGesture(TapGesture(count: 1).onEnded({ _ in
            if !self.hasMoved {
                self.onTapGesture()
            }
        }))
        .onAppear {
            self.hapticFeedback.prepare()
        }
    }
}

#if DEBUG
struct DraggableActivity_Previews: PreviewProvider {
    static var previews: some View {
        DraggableActivity(
            activity: sampleActivity,
            gestureViewState: .constant(.inactive),
                       onTapGesture: {

        },
                       willEndGesture: { _ in

        },
                       endGestureHandler: {handler in

        })
    }
}
#endif
