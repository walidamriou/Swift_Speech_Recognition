//
//  main.swift
//  Swift_Speech_Recognition
//
//  Created by Walid Amriou on 14/11/2021.
//

import Foundation
import Speech
import AppKit


// Every app uses a single instance of NSApplication to control the main event loop, that used to keep track of the app’s windows and menus, distribute events to the appropriate objects (that’s, itself or one of its windows), set up autorelease pools, and receive notification of app-level events.
//  we use NSApplication with shared to returns the application instance, creating it if it doesn’t exist yet.
let app = NSApplication.shared;

// define AppDelegate class
// to create the app delegate which it is an object that the application object can use to do certain things
// NSApplicationDelegate is a set of methods that delegates of NSApplication objects can implement
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // create a object using AVAudioEngine() that manages a graph of audio nodes, controls playback, and configures real-time rendering constraints
    private let audioEngine = AVAudioEngine();
    
    // Initiate the speech recognition process with specified locale
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"));
    
    //the question mark ? after SFSpeechAudioBufferRecognitionRequest means the value is optional. Optionals could contain a value or it could be nil
    // We use an SFSpeechAudioBufferRecognitionRequest object to perform speech recognition on live audio, or on a set of existing audio buffers. For example, we use this request object to route audio from a device's microphone to the speech recognizer.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    // We use an SFSpeechRecognitionTask object to determine the state of a speech recognition task, to cancel an ongoing task, or to signal the end of the task.
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Tells the delegate when the app has finished launching
    func applicationDidFinishLaunching(_ notification: Notification) {
        // create input node
        let inputNode = audioEngine.inputNode;
        //  make the output support format that best matches the rendering context's workingFormat.
        let recordingFormat = inputNode.outputFormat(forBus: 0);
        
        // Installs an audio tap on the bus 0 to record, monitor, and observe the output of the node.
        inputNode.installTap(onBus: 0,bufferSize: 1024,format: recordingFormat){
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in self.recognitionRequest?.append(buffer)
        }
        
        //
        SFSpeechRecognizer.requestAuthorization({ (authStatus:SFSpeechRecognizerAuthorizationStatus) in
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest();
            
            guard let speechRecognizer = self.speechRecognizer else { fatalError("Unable to create a SpeechRecognizer object") }
            guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // RecognitionTask executes the speech recognition request and delivers the results to the specified handler block
            self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                let isFinal = false
                if let result = result {
                    let result_speech = result.bestTranscription.formattedString;
                    print(result_speech);
                }
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    app.terminate(self)
                }
            }
        })
        audioEngine.prepare()
        try! audioEngine.start()
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
