//
//  SparklineView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

struct SparklineView: View {
    let data: [Double]
    var lineColor: Color = Color(hex: "6366F1")
    var lineWidth: CGFloat = 3
    
    var body: some View {
        GeometryReader { geometry in
            if data.count > 1 {
                let maxData = data.max() ?? 1
                let minData = data.min() ?? 0
                let range = maxData - minData == 0 ? 1 : maxData - minData
                
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(data.count - 1)
                
                // Draw filled gradient under the line
                Path { path in
                    for (index, value) in data.enumerated() {
                        let normalizedY = 1 - CGFloat((value - minData) / range)
                        let x = CGFloat(index) * step
                        let y = normalizedY * height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: height))
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        if index == data.count - 1 {
                            path.addLine(to: CGPoint(x: x, y: height))
                        }
                    }
                }
                .fill(
                    LinearGradient(
                        colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Draw the stroke line
                Path { path in
                    for (index, value) in data.enumerated() {
                        let normalizedY = 1 - CGFloat((value - minData) / range)
                        let x = CGFloat(index) * step
                        let y = normalizedY * height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(lineColor.opacity(0.8), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            } else {
                // Not enough data
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                }
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: lineWidth, dash: [5, 5]))
            }
        }
    }
}
