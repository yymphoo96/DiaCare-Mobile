////
////  HealthProfile.swift
////  ReceiveData
////
////  Created by Yin Yin May Phoo on 28/11/2025.
////
//
//import SwiftUI
//
//struct HealthProfileFormView: View {
//    @Binding var user: User?
//    @Binding var isPresented: Bool
//    
//    @State private var currentSection = 0
//    @State private var gender = ""
//    @State private var age = "1"
//    @State private var height = " "
//    @State private var weight = ""
//    @State private var familyHistoryDiabetes = false
//    @State private var highBP = false
//    @State private var cholesterolLevel: CholesterolLevel = .normal
//    @State private var smoking = false
//    @State private var heartDisease = false
//    @State private var dietHealthy = false
//    @State private var eatFruitPerDay = false
//    @State private var eatVegetablePerDay = false
//    @State private var alcohol = false
//    @State private var generalHealth = 1
//    @State private var mentalHealth = 0
//    @State private var physicalHealth = 0
//    @State private var difficultyWalking = false
//    @State private var stressLevel: StressLevel = .moderate
//    @State private var sleepHours = ""
//    @State private var education = 1
//    @State private var income = 1
//    
//    private let sections = ["Basic", "Medical", "Lifestyle", "Health"]
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background gradient
//                LinearGradient(
//                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    // Progress indicator
//                    progressBar
//                    
//                    // Content
//                    TabView(selection: $currentSection) {
//                        basicInfoSection.tag(0)
//                        medicalHistorySection.tag(1)
//                        lifestyleSection.tag(2)
//                        healthRatingsSection.tag(3)
//                    }
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//                    
//                    // Navigation buttons
//                    navigationButtons
//                }
//            }
//            .navigationTitle("Health Profile")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: { isPresented = false }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray)
//                            .font(.title3)
//                    }
//                }
//            }
//            .onAppear {
//                loadExistingProfile()
//            }
//        }
//    }
//    
//    // MARK: - Progress Bar
//    
//    private var progressBar: some View {
//        VStack(spacing: 8) {
//            HStack(spacing: 4) {
//                ForEach(0..<4) { index in
//                    RoundedRectangle(cornerRadius: 2)
//                        .fill(index <= currentSection ? Color.purple : Color.gray.opacity(0.3))
//                        .frame(height: 4)
//                }
//            }
//            .padding(.horizontal)
//            
//            Text(sections[currentSection])
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding(.top, 8)
//        .padding(.bottom, 16)
//    }
//    
//    // MARK: - Section 1: Basic Info
//    
//    private var basicInfoSection: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                headerView(icon: "person.fill", title: "Basic Information", subtitle: "Let's start with the basics")
//                
//                CustomCard {
//                    VStack(spacing: 20) {
//                        CustomPicker(
//                            title: "Gender",
//                            selection: $gender,
//                            options: ["", "Male", "Female", "Other"]
//                        )
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Age")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Picker("", selection: $age) {
//                                Text("18-24").tag("1")
//                                Text("25-29").tag("2")
//                                Text("30-34").tag("3")
//                                Text("35-39").tag("4")
//                                Text("40-44").tag("5")
//                                Text("45-49").tag("6")
//                                Text("50-54").tag("7")
//                                Text("55-59").tag("8")
//                                Text("60-64").tag("9")
//                                Text("65-69").tag("10")
//                                Text("70-74").tag("11")
//                                Text("75-79").tag("12")
//                                Text("80+").tag("13")
//                            }
//                            .pickerStyle(.menu)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(12)
//                            .tint(.purple)
//                        }
//                        
//                        HStack(spacing: 16) {
//                            CustomTextField(
//                                title: "Height (cm)",
//                                text: $height,
//                                placeholder: "170",
//                                keyboardType: .decimalPad
//                            )
//                            
//                            CustomTextField(
//                                title: "Weight (kg)",
//                                text: $weight,
//                                placeholder: "70",
//                                keyboardType: .decimalPad
//                            )
//                        }
//                        
//                        if let h = Double(height), let w = Double(weight), h > 0 {
//                            let bmi = w / pow(h/100, 2)
//                            HStack {
//                                Text("BMI:")
//                                    .font(.title3)
//                                    .foregroundColor(.gray)
//                                Text(String(format: "%.1f", bmi))
//                                    .font(.title)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(bmiColor(bmi))
//                            }
//                            .font(.subheadline)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//    // MARK: - Section 2: Medical History
//    
//    private var medicalHistorySection: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                headerView(icon: "heart.text.square.fill", title: "Medical History", subtitle: "Your health background")
//                
//                CustomCard {
//                    VStack(spacing: 16) {
//                        ToggleRow(title: "Family History of Diabetes", isOn: $familyHistoryDiabetes)
//                        ToggleRow(title: "High Blood Pressure", isOn: $highBP)
//                        ToggleRow(title: "Smoking", isOn: $smoking)
//                        ToggleRow(title: "Heart Disease", isOn: $heartDisease)
//                        
//                        Divider()
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Cholesterol Level")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            HStack(spacing: 8) {
//                                ForEach(CholesterolLevel.allCases, id: \.self) { level in
//                                    Button(action: { cholesterolLevel = level }) {
//                                        Text(level.rawValue)
//                                            .font(.subheadline)
//                                            .fontWeight(cholesterolLevel == level ? .semibold : .regular)
//                                            .foregroundColor(cholesterolLevel == level ? .white : Color(red: 0.5, green: 0.2, blue: 0.7))
//                                            .padding(.horizontal, 12)
//                                            .padding(.vertical, 8)
//                                            .background(
//                                                RoundedRectangle(cornerRadius: 8)
//                                                    .fill(cholesterolLevel == level ? Color.purple : Color.purple.opacity(0.1))
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//    // MARK: - Section 3: Lifestyle
//    
//    private var lifestyleSection: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                headerView(icon: "leaf.fill", title: "Lifestyle", subtitle: "Your daily habits")
//                
//                CustomCard {
//                    VStack(spacing: 16) {
//                        ToggleRow(title: "Healthy Diet", isOn: $dietHealthy, icon: "🥗")
//                        ToggleRow(title: "Eat Fruit Daily", isOn: $eatFruitPerDay, icon: "🍎")
//                        ToggleRow(title: "Eat Vegetables Daily", isOn: $eatVegetablePerDay, icon: "🥦")
//                        ToggleRow(title: "Alcohol Consumption", isOn: $alcohol, icon: "🍺")
//                        
//                        Divider()
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Stress Level")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            HStack(spacing: 8) {
//                                ForEach(StressLevel.allCases, id: \.self) { level in
//                                    Button(action: { stressLevel = level }) {
//                                        Text(level.rawValue)
//                                            .font(.subheadline)
//                                            .fontWeight(stressLevel == level ? .semibold : .regular)
//                                            .foregroundColor(stressLevel == level ? .white : Color.orange)
//                                            .padding(.horizontal, 16)
//                                            .padding(.vertical, 8)
//                                            .background(
//                                                RoundedRectangle(cornerRadius: 8)
//                                                    .fill(stressLevel == level ? Color.orange : Color.orange.opacity(0.1))
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        CustomTextField(
//                            title: "Sleep Hours per Day",
//                            text: $sleepHours,
//                            placeholder: "7-8 hours",
//                            keyboardType: .decimalPad
//                        )
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//    // MARK: - Section 4: Health Ratings
//    
//    private var healthRatingsSection: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                headerView(icon: "heart.circle.fill", title: "Health Assessment", subtitle: "Rate your health")
//                
//                CustomCard {
//                    VStack(spacing: 24) {
//                        // General Health (1-5: 1=Excellent to 5=Poor)
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                Text("General Health")
//                                    .font(.subheadline)
//                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                
//                                Spacer()
//                                
//                                Text(generalHealthLabel(generalHealth))
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.green)
//                            }
//                            
//                            HStack(spacing: 8) {
//                                ForEach(1...5, id: \.self) { rating in
//                                    Button(action: { generalHealth = rating }) {
//                                        Circle()
//                                            .fill(generalHealth == rating ? Color.green : Color.green.opacity(0.2))
//                                            .frame(width: 40, height: 40)
//                                            .overlay(
//                                                Text("\(rating)")
//                                                    .font(.caption)
//                                                    .fontWeight(.semibold)
//                                                    .foregroundColor(generalHealth == rating ? .white : .green)
//                                            )
//                                    }
//                                }
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        // Mental Health (0-30 days)
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                Text("Mental Health")
//                                    .font(.subheadline)
//                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                
//                                Spacer()
//                                
//                                Text("\(mentalHealth) days")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.blue)
//                            }
//                            
//                            Text("Days of poor mental health in past 30 days")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                            
//                            HStack(spacing: 12) {
//                                TextField("0-30", value: $mentalHealth, format: .number)
//                                    .keyboardType(.numberPad)
//                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//                                    .padding()
//                                    .background(Color.gray.opacity(0.1))
//                                    .cornerRadius(12)
//                                    .frame(width: 100)
//                                
//                                Stepper("", value: $mentalHealth, in: 0...30)
//                                    .labelsHidden()
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        // Physical Health (0-30 days)
//                        VStack(alignment: .leading, spacing: 12) {
//                            HStack {
//                                Text("Physical Health")
//                                    .font(.subheadline)
//                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                                
//                                Spacer()
//                                
//                                Text("\(physicalHealth) days")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.orange)
//                            }
//                            
//                            Text("Days of physical illness/injury in past 30 days")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                            
//                            HStack(spacing: 12) {
//                                TextField("0-30", value: $physicalHealth, format: .number)
//                                    .keyboardType(.numberPad)
//                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//                                    .padding()
//                                    .background(Color.gray.opacity(0.1))
//                                    .cornerRadius(12)
//                                    .frame(width: 100)
//                                
//                                Stepper("", value: $physicalHealth, in: 0...30)
//                                    .labelsHidden()
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        ToggleRow(title: "Difficulty Walking", isOn: $difficultyWalking)
//                        
//                        Divider()
//                        
//                        // Education Level with beautiful menu picker
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Education Level")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Menu {
//                                Button("Kindergarten") { education = 1 }
//                                Button("Elementary (Grades 1-8)") { education = 2 }
//                                Button("Some High School (Grades 9-11)") { education = 3 }
//                                Button("High School Graduate") { education = 4 }
//                                Button("Some College (1-3 years)") { education = 5 }
//                                Button("College Graduate (4+ years)") { education = 6 }
//                            } label: {
//                                HStack {
//                                    Text(educationLabel(education))
//                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//                                    Spacer()
//                                    Image(systemName: "chevron.down")
//                                        .foregroundColor(.purple)
//                                        .font(.caption)
//                                }
//                                .padding()
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(12)
//                            }
//                        }
//                        
//                        // Income Level with beautiful menu picker
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Income Level")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Menu {
//                                Button("Less than $10,000") { income = 1 }
//                                Button("$10,000 - $15,000") { income = 2 }
//                                Button("$15,000 - $20,000") { income = 3 }
//                                Button("$20,000 - $25,000") { income = 4 }
//                                Button("$25,000 - $35,000") { income = 5 }
//                                Button("$35,000 - $50,000") { income = 6 }
//                                Button("$50,000 - $75,000") { income = 7 }
//                                Button("$75,000 or more") { income = 8 }
//                            } label: {
//                                HStack {
//                                    Text(incomeLabel(income))
//                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//                                    Spacer()
//                                    Image(systemName: "chevron.down")
//                                        .foregroundColor(.purple)
//                                        .font(.caption)
//                                }
//                                .padding()
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(12)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//    // MARK: - Navigation Buttons
//    
//    private var navigationButtons: some View {
//        HStack(spacing: 16) {
//            if currentSection > 0 {
//                Button(action: { withAnimation { currentSection -= 1 } }) {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                        Text("Back")
//                    }
//                    .font(.headline)
//                    .foregroundColor(.purple)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 50)
//                    .background(Color.purple.opacity(0.1))
//                    .cornerRadius(16)
//                }
//            }
//            
//            Button(action: {
//                if currentSection < 3 {
//                    withAnimation { currentSection += 1 }
//                } else {
//                    saveHealthProfile()
//                }
//            }) {
//                HStack {
//                    Text(currentSection < 3 ? "Next" : "Save")
//                    Image(systemName: currentSection < 3 ? "chevron.right" : "checkmark")
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 50)
//                .background(
//                    LinearGradient(
//                        colors: [Color.purple, Color.pink],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    )
//                )
//                .cornerRadius(16)
//            }
//        }
//        .padding()
//        .background(Color.white)
//    }
//    
//    // MARK: - Helper Views
//    
//    private func headerView(icon: String, title: String, subtitle: String) -> some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.system(size: 40))
//                .foregroundColor(.purple)
//            
//            Text(title)
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text(subtitle)
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical)
//    }
//    
//    private func bmiColor(_ bmi: Double) -> Color {
//        if bmi < 18.5 { return .blue }
//        else if bmi < 25 { return .green }
//        else if bmi < 30 { return .orange }
//        else { return .red }
//    }
//    
//    private func generalHealthLabel(_ rating: Int) -> String {
//        switch rating {
//        case 1: return "Excellent"
//        case 2: return "Very Good"
//        case 3: return "Good"
//        case 4: return "Fair"
//        case 5: return "Poor"
//        default: return "Good"
//        }
//    }
//    
//    private func educationLabel(_ level: Int) -> String {
//        switch level {
//        case 1: return "Kindergarten"
//        case 2: return "Elementary (Grades 1-8)"
//        case 3: return "Some High School"
//        case 4: return "High School Graduate"
//        case 5: return "Some College"
//        case 6: return "College Graduate"
//        default: return "Select Education"
//        }
//    }
//    
//    private func incomeLabel(_ level: Int) -> String {
//        switch level {
//        case 1: return "< $10,000"
//        case 2: return "$10,000 - $15,000"
//        case 3: return "$15,000 - $20,000"
//        case 4: return "$20,000 - $25,000"
//        case 5: return "$25,000 - $35,000"
//        case 6: return "$35,000 - $50,000"
//        case 7: return "$50,000 - $75,000"
//        case 8: return "$75,000+"
//        default: return "Select Income"
//        }
//    }
//    
//    // MARK: - Data Management
//    
//    private func loadExistingProfile() {
//        if let profile = user?.healthProfile {
//            gender = profile.gender ?? ""
//            age = profile.age.map { String($0) } ?? "1"
//            height = profile.height.map { String($0) } ?? ""
//            weight = profile.weight.map { String($0) } ?? ""
//            familyHistoryDiabetes = profile.familyHistoryDiabetes ?? false
//            highBP = profile.highBP ?? false
//            cholesterolLevel = profile.cholesterolLevel ?? .normal
//            smoking = profile.smoking ?? false
//            heartDisease = profile.heartDisease ?? false
//            dietHealthy = profile.dietHealthy ?? false
//            eatFruitPerDay = profile.eatFruitPerDay ?? false
//            eatVegetablePerDay = profile.eatVegetablePerDay ?? false
//            alcohol = profile.alcohol ?? false
//            generalHealth = profile.generalHealth ?? 1
//            mentalHealth = profile.mentalHealth ?? 0
//            physicalHealth = profile.physicalHealth ?? 0
//            difficultyWalking = profile.difficultyWalking ?? false
//            stressLevel = profile.stressLevel ?? .moderate
//            sleepHours = profile.sleepHours.map { String($0) } ?? ""
//            education = profile.education ?? 1
//            income = profile.income ?? 1
//        }
//    }
//    
//    private func saveHealthProfile() {
//        let profile = HealthProfile(
//            gender: gender.isEmpty ? nil : gender,
//            age: Int(age),
//            height: Double(height),
//            weight: Double(weight),
//            familyHistoryDiabetes: familyHistoryDiabetes,
//            highBP: highBP,
//            cholesterolLevel: cholesterolLevel,
//            smoking: smoking,
//            heartDisease: heartDisease,
//            dietHealthy: dietHealthy,
//            eatFruitPerDay: eatFruitPerDay,
//            eatVegetablePerDay: eatVegetablePerDay,
//            alcohol: alcohol,
//            generalHealth: generalHealth,
//            mentalHealth: mentalHealth,
//            physicalHealth: physicalHealth,
//            difficultyWalking: difficultyWalking,
//            stressLevel: stressLevel,
//            sleepHours: Double(sleepHours),
//            education: education,
//            income: income
//        )
//        
//        user?.healthProfile = profile
//        
//        if let encoded = try? JSONEncoder().encode(user) {
//            UserDefaults.standard.set(encoded, forKey: "currentUser")
//        }
//        
//        isPresented = false
//    }
//}
//
//// MARK: - Custom Components
//
//struct CustomCard<Content: View>: View {
//    let content: Content
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    var body: some View {
//        content
//            .padding()
//            .background(Color.white)
//            .cornerRadius(20)
//            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
//    }
//}
//
//struct CustomTextField: View {
//    let title: String
//    @Binding var text: String
//    let placeholder: String
//    var keyboardType: UIKeyboardType = .default
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            
//            TextField(placeholder, text: $text)
//                .keyboardType(keyboardType)
//                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(12)
//        }
//    }
//}
//
//struct CustomPicker: View {
//    let title: String
//    @Binding var selection: String
//    let options: [String]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            
//            HStack(spacing: 12) {
//                ForEach(options.filter { !$0.isEmpty }, id: \.self) { option in
//                    Button(action: { selection = option }) {
//                        Text(option)
//                            .font(.subheadline)
//                            .fontWeight(selection == option ? .semibold : .regular)
//                            .foregroundColor(selection == option ? .white : Color(red: 0.5, green: 0.2, blue: 0.7))
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 10)
//                            .background(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .fill(selection == option ? Color.purple : Color.purple.opacity(0.1))
//                            )
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ToggleRow: View {
//    let title: String
//    @Binding var isOn: Bool
//    var icon: String = ""
//    
//    var body: some View {
//        HStack {
//            if !icon.isEmpty {
//                Text(icon)
//                    .font(.title3)
//            }
//            
//            Text(title)
//                .font(.body)
//                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
//            
//            Spacer()
//            
//            Toggle("", isOn: $isOn)
//                .labelsHidden()
//                .tint(.purple)
//        }
//    }
//}
//
//struct RatingSlider: View {
//    let title: String
//    @Binding var value: Int
//    let color: Color
//    
//    private let labels = ["Poor", "Fair", "Good", "Very Good", "Excellent"]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text(title)
//                    .font(.subheadline)
//                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
//                
//                Spacer()
//                
//                Text(labels[value - 1])
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(color)
//            }
//            
//            HStack(spacing: 8) {
//                ForEach(1...5, id: \.self) { rating in
//                    Button(action: { value = rating }) {
//                        Circle()
//                            .fill(value >= rating ? color : color.opacity(0.2))
//                            .frame(width: 40, height: 40)
//                            .overlay(
//                                Text("\(rating)")
//                                    .font(.caption)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(value >= rating ? .white : color)
//                            )
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    HealthProfileFormView(user: .constant(nil), isPresented: .constant(true))
//}
