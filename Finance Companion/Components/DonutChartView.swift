//
//  DonutChartView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

struct DonutSlice: Identifiable {
    let id = UUID()
    let percentage: Double
    let color: Color
}

struct DonutChartView: View {
    let slices: [DonutSlice]
    var lineWidth: CGFloat = 24
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Background track
                Circle()
                    .stroke(Color(UIColor.tertiarySystemGroupedBackground), lineWidth: lineWidth)
                    .frame(width: size, height: size)
                
                if !slices.isEmpty {
                    // Segments
                    ForEach(0..<slices.count, id: \.self) { i in
                        let startParams = startAngle(for: i)
                        let endParams = startParams + slices[i].percentage
                        
                        Circle()
                            .trim(from: CGFloat(startParams), to: CGFloat(endParams))
                            .stroke(slices[i].color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                            .rotationEffect(.degrees(-90))
                            .frame(width: size, height: size)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func startAngle(for index: Int) -> Double {
        var sum: Double = 0
        for i in 0..<index {
            sum += slices[i].percentage
        }
        return sum
    }
}
