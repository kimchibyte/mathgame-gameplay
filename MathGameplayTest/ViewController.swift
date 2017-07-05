//
//  ViewController.swift
//  MathGameplayTest
//
//  Created by Justin Lee on 6/28/17.
//  Copyright © 2017 Justin Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        slotBtns.removeAll()
        numBtns.removeAll()
        opBtns.removeAll()
        lastBtn = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let slotIDs: [Int] = [1, 2, 3]
    var curSlots: [Int] = [-1, -1, -1]
    let numIDs: [Int] = [101, 102, 103]
    var numVals: [Int] = [2, 1, 3]
    let opIDs: [Int] = [201]
    let opNames: [String] = ["Add"]
    var slotBtns: [Int: AnyObject?] = [:]
    var numBtns: [Int: AnyObject?] = [:]
    var opBtns: [Int: AnyObject?] = [:]
    var lastBtn: AnyObject? = nil
    
    var target: Int = 4
    
    // "Check" button
    @IBAction func checker(_ sender: AnyObject) {
        if (target == calculateTotal(ind: 1, prevVal: curSlots[0])) {
            // Display success
            print("Success")
        } else {
            // Display failure
            print("Failure")
        }
    }
    
    func calculateTotal(ind: Int, prevVal: Int) -> Int {
        if (ind >= curSlots.count || (ind + 1) >= curSlots.count || curSlots[ind] == -1) {
            return prevVal
        } else if (!opIDs.contains(curSlots[ind])) {
            return Int.max
        } else if (opNames[curSlots[ind] - 201] == "Add") {
            return calculateTotal(ind: ind + 2, prevVal: prevVal + curSlots[ind + 1])
        }
        return Int.max
    }

    // All buttons except "Check"
    @IBAction func button(_ sender: AnyObject) {
        if (lastBtn != nil && sender.tag == lastBtn?.tag) {
            if (slotIDs.contains(sender.tag)) {
                // Resets the image
                if (numVals.contains(curSlots[sender.tag - 1])) {
                    resetImg(sdrBtn: sender)
                }
                sender.setImage(UIImage(named: "numBlank"), for: UIControlState())
            }
            // Undoes current selection
            lastBtn = nil
        } else if (numIDs.contains(sender.tag)) {
            // Sets lastBtn to sender if sender has not already been placed in a slot
            if (findPos(val: numVals[sender.tag - 101], lst: curSlots) == -1) {
                lastBtn = sender
                numBtns[sender.tag] = sender
            } else {
                lastBtn = nil
            }
        } else if (opIDs.contains(sender.tag)) {
            // Sets lastBtn to sender
            lastBtn = sender
            opBtns[sender.tag] = sender
        } else if (slotIDs.contains(sender.tag) && lastBtn == nil) {
            lastBtn = sender
            slotBtns[sender.tag] = sender
        } else if let _ = numBtns[(lastBtn?.tag)!] {
            // Moves the value of lastBtn to sender
            let numImg: String = imageName(imgType: "num", numVal: numVals[(lastBtn?.tag)! - 101])
            sender.setImage(UIImage(named: numImg), for: UIControlState())
            lastBtn?.setImage(UIImage(named: "numBlank"), for: UIControlState())
            // if-else conditional based on whether or not exists already (val != -1)
            if (numVals.contains(curSlots[sender.tag - 1])) {
                resetImg(sdrBtn: sender)
            }
            curSlots[sender.tag - 1] = numVals[(lastBtn?.tag)! - 101]
            lastBtn = nil
            slotBtns[sender.tag] = sender
        } else if let _ = opBtns[(lastBtn?.tag)!] {
            let opImg: String = imageName(imgType: "op", opVal: opNames[(lastBtn?.tag)! - 201])
            sender.setImage(UIImage(named: opImg), for: UIControlState())
            // if-else conditional based on whether or not exists already (val != -1)
            if (numVals.contains(curSlots[sender.tag - 1])) {
                resetImg(sdrBtn: sender)
            }
            curSlots[sender.tag - 1] = opIDs[(lastBtn?.tag)! - 201]
            lastBtn = nil
            slotBtns[sender.tag] = sender
        } else if let _ = slotBtns[(lastBtn?.tag)!] {
            // Swaps the images
            var storedVal: Int = curSlots[sender.tag - 1]
            var imgName: String = ""
            if (storedVal == -1) {
                imgName = "numBlank"
            } else if (opIDs.contains(storedVal)) {
                imgName = imageName(imgType: "op", opVal: opNames[(opBtns[storedVal]??.tag)! - 201])
            } else {
                imgName = imageName(imgType: "num", numVal: storedVal)
            }
            lastBtn?.setImage(UIImage(named: imgName), for: UIControlState())
            storedVal = curSlots[(lastBtn?.tag)! - 1]
            curSlots[(lastBtn?.tag)! - 1] = curSlots[sender.tag - 1]
            curSlots[sender.tag - 1] = storedVal
            if (storedVal == -1) {
                imgName = "numBlank"
            } else if (opIDs.contains(storedVal)) {
                imgName = imageName(imgType: "op", opVal: opNames[(opBtns[storedVal]??.tag)! - 201])
            } else {
                imgName = imageName(imgType: "num", numVal: storedVal)
            }
            sender.setImage(UIImage(named: imgName), for: UIControlState())
            lastBtn = nil
        }
    }
    
    func imageName(imgType: String, numVal: Int = -1, opVal: String = "None") -> String {
        if (numVal == -1) {
            return "\(imgType)\(opVal)"
        } else if (opVal == "None") {
            return "\(imgType)\(numVal)"
        }
        return "NULL"
    }
    
    // Given an Integer val and an array of Integers lst, returns the index that val is located in.
    // If the index does not exist, return -1.
    func findPos(val: Int, lst: [Int]) -> Int {
        var pos = 0
        while (pos < lst.count && lst[pos] != val) {
            pos += 1
        }
        if (pos == lst.count) {
            return -1
        }
        return pos
    }
    
    // Given the sender button with a number image, sets the image to its original button
    func resetImg(sdrBtn: AnyObject?) {
        let idPos: Int = findPos(val: curSlots[(sdrBtn?.tag)! - 1], lst: numVals)
        let numImg: String = imageName(imgType: "num", numVal: numVals[idPos])
        let selBtn: AnyObject?? = numBtns[numIDs[idPos]]
        selBtn??.setImage(UIImage(named: numImg), for: UIControlState())
        curSlots[(sdrBtn?.tag)! - 1] = -1
    }
    
    // Returns true if dictionary dict contains a key, value pair with key k
    func doesContain(dict: [Int: AnyObject?], k: Int) -> Bool {
        if let _ = dict[k] {
            return true
        }
        return false
    }

}

