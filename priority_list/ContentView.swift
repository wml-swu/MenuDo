//
//  ContentView.swift
//  priority_list
//
//  Created by 大大怪将军 on 2026/2/1.
//

import SwiftUI

struct ContentView: View {
    @State private var store = TodoStore()
    @FocusState private var focusedQuadrant: QuadrantType?
    @State private var draftText: [QuadrantType: String] = [:]

    /// 每个象限为固定正方形，尺寸对应 macOS 桌面插件最大尺寸（systemLarge 约 329×345 pt，取 345 pt 作为正方形边长）
    private static let quadrantSize: CGFloat = 345
    private static let gridSpacing: CGFloat = 12

    private let columns = [
        GridItem(.fixed(Self.quadrantSize), spacing: Self.gridSpacing),
        GridItem(.fixed(Self.quadrantSize), spacing: Self.gridSpacing)
    ]

    private func binding(for quadrant: QuadrantType) -> Binding<String> {
        Binding(
            get: { draftText[quadrant] ?? "" },
            set: { newValue in
                var copy = draftText
                copy[quadrant] = newValue
                draftText = copy
            }
        )
    }

    /// 保存当前象限草稿并失焦（用于回车或点击其他区域时）
    private func saveDraftAndResignFocus(quadrant: QuadrantType) {
        let text = (draftText[quadrant] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            store.add(title: text, quadrant: quadrant)
        }
        var copy = draftText
        copy[quadrant] = ""
        draftText = copy
        focusedQuadrant = nil
    }

    var body: some View {
        ZStack {
            // 背景：浅灰色
            Color(white: 0.1)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Text("Do it!")
                        .font(.title.bold())
                    Spacer()
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)

                // 四象限网格（固定正方形，尺寸同 macOS 桌面小插件）
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Self.gridSpacing) {
                        ForEach(QuadrantType.allCases, id: \.self) { quadrant in
                            QuadrantCard(
                                size: Self.quadrantSize,
                                quadrant: quadrant,
                                tasks: store.tasks(for: quadrant),
                                onToggle: { store.toggleCompletion($0) },
                                onDelete: { store.delete($0) }
                            ) {
                                TextField("添加任务…", text: binding(for: quadrant))
                                    .textFieldStyle(.plain)
                                    .focused($focusedQuadrant, equals: Optional(quadrant))
                                    .onSubmit { saveDraftAndResignFocus(quadrant: quadrant) }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color(white: 0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(16)
                }
                .frame(minWidth: ContentView.quadrantSize * 2 + ContentView.gridSpacing + 32)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                if focusedQuadrant != nil { focusedQuadrant = nil }
            }
        )
        .onChange(of: focusedQuadrant) { oldValue, newValue in
            if let q = oldValue {
                let text = (draftText[q] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    store.add(title: text, quadrant: q)
                }
                var copy = draftText
                copy[q] = ""
                draftText = copy
            }
        }
    }
}

// MARK: - 单象限卡片（固定正方形）
private struct QuadrantCard<AddField: View>: View {
    let size: CGFloat
    let quadrant: QuadrantType
    let tasks: [TodoItem]
    let onToggle: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    @ViewBuilder let addTaskField: () -> AddField

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题 + 圆点
            HStack(spacing: 6) {
                Circle()
                    .fill(quadrant.color)
                    .frame(width: 8, height: 8)
                Text(quadrant.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            // 任务列表 + 输入框作为下一项（无 item 时即为第一项）
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tasks) { item in
                        TaskRowView(
                            item: item,
                            onToggle: { onToggle(item) },
                            onDelete: { onDelete(item) }
                        )
                    }
                    addTaskField()
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(12)
        .frame(width: size, height: size)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - 单条任务行
private struct TaskRowView: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.subheadline)
                .strikethrough(item.isCompleted, color: .secondary)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ContentView()
}
