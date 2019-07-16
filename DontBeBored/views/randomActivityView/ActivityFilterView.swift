//
//  ActivityFilterView.swift
//  DontBeBored
//
//  Created by reztsov on 7/31/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import SwiftUI

struct ActivityFilterView: View {

    @Binding var filter: Filter?
    @Environment(\.presentationMode) var presentationMode
    @State var selectedTypeIndex: Int = 0
    var onDismiss: () -> ()

    private var typesArr: [String] {
        var array = ActivityType.allCases.map({ $0.rawValue })
        array.insert("none", at: 0)
        return array
    }

    var createFilter: Filter? {
        guard selectedTypeIndex != 0 else {
            return nil
        }

        return .type(typesArr[selectedTypeIndex])
    }

    private var settingsSection: some View {
        Section(header: Text("filter by:"), content: {
            Picker("Type", selection: $selectedTypeIndex) {
                ForEach(0 ..< typesArr.count) {
                    Text(self.typesArr[$0]).tag($0)
                }
            }
        })
    }

    private var cancelButton: some View {
        Button(action: {
            self.presentationMode.value.dismiss()
            self.filter = nil
            self.selectedTypeIndex = 0
            self.onDismiss()
        }, label: {
            Text("Cancel").foregroundColor(.gold)
        })
    }

    private var saveButton: some View {
        Button(action: {
            self.presentationMode.value.dismiss()
            self.filter = self.createFilter
            self.onDismiss()
        }, label: {
            Text("Save").foregroundColor(.gold)
        })
    }

    var body: some View {
        NavigationView {
            Form {
                settingsSection
            }
            .navigationBarTitle(Text("Filter settings"), displayMode: .large)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .background(Color.mineShaft)
    }
}

#if DEBUG
struct ActivityFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityFilterView(filter: .constant(nil), onDismiss: {})
    }
}
#endif
