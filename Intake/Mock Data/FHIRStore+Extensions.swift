//
// This source file is part of the Stanford LLM on FHIR project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import SpeziFHIR
import SwiftUI

extension FHIRStore {
    var llmRelevantResources: [FHIRResource] {
        allergyIntolerances
            + llmConditions
            + encounters.uniqueDisplayNames
            + immunizations
            + llmMedications
            + observations.uniqueDisplayNames
            + procedures.uniqueDisplayNames
    }

    var allResources: [FHIRResource] {
        allergyIntolerances
            + conditions
            + diagnostics
            + encounters
            + immunizations
            + medications
            + observations
            + otherResources
            + procedures
    }

    var patient: FHIRResource? {
        otherResources
            .first { resource in
                guard case let .r4(resource) = resource.versionedResource,
                      resource is ModelsR4.Patient else {
                    return false
                }

                return true
            }
    }

    private var llmConditions: [FHIRResource] {
        conditions
            .filter { resource in
                guard case let .r4(resource) = resource.versionedResource,
                      let condition = resource as? ModelsR4.Condition else {
                    return false
                }

                return condition.clinicalStatus?.coding?.contains { coding in
                    guard coding.system?.value?.url == URL(string: "http://terminology.hl7.org/CodeSystem/condition-clinical"),
                          coding.code?.value?.string == "active" else {
                        return false
                    }

                    return true
                } ?? false
            }
    }
    var llmMedications: [FHIRResource] {
            let outpatientMedications = medications
                .filter { medication in
                    guard let medicationRequest = medicationRequest(resource: medication),
                         medicationRequest.category?
                              .contains(where: { codableconcept in
                                  codableconcept.text?.value?.string.lowercased() == "outpatient"
                              })
                              ?? false else {
                        return false
                    }

                    return true
                }
                .uniqueDisplayNames

            let activeMedications = medications
                .filter { medication in
                    guard let medicationRequest = medicationRequest(resource: medication),
                          medicationRequest.status == .active else {
                        return false
                    }

                    return true
                }
                .uniqueDisplayNames

            return outpatientMedications + activeMedications
        }

        func medicationRequest(resource: FHIRResource) -> MedicationRequest? {
            guard case let .r4(resource) = resource.versionedResource,
                  let medicationRequest = resource as? ModelsR4.MedicationRequest else {
                return nil
            }

            return medicationRequest
        }
}

extension Array where Element == FHIRResource {
    fileprivate var uniqueDisplayNames: [FHIRResource] {
        let reducedEncounters = Dictionary(
            map { ($0.displayName, $0) },
            uniquingKeysWith: { first, second in
                if first.date ?? .distantFuture < second.date ?? .distantPast {
                    return second
                } else {
                    return first
                }
            }
        )

        return Array(reducedEncounters.values)
    }

    fileprivate func dateSuffix(maxLength: Int) -> [FHIRResource] {
        self.lazy.sorted(by: { $0.date ?? .distantPast < $1.date ?? .distantPast }).suffix(maxLength)
    }
}
