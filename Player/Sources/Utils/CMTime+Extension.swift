//
//  CMTime+Extension.swift
//  Player
//
//  Created by 이재훈 on 11/6/24.
//

import AVFoundation

extension CMTime {
    func convertIntervalTimeToString()-> String {
        var timeInSeconds = Int(CMTimeGetSeconds(self))
        let isPositive = timeInSeconds >= 0
        timeInSeconds = abs(timeInSeconds)
        
        let hours = String(format: "%02d:", timeInSeconds / 3600)
        let minutes =  String(format: "%02d:", timeInSeconds / 60 % 60)
        let seconds =  String(format: "%02d", timeInSeconds % 60)
        var time = hours + minutes + seconds
        
        if hours == "00:" {
            time = minutes + seconds
        }
        else if  hours == "00:" && minutes == "00:" {
            time = seconds
        }
        
        return (isPositive ? "+" : "-") + time
    }
    
    func convertCMTimeToString()-> String {
        let timeInSeconds = CMTimeGetSeconds(self)
        
        guard (timeInSeconds.isNaN || timeInSeconds.isInfinite) == false else { return "" }
        
        let hours = Int(timeInSeconds) / 3600
        let minutes = Int(timeInSeconds) / 60 % 60
        let seconds = Int(timeInSeconds) % 60
        
        var value = ""
        if hours == 0 {
            value = String(format: "%02d:%02d", minutes, seconds)
        }
        else {
            value = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        return value
    }
}
