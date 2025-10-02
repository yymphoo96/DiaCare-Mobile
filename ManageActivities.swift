//
//  ManageActivities.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 16/09/2025.
//

import Foundation
import HealthKit

class ManageActivities: ObservableObject {
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                self.fetchYesterdaySteps()
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func fetchYesterdaySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let today = Date()
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: endOfYesterday, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("No data or error: \(String(describing: error))")
                return
            }
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            print("Yesterday's steps: \(steps)")
            self.sendStepsToBackend(steps: steps, date: startOfYesterday)
        }
        
        healthStore.execute(query)
    }
    
    func sendStepsToBackend(steps: Int, date: Date) {
        guard let url = URL(string: "http://172.20.10.8:8000/api/steps/update") else { return } // replace with your FastAPI server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let iso8601String = ISO8601DateFormatter().string(from: date)
        let dateString = String(iso8601String.prefix(10))
        
        let payload: [String: Any] = [
            "user_id": 1,
            "activity_type" : "step_count",
            "value": steps,
            "date": dateString
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Error sending steps: \(error)")
            } else {
                print("Successfully sent steps to backend")
            }
        }.resume()
    }
}
