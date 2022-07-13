//
//  ContentView.swift
//  audioRecording
//
//  Created by Prakash Chandra Awal on 7/10/22.
//

import SwiftUI

struct ContentView: View {
    
    var audioManager = AudioManager()
//    var recorder1 = Recorder()
    var body: some View {
        ZStack {
            HStack {
                Button {
                    audioManager.startPlay()

                } label: {
                    Text("Play")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                }
                Spacer()
                Button {
                    audioManager.playAudioRecorded()
                } label: {
                    Text("Play audio recorded")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                }
                Spacer()
                Button {
//                    try? recorder1.startRecording()
                    audioManager.startRecord()
                } label: {
                    Text("Record")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                
                Spacer()
                Button {
                    audioManager.stopRecord()
//                    try? recorder1.stopRecording()
                } label: {
                    Text("Stop Record")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                
            }
        }
        .padding()
        
    }

}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


