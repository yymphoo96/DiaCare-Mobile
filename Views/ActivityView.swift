//
//  ActivityView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 02/12/2025.
//

import SwiftUI
import Charts

struct ActivityView: View {
    @StateObject private var healthManager = HealthActivitiesManager()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: MetricType = .steps
    @State private var showAuthAlert = false
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        
        var icon: String {
            switch self {
            case .day: return "calendar.day.timeline.left"
            case .week: return "calendar"
            }
        }
    }
    
    enum MetricType: String, CaseIterable {
        case steps = "Steps"
        case calories = "Calories"
        case exercise = "Exercise"
        case distance = "Distance"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .calories: return "flame.fill"
            case .exercise: return "timer"
            case .distance: return "location.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .green
            case .calories: return .orange
            case .exercise: return .blue
            case .distance: return .purple
            }
        }
        
        var unit: String {
            switch self {
            case .steps: return "steps"
            case .calories: return "cal"
            case .exercise: return "min"
            case .distance: return "km"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with Last Sync
                    headerSection
                    
                    if !healthManager.isAuthorized {
                        authorizationCard
                    } else if healthManager.isSyncing {
                        syncingProgressView
                    } else if healthManager.isLoading {
                        ProgressView("Loading activities...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        // Today's Quick Stats
                        todayStatsSection
                        
                        // Time Range Selector
                        timeRangePicker
                        
                        // Beautiful Chart
                        chartSection
                        
                        // Activity Breakdown
                        activityBreakdownSection
                        
                        // Sync Button
                        syncButton
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                if !healthManager.isAuthorized {
                    healthManager.requestAuthorization { success in
                        if !success {
                            showAuthAlert = true
                        }
                    }
                } else if healthManager.shouldPerformSync() {
                    healthManager.performInitialSync()
                }
            }
            .alert("HealthKit Access Required", isPresented: $showAuthAlert) {
                Button("Settings", action: openSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable HealthKit access in Settings to view your activity data.")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let lastSync = healthManager.lastSyncDate {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("Synced \(lastSync, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Authorization Card
    
    private var authorizationCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Connect to Health App")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Allow access to track your activities and provide personalized health insights")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                healthManager.requestAuthorization { _ in }
            }) {
                Text("Connect Health App")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Syncing Progress
    
    private var syncingProgressView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.purple)
                .rotationEffect(.degrees(healthManager.isSyncing ? 360 : 0))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: healthManager.isSyncing)
            
            Text("Syncing Health Data")
                .font(.headline)
            
            ProgressView(value: healthManager.syncProgress)
                .tint(.purple)
                .padding(.horizontal, 40)
            
            Text("\(Int(healthManager.syncProgress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Today's Stats
    
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                MiniStatCard(
                    icon: "figure.walk",
                    value: "\(healthManager.todaySteps)",
                    label: "Steps",
                    color: .green
                )
                
                MiniStatCard(
                    icon: "flame.fill",
                    value: String(format: "%.0f", healthManager.todayCalories),
                    label: "Cal",
                    color: .orange
                )
                
                MiniStatCard(
                    icon: "timer",
                    value: String(format: "%.0f", healthManager.todayExerciseMinutes),
                    label: "Min",
                    color: .blue
                )
                
                MiniStatCard(
                    icon: "location.fill",
                    value: String(format: "%.1f", healthManager.todayDistance),
                    label: "km",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Time Range Selector
                HStack(spacing: 8) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTimeRange = range
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: range.icon)
                                    .font(.caption)
                                Text(range.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedTimeRange == range ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTimeRange == range ? Color.purple : Color.gray.opacity(0.1))
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Metric Selector Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMetric = metric
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: metric.icon)
                                    .font(.system(size: 14))
                                Text(metric.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(selectedMetric == metric ? .white : metric.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedMetric == metric ? metric.color : metric.color.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if selectedTimeRange == .day {
                dailyChart
            } else {
                weeklyChart
            }
        }
    }
    
    // MARK: - Daily Chart (Hourly Breakdown)
    
    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Activity")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
                
                Text(selectedMetric.unit)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            // Simulated hourly data - replace with real data
            let hourlyData = generateHourlyData()
            
            if !hourlyData.isEmpty {
                Chart(hourlyData) { dataPoint in
                    BarMark(
                        x: .value("Hour", dataPoint.date, unit: .hour),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(selectedMetric.color.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal)
            } else {
                emptyChartView
            }
        }
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Last 7 Days")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
                
                Text(selectedMetric.unit)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            let weeklyData = getWeeklyDataForMetric()
            
            if !weeklyData.isEmpty {
                Chart(weeklyData) { dataPoint in
                    LineMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(selectedMetric.color.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Circle()
                            .fill(selectedMetric.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    AreaMark(
                        x: .value("Day", dataPoint.date, unit: .day),
                        y: .value("Value", dataPoint.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [selectedMetric.color.opacity(0.3), selectedMetric.color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal)
            } else {
                emptyChartView
            }
        }
    }
    
    // MARK: - Empty Chart View
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No data available")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Start moving to see your progress!")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Activity Breakdown
    
    private var activityBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Types")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(ActivityType.allCases, id: \.self) { activityType in
                    if let value = healthManager.activitySummaries[activityType], value > 0 {
                        ActivityBreakdownRow(
                            activityType: activityType,
                            value: value
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Sync Button
    
    private var syncButton: some View {
        Button(action: {
            healthManager.manualSync()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
                Text("Sync with Health App")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(healthManager.isSyncing)
        .opacity(healthManager.isSyncing ? 0.6 : 1.0)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    
    private func getWeeklyDataForMetric() -> [ChartDataPoint] {
        // Get last 7 days of data for selected metric
        let calendar = Calendar.current
        var data: [ChartDataPoint] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            
            let value: Double
            switch selectedMetric {
            case .steps:
                value = healthManager.monthlyData.first(where: {
                    calendar.isDate($0.date, inSameDayAs: date)
                })?.value ?? 0
            case .calories:
                value = Double.random(in: 100...500) // Replace with real data
            case .exercise:
                value = Double.random(in: 10...60) // Replace with real data
            case .distance:
                value = Double.random(in: 1...8) // Replace with real data
            }
            
            if value > 0 {
                data.append(ChartDataPoint(date: date, value: value))
            }
        }
        
        return data.reversed()
    }
    
    private func generateHourlyData() -> [ChartDataPoint] {
        // Generate hourly data for today (8am to 8pm)
        let calendar = Calendar.current
        var data: [ChartDataPoint] = []
        let now = Date()
        
        for hour in 8...20 {
            guard let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) else { continue }
            
            if date <= now {
                let value: Double
                switch selectedMetric {
                case .steps:
                    value = Double.random(in: 200...1200)
                case .calories:
                    value = Double.random(in: 10...80)
                case .exercise:
                    value = Double.random(in: 0...15)
                case .distance:
                    value = Double.random(in: 0.1...1.5)
                }
                
                data.append(ChartDataPoint(date: date, value: value))
            }
        }
        
        return data
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Mini Stat Card

struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Activity Breakdown Row

struct ActivityBreakdownRow: View {
    let activityType: ActivityType
    let value: Double
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(activityType.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: activityType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(activityType.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activityType.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("\(String(format: "%.1f", value)) \(activityType.unit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

#Preview {
    ActivityView()
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
    
}


#Preview {
    ActivityView()
}
