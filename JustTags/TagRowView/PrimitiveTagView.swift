//
//  PrimitiveTagView.swift
//  JustTags
//
//  Created by Yurii Zadoianchuk on 01/06/2022.
//

import SwiftUI
import SwiftyEMVTags

internal struct PrimitiveTagVM: Identifiable, TagHeaderVM {
    
    typealias ID = TagRowVM.ID
    
    let id: UUID
    let tag: String
    let name: String
    let valueVM: TagValueVM
    let canExpand: Bool
    let showsDetails: Bool
    
}

internal struct PrimitiveTagView: View {
    
    @EnvironmentObject private var windowVM: MainVM
    @State internal var isExpanded: Bool = false
    
    private let vm: PrimitiveTagVM
    
    internal init(vm: PrimitiveTagVM) {
        self.vm = vm
    }
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: commonPadding) {
            TagHeaderView(vm: vm)
            tagValueView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if vm.showsDetails {
                detailsButton
            }
        }
        .contentShape(Rectangle())
        .gesture(TapGesture().modifiers(.command).onEnded { _ in
            windowVM.onTagSelected(id: vm.id)
        })
        .onTapGesture(count: 2) {
            if vm.showsDetails { windowVM.onDetailTagSelected(id: vm.id) }
        }
        .onTapGesture {
            if vm.canExpand { isExpanded.toggle() }
        }
    }
    
    @ViewBuilder
    private var tagValueView: some View {
        if vm.canExpand {
            expandableValueView
                .padding(-commonPadding)
        } else {
            TagValueView(vm: vm.valueVM)
        }
    }
    
    @ViewBuilder
    private func byteValueView(for byte: UInt8) -> some View {
        Text(byte.hexString)
            .font(.title3.monospaced())
    }
    
    private var expandableValueView: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
            // TODO: Add selected meanings
//                SelectedMeaningList(tag: tag)
//                    .padding(.leading, commonPadding * 3)
            }, label: {
                TagValueView(vm: vm.valueVM)
            }
        )
        .padding(.horizontal, commonPadding)
        .animation(.none, value: isExpanded)
    }
    
    private var detailsButton: some View {
        Button(
            action: {
                windowVM.onDetailTagSelected(id: vm.id)
            }, label: {
                GroupBox {
                    EmptyView()
                    // TODO: add tag id as property
//                    Label(
//                        "Details",
//                        systemImage: windowVM.detailTag?.id == vm.id ? "lessthan" : "greaterthan"
//                    )
                    .labelStyle(.iconOnly)
                    .padding(.horizontal, commonPadding)
                }
            }
        )
        .padding(.horizontal, commonPadding)
        .buttonStyle(.plain)
    }
}

struct PrimitiveTagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrimitiveTagView(
                vm: .make(with: .mockTag)
            )
            PrimitiveTagView(
                vm: .make(with: .mockTagExtended)
            )
            PrimitiveTagView(
                vm: .make(with: .mockTag, canExpand: true)
            )
            PrimitiveTagView(
                vm: .make(with: .mockTag, showsDetails: false)
            )
        }.environmentObject(MainVM())
    }
}
