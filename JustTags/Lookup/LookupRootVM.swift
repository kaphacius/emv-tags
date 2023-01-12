//
//  LookupRootVM.swift
//  JustTags
//
//  Created by Yurii Zadoianchuk on 04/01/2023.
//

import SwiftyEMVTags
import SwiftUI
import Combine

internal final class LookupRootVM: ObservableObject {
    
    private static let allTags = "All Tags"
    
    @Published internal var searchText = ""
    @Published internal var kernelList: [String]
    @Published internal var selectedKernel: String
    @Published internal var selectedTag: TagDecodingInfo?
    @Published internal var tagList: [TagDecodingInfo]
    
    private let allTags: [TagDecodingInfo]
    private let tagParser: TagParser
    private let kernels: [KernelInfo]
    private var cancellables: Set<AnyCancellable> = []
    
    init(tagParser: TagParser) {
        self.kernels = tagParser.initialKernels.sorted(by: { $0.id < $1.id })
        self.kernelList = [Self.allTags] + kernels.map(\.id)
        self.allTags = tagParser.initialKernels
            .flatMap(\.tags)
            .sorted(by: { $0.info.tag.hexString < $1.info.tag.hexString })
        self.tagList = allTags
        self.selectedKernel = Self.allTags
        self.tagParser = tagParser
        
        _selectedKernel.projectedValue
            .sink(receiveValue: { [weak self] in self?.selectedKernelUpdated($0) })
            .store(in: &cancellables)
        
        self.setUpSearch()
    }
    
    private func selectedKernelUpdated(_ newKernel: String) {
        guard newKernel != Self.allTags else {
            self.tagList = allTags
            return
        }
        
        if let idx = kernelList.firstIndex(of: newKernel) {
            // 0 is for All Tags
            self.tagList = kernels[idx - 1].tags
        }
    }
    
    private func setUpSearch() {
        _searchText.projectedValue
            .debounce(for: 0.10, scheduler: RunLoop.main, options: nil)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .sink { [weak self] in self?.searchTags($0) }
            .store(in: &cancellables)
    }
    
    private func searchTags(_ searchText: String) {
        if searchText.count < 2 {
            selectedKernel = Self.allTags
            selectedKernelUpdated(self.selectedKernel)
        } else {
            let sstr = searchText.lowercased()
            selectedKernel = Self.allTags
            selectedKernelUpdated(self.selectedKernel)
            tagList = allTags.filter {
                $0.info.searchComponents.joined()
                    .appending($0.info.tag.hexString)
                    .lowercased()
                    .contains(sstr)
            }
        }
    }
    
}
