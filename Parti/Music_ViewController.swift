//
//  ViewController.swift
//  Music Upvote
//
//  Created by Ethan Elkins on 3/28/18.
//  Copyright © 2018 Ethan Elkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

func upvote(imageId: String,
            success successBlock: (Int) -> Void,
            error errorBlock: () -> Void) {
    
    let ref = Firebase(url: "thepartiapp firebase")
        .childByAppendingPath(imageId)
        .childByAppendingPath("upvotes")
    
    ref.runTransactionBlock({
        (currentData: FMutableData!) in
        
        //value of the counter before an update
        var value = currentData.value as? Int
        
        //checking for nil data is very important when using
        //transactional writes
        if value == nil {
            value = 0
        }
        
        //actual update
        currentData.value = value! + 1
        return FTransactionResult.successWithValue(currentData)
    }, andCompletionBlock: {
        error, commited, snap in
        
        //if the transaction was commited, i.e. the data
        //under snap variable has the value of the counter after
        //updates are done
        if commited {
            let upvotes = snap.value as! Int
            //call success callback function if you want
            successBlock(upvotes)
        } else {
            //call error callback function if you want
            errorBlock()
        }
    })
}
