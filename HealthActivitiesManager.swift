//
//  ManageActivities.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 16/09/2025.
//

//
//  HealthActivitiesManager.swift
//  Smart Auto-Sync System
//

import Foundation
import HealthKit
import SwiftUI

// MARK: - Activity Data Models

struct ActivityData: Identifiable, Codable {
    let id = UUID()
    let type: ActivityType
    let value: Double
    let date: Date
    let unit: String
    
    enum CodingKeys: String, CodingKey {
        case type, value, date, unit
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case steps = "step_count"
    case walking = "walking_running"
    case running = "running"
    case cycling = "cycling"
    case climbing = "stair_climbing"
    case exercise = "exercise_time"
    case activeEnergy = "active_energy"
    case distance = "distance"
    case heartRate = "heart_rate"
    
    var displayName: String {
        switch self {
        case .steps: return "Steps"
        case .walking: return "Walking/Running"
        case .running: return "Running"
        case .cycling: return "Cycling"
        case .climbing: return "Stair Climbing"
        case .exercise: return "Exercise"
        case .activeEnergy: return "Active Energy"
        case .distance: return "Distance"
        case .heartRate: return "Heart Rate"
        }
    }
    
    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .walking: return "figure.walk.motion"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .climbing: return "figure.stairs"
        case .exercise: return "figure.strengthtraining.traditional"
        case .activeEnergy: return "flame.fill"
        case .distance: return "location.fill"
        case .heartRate: return "heart.fill"
        }
    }
    
    var unit: String {
        switch self {
        case .steps: return "steps"
        case .walking, .running: return "min"
        case .cycling: return "min"
        case .climbing: return "flights"
        case .exercise: return "min"
        case .activeEnergy: return "kcal"
        case .distance: return "km"
        case .heartRate: return "bpm"
        }
    }
    
    var color: Color {
        switch self {
        case .steps: return .green
        case .walking: return .blue
        case .running: return .orange
        case .cycling: return .purple
        case .climbing: return .pink
        case .exercise: return .red
        case .activeEnergy: return .yellow
        case .distance: return .teal
        case .heartRate: return .red
        }
    }
    
    var healthKitType: HKQuantityType? {
        switch self {
        case .steps:
            return HKQuantityType.quantityType(forIdentifier: .stepCount)
        case .activeEnergy:
            return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        case .exercise:
            return HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)
        case .distance:
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .climbing:
            return HKQuantityType.quantityType(forIdentifier: .flightsClimbed)
        case .heartRate:
            return HKQuantityType.quantityType(forIdentifier: .heartRate)
        default:
            return nil
        }
    }
    
    var healthKitUnit: HKUnit {
        switch self {
        case .steps, .climbing:
            return .count()
        case .activeEnergy:
            return .kilocalorie()
        case .exercise, .walking, .running, .cycling:
            return .minute()
        case .distance:
            return .meterUnit(with: .kilo)
        case .heartRate:
            return .count().unitDivided(by: .minute())
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct DailySyncStatus: Codable {
    let date: String
    let isSynced: Bool
    let lastSyncTime: Date
}

// MARK: - Health Activities Manager

class HealthActivitiesManager: ObservableObject {
    let healthStore = HKHealthStore()
    private let baseURL = "http://172.20.10.8:8000/api"
    
    @Published var todaySteps = 0
    @Published var todayCalories = 0.0
    @Published var todayExerciseMinutes = 0.0
    @Published var todayDistance = 0.0
    
    @Published var monthlyData: [ChartDataPoint] = []
    @Published var activitySummaries: [ActivityType: Double] = [:]
    @Published var isAuthorized = false
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    
    private var backgroundObserverQueries: [HKObserverQuery] = []
    
    init() {
        loadLastSyncDate()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKWorkoutType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    // Setup background observers
                    self.setupBackgroundObservers()
                    // Initial sync when authorized
                    self.performInitialSync()
                } else {
                    print("HealthKit authorization failed: \(String(describing: error))")
                }
                completion(success)
            }
        }
    }
    
    // MARK: - Initial Sync Strategy
    
    func performInitialSync() {
        guard isAuthorized else { return }
        
        isSyncing = true
        syncProgress = 0.0
        
        Task {
            // Step 1: Fetch missing dates from backend
            let missingDates = await fetchMissingDatesFromBackend()
            
            // Step 2: Fetch last 30 days from HealthKit
            await syncLast30Days(missingDates: missingDates)
            
            // Step 3: Fetch today's data for display
            await fetchTodayData()
            
            // Step 4: Fetch monthly chart data
            await fetchMonthlyChartData()
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.syncProgress = 1.0
                self.lastSyncDate = Date()
                self.saveLastSyncDate()
            }
        }
    }
    
    // MARK: - Fetch Missing Dates from Backend
    
    private func fetchMissingDatesFromBackend() async -> Set<String> {
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              let url = URL(string: "\(baseURL)/activities/missing-dates?user_id=\(userId)&days=30") else {
            return Set()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let missingDates = json["missing_dates"] as? [String] {
                return Set(missingDates)
            }
        } catch {
            print("Error fetching missing dates: \(error)")
        }
        
        // If API fails, sync all 30 days
        return getAllLast30Days()
    }
    
    private func getAllLast30Days() -> Set<String> {
        let calendar = Calendar.current
        var dates = Set<String>()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                dates.insert(formatter.string(from: date))
            }
        }
        
        return dates
    }
    
    // MARK: - Sync Last 30 Days
    
    private func syncLast30Days(missingDates: Set<String>) async {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var totalDays = missingDates.count
        if totalDays == 0 {
            totalDays = 30 // If no specific missing dates, sync all 30 days
        }
        var processedDays = 0
        
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let dateString = dateFormatter.string(from: date)
            
            // Only sync if date is missing or if we're doing a full sync
            if missingDates.isEmpty || missingDates.contains(dateString) {
                await syncDayData(for: date)
                processedDays += 1
                
                DispatchQueue.main.async {
                    self.syncProgress = Double(processedDays) / Double(totalDays)
                }
                
                // Small delay to avoid overwhelming the API
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
        }
    }
    
    // MARK: - Sync Single Day
    
    private func syncDayData(for date: Date) async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        // Sync each activity type for this day
        for activityType in [ActivityType.steps, .activeEnergy, .exercise, .distance, .climbing] {
            guard let quantityType = activityType.healthKitType else { continue }
            
            let value = await fetchDayData(quantityType: quantityType, unit: activityType.healthKitUnit, start: startOfDay, end: endOfDay)
            
            if value > 0 {
                await sendActivityToBackend(activityType: activityType, value: value, date: date)
            }
        }
    }
    
    private func fetchDayData(quantityType: HKQuantityType, unit: HKUnit, start: Date, end: Date) async -> Double {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let result = result, let sum = result.sumQuantity() {
                    continuation.resume(returning: sum.doubleValue(for: unit))
                } else {
                    continuation.resume(returning: 0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Fetch Today's Data
    
    func fetchTodayData() async {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // Fetch today's stats
        todaySteps = Int(await fetchDayData(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            unit: .count(),
            start: startOfDay,
            end: now
        ))
        
        todayCalories = await fetchDayData(
            quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            unit: .kilocalorie(),
            start: startOfDay,
            end: now
        )
        
        todayExerciseMinutes = await fetchDayData(
            quantityType: HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            unit: .minute(),
            start: startOfDay,
            end: now
        )
        
        todayDistance = await fetchDayData(
            quantityType: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            unit: .meterUnit(with: .kilo),
            start: startOfDay,
            end: now
        )
        
        // Update activity summaries
        DispatchQueue.main.async {
            self.activitySummaries[.steps] = Double(self.todaySteps)
            self.activitySummaries[.activeEnergy] = self.todayCalories
            self.activitySummaries[.exercise] = self.todayExerciseMinutes
            self.activitySummaries[.distance] = self.todayDistance
        }
    }
    
    // MARK: - Fetch Monthly Chart Data
    
    func fetchMonthlyChartData() async {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let dataPoints = await fetchMonthlyData(for: stepType, unit: .count())
        
        DispatchQueue.main.async {
            self.monthlyData = dataPoints
        }
    }
    
    private func fetchMonthlyData(for type: HKQuantityType, unit: HKUnit) async -> [ChartDataPoint] {
        await withCheckedContinuation { continuation in
            let calendar = Calendar.current
            let now = Date()
            guard let startDate = calendar.date(byAdding: .day, value: -30, to: now) else {
                continuation.resume(returning: [])
                return
            }
            
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: nil,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, error in
                guard let results = results else {
                    continuation.resume(returning: [])
                    return
                }
                
                var dataPoints: [ChartDataPoint] = []
                results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let value = sum.doubleValue(for: unit)
                        dataPoints.append(ChartDataPoint(date: statistics.startDate, value: value))
                    }
                }
                
                continuation.resume(returning: dataPoints)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Background Observers for Real-time Sync
    
    func setupBackgroundObservers() {
        // Setup observers for important metrics
        let typesToObserve: [HKQuantityType] = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        for type in typesToObserve {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, error in
                guard error == nil else {
                    completionHandler()
                    return
                }
                
                // Sync today's data when health data changes
                Task {
                    await self?.fetchTodayData()
                    await self?.syncDayData(for: Date())
                }
                
                completionHandler()
            }
            
            healthStore.execute(query)
            backgroundObserverQueries.append(query)
        }
        
        // Enable background delivery
        for type in typesToObserve {
            healthStore.enableBackgroundDelivery(for: type, frequency: .hourly) { success, error in
                if success {
                    print("Background delivery enabled for \(type)")
                } else {
                    print("Failed to enable background delivery: \(String(describing: error))")
                }
            }
        }
    }
    
    // MARK: - Send Data to Backend
    
    private func sendActivityToBackend(activityType: ActivityType, value: Double, date: Date) async {
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              let url = URL(string: "\(baseURL)/activities/update") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let payload: [String: Any] = [
            "user_id": userId,
            "activity_type": activityType.rawValue,
            "value": value,
            "unit": activityType.unit,
            "date": dateString
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Synced \(activityType.rawValue) for \(dateString): \(httpResponse.statusCode)")
            }
        } catch {
            print("Error syncing activity: \(error)")
        }
    }
    
    // MARK: - Manual Sync
    
    func manualSync() {
        performInitialSync()
    }
    
    // MARK: - Last Sync Date Management
    
    private func loadLastSyncDate() {
        if let timestamp = UserDefaults.standard.object(forKey: "lastHealthSyncDate") as? Date {
            lastSyncDate = timestamp
        }
    }
    
    private func saveLastSyncDate() {
        UserDefaults.standard.set(Date(), forKey: "lastHealthSyncDate")
    }
    
    // MARK: - Check if Sync Needed
    
    func shouldPerformSync() -> Bool {
        guard let lastSync = lastSyncDate else {
            return true // Never synced before
        }
        
        // Sync if last sync was more than 6 hours ago
        let hoursSinceLastSync = Date().timeIntervalSince(lastSync) / 3600
        return hoursSinceLastSync >= 6
    }
}
