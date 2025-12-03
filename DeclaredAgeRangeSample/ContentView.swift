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
                
                // アイコン
                Image(systemName: "person.crop.circle.badge.clock")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                // 説明テキスト
                Text("Declared Age Range API")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Apple IDで申告された年齢範囲を取得します")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // 結果表示エリア
                if isLoading {
                    ProgressView("取得中...")
                        .padding()
                } else if let ageRange {
                    ageRangeView(ageRange)
                } else if declined {
                    declinedView()
                } else if let errorMessage {
                    errorView(errorMessage)
                }
                
                Spacer()
                
                // 取得ボタン
                Button {
                    fetchAgeRange()
                } label: {
                    Label("年齢範囲を取得", systemImage: "arrow.down.circle.fill")
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
    
    // 年齢範囲の表示
    @ViewBuilder
    private func ageRangeView(_ range: AgeRangeService.AgeRange) -> some View {
        VStack(spacing: 16) {
            Text("取得した年齢範囲")
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
                    Text("申告方法: \(declarationDescription(declaration))")
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
    
    // 拒否された場合の表示
    @ViewBuilder
    private func declinedView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.title)
                .foregroundStyle(.gray)
            
            Text("年齢範囲の共有が拒否されました")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // エラー表示
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
    
    // 年齢範囲を取得
    private func fetchAgeRange() {
        isLoading = true
        errorMessage = nil
        ageRange = nil
        declined = false
        
        Task {
            do {
                // 13歳、16歳、18歳をAge Gateとして設定
                let response = try await requestAgeRange(ageGates: 13, 16, 18)
                
                await MainActor.run {
                    switch response {
                    case .declinedSharing:
                        self.declined = true
                    case .sharing(let range):
                        self.ageRange = range
                    @unknown default:
                        <#fatalError()#>
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "年齢範囲の取得に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // 年齢範囲の説明文字列
    private func ageRangeDescription(_ range: AgeRangeService.AgeRange) -> String {
        if let lower = range.lowerBound, let upper = range.upperBound {
            return "\(lower)歳〜\(upper)歳未満"
        } else if let lower = range.lowerBound {
            return "\(lower)歳以上"
        } else if let upper = range.upperBound {
            return "\(upper)歳未満"
        } else {
            return "不明"
        }
    }
    
    // 申告方法の説明
    private func declarationDescription(_ declaration: AgeRangeService.AgeRangeDeclaration) -> String {
        switch declaration {
        case .selfDeclared:
            return "本人申告"
        case .guardianDeclared:
            return "保護者申告"
        case .checkedByOtherMethod:
            return "その他の方法で確認"
        case .guardianCheckedByOtherMethod:
            return "保護者がその他の方法で確認"
        case .governmentIDChecked:
            return "政府ID確認"
        case .guardianGovernmentIDChecked:
            return "保護者が政府ID確認"
        case .paymentChecked:
            return "支払い方法で確認"
        case .guardianPaymentChecked:
            return "保護者が支払い方法で確認"
        @unknown default:
            return "不明"
        }
    }
}

#Preview {
    ContentView()
}
