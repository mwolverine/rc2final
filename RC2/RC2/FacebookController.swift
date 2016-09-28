//
//  FacebookController.swift
//  RC2
//
//  Created by Chris Yoo on 9/21/16.
//  Copyright © 2016 Chris Yoo. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth

class FacebookController {
    
    var friendData: [String] = []
    var friendDataArray : [Friend] = []
    var userData: User?
    var friendlyData: Friend?
    var sessions: [Session] = [] {
        didSet{
            sessions.sortInPlace { (session1, session2) -> Bool in
                session1.date < session2.date
            }
        }
    }
    
    var friendSessions: [Session] = [] {
        didSet{
            sessions.sortInPlace { (session1, session2) -> Bool in
                session1.date < session2.date
            }
        }
    }
    
    
    //temp id placed for testing
    var uid: String = ""
    static let sharedController = FacebookController()
    let firebaseURL = FIRDatabase.database().referenceFromURL("https://rc2p-15dd8.firebaseio.com/")
    
    //FIREBASE FACEBOOK: Integration with Firebase through authentication from Facebook
    
    func facebookCredential() {
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if let error = error {
                print(error)
            } else {
                
                print("Firebase authenticated")
                
                //FIREBASE: Create a user in database with the same authentication UID
                
                FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
                    
                    if (user != nil) {
                        
                        guard let user = user else { return }
                        guard let photoLink = user.photoURL else { return }
                        let photoStringURL = photoLink.absoluteString
                        
                        let newUser = ["displayName": user.displayName! as String, "email": user.email! as String, "photoURL": photoStringURL as String]
                        self.uid = user.uid as String
                        let usersReference = self.firebaseURL.child("users/\(self.uid)")
                        
                        usersReference.updateChildValues(newUser) { (err, ref) in
                            if err != nil {
                                print(err)
                                return
                            }
                            print("saved successful in firebase database")
                        }
                        
                        self.returnMyData()
                        self.returnFriendListData()
                        self.pullUserData(nil)
                        
                        
                        //commented out background delivery for testing
                        
                        
                        HealthKitController.sharedController.authorizeHealthKit { (success, error) in
                            if success {
                                //                                HealthKitController.sharedController.enableBackgroundDelivery()
                            }
                            HealthKitController.sharedController.setLastDaysToZero()
                            HealthKitController.sharedController.setupMilesCollectionStatisticQuery()
                            HealthKitController.sharedController.setupStepsCollectionStatisticQuery()
                        }
                        
                    }
                })
            }
        }
    }
    
    // FACEBOOK returns data on current user
    func returnMyData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, gender"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else
                {
                    let resultdict = result as! NSDictionary
                    
                    let fID = resultdict.objectForKey("id") as! String
                    let firstName = resultdict.objectForKey("first_name") as! String
                    let lastName = resultdict.objectForKey("last_name") as! String
                    let gender = resultdict.objectForKey("gender") as! String
                    
                    // Adds Facebook data to Firebase
                    
                    let detailedUser = ["fID": fID, "firstName": firstName, "lastName": lastName, "gender": gender]
                    
                    //Add Facebook User Detail into facebookUser
                    let facebookUserAuthID = ["\(fID)": "\(self.uid)"]
                    let facebookUsersReference = self.firebaseURL.child("facebookUser")
                    facebookUsersReference.updateChildValues(facebookUserAuthID)
                    
                    //Add user deatil
                    self.addUserDetail(detailedUser)
                }
            })
        }
    }
    
    // FIREBASE adds detailed user information to Firebase from Facebook
    func addUserDetail(detailedUser: [String: AnyObject]){
        let usersReference = self.firebaseURL.child("users/\(self.uid)")
        
        usersReference.updateChildValues(detailedUser, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err)
                return
            }
        })
    }
    
    // FACEBOOK returns data on current user's friends with the app
    func returnFriendListData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                let resultdict = result as! NSDictionary
                //                print("Result Dict: \(resultdict)")
                
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                
                for i in 0..<data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    let name = valueDict.objectForKey("name") as! String
                    
                    //                    print("the id value is \(id)") print("\(name)")
                    
                    self.createFriend("\(id)", friendName: "\(name)")
                }
                let friends = resultdict.objectForKey("data") as! NSArray
                print("Found \(friends.count) friends")
                
                //Test Query For Miles
                // TODO: - Need to look into why FB wasn't logging in
                
                HealthKitController.sharedController.authorizeHealthKit({ (success, error) in
                    if success {
                        HealthKitController.sharedController.setLastDaysToZero()
                        HealthKitController.sharedController.setupMilesCollectionStatisticQuery()
                        HealthKitController.sharedController.setupStepsCollectionStatisticQuery()
                        
                        self.queryMiles()
                    }
                })
            }
        })
    }
    
    // FIREBASE adds information on friends to Firebase from Facebook
    
    func createFriend(friendID: String, friendName: String) {
        let usersReference = firebaseURL.child("users/\(uid)")
        
        let friendsInfo = [friendID: friendName]
        
        usersReference.child("friendList").updateChildValues(friendsInfo, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err)
                return
            }
        })
    }
    // Creates session per day on FIR from app - MILES
    
    func createSessionMiles(miles: String, date: NSDate) {
        let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid)!
        //        print(fireBaseID)
        let formatter = NSDateFormatter()
        // look into mm/dd/yyyy without branches
        formatter.dateFormat = "yyyy-MM-dd"
        let firebaseTime = date.timeIntervalSince1970 * 1000
        let sessionInfo = ["miles": miles, "date": "\(firebaseTime)"]
        let sessionReference = firebaseURL.child("session")
        
        sessionReference.child(fireBaseID).child("days").child("\(formatter.stringFromDate(date))").updateChildValues(sessionInfo, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error)
                return
            }
        })
    }
    
    // Creates session per day on FIR from app - STEPS
    func createSessionSteps(steps: String, date: NSDate) {
        guard let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid) else {return}
        
        let formatter = NSDateFormatter()
        // look into mm/dd/yyyy without branches
        formatter.dateFormat = "yyyy-MM-dd"
        
        
        let firebaseTime = date.timeIntervalSince1970 * 1000
        let sessionInfo = ["steps" : steps, "date": "\(firebaseTime)"]
        let sessionReference = firebaseURL.child("session")
        
        sessionReference.child(fireBaseID).child("days").child("\(formatter.stringFromDate(date))").updateChildValues(sessionInfo, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error?.localizedDescription)
                return
                
            }
        })
    }
    
    // Pulls user friend's data
    //****CHANGE ID
    //from FIR to App
    //**DATE IS TODAY
    
    func pullFriendsMilesData(){
        let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid)!

        //"UQRBpwDLs5a96JSfXZllYkjIvt23"
        //(FIRAuth.auth()?.currentUser?.uid)!
        
        //"UQRBpwDLs5a96JSfXZllYkjIvt23"
        let date = NSDate()
        let formatter = NSDateFormatter()
        // look into mm/dd/yyyy without branches
        formatter.dateFormat = "yyyy-MM-dd"
        
        //grab FID of User
        firebaseURL.child("users").child(fireBaseID).child("friendList").observeEventType(.Value, withBlock: {(snapshot) in
            if let friendIdDict = snapshot.value as? [String: String] {
                
                for (key, _) in friendIdDict {
                    let friendFID = key
                    
                    self.firebaseURL.child("facebookUser").child(friendFID).observeEventType(.Value, withBlock: {(snapshot) in
                        if let friendUID = snapshot.value as? String {
                            print(friendUID)
                            self.firebaseURL.child("session").child(friendUID).child("days").child("\(formatter.stringFromDate(date))").observeEventType(.Value, withBlock: { (snapshot) in
                                guard let friendMiles = snapshot.value!["miles"] as? String else { return }
                                guard let friendSteps = snapshot.value!["steps"] as? String else { return }
                                print(friendMiles)
                                
                                self.firebaseURL.child("users").child(friendUID).observeEventType(.Value, withBlock: { (snapshot) in
                                    guard let friendFirstName = snapshot.value!["firstName"] as? String else { return }
                                    guard let friendLastName = snapshot.value!["lastName"] as? String else { return }
                                    print(friendLastName)
                                    let friendData = Friend(friendUID: friendUID, friendFirstName: friendFirstName, friendLastName: friendLastName, friendMiles: friendMiles, friendSteps: friendSteps)
                                    self.friendDataArray.append(friendData)
                                    print(self.friendDataArray.count)
                                })
                            })
                        }
                    })
                }
            }
        })
    }
    
    // Pulls user information from FIR ...for the friendlist
    //**DATE IS TODAY
    
    func pullUserMilesData(){
        let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid)!

        //"UQRBpwDLs5a96JSfXZllYkjIvt23"
        //(FIRAuth.auth()?.currentUser?.uid)!
        //"UQRBpwDLs5a96JSfXZllYkjIvt23"
        let date = NSDate()
        let formatter = NSDateFormatter()
        // look into mm/dd/yyyy without branches
        formatter.dateFormat = "yyyy-MM-dd"
        
        firebaseURL.child("users").child(fireBaseID).observeEventType(.Value, withBlock: {(snapshot) in
            guard let userFirstName = snapshot.value!["firstName"] as? String else { return }
            guard let userLastName = snapshot.value!["lastName"] as? String else { return }
            
            self.firebaseURL.child("session").child(fireBaseID).child("days").child("\(formatter.stringFromDate(date))").observeEventType(.Value, withBlock: { (snapshot) in
                guard let userMiles = snapshot.value!["miles"] as? String else { return }
                guard let userSteps = snapshot.value!["steps"] as? String else { return }
                
                let userData = Friend(friendUID: fireBaseID, friendFirstName: userFirstName, friendLastName: userLastName, friendMiles: userMiles, friendSteps: userSteps)
                
                self.friendDataArray.append(userData)
                print(self.friendDataArray.count)
            })
        })
    }
    
    // Pulls user data from Firebase to User Model
    //**DATE IS TODAY
    
    // Added completion to make Profile load faster...
    
    func pullUserData(completion: (() -> Void)?) {
        let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid)!
        
        //"UQRBpwDLs5a96JSfXZllYkjIvt23"
        //            (FIRAuth.auth()?.currentUser?.uid)!
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        firebaseURL.child("users").child(fireBaseID).observeEventType(.Value, withBlock: {(snapshot) in
            guard let userFirstName = snapshot.value!["firstName"] as? String else { return }
            guard let userLastName = snapshot.value!["lastName"] as? String else { return }
            guard let userEmail = snapshot.value!["email"] as? String else { return }
            guard let userGender = snapshot.value!["gender"] as? String else { return }
            guard let userPhotoURL = snapshot.value!["photoURL"] as? String else { return }
            guard let userFID = snapshot.value!["fID"] as? String else { return }
            
            
            self.firebaseURL.child("session").child(fireBaseID).child("days").child("\(formatter.stringFromDate(date))").observeEventType(.Value, withBlock: { (snapshot) in
                guard let userMiles = snapshot.value!["miles"] as? String else { return }
                guard let userSteps = snapshot.value!["steps"] as? String else { return }
                
                let userData = User(userFirstName: userFirstName, userLastName: userLastName, userEmail: userEmail, userGender: userGender, userFID: userFID, userUID: fireBaseID, userPhotoURL: userPhotoURL, userMiles: userMiles, userSteps: userSteps)
                print(userData.userFirstName)
                self.userData = userData
                if let completion = completion {
                    completion()
                }
            })
        })
    }
    
    // finds total miles and daily totals for the current user
    func queryMiles() {
        let fireBaseID: String = (FIRAuth.auth()?.currentUser?.uid)!
        self.sessions = []
        var total = 0.00
        firebaseURL.child("session").child(fireBaseID).child("days").queryOrderedByChild("miles").observeEventType(.Value, withBlock: { (snapshot) in
            
            if  let milesDict = snapshot.value as? [String: AnyObject] {
                for (key, value) in milesDict {
                    guard let miles = value["miles"] as? String else { return }
                    if let mile: Double =  Double(miles){
                        total += mile
                    }
                    guard let date = value["date"] as? String else {return}
                    guard let trueDate = Double(date) else {return}
                    guard let steps = value["steps"] as? String else {return}
                    let session = Session(date: trueDate, formattedDate: key, miles: miles, steps: steps)
                    self.sessions.append(session)
                }
            } else {
                print("Total Miles is 0")
            }
        })
    }
    
    func queryFriendMiles(friendUID: String) {
        
        self.friendSessions = []
        
        var total = 0.00
        firebaseURL.child("session").child(friendUID).child("days").queryOrderedByChild("miles").observeEventType(.Value, withBlock: { (snapshot) in
            
            if  let milesDict = snapshot.value as? [String: AnyObject] {
                for (key, value) in milesDict {
                    guard let miles = value["miles"] as? String else { return }
                    if let mile: Double =  Double(miles){
                        total += mile
                    }
                    guard let date = value["date"] as? String else {return}
                    guard let trueDate = Double(date) else {return}
                    guard let steps = value["steps"] as? String else {return}
                    let friendSession = Session(date: trueDate, formattedDate: key, miles: miles, steps: steps)
                    self.friendSessions.append(friendSession)
                }
                print(self.friendSessions.count)
            } else {
                print("Total Miles is 0")
            }
        })
    }
    
    
}