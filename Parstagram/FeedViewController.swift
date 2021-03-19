//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Hayley Robinson on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentBar.inputTextView.placeholder = "Add a comment ..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive //dismiss keyboard by dragging down on table view
        
        // Do any additional setup after loading the view.
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControl.Event.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func keyboardWillBeHidden(note:Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    //2 functions that add message input bar at bottom of screen
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {

        // ... Create the URLRequest `myRequest` to post feed...
        let myRequest = URL(string: "https://parseapi.back4app.com/classes/Posts")
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: myRequest!) { (data: Data?, response: URLResponse?, error: Error?) in

            // ... Use the new data to update the data source ...

            // Reload the tableView now that there is new data
            self.tableView.reloadData()

            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    //parse
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) //refresh table view after post you just created
        
        let query = PFQuery(className:"Posts")  //get query
        
        query.includeKeys(["author", "comments", "comments.author"]) //fetch pointer to object
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in  //store data
            if posts != nil{
                self.posts = posts!  //reload table view
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["user"] = PFUser.current()!

        //every post should have an array of comments and add comment to array
        selectedPost.add(comment, forKey: "comments")

        //save comment
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved!")
            }
            else{
                print("Error saving comment!")
            }

        }
        
        tableView.reloadData()
        
        //clear and dismiss bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ??  [] //parentheses make it an optional because comments could nil(no comments)
        
        return comments.count + 2 //sections of comment + 1 row for post + 1 row for add comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ??  []
        
        
        //postcell is always at 0th row
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser // this is a PF user
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
            
            cell.photoView.af.setImage(withURL: url!)
            
            return cell
            
        }
        else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row-1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = post["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
       
    }
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        //switch user back to log in screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //go to Scene delegate
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate
        else{
            return
        }
        
        delegate.window?.rootViewController = loginViewController
        
    }

    //did select // selects row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //choose post to add a comment to
        let post = posts[indexPath.section]
        
        //create comment object
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //pulls up text bar if last comment
        if indexPath.row == comments.count+1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
//        comment["text"] = "this is ranndom !"
//        comment["post"] = post
//        comment["user"] = PFUser.current()!
//
//        //every post should have an array of comments and add comment to array
//        post.add(comment, forKey: "comments")
//
//        //save comment
//        post.saveInBackground { (success, error) in
//            if success{
//                print("Comment saved!")
//            }
//            else{
//                print("Error saving comment!")
//            }
//
//        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
