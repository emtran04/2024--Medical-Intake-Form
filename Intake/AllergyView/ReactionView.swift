//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFHIR
import SwiftUI


struct ReactionView: View {
    @State private var reactionRecords: [ReactionItem]
    @State private var name: String

    
    var body: some View {
        NavigationView {
            List {
                ForEach($reactionRecords) { $item in
                    HStack {
                        TextField("Reactions", text: $item.reaction)
                        Button(action: {
                            // Action to delete this item
                            if let index = reactionRecords.firstIndex(where: { $0.id == item.id }) {
                                reactionRecords.remove(at: index)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .accessibilityLabel(Text("DELETE_REACTION"))
                        }
                    }
                }

                Button(action: {
                    // Action to add new item
                    reactionRecords.append(ReactionItem(reaction: ""))
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel(Text("ADD_REACTION"))
                        Text("Add Field")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(name) Reactions")
                        .font(.system(size: 28)) // Choose a size that fits
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Adjusts the font size to fit the width of the line
                }
            }
        }
    }

    
    init(reactionRecords: [ReactionItem], name: String) {
        self._reactionRecords = State(initialValue: reactionRecords)
        self._name = State(initialValue: name)
    }
}


#Preview {
    ReactionView(reactionRecords: [ReactionItem(reaction: "hello")], name: "Diabetes")
        .previewWith {
            FHIRStore()
        }
}
