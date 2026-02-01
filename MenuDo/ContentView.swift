//
//  ContentView.swift
//  MenuDo
//
//  Created by 大大怪将军 on 2026/2/1.
//

import SwiftUI

struct ContentView: View {
    @State private var store = TodoStore()
    @FocusState private var focusedQuadrant: QuadrantType?
    @FocusState private var focusResignSink: Bool  // 点击其他区域时聚焦此处，使输入框/编辑框失焦并触发保存
    @State private var draftText: [QuadrantType: String] = [:]
    @State private var editingItemId: UUID?

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

            // 不可见的焦点承接视图：点击其他区域时聚焦此处，让输入框/编辑框失焦
            Color.clear
                .frame(width: 1, height: 1)
                .focusable()
                .focused($focusResignSink, equals: true)
                .focusEffectDisabled()  // 不显示蓝色焦点环
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Text("MenuDo")
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

                // 四象限网格固定不滚动，仅象限内任务列表可滚动（鼠标在哪个象限就滚哪个）
                LazyVGrid(columns: columns, spacing: Self.gridSpacing) {
                    ForEach(QuadrantType.allCases, id: \.self) { quadrant in
                        QuadrantCard(
                            size: Self.quadrantSize,
                            quadrant: quadrant,
                            tasks: store.tasks(for: quadrant),
                            editingItemId: $editingItemId,
                            onToggle: { store.toggleCompletion($0) },
                            onDelete: { store.delete($0) },
                            onEdit: { item, newTitle in
                                store.updateTitle(item, to: newTitle)
                                editingItemId = nil
                            }
                        ) {
                            TextField("添加任务…", text: binding(for: quadrant), axis: .vertical)
                                .textFieldStyle(.plain)
                                .lineLimit(2...8)
                                .focused($focusedQuadrant, equals: Optional(quadrant))
                                .onSubmit { saveDraftAndResignFocus(quadrant: quadrant) }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(white: 0.05), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
                .padding(16)
                .frame(minWidth: ContentView.quadrantSize * 2 + ContentView.gridSpacing + 32)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                // 将焦点移到“沉没”视图，输入框/编辑框会失焦，onChange 会触发保存
                focusResignSink = true
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
    @Binding var editingItemId: UUID?
    let onToggle: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    let onEdit: (TodoItem, String) -> Void
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
                            isEditing: editingItemId == item.id,
                            onToggle: { onToggle(item) },
                            onDelete: { onDelete(item) },
                            onStartEdit: { editingItemId = item.id },
                            onCommitEdit: { newTitle in onEdit(item, newTitle) }
                        )
                    }
                    addTaskField()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
    let isEditing: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onStartEdit: () -> Void
    let onCommitEdit: (String) -> Void

    @State private var editText: String = ""
    @FocusState private var isEditFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
            }
            .buttonStyle(.plain)
            .disabled(isEditing)

            if isEditing {
                TextField("任务内容", text: $editText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .lineLimit(2...8)
                    .focused($isEditFocused)
                    .onSubmit { onCommitEdit(editText) }
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(item.title)
                    .font(.subheadline)
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .contentShape(Rectangle())
                    .onTapGesture { onStartEdit() }
            }

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(isEditing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                editText = item.title
                isEditFocused = true
            }
        }
        .onChange(of: isEditFocused) { _, newValue in
            if !newValue && isEditing {
                onCommitEdit(editText)
            }
        }
    }
}

#Preview {
    ContentView()
}
