# 💰 Finance Companion

A modern, premium iOS personal finance app built with **SwiftUI** and **SwiftData**, designed to help users track expenses, manage budgets, and gain actionable financial insights.

---

## 🎥 Demo

Watch the app in action:  
👉 [Demo Video](https://drive.google.com/drive/folders/14D15iOT1w6Bdf43xauwo6QtvVgxNIgmX?usp=sharing)

---

## 🚀 Features

- 📊 **Smart Expense Tracking**  
  Easily log and categorize transactions with a clean, intuitive interface.

- 💸 **Budget Management**  
  Set a monthly spending limit and allocate category-wise budgets.

- 📈 **Insights & Analytics**  
  Visualize spending patterns using interactive charts and summaries.

- 📄 **PDF Reports**  
  Generate high-quality, shareable financial reports.

- 🎨 **Premium UI/UX**  
  Glassmorphism, gradients, and smooth micro-interactions for a polished experience.

---

## 🏗️ Architecture

The app follows a **MVVM + Store pattern**:

- **ViewModels** handle UI state and formatting  
- **Stores** act as a single source of truth for business logic  
- Ensures predictable and maintainable data flow  

---

## 🧠 Technical Decisions & Trade-offs

### 1. Architecture
- **Chosen**: MVVM + Store  
- **Why**: Clear separation of concerns and centralized state  
- **Trade-off**: Singleton stores may introduce coupling  

---

### 2. Persistence
- **Chosen**: SwiftData  
- **Why**: Minimal boilerplate and seamless SwiftUI integration  
- **Trade-off**: Requires iOS 17+ and has limited debugging tools  

---

### 3. PDF Export
- **Chosen**: Native rendering (`UIGraphicsPDFRenderer`)  
- **Why**: High-quality vector output and full layout control  
- **Trade-off**: Manual layout increases complexity  

---

### 4. Budgeting System
- **Chosen**: Constraint-based budgeting  
- **Why**: Encourages disciplined financial planning  
- **Trade-off**: Less flexible for quick setup  

---

### 5. Charts & Visualization
- **Chosen**: Custom SwiftUI charts  
- **Why**: Full design control and no external dependencies  
- **Trade-off**: Increased development time  

---

## 🛠️ Tech Stack

- **Language**: Swift  
- **UI Framework**: SwiftUI  
- **Persistence**: SwiftData  
- **Architecture**: MVVM + Store  
- **PDF Generation**: UIKit (UIGraphicsPDFRenderer)

---

## 📱 Requirements

- iOS 17+
- Xcode 15+

---

## 📸 Screenshots

> Add your screenshots here
