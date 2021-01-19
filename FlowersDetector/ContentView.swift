//
//  ContentView.swift
//  FlowersDetector
//
//  Created by Anna Volkova on 13.01.2021.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model = FlowersDetectorModel()
    
    var body: some View {
        
        self.model.image
            .resizable()
            .scaledToFit()
            .onTapGesture {
                guard self.model.index + 1 > 9 else {
                    self.model.index += 1
                    self.model.start()
                    return
                }
                self.model.index = 1
                self.model.start()
            }
            .onAppear() {
                self.model.start()
            }
            .alert(isPresented: self.$model.showingAlert) {
                Alert(title: Text("Identification finished"), message: Text("This is \(self.model.flowerName ?? "")"), dismissButton: .default(Text("Got it!")))
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
