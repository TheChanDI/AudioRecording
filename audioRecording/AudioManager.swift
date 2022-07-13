//
//  AudioManager.swift
//  audioRecording
//
//  Created by Prakash Chandra Awal on 7/11/22.
//

import Foundation
import AVFoundation

class AudioManager: NSObject {
    
    var audioEngine = AVAudioEngine()
    var audioFile: AVAudioFile?
    var mixer : AVAudioMixerNode!
    var audioFilePlayer: AVAudioPlayerNode!
    var recordedFile: AVAudioFile?
    var audioRecordFilePlayer: AVAudioPlayerNode!
    let audioSession = AVAudioSession.sharedInstance()
    
    
    override init() {
        super.init()
        askingForPermission()
        setupAudioSession()
        audioFilePlayer = AVAudioPlayerNode()
//        audioRecordFilePlayer = AVAudioPlayerNode()
        mixer = AVAudioMixerNode()
        
        audioEngine.attach(audioFilePlayer)
        audioEngine.attach(mixer)
//        audioEngine.attach(audioRecordFilePlayer)
        
        let inputNode = audioEngine.inputNode
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        audioEngine.connect(inputNode, to: mixer, format: nil)
        
        audioEngine.connect(audioFilePlayer, to: mixer, format: nil)
//        audioEngine.connect(audioRecordFilePlayer, to: mixer, format: nil)
        
        try? audioEngine.inputNode.setVoiceProcessingEnabled(true)
        
        let mainMixerNode = audioEngine.mainMixerNode
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        
        audioEngine.connect(mixer, to: mainMixerNode, format: mixerFormat)
        
        audioEngine.prepare()
        
    }
    
    func askingForPermission() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio,
                                          completionHandler: { (granted: Bool) in
            })
        }
    }
    
    
    func setupAudioSession() {
        do{
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            //            try audioSession.setActive(true)
        } catch{
            print(error.localizedDescription)
        }
    }
    
    
    
    func startRecord() {
        
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                                   sampleRate: 44100,
                                   channels: 1,
                                   interleaved: true)
        
        
        let tapNode: AVAudioNode = mixer
        let format1 = tapNode.outputFormat(forBus: 0)
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // AVAudioFile uses the Core Audio Format (CAF) to write to disk.
        // So we're using the caf file extension.
        
        recordedFile = try? AVAudioFile(forWriting: documentURL.appendingPathComponent("recording.caf"), settings: format1.settings)
        
        print(documentURL.appendingPathComponent("recording.caf"), "lets see here ----->")
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            print(buffer, "buffer ------>")
            try? self.recordedFile?.write(from: buffer)
            
        })
        //Start Engine
        //        try! self.audioEngine.start()
    }
    
    
    
    func startPlay() {
        
        guard let fileURL = Bundle.main.url(forResource: "Intro", withExtension: "mp3") else {return}
        
        self.audioFile = try! AVAudioFile(forReading: fileURL)
        let audioFormat = audioFile!.processingFormat
        let audioFrameCount = UInt32(audioFile!.length)
        
        let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        
        try? audioFile!.read(into: audioFileBuffer!)
        
        
        audioFilePlayer.volume = 1
        audioFilePlayer.scheduleFile(audioFile!,
                                     at: nil,
                                     completionCallbackType: .dataPlayedBack) { _ in
            /* Handle any work that's necessary after playback. */
        }
        
        try! self.audioEngine.start()
        
        audioFilePlayer.play()
        
    }
    
    func stopRecord() {
        
        audioFilePlayer.stop()
//        audioEngine.inputNode.removeTap(onBus: 0)
//        audioEngine.disconnectNodeInput(audioEngine.inputNode)
//        audioEngine.detach(audioEngine.inputNode)
        audioEngine.stop()

    }
    
    func playAudioRecorded() {
        
        do {

            audioFilePlayer.volume = 1
            audioFilePlayer.scheduleFile(recordedFile!,
                                         at: nil,
                                         completionCallbackType: .dataPlayedBack) { _ in
            }
            
            try self.audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
        audioFilePlayer.play()
    }
    
    
    func URLFor(filename: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(filename)
    }
}


