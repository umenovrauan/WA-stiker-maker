//
//  ContentView.swift
//  WA stiker maker
//
//  Created by Rauan Umenov on 17.12.2023.
//

import SwiftUI

struct ContentView: View {
    
    let coloums = [GridItem(.adaptive(minimum: width, maximum: width), spacing: spacing)]
    @State var vm = ViewModel()
    
    
    var body: some View {
        ScrollView {
            HStack {
                ImagePicker {
                    ImageContainerView(badgeText: "IC", image: vm.showOriginalImage ? vm.trayIcon.inputImage : vm.trayIcon.outputImage)
                } onSelectImage: { image in
                    vm.onInputImageSelected(image, stiker: vm.trayIcon)
                }
                Toggle("Show original", isOn: $vm.showOriginalImage)
            }
            .padding(32)
            
            LazyVGrid(columns: coloums, spacing: spacing) {
                ForEach(vm.stikers) {stiker in
                    ImagePicker {
                        ImageContainerView(badgeText: String(stiker.pos + 1), image: vm.showOriginalImage ? stiker.inputImage : stiker.outputImage)
                    } onSelectImage: { image in
                        vm.onInputImageSelected(image, stiker: stiker)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("WA Stiker Maker")
        .toolbar{
            ToolbarItem(placement: .primaryAction) {
                Button("Export") {
                    vm.sendToWhatsApp()
                }
                .disabled(!vm.isAbleToExportAsStikers)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
