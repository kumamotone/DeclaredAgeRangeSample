//
//  ContentView.swift
//  DeclaredAgeRangeSample
//
//  A sample app demonstrating the Declared Age Range API (iOS 26+)
//

import SwiftUI
import DeclaredAgeRange

struct ContentView: View {
    @Environment(\.requestAgeRange) private var requestAgeRange
    
    @State private var ageRange: AgeRangeService.AgeRange?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var declined = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                Image(systemName: "person.crop.circle.badge.clock")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                // Description
                Text("Declared Age Range API")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Request the declared age range from Apple ID")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Result display area
                if isLoading {
                    ProgressView("Requesting...")
                        .padding()
                } else if let ageRange {
                    ageRangeView(ageRange)
                } else if declined {
                    declinedView()
                } else if let errorMessage {
                    errorView(errorMessage)
                }
                
                Spacer()
                
                // Request button
                Button {
                    fetchAgeRange()
                } label: {
                    Label("Request Age Range", systemImage: "arrow.down.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Age Range Sample")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Result Views
    
    @ViewBuilder
    private func ageRangeView(_ range: AgeRangeService.AgeRange) -> some View {
        VStack(spacing: 16) {
            Text("Age Range Result")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    
                    Text(ageRangeDescription(range))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                if let declaration = range.ageRangeDeclaration {
                    Text("Declaration: \(declarationDescription(declaration))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
    
    @ViewBuilder
    private func declinedView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.title)
                .foregroundStyle(.gray)
            
            Text("User declined to share age range")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundStyle(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func fetchAgeRange() {
        isLoading = true
        errorMessage = nil
        ageRange = nil
        declined = false
        
        Task {
            do {
                // Request age range with age gates at 13, 16, and 18
                let response = try await requestAgeRange(ageGates: 13, 16, 18)
                
                await MainActor.run {
                    switch response {
                    case .declinedSharing:
                        self.declined = true
                    case .sharing(let range):
                        self.ageRange = range
                    @unknown default:
                        self.errorMessage = "Unknown response received"
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to request age range: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func ageRangeDescription(_ range: AgeRangeService.AgeRange) -> String {
        if let lower = range.lowerBound, let upper = range.upperBound {
            return "\(lower) - \(upper) years old"
        } else if let lower = range.lowerBound {
            return "\(lower)+ years old"
        } else if let upper = range.upperBound {
            return "Under \(upper) years old"
        } else {
            return "Unknown"
        }
    }
    
    private func declarationDescription(_ declaration: AgeRangeService.AgeRangeDeclaration) -> String {
        switch declaration {
        case .selfDeclared:
            return "Self-declared"
        case .guardianDeclared:
            return "Guardian-declared"
        case .checkedByOtherMethod:
            return "Verified by other method"
        case .guardianCheckedByOtherMethod:
            return "Guardian verified by other method"
        case .governmentIDChecked:
            return "Government ID verified"
        case .guardianGovernmentIDChecked:
            return "Guardian verified with Government ID"
        case .paymentChecked:
            return "Payment method verified"
        case .guardianPaymentChecked:
            return "Guardian verified with payment method"
        @unknown default:
            return "Unknown"
        }
    }
}

#Preview {
    ContentView()
}
