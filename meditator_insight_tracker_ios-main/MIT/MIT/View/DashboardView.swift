import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    let userId: String
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleSection
                personalDataSection
                stressLevelChart
                ecgHRVDataCard(title: "ECG-HRV", data: healthKitManager.ecgHRVData, color: .green)
            }
            .padding()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    private var stressLevelChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stress Level Chart")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.blue)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(last30DaysData(), id: \.0) { date, value in
                            LineMark(
                                x: .value("Date", date),
                                y: .value("HRV", value)
                            )
                            PointMark(
                                x: .value("Date", date),
                                y: .value("HRV", value)
                            )
                            .annotation {
                                Text("\(Int(value))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine() // 垂直线保持灰色
                                .foregroundStyle(.gray)
                            AxisTick()
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(date, format: .dateTime.month().day())
                                }
                                .foregroundStyle(.black) // X轴标签颜色变为黑色
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 8)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(width: max(UIScreen.main.bounds.width - 40, CGFloat(last30DaysData().count) * 100), height: 300)
                    .id("chart")
                }
                .overlay(alignment: .topLeading) {
                    Text("Less Stress")
                        .font(.caption.bold()) // 加粗
                        .foregroundColor(.green)
                        .padding(.top, 5)
                        .padding(.leading, 4)
                }
                .overlay(alignment: .bottomLeading) {
                    Text("Most Stress")
                        .font(.caption.bold()) // 加粗
                        .foregroundColor(.red)
                        .padding(.bottom, 15)
                        .padding(.leading, 4)
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo("chart", anchor: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }


    private func last30DaysData() -> [(Date, Double)] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        
        return healthKitManager.ppgHRVData.filter { dataPoint in
            (startDate...endDate).contains(dataPoint.0)
        }.sorted(by: { $0.0 < $1.0 })
    }

    
    private var titleSection: some View {
        Text("Health Dashboard")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .padding(.top, 20)
    }
    
    private var personalDataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personal Data")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.purple)
            
            HStack {
                DataItem(title: "Age Range", value: "10-30")
                Spacer()
                DataItem(title: "Overall Stress Level", value: "LOW", valueColor: .green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var hrvDataSection: some View {
        VStack(spacing: 20) {
            hrvDataCard(title: "PPG-HRV", data: healthKitManager.ppgHRVData, color: .blue)
            ecgHRVDataCard(title: "ECG-HRV", data: healthKitManager.ecgHRVData, color: .green) // 单独为ECG数据创建一个函数
        }
    }

    // PPG-HRV的通用数据卡片
    private func hrvDataCard(title: String, data: [(Date, Double)], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            if data.isEmpty {
                Text("No data available")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(Array(data.prefix(30).enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text(formatDate(item.0))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("HRV: \(String(format: "%.0f", item.1)) ms")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(color)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    // ECG-HRV的通用数据卡片（处理包含额外String信息的数组）
    private func ecgHRVDataCard(title: String, data: [(Date, Double, String)], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            if data.isEmpty {
                Text("No data available")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(Array(data.prefix(30).enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text(formatDate(item.0))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(item.2) HRV: \(String(format: "%.0f", item.1)) ms") // 这里使用额外的String字段
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(color)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        return formatter.string(from: date)
    }
}

struct DataItem: View {
    let title: String
    let value: String
    var valueColor: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(userId: "1")
            .environmentObject(HealthKitManager())
    }
}
