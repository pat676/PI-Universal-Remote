//
//  DataStructure.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 28.12.2017.
//  Copyright © 2017 Patrick Henriksen. All rights reserved.
//

import UIKit

class DataStructure: NSObject{
    
    var layouts = ArrayWrap<Layout>();
    
    override init(){
        super.init()
        load()
    }
    
    func getLayout(usedWith device: String) -> Layout?{
        for layout in layouts{
            if layout.usedWith.contains(device){
                return layout
            }
        }
        return nil;
    }
    
    func getLayout(withName name: String) -> Layout?{
        for layout in layouts{
            if(layout.name == name){
                return layout
            }
        }
        return nil
    }
    
    //MARK: Data Storage
    
    func getPath() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("DataStructure.plist")
    }
    
    func save(){
        let path = getPath()
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(layouts.array, forKey: "Layouts")
        archiver.finishEncoding()
        data.write(to: path, atomically: true)
    }
    
    func load(){
        let path = getPath()
        if let data = try? Data(contentsOf: path){
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            if let loadedLayouts = unarchiver.decodeObject(forKey: "Layouts") as? [Layout]{
                layouts.array = loadedLayouts
            }
            unarchiver.finishDecoding();
        }
    }
}
