import SwiftUI
import Charts

struct ScoreBarChart: View {
    let testResults: [TestResult]
    @State private var selectedIndex: Int? = nil
    
    // Fixed width for each bar
    private let barWidth: CGFloat = 50
    private let barSpacing: CGFloat = 6
    
    // Calculate total width needed for all bars
    private var totalChartWidth: CGFloat {
        let totalBars = CGFloat(testResults.count)
        return totalBars * barWidth + (totalBars - 1) * barSpacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: true) {
                Chart {
                    let enumeratedResults = Array(testResults.enumerated())
                    
                    ForEach(enumeratedResults, id: \.0) { index, test in
                        let barColor = Color.blue.gradient

                        BarMark(
                            x: .value("Test", "Test \(index + 1)"),
                            y: .value("Score", test.bandScore)
                        )
                        .cornerRadius(5)
                        .foregroundStyle(barColor)
                        .annotation(position: .top) {
                            Text(String(format: "%.1f", test.bandScore))
                                .font(.caption2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .chartYScale(domain: 0...9)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisTick()
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .frame(width: max(totalChartWidth, 300)) // Minimum width of 300
                }
                .frame(height: 200)
                .padding(.horizontal, 16)
                .padding(.bottom, 8) // Add bottom padding to prevent scrollbar overlap
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 16)
    }
}

// Alternative implementation with more control over spacing
struct ScoreBarChartAdvanced: View {
    let testResults: [TestResult]
    @State private var selectedIndex: Int? = nil
    
    private let barWidth: CGFloat = 50
    private let minChartWidth: CGFloat = 300
    
    private var chartWidth: CGFloat {
        let calculatedWidth = CGFloat(testResults.count) * barWidth + 100 // Extra space for margins
        return max(calculatedWidth, minChartWidth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: true) {
                Chart {
                    let enumeratedResults = Array(testResults.enumerated())
                    
                    ForEach(enumeratedResults, id: \.0) { index, test in
                        BarMark(
                            x: .value("Test", index),
                            y: .value("Score", test.bandScore)
                        )
                        .cornerRadius(5)
                        .foregroundStyle(Color.blue.gradient)
                        .annotation(position: .top) {
                            Text(String(format: "%.1f", test.bandScore))
                                .font(.caption2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .chartYScale(domain: 0...9)
                .chartXScale(domain: 0...testResults.count)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        if let index = value.as(Int.self), index < testResults.count {
                            AxisTick()
                            AxisValueLabel {
                                Text("Test \(index + 1)")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(width: chartWidth, height: 200)
                .padding(.horizontal, 16)
                .padding(.bottom, 20) // Add bottom padding to prevent scrollbar overlap
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 16)
    }
}
