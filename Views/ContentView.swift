//
//  ContentView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 07/04/2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var healthManager = Manager()
    @StateObject var healthUpdater = ManageActivities()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text(healthManager.healthStatus)
            Text("Today's steps: \(healthManager.stepcount)")
            Button("Fetch & Upload Yesterday's Steps") {
                            healthUpdater.requestAuthorization()
                        }

        }
        .padding()
        .onAppear {
            healthManager.checkHealthData()
        }
    }
}

#Preview {
    ContentView()
}
//Activity Type    HealthKit Type
//Steps    HKQuantityTypeIdentifier.stepCount
//Distance walked/ran    HKQuantityTypeIdentifier.distanceWalkingRunning
//Active energy burned    HKQuantityTypeIdentifier.activeEnergyBurned
//Exercise minutes    HKQuantityTypeIdentifier.appleExerciseTime
//Move/Stand time    HKQuantityTypeIdentifier.appleMoveTime, appleStandTime
//Flights climbed    HKQuantityTypeIdentifier.flightsClimbed
class Manager: ObservableObject {
    @Published var healthStatus: String = "Checking..."
    @Published var stepcount: Double = 0

    @Published var walkrun: Double = 0
    let allTypes: Set = [
        HKQuantityType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceCycling),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.stepCount),
        HKQuantityType(.flightsClimbed),
        HKQuantityType(.appleExerciseTime),
        HKQuantityType(.appleMoveTime),
        HKQuantityType(.appleStandTime),
    ]

    let healthStore = HKHealthStore()

    func checkHealthData() {
        do{
            if HKHealthStore.isHealthDataAvailable() {
                   healthStatus = "Hello Phoo! Health Available ✅"

                   healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, error in
                       if success {
                           DispatchQueue.main.async {
                               self.healthStatus = "HealthKit Authorization granted. Reading data..."
                           }
                           print("✅ HealthKit Authorization granted.")
                           self.readSteps()
                           self.readWalkingRunning()
                       } else {
                           DispatchQueue.main.async {
                               self.healthStatus = "❌ Authorization failed."
                           }
                           print("❌ Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                       }
                   }
               } else {
                   DispatchQueue.main.async {
                       self.healthStatus = "NO Health ❌"
                   }
               }
        } catch {
            
            // Typically, authorization requests only fail if you haven't set the
            // usage and share descriptions in your app's Info.plist, or if
            // Health data isn't available on the current device.
            fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
        }

    }
    
    func readSteps() {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("❌ Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            self.stepcount = steps
            print("👣 Steps today: \(steps)")
            
//            self.sendToAPI(steps: steps)
        }
        
        healthStore.execute(query)
    }
    
    func readWalkingRunning() {
        let walk_run = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKStatisticsQuery(quantityType: walk_run, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("❌ Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let walkrun = sum.doubleValue(for: HKUnit.meter())
            self.walkrun = walkrun
            print("👣 Steps Walking Running: \(walkrun)")
            
//            self.sendToAPI(steps: steps)
        }
        
        healthStore.execute(query)
    }
}


