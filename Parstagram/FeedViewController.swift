//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Hayley Robinson on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 350
        // Do any additional setup after loading the view.
    }

    //parse
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) //refresh table view after post you just created
        
        let query = PFQuery(className:"Posts")  //get query
        
        query.includeKey("author") //fetch pointer to object
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in  //store data
            if posts != nil{
                self.posts = posts!  //reload table view
                self.tableView.reloadData()
            }
        }
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser // this is a PF user
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)
        
        cell.photoView.af.setImage(withURL: url!)
      
        
        return cell
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
