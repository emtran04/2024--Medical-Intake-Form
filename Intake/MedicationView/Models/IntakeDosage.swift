// This source file is part of the Intake based on the Stanford Spezi Template Medication project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziMedication

/// The IntakeDosage struct has a localizedDescription that describes the dosage information.
struct IntakeDosage: Dosage, Codable {
    var localizedDescription: String
}
