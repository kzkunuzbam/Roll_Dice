//
//  ViewController.swift
//  Roll Dice
//
//  Created by Murat Kunuzbayev on 4/30/20.
//  Copyright © 2020 Murat Kunuzbayev. All rights reserved.
//

import UIKit
import AWSAppSync

var appSyncClient: AWSAppSyncClient?
var discard: Cancellable?
class ViewController: UIViewController {
    
    
    @IBOutlet weak var UItext: UITextField!
    @IBOutlet weak var UIlabel: UILabel!
    @IBOutlet weak var leftUIImageView: UIImageView!
    @IBOutlet weak var rightUIImageView: UIImageView!
    
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        
        rollDice()
        
    }
   

    func rollDice(){

        let numberOne = arc4random_uniform(6) + 1
        let numberTwo = arc4random_uniform(6) + 1
        UItext.text = ": \(numberOne + numberTwo)"
        leftUIImageView.image = UIImage(named: "Dice\(numberOne)")
        rightUIImageView.image = UIImage(named: "Dice\(numberTwo)")
    }
    @IBAction func rollACTIO(_ sender: UIButton) {
        rollDice()
        
    }
    
    func runMutation(){
        let mutationInput = CreateTodoInput(name: "Use AppSync", description:"Realtime and Offline")
        appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
    }
    func runQuery(){
        appSyncClient?.fetch(query: ListTodosQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            result?.data?.listTodos?.items!.forEach { print(($0?.name)! + " " + ($0?.description)!) }
        }
    }
    func subscribe() {
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(), resultHandler: { (result, transaction, error) in
                if let result = result {
                    print("CreateTodo subscription data:" + result.data!.onCreateTodo!.name + " " + result.data!.onCreateTodo!.description!)
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            print("Subscribed to CreateTodo Mutations.")
            } catch {
                print("Error starting subscription.")
            }
    }
}

