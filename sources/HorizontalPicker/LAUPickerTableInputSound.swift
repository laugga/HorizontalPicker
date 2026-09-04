/*

 LAUPickerTableInputSound.swift
 HorizontalPicker

 Copyright (cc) 2012 Luis Laugga.
 Some rights reserved, all wrongs deserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

import AudioToolbox
import Foundation

/// The iOS click-input sound, played when the highlighted column changes.
public class LAUPickerTableInputSound {

    public static let shared = LAUPickerTableInputSound()

    private var inputSoundId: SystemSoundID = 0

    private init() {
        if let soundURL = Bundle.module.url(forResource: "tick", withExtension: "caf") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &inputSoundId)
        }
    }

    deinit {
        if inputSoundId != 0 {
            AudioServicesDisposeSystemSoundID(inputSoundId)
        }
    }

    public func play() {
        guard inputSoundId != 0 else {
            return
        }

        AudioServicesPlaySystemSound(inputSoundId)
    }
}
