import UIKit
import PDFKit

struct PDFReportGenerator {
    static func generateInsightsPDF(viewModel: InsightsViewModel) -> URL? {
        let format = UIGraphicsPDFRendererFormat()
        let metadata = [
            kCGPDFContextAuthor: "Finance Companion",
            kCGPDFContextTitle: "Insights Report"
        ]
        format.documentInfo = metadata as [String: Any]
        
        let pageWidth = 595.2 // A4 width
        let pageHeight = 841.8 // A4 height
        let bounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let cgContext = context.cgContext
            
            var cursorY: CGFloat = 40
            let margin: CGFloat = 40
            let contentWidth = pageWidth - margin * 2
            
            // Helper to draw text
            func drawText(_ text: String, font: UIFont, color: UIColor = .black, xOffset: CGFloat = margin, spacing: CGFloat = 8) {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                
                // Estimate bounds and handle overflow to next page if needed
                let textWidth = contentWidth - (xOffset - margin)
                let rect = CGRect(x: xOffset, y: cursorY, width: textWidth, height: pageHeight - cursorY - margin)
                let size = attributedString.boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if cursorY + size.height > pageHeight - margin - 30 {
                    context.beginPage()
                    cursorY = margin
                }
                
                let drawRect = CGRect(origin: CGPoint(x: xOffset, y: cursorY), size: size.size)
                attributedString.draw(in: drawRect)
                cursorY += size.height + spacing
            }

            func drawDivider() {
                cursorY += 10
                if cursorY > pageHeight - margin - 30 {
                    context.beginPage()
                    cursorY = margin
                }
                cgContext.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.5).cgColor)
                cgContext.setLineWidth(1)
                cgContext.move(to: CGPoint(x: margin, y: cursorY))
                cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: cursorY))
                cgContext.strokePath()
                cursorY += 20
            }
            
            // 1. Header
            drawText("Finance Companion", font: .systemFont(ofSize: 14, weight: .bold), color: .systemGray)
            drawText("Insights Report", font: .systemFont(ofSize: 28, weight: .bold), spacing: 4)
            drawText("Period: \(viewModel.reportPeriodString)", font: .systemFont(ofSize: 16, weight: .medium), color: .darkGray, spacing: 4)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            drawText("Generated: \(dateFormatter.string(from: Date()))", font: .systemFont(ofSize: 14, weight: .regular), color: .systemGray, spacing: 20)
            
            drawDivider()
            
            // 2. Summary
            drawText("Summary", font: .systemFont(ofSize: 20, weight: .semibold), spacing: 12)
            drawText(viewModel.reportSummaryString, font: .systemFont(ofSize: 16, weight: .regular), spacing: 20)
            
            drawDivider()
            
            // 3. Key Insights
            drawText("Key Insights", font: .systemFont(ofSize: 20, weight: .semibold), spacing: 12)
            for card in viewModel.insightCards {
                drawText("• \(card.description): \(card.headline)", font: .systemFont(ofSize: 16, weight: .regular), xOffset: margin + 10, spacing: 12)
            }
            cursorY += 8
            
            drawDivider()
            
            // 4. Category Breakdown
            drawText("Category Breakdown", font: .systemFont(ofSize: 20, weight: .semibold), spacing: 12)
            for breakdown in viewModel.categoryBreakdowns {
                let amountStr = viewModel.currencyFormatter.string(from: NSNumber(value: breakdown.amount)) ?? "₹0"
                drawText("\(breakdown.category.rawValue) — \(amountStr)", font: .systemFont(ofSize: 16, weight: .regular), xOffset: margin + 10, spacing: 10)
            }
            if viewModel.categoryBreakdowns.isEmpty {
                drawText("No spending in this period.", font: .systemFont(ofSize: 16, weight: .regular), xOffset: margin + 10, spacing: 10)
            }
            cursorY += 10
            
            drawDivider()
            
            // 5. Optional Observation
            if let observation = viewModel.reportObservationText {
                drawText("Observation", font: .systemFont(ofSize: 20, weight: .semibold), spacing: 12)
                drawText(observation, font: .systemFont(ofSize: 16, weight: .regular), spacing: 20)
                drawDivider()
            }
            
            // 6. Footer
            let footerText = "Generated by Finance Companion"
            let ftFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let ftAttributes: [NSAttributedString.Key: Any] = [.font: ftFont, .foregroundColor: UIColor.lightGray]
            let ftSize = NSAttributedString(string: footerText, attributes: ftAttributes).size()
            
            let footerRect = CGRect(
                x: (pageWidth - ftSize.width) / 2, // Centered
                y: pageHeight - margin - ftSize.height,
                width: ftSize.width,
                height: ftSize.height
            )
            NSAttributedString(string: footerText, attributes: ftAttributes).draw(in: footerRect)
        }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Insights_Report.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
}
