//
//  Setting.swift
//  Pods
//
//  Created by 林涛 on 2017/1/1.
//
//

import Foundation

public struct OMGImagePickerSetting {
   public var rightBarTitle:String
   public var leftBarTitle:String
   public var navigationBarColor:UIColor
   public var navigationBarTranslucent:Bool
   public var maxNumberOfSelection:Int
   
   public init(_ rightBarTitle:String = "Done",
         leftBarTitle:String = "Cancel",
         navigationBarColor:UIColor = UIColor.white,
         navigationBarTranslucent:Bool = false,
         maxNumberOfSelection:Int = 5) {
        self.rightBarTitle = rightBarTitle
        self.leftBarTitle = leftBarTitle
        self.navigationBarColor = navigationBarColor
        self.navigationBarTranslucent = navigationBarTranslucent
        self.maxNumberOfSelection = maxNumberOfSelection
    }
}
