//
//  ArrayWrap.swift
//  BlueMote
//
//  Created by Patrick Henriksen on 02.01.2018.
//  Copyright © 2018 Patrick Henriksen. All rights reserved.
//

import Foundation


// A wrapper class around array, mainly used to pass by reference isntead of value
class ArrayWrap<T>: NSObject, NSCoding, Sequence{
    
    var array = [T]()
    var count: Int{
        get{
            return array.count
        }
    }

    override init(){}
    
    func makeIterator() -> Array<T>.Iterator {
        return array.makeIterator()
    }
    
    subscript(index: Int) -> T{
        get{return array[index]}
        set(newValue){array[index] = newValue}
    }

    func remove(at index: Int){
        array.remove(at: index)
    }
    
    func insert(_ object: T, at index: Int){
        array.insert(object, at: index)
    }
    
    func append(_ object: T){
        array.append(object)
    }
    
    //MARK: - Data Strorage
    
    required init?(coder aDecoder: NSCoder) {
        if let decArray = aDecoder.decodeObject(forKey: "array") as? [T] {array = decArray}
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(array, forKey: "array")
    }
}
