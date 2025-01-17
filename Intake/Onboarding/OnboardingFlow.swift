//
// This source file is part of the Intake based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziOnboarding
import SwiftUI

/// Displays an multi-step onboarding flow for the Intake.
struct OnboardingFlow: View {
    @Environment(HealthKit.self) private var healthKitDataSource
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false

    
    private var healthKitAuthorization: Bool {
        // As HealthKit not available in preview simulator
        if ProcessInfo.processInfo.isPreviewSimulator {
            return false
        }
        return healthKitDataSource.authorized
    }

    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()
            InterestingModules()

            #if !(targetEnvironment(simulator) && (arch(i386) || arch(x86_64)))
                Consent()
            #endif

            if HKHealthStore.isHealthDataAvailable() && !healthKitAuthorization {
                HealthKitPermissions()
            }
        }
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}

#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: IntakeStandard()) {
            OnboardingDataSource()
            HealthKit()
        }
}
#endif
