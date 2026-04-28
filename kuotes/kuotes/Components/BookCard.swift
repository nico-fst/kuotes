//
//  BookCard.swift
//  kuotes
//
//  Created by Nico Stern on 27.04.26.
//

import SwiftUI
import SwiftData

struct KuoteCard: View {
    let kuote: Kuote
    let detailed: Bool
    let isFrameFloating: Bool
    let onChanged: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    private let textWidth = UIScreen.main.bounds.width * 0.7
    
    @EnvironmentObject var filterVM: FilterHeaderViewModel
    @EnvironmentObject var vm: KuotesViewModel
    @Environment(\.modelContext) private var ctx
    
    @State private var selectedDrawer: DrawerType
    @State private var selectedColor: ColorType
    @State private var changeError: String = ""
    @State private var updating: Bool = false
    @State private var didChangeKuote = false
    
    init(
        kuote: Kuote,
        detailed: Bool = false,
        isFrameFloating: Bool = false,
        onChanged: @escaping () -> Void
    ) {
        self.kuote = kuote
        self.detailed = detailed
        self.isFrameFloating = isFrameFloating
        _selectedDrawer = State(initialValue: kuote.drawer) // auto von kuote nehmen
        _selectedColor = State(initialValue: kuote.color) // auto von kuote nehmen
        self.onChanged = onChanged
    }

    var body: some View {
        VStack {
            kuoteFrame
            
            if detailed {
                kuoteControls
                .padding(.top, 20)
            }
            
            if !changeError.isEmpty {
                Text(changeError)
                    .foregroundStyle(.red)
            }
        }
        
    }

    var kuoteFrame: some View {
        VStack(alignment: .leading) {
            if !updating {
                Text(kuote.fileItem.displayName)
                    .frame(width: textWidth, alignment: .leading) // nicht in die Anführungszeichen reinragen
                Text("page \(kuote.pageno) ⋅ \(kuote.chapter)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(detailed ? nil : 1)
                    .frame(width: textWidth, alignment: .leading) // nicht in die Anführungszeichen reinragen
                Text(kuote.text)
                    .lineLimit(detailed ? nil : 2)
                    .padding(.vertical, 8)
                    .font(.system(.body, design: .serif))
                    .bold()
                Text(
                    "\(kuote.datetime.formatted(.dateTime.year().month().day().hour().minute()))"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            } else {
                ProgressView("Updating...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colorScheme == .dark
                ? selectedColor.swiftUIColor.opacity(0.2)
                : selectedColor.swiftUIColor.opacity(0.3),
            in: RoundedRectangle(cornerRadius: 32)
        )
        .shadow(color: kuote.color.swiftUIColor, radius: 16, x: 0, y: 8)
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    .white.opacity(0.2),
                    lineWidth: colorScheme == .dark ? 1 : 3)
        }
        .overlay(alignment: .topTrailing) {
            Text("❞")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
                .opacity(0.3)
                .frame(width: 40, height: 50)
                .padding(.top, 20)
                .padding(.trailing, 20)
        }
        .modifier(Floating3DEffect(isActive: isFrameFloating))
    }

    var kuoteControls: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        DrawerPickers(
                            selectedDrawer: Binding(
                                get: { [selectedDrawer] as Set<DrawerType> },
                                set: { newSet in
                                    changeError = ""
                                    let newValue = newSet.first ?? selectedDrawer
                                    
                                    // no updates if same color selected
                                    guard newValue != selectedDrawer else { return }
                                    
                                    Task {
                                        do {
                                            updating = true
                                            defer { updating = false }
                                            
                                            let found = try await FetchServices.shared.updateHighlightDrawer(for: kuote, to: newValue)
                                            if !found {
                                                changeError = "Kuote not found - reload local Kuotes"
                                            }
                                            
                                            selectedDrawer = newValue
                                            didChangeKuote = true
                                            onChanged()
                                        } catch {
                                            selectedDrawer = kuote.drawer // rollback
                                            changeError = error.localizedDescription
                                        }
                                    }
                                }),
                            allowMulti: false
                        )
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ColorPickers(
                            selectedColor: Binding(
                                get: { [selectedColor] as Set<ColorType> },
                                set: { newSet in
                                    changeError = ""
                                    let newValue = newSet.first ?? selectedColor
                                    
                                    // no updates if same color selected
                                    guard newValue != selectedColor else { return }
                                    
                                    Task {
                                        do {
                                            updating = true
                                            defer { updating = false }
                                            
                                            let found = try await FetchServices.shared.updateHighlightColor(for: kuote, to: newValue)
                                            if !found {
                                                changeError = "Kuote not found - reload local Kuotes"
                                            }
                                            
                                            selectedColor = newValue
                                            didChangeKuote = true
                                            onChanged()
                                        } catch {
                                            selectedColor = kuote.color // rollback
                                            changeError = error.localizedDescription
                                        }
                                    }
                                }),
                            allowMulti: false
                        )
                    }
                }
            }
        }
    }
}

struct KuoteRow: View {
    let kuote: Kuote
    @Binding var selectedKuote: Kuote?
    var kuoteAnimation: Namespace.ID
    var onSelect: () -> Void
    var onChanged: () -> Void
    var onDelete: () -> Void

    var body: some View {
        KuoteCard(
            kuote: kuote,
            detailed: false,
            onChanged: onChanged
        )
            .frame(maxWidth: .infinity)
            .matchedGeometryEffect(id: kuote.id, in: kuoteAnimation)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
            .sensoryFeedback(.selection, trigger: selectedKuote)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

struct Floating3DEffect: ViewModifier {
    let isActive: Bool
    @State private var enteredFloating = false
    @State private var animate = false // bool für beide Animations-Zustände A, B
    
    @State private var xAngle: Double = 5
    @State private var yAngle: Double = 5
    @State private var zAngle: Double = 1.5
    @State private var duration: Double = 4
    
    private func randomize() {
        xAngle = Double.random(in: 2...7)
        yAngle = Double.random(in: 2...7)
        zAngle = Double.random(in: 0.5...2)
        duration = Double.random(in: 3.5...5.5)
    }

    func body(content: Content) -> some View {
        content
            .rotation3DEffect( // x-Achse
                .degrees(isActive
                        ? (enteredFloating
                            ? (animate ? xAngle : -xAngle)
                            : (animate ? xAngle : 0))
                        : 0
                ),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect( // y-Achse
                .degrees(isActive
                        ? (enteredFloating
                            ? (animate ? yAngle : -yAngle)
                            : (animate ? yAngle : 0))
                        : 0
                ),
                axis: (x: 0, y: 1, z: 0)
            )
            .rotation3DEffect( // z-Achse
                .degrees(isActive
                         ? (enteredFloating
                            ? (animate ? zAngle : -zAngle)
                            : (animate ? zAngle : 0))
                         : 0
                ),
                axis: (x: 0, y: 0, z: 1)
            )
            .animation(
                isActive
                    ? .easeInOut(duration: 4).repeatForever(autoreverses: true)
                    : .easeOut(duration: 0.2),
                value: animate
            )
            .animation(.easeOut(duration: 0.2), value: isActive)
            .onChange(of: isActive) { _, newValue in
                guard newValue else {
                    animate = false
                    return
                }
                
                randomize()

                animate = false
                DispatchQueue.main.async {
                    animate = true
                }
            }
    }
}


#Preview("S Normal") {
    KuoteCard(kuote: .templateShort, detailed: false) {}
        .environmentObject(FilterHeaderViewModel())
        .environmentObject(KuotesViewModel())
}

#Preview("S Detailed") {
    KuoteCard(kuote: .templateShort, detailed: true) {}
        .environmentObject(FilterHeaderViewModel())
        .environmentObject(KuotesViewModel())
}

#Preview("M Detailed") {
    KuoteCard(kuote: .templateMedium, detailed: true) {}
        .environmentObject(FilterHeaderViewModel())
        .environmentObject(KuotesViewModel())
}

#Preview("L Detailed") {
    KuoteCard(kuote: .templateLong, detailed: true) {}
        .environmentObject(FilterHeaderViewModel())
        .environmentObject(KuotesViewModel())
}
